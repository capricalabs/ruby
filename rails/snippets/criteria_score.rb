class CriteriaScore < ActiveRecord::Base

  set_table_name 'criteria_scores'

  belongs_to :provider_application
  belongs_to :criteria_label
  belongs_to :user


  #compile total appeal minimum score for an application
  def self.get_total_appeal_min(feedback)
    score=0
      feedback.each do |f|
        score+=f[:min_score] unless f[:min_score].nil?
      end
    return score
  end


  def self.gather_feedback (app_id, non_ones)

      criteria = self.get_min_score(app_id,non_ones)

      feedback=[]
      criteria.each do | c |
        criterion={
                  :min_score=>c.score,
                  :scores=>self.get_scores(c.criteria_label_id,app_id),
                  :criteria_label=>c.criteria_label,
                  :comments => self.get_comments(c.criteria_label_id,app_id)
                 }

        feedback << criterion
      end

    return feedback
  end


  #collect labels which did *not* score all 1's->correction:gather all feedback :-/
  def self.get_min_score (app_id,non_ones)

    condition = (non_ones) ? ' AND score < 1' : ''
    scores = self.find( :all,
                        :select => "criteria_label_id, MIN(score) as score",
                        :conditions => "criteria_scores.provider_application_id=#{app_id}#{condition}",
                        :group => :criteria_label_id )
    return scores
  end


  def self.get_comments label_id,app_id
    return self.find(:all, :conditions => "criteria_label_id=#{label_id} AND provider_application_id=#{app_id} AND score < 1").collect {|s| s.comments }
  end


  def self.get_scores label_id,app_id
    return self.find(:all, :conditions => "criteria_label_id=#{label_id} AND provider_application_id=#{app_id}",:joins => :criteria_label, :order => :label_key).collect {|s| s.score }
  end


  def self.app_complete? app_id, user_id
    app = ProviderApplication.find(app_id)
    appeal_sql = app.class==Appeal ? ' AND criteria_labels.id IN('+ app.criteria_appeal.collect{ |ca| ca.criteria_label_id }.join(',') + ')' : ''

    result = CriteriaLabel.find( :first,
       :conditions=> "criteria_scores.comments='' OR criteria_scores.score IS NULL",
       :select => 'COUNT(*) AS num_incomplete',
       :joins => "LEFT JOIN criteria_scores ON (criteria_scores.criteria_label_id=criteria_labels.id AND
                                                criteria_scores.provider_application_id=#{app_id} AND
                                                criteria_scores.reviewer_id=#{user_id})"
    )

    return result[:num_incomplete].to_f > 0 ? false : true

  end


  #retrieve scores for a
  def retrieve_by_letter user_id, app_id, letter

    criteria_scores = CriteriaScore.find( :all,
                                          :conditions => {
                                            :provider_application_id => app_id,
                                            :reviewer_id => user_id,
                                            criteria_label.title_key => letter
                                          },
                                          :joins => :criteria_label
                                          )
  end

  #total score for a given user and application
  def self.app_score_for_user  app_id, user_id

      app = ProviderApplication.find(app_id)

      criteria_score = self.find(   :first,
                                    :conditions => { :provider_application_id => app_id,
                                                     :reviewer_id => user_id },
                                    :select => 'SUM(score) AS total_score'
                                 )

      return criteria_score[:total_score].to_f + self.get_appeal_ones(app) if app.class==Appeal

      return criteria_score[:total_score] == nil ? 0 : criteria_score[:total_score]

  end

  #For a given appeal application, get the minimum number of points a provider will score by
  #determining how many criteria labels are *not* associated to the application
  def self.get_appeal_ones(app)
    result = CriteriaLabel.find(:first, :select => 'COUNT(*) AS count')
    need_appeals = CriteriaLabel.get_need_appeal(app.original_application_id).uniq.length

    return (result[:count].to_i - need_appeals)
  end


  #save posted scores
  def self.save_post params, user_id
    params[:score_exists].each do | label_id, score_id |
      if score_id.to_i > 0
        CriteriaScore.update(score_id,
          :score => params[:criteria_score][label_id.to_sym],
          :comments => params[:criteria_comment][label_id.to_sym]
         )
      else
        CriteriaScore.new (
          :criteria_label_id => label_id,
          :reviewer_id => user_id,
          :score => params[:criteria_score][label_id.to_sym],
          :comments => params[:criteria_comment][label_id.to_sym],
          :provider_application_id => params[:provider_application_id]
        ).save
      end
    end
  end


  def self.compile_scores scores
    results={}
      scores.each do | score |
        if results[score[:reviewer_id]]
          results[score[:reviewer_id]].merge!({score[:criteria_label_id] => score})
        else
          results[score[:reviewer_id]] = {score[:criteria_label_id] => score}
        end
      end

    return results
  end


  def self.view_application app
    results = self.find(  :all,
                  :conditions => { :provider_application_id => app.id }
                )

    scores = self.compile_scores(results)

    return scores unless app.class==Appeal

    return self.append_exempt_criteria(scores, app)
  end


  def self.append_exempt_criteria scores, app

    appeal_criteria = CriteriaLabel.get_need_appeal(app.original_application_id)
    criteria_label_ids = CriteriaLabel.find(:all).collect{ |cl| cl.id }.delete_if{|id| appeal_criteria.include?(id)}
    new_scores={}
      criteria_label_ids.each do | cl |
        new_scores.merge!({ cl => (CriteriaScore.new (
          :criteria_label_id => cl,
          :score => 1,
          :comments => 'exempt criteria'
        )) })
      end

    new_hash={}
      scores.each do | k,v |
        new_hash[k]= v.merge(new_scores)
      end

    return new_hash
  end


  def self.remove app_id, user_id
    self.delete_all(:provider_application_id=>app_id, :reviewer_id=>user_id)
  end
end