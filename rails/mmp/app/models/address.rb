class Address < ActiveRecord::Base
	belongs_to :user
	
	attr_accessible :billing, :default, :line, :line2, :city, :state, :zip, :country
	
	validates_presence_of :line, :city, :zip, :country
	
	before_save :defaultize
	
	def defaultize
		if self.default
			Address.where( "user_id = ? and billing = ? and id != ?", self.user_id, self.billing, ( self.id ? self.id : 0 ) ).update_all '`default` = 0'
		end
	end
	
	def to_s
		line.to_s+
		( line2.blank? ? '' : "\n"+line2.to_s )+
		"\n"+city.to_s+', '+state.to_s+' '+zip.to_s+
		"\n"+country.to_s
	end
	
	def self.listing_fields
		[ :line, :city, :zip, :country, :default ]
	end
	
	def self.form_fields
		[ :default, :line, :line2, :city, :state, :zip, :country ]
	end
end
