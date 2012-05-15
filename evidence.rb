class Evidence < ActiveRecord::Base

  belongs_to :provider_application

  has_attached_file :upload,
                    :path => ':rails_root/uploaded_files/:class/:id_partition/:id.:extension'

  validates_attachment_content_type :upload, :content_type => [ 'application/pdf'], :if=>Proc.new { |evidence| evidence.upload_file_name? }, :message=>"- uploaded files must be in PDF format"

  validates_presence_of :criteria_evidence, :message => 'relationship(s) needs to be established. Please select a criteria.'

  has_many :criteria_evidence, :dependent => :delete_all

  def validate
    errors.add_to_base("You must either upload a file or enter a comment") unless (self.comment? or self.upload_file_name?)
  end

  def after_save
    if self.provider_application
      self.provider_application.update_attribute(:updated_at,DateTime.now)
    end
  end

  def downloadable?(user)
    return true if self.provider_application and user.id == self.provider_application.user_id
    return true if user.is_arc_member?
    return true if user.is_dld_staff?
    return false
  end

  def selected_criteria
    self.criteria_evidence.collect { |c| c.criteria_label_id }
  end

  def self.group_by_criteria(evidences)
    e = {}
    evidences.each do | evidence |
      evidence.selected_criteria.each do | id |
        if e[id]
          e[id] << evidence
        else
          e[id] = [evidence]
        end
      end
    end
    return e
  end

end
