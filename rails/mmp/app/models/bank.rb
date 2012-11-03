class Bank < ActiveRecord::Base
	attr_accessible :city, :state, :country, :bank_info
	validates_presence_of :bank_info, :country
	
	def to_s
		self.bank_info
	end
	
	def self.listing_fields
		[ :country, :state, :city, :bank_info ]
	end
	
	def self.form_fields
		[ :country, :state, :city, :bank_info ]
	end

	def self.by_region( address )
		bank = self.where( '( city = ? or city = "" or city is null ) and ( state = ? or state = "" or state is null) and country = ?', address.city, address.state, address.country ).first
		bank = self.first unless bank
		bank
	end
end
