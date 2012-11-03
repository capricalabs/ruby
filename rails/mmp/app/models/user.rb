class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :token_authenticatable, :confirmable, and :omniauthable
	devise :database_authenticatable, :registerable, :lockable, :timeoutable,
		:recoverable, :rememberable, :trackable, :validatable
	
	has_many :shipping_addresses, :class_name => 'Address', :conditions => { :billing => false }, :dependent => :destroy
	has_many :billing_addresses, :class_name => 'Address', :conditions => { :billing => true }, :dependent => :destroy
	accepts_nested_attributes_for :shipping_addresses, :billing_addresses
	
	has_many :deals
	belongs_to :admin
	
	attr_accessible :email, :password, :password_confirmation, :remember_me, :dealer, :name, :company, :phone, :shipping_address, :billing_address, :active, :bank_name, :account_name, :account_number, :swift_code, :sign_in_count, :current_sign_in_at, :admin_id
	
	validates_presence_of :name#, :email
	validates_presence_of :bank_name, :account_name, :account_number, :swift_code, :if => Proc.new { |user| !user.dealer }
	validates_inclusion_of :dealer, :in => [true,false], :message => 'must be selected'

	def to_s
		self.name
	end
	
	def shipping_address
		self.shipping_addresses.where( :default => true ).first || ( self.shipping_addresses << ShippingAddress.new( :default => true ); self.shipping_addresses.first )
	end
	
	def billing_address
		self.billing_addresses.where( :default => true ).first || ( self.billing_addresses << BillingAddress.new( :default => true ); self.billing_addresses.first )
	end
	
	def shipping_address=(attributes)
		self.shipping_address.update_attributes( attributes )
	end
	
	def billing_address=(attributes)
		self.billing_address.update_attributes( attributes )
	end
	
	def self.listing_fields
		[ :name, :email, :billing_address, :shipping_address, :sign_in_count, :current_sign_in_at ]
	end
	
	def self.form_fields
		[ :name, :email, :password, :company, :phone, :admin_id, :active ]
	end
	
	def self.related_edit
		'related_addresses'
	end
	
	def self.for_select
		self.where( :active => 1 ).order( 'concat( dealer, name )' ).map{ |u| [ ( u.dealer ? 'Dealer: ' : 'Wholesaler: ' )+u.name, u.id ] }
	end
	
	# override devise method to check if it can login after signup
	def active_for_authentication?
		self.active
	end
	
protected
	
	# allow admin to edit user without specifying a password
	def password_required?
		!persisted? || ( !password.nil? and !password.blank? ) || !password_confirmation.nil?
	end
end
