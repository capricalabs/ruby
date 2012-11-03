class SlideshowPicture < ActiveRecord::Base
  belongs_to :company
  
  has_attached_file :picture,
    :storage => :s3,
    :s3_credentials => S3_CREDENTIALS,
    :s3_protocol => "http",
    :styles => {:medium => "200x113>", :thumb => "80x45>", :list => "32x18>"},
    :path => "company/slideshow/:company_id/:style/:id.:extension",
    :default_url => "/assets/company_:style.jpg"

  Paperclip.interpolates :company_id do |attachment, style|
    attachment.instance.company.id
  end
end