class CompanyAdmin < ActiveRecord::Base
  url_regexp = Regexp.new("(ftp|http|https):\\/\\/([_a-z\\d\\-]+(\\.[_a-z\\d\\-]+)+)(([_a-z\\d\\-\\\\\\.\\/]+[_a-z\\d\\-\\\\/])+)*")

  # Add http:// if the user inputed just www.something.com
  before_validation :guess_the_url
  
  validates :name, :presence => true, :length => {:minimum => 3, :maximum => 100}
  validates :company_name, :presence => true, :uniqueness => {:case_sensitive => false}, :length => {:within => 0..30}
  validates :company_website, :presence => true, :uniqueness => {:case_sensitive => false}, :format => {:with => url_regexp, :unless => lambda {company_website.blank?}}
  validate :website_email, :on => :create

  belongs_to :company
  
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :company_name, :company_website

  def confirm!
    super
    # if no errors and confirmed -> create/update the company
    if self.errors.none? and confirmed?
      associate_with_company
    end
  end

  def associate_with_company
    uri = URI.parse company_website
    company = Company.find( :first, :conditions => [ "url similar to ?", "(ftp|http|https)://(www.)?"+uri.host+"%" ] )
    unless company
      company = Company.find( :first, :conditions => ["lower(name) = ?", company_name.downcase])
      unless company
        company = Company.create({
          :name => company_name,
          :url => company_website
        })
      end
    end
    self.company_id = company.id
    self.save
  end

  protected

    def website_email
      return if email.blank? or company_website.blank?
      email_domain = email.match( /@(.*)$/ )[1]
      uri = URI.parse company_website
      if uri.host.sub( /^www\./, '' ) != email_domain
        errors.add :email, "domain is different than website domain."
      end
    end
  
    def guess_the_url
      self.company_website = "http://#{company_website}" unless company_website.nil? or company_website.empty? or company_website.start_with?("http", "https", "ftp")
    end
end
