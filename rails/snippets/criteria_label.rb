class CriteriaLabel < ActiveRecord::Base

  set_table_name 'criteria_labels'

  belongs_to :provider_application
  has_many :criteria_score

  def self.get_all_labels
    results = self.find( :all, :order => :id )

    return self.group_by_title_label(results)
  end


  def self.group_by_title_label results
    grouped = {}
    CRITERIA_TITLES.each do | key, value |
      results.each do | label |
        grouped.merge!(key => []) unless grouped.key?(key)
        grouped[key] << label if label.title_key == key
      end
    end

    return grouped
  end


  def self.get_appeal_labels label_ids

    results = self.find( :all,
                        :conditions => "id IN(#{label_ids.join(",")})",
                        :order => :id
                  )

    return self.group_by_title_label(results)
  end


  def self.get_need_appeal app_id
    results = self.find( :all,
                      :conditions => "provider_application_id=#{app_id} AND criteria_scores.score < 1",
                      :select => 'criteria_labels.id',
                      :joins => :criteria_score )

    return results.collect { |c| c.id }
  end


  #return score for a given criteria label, reviewer, and provider app
  def score ( provider_application_id, user_id )

    criteria_score = CriteriaScore.find(:first, :conditions => {
                    :criteria_label_id => self.id,
                    :provider_application_id => provider_application_id,
                    :reviewer_id => user_id
                  })

    return criteria_score unless criteria_score==nil

    criteria_score = CriteriaScore.new
    criteria_score.criteria_label_id=self.id

    return criteria_score

  end


  # retrieve label status for reviewer
  def self.scoring_complete? user_id, app, letter

    return false if app.class==Appeal && app.criteria_appeal.empty?

    appeal_sql = app.class==Appeal ? ' AND criteria_labels.id IN('+ app.criteria_appeal.collect{ |ca| ca.criteria_label_id }.join(',') + ')' : ''
    criteria_scores = self.find(  :all,
                                  :conditions => "criteria_labels.title_key='#{letter}'#{appeal_sql}",
                                  :select => 'criteria_scores.score, criteria_scores.comments',
                                  :joins => "LEFT JOIN criteria_scores ON (criteria_labels.id = criteria_scores.criteria_label_id
                                                                            AND criteria_scores.reviewer_id=#{user_id})
                                                                            AND criteria_scores.provider_application_id=#{app.id}"
                               )

    criteria_scores.each { | cs |
      return false if cs[:score].nil? or cs[:comments].blank?
    }

    return true
  end


  def self.appeal_criteria_exists? letter,app

    return false if app.class==Appeal && app.criteria_appeal.empty?

    in_appeal_ids=' AND criteria_labels.id IN('+ app.criteria_appeal.collect{ |ca| ca.criteria_label_id }.join(',') + ')'

    results = self.find(  :first,
                                  :conditions => "criteria_labels.title_key='#{letter}'#{in_appeal_ids} AND criteria_appeal.provider_application_id='#{app.id}'",
                                  :select => 'COUNT(1) AS count',
                                  :joins => "INNER JOIN criteria_appeal ON (criteria_labels.id = criteria_appeal.criteria_label_id)"
                               )

    return (results['count'].to_i > 0) ? true : false
  end


  #build array of criteria titles w/their statuses
  def self.compile_criteria_statuses user_id, app_id
    app = ProviderApplication.find(app_id)
    titles=[]

    CRITERIA_TITLES.each do | key, value |
      if app.class==Appeal
        visible=self.appeal_criteria_exists?(key,app) ? true : false
      else
        visible=true
      end
      status = self.scoring_complete? user_id, app, key
      titles << { :title_key=>key, :title=>value, :status=>status, :visible=>visible }
    end

    return titles
  end


  #build array of criteria titles w/out statuses - for appliaction side -
  #TODO - make leaner since status data isn't needed?
  def self.compile_criteria user_id, app
    titles=[]

    CRITERIA_TITLES.each do | key, value |
      if app.class==Appeal
        visible=self.appeal_criteria_exists?(key,app) ? true : false
      else
        visible=true
      end

      status = self.has_evidence? user_id, app, key
      titles << { :title_key=>key, :title=>value, :status=>status, :visible=>visible }
    end

    return titles
  end


  # return true if all criteria categories have
  def self.has_evidence?(user_id, app, key)

    return false if app.class==Appeal && app.criteria_appeal.empty?

    appeal_sql = app.class==Appeal ? ' AND criteria_labels.id IN('+ app.criteria_appeal.collect{ |ca| ca.criteria_label_id }.join(',') + ')' : ''

    key_count = self.find (:first, :select => 'count(*) AS count', :conditions => "criteria_labels.title_key='#{key}'" )

    evidence_count = self.find(  :first,
                                 :conditions => "criteria_labels.title_key='#{key}'#{appeal_sql}",
                                 :select => 'COUNT(DISTINCT criteria_evidence.criteria_label_id) AS count',
                                 :joins => "INNER JOIN criteria_evidence ON (criteria_labels.id = criteria_evidence.criteria_label_id)
                                  INNER JOIN evidences ON (criteria_evidence.evidence_id = evidences.id AND evidences.provider_application_id=#{app.id})"
                               )

    if key_count[:count] == evidence_count[:count]
      return true
    else
      return false
    end
  end


  def self.app_scoring_complete? labels,user_id=false,app_id=false

    if labels
      criteria = labels;
    else
      criteria = self.compile_criteria_statuses user_id, app_id
    end

    criteria.each do | label |
      return false unless label[:status] == true
    end

    return true
  end
end