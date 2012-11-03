class ProductImage < ActiveRecord::Base
	belongs_to :product
	attr_accessible :product_id, :image, :image_cache, :remove_image
	mount_uploader :image, ProductUploader
	before_destroy :remember_id
	after_destroy :remove_id_directory
	
	protected
	
	def remember_id
		@id = id
	end
	
	def remove_id_directory
		FileUtils.remove_dir("#{Rails.root}/public/uploads/product_image/#{@id}", :force => true)
	end	
end
