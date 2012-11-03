class Product < ActiveRecord::Base
	belongs_to :brand
	has_many :images, :class_name => "ProductImage", :dependent => :destroy
	accepts_nested_attributes_for :images
	
	has_many :deals
	
	attr_accessible :brand_id, :name, :active, :model, :summary, :features, :warranty, :images
	validates_presence_of :brand_id, :name, :model, :summary, :features
	
	def initialize( params = nil )
		i = []
		if params and params[:images]
			params[:images].keys.sort.each do |key|
				img = params[:images][key]
				params[:images][key].delete( :image_cache ) unless img[:image].blank?
				i.push ProductImage.new( img ) if img[:image]
			end
			params.delete( :images )
		end
		super params
		self.images << i if i
		self
	end
	
	def update_attributes( params )
		if params and params[:images]
			params[:images].keys.sort.each do |key|
				img = params[:images][key]
				params[:images][key].delete( :image_cache ) unless img[:image].blank?
				if key.to_i < self.images.size
					self.images[key.to_i].update_attributes( img )
					self.images[key.to_i].destroy if img[:remove_image]
				else
					self.images << ProductImage.new( img ) if img[:image]
				end
			end
			params.delete( :images )
		end
		super params
	end
	
	def thumb
		if self.images.size > 0
			self.images.first.image.thumb.url
		else
			nil
		end
	end
	
	def to_s
		self.name
	end
	
	def self.listing_fields
		[ :brand, :thumb, :name, :model ]
	end
	
	def self.form_fields
		[ :brand_id, :name, :model, :summary, :features, :warranty, :active ]
	end
	
	def self.for_select
		self.where( :active => 1 ).joins( :brand ).order( 'concat( brands.name, products.name )' ).map{ |p| [ p.brand.name+': '+p.name, p.id ] }
	end
	
	def self.right_pane
		'product_images'
	end
end
