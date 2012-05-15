class CriteriaScoreUser < ActiveRecord::Base

  set_table_name 'criteria_score_user'

  belongs_to :provider_application
  belongs_to :user

  PASSING_SCORE = 45.5

  def self.scoring_status score_statuses
    str=''
      score_statuses.group_by(&:status).each do | k, v |
        str+=', ' unless str.empty?
        str+="#{v.length} #{k}"
      end

    return str unless str.empty?
    return 'No Activity'
  end


  def self.remove id
    score_user = self.find(id)

    begin
      transaction do
        CriteriaScore.remove(score_user.provider_application_id, score_user.user_id)
        score_user.destroy
      end

      return true
    rescue ActiveRecord::RecordInvalid => invalid
      return false
    end
  end

  def self.get_or_create app_id,user_id,score

    criteria_score_user = CriteriaScoreUser.find(:first,:conditions=>{:user_id=>user_id,:provider_application_id=>app_id})

    unless criteria_score_user
      criteria_score_user=self.new
      criteria_score_user.user_id = user_id
      criteria_score_user.provider_application_id=app_id
      status = 'incomplete'
    else
      status = CriteriaScore.app_complete?(app_id,user_id) ? 'complete' : 'incomplete'
    end

    criteria_score_user.status=status
    criteria_score_user.score=score
    criteria_score_user.compile_result
    criteria_score_user.save

  end


  def self.confirm app_id, user_id
    user_status = self.find(:first,:conditions=>{:provider_application_id=>app_id,:user_id=>user_id})
    user_status.status = 'submitted'
    user_status.compile_result
    user_status.save
  end


  def self.unlock app_id, user_id
    user_status = self.find(:first,:conditions=>{:provider_application_id=>app_id,:user_id=>user_id})
    user_status.status = 'pending'
    user_status.save

    return user_status
  end


  def compile_result
    if self.score >= PASSING_SCORE
      self.result='approved'
    else
      self.result='unapproved'
    end
  end


  def self.average_score app_id
    score = self.find (   :first,
                          :conditions => {:provider_application_id => app_id },
                          :select => 'SUM(score) AS total_score, COUNT(id) AS reviewer_count'
                       )

    if score
       average = (score[:total_score].to_f/score[:reviewer_count].to_f)

       if average > 0
         return average.round
       else
         return 0
       end
    else
       return 0
    end
  end


  def self.get_or_fake app_id, user_id
      criteria_score_user = CriteriaScoreUser.find(:first,:conditions=>{:provider_application_id=>app_id,:user_id=>user_id})
      criteria_score_user = CriteriaScoreUser.new({:status=>'pending',:score=>0.0}) unless criteria_score_user

      return criteria_score_user
  end


  def self.score_result score
    if score >= PASSING_SCORE
        return 'approved'
    else
        return 'unapproved'
    end
  end
end