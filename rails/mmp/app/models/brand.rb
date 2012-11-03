class Brand < ActiveRecord::Base
	has_many :products
	attr_accessible :name, :active
	validates_presence_of :name
	
	def to_s
		self.name
	end
	
	def self.listing_fields
		[ :name ]
	end
	
	def self.form_fields
		[ :name, :active ]
	end
	
	def self.for_select
		self.all.sort_by{ |b| b.name }.map{ |b| [ b.name, b.id ] }
	end
end
