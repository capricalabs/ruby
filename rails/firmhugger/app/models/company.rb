class Company < ActiveRecord::Base
  url_regexp = Regexp.new("(ftp|http|https):\\/\\/([_a-z\\d\\-]+(\\.[_a-z\\d\\-]+)+)(([_a-z\\d\\-\\\\\\.\\/]+[_a-z\\d\\-\\\\/])+)*")
  
  # Add http:// if the user inputed just www.something.com
  before_validation :guess_the_url
  
  # When an user creates a company, he also hugs it
  after_create :hug_by_owner
  
  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}, :length => {:within => 0..30}
  validates :url, :format => {:with => url_regexp, :unless => lambda {url.blank?}}
  validates :tagline, :length => {:within => 0..140}
  
  has_many :productions, :dependent => :destroy
  has_many :products, :through => :productions
  has_many :hugs, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  belongs_to :user
  has_one :company_admin
  has_many :slideshow_pictures, :dependent => :destroy
  
  ["first", "second", "third"].each do |nth|
    belongs_to "#{nth}_category".to_sym, :class_name => "Category", :foreign_key => "#{nth}_category_id"
  end
  before_save :make_categories_unique
  
  accepts_nested_attributes_for :comments, :reject_if => lambda {|comment| comment[:content].blank?}, :allow_destroy => true
  accepts_nested_attributes_for :slideshow_pictures, :allow_destroy => true
  
  geocoded_by :location
  after_validation :geocode
  
  acts_as_gmappable :process_geocoding => false # geocoding is taken care by Geocoder
  alias_attribute :gmap4rails_address, :location
  
  paginates_per 10
  
  has_paper_trail :class_name => 'CompanyVersion',
    :meta => { :slideshow_pictures => Proc.new { |company| company.slideshow_pictures.to_yaml } }
  attr_accessor :versioned_slideshow_pictures
  
  has_attached_file :picture,
    :storage => :s3,
    :s3_credentials => S3_CREDENTIALS,
    :s3_protocol => "http",
    :styles => {:medium => "200x200>", :thumb => "80x80>", :list => "32x32>"},
    :path => "company/:attachment/:style/:id.:extension",
    :default_url => "/assets/company_:style.jpg"
    
  before_validation :decide_wether_to_delete_the_picture_or_not
  attr_accessor :delete_picture
  
  include PostgreSearch
  include AcceptsProductList
  include SmartOrder
  include SeoFriendlyUrl
  include CompanySearch
  
  def delete_picture=(decision)
    @delete_picture = (not decision.to_i.zero?)
  end

  def slideshow_pictures
    if live?
      super
    else
      versioned_slideshow_pictures or []
    end
  end

  class << self
    # Gives <number> randomly selected companies
    def random(number)
      ids = find(:all, :select => :id).map(&:id)
      Company.find((1..number).map {ids.delete_at(ids.size * rand)})
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
  
  protected
    def decide_wether_to_delete_the_picture_or_not
      self.picture = nil if @delete_picture
    end
    
    def guess_the_url
      self.url = "http://#{url}" unless url.nil? or url.empty? or url.start_with?("http", "https", "ftp")
    end
    
    def hug_by_owner
      self.hugs.create( :user => user ) if user
    end
    
    def make_categories_unique
      names = ["first", "second", "third"]
      
      categories = names.map{ |nth| send("#{nth}_category".to_sym) }
      categories = categories.uniq
      
      names.each_index do |i|
        send("#{names[i]}_category=".to_sym, categories[i])
      end
    end
end