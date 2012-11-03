class Admin < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :token_authenticatable, :confirmable, :registerable, and :omniauthable
	devise :database_authenticatable, :lockable, :timeoutable,
		:recoverable, :rememberable, :trackable, :validatable
	
	attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :phone, :active
	
	validates_presence_of :name
	
	def to_s
		self.name
	end
	
	def self.listing_fields
		[ :name, :email, :phone ]
	end
	
	def self.form_fields
		[ :name, :email, :password, :phone, :active ]
	end
	
	def self.for_select
		self.where( :active => 1 ).order( 'name' ).map{ |a| [ a.name, a.id ] }
	end
	
protected
	# allow admin to edit user without specifying a password
	def password_required?
		!persisted? || ( !password.nil? and !password.blank? ) || !password_confirmation.nil?
	end
end
