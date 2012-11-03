class Page < ActiveRecord::Base
	attr_accessible :body, :meta_tags, :title, :layout
	
	SPLITTER = "---MMPPAGESPLITTER---".freeze
	
	def body=( arr )
		write_attribute( :body, arr.join( SPLITTER ) )
	end
	
	def columns
		num = 1
		unless self.layout.nil?
			m = self.layout.match( /^(\d+)/ )
			unless m.nil?
				num = m[1].to_i
			end
		end
		num
	end
	
	def column( num )
		self.body.split( SPLITTER )[num-1] rescue nil
	end
	
	def template
		if self.layout
			self.layout.downcase.gsub( ' ', '_' )
		else
			'wide'
		end
	end
	
	def self.listing_fields
		[ :title, :layout ]
	end
	
	def self.form_fields
		[ :title, :layout, :body, :meta_tags ]
	end
	
	def self.layouts
		[ '2 columns', '2 columns left', '2 columns right', '3 columns', '3 columns wide', '4 columns', 'Wide' ]
	end
end
