class PublicController < ApplicationController
	def index
		@show_slider = true
		@page = Page.find(6)
		@meta_title = @page.title
		render @page.template
	end
	
	def phone_specs
		product = Product.find( params[:id] ) rescue nil
		if product
			render :text => product.features
		else
			render :nothing => true
		end
	end

	def warranty_info
		product = Product.find( params[:id] ) rescue nil
		if product
			render :text => product.warranty
		else
			render :nothing => true
		end
	end
	
	def how_it_works
		@page = Page.find(7)
		@meta_title = @page.title
		render @page.template
	end
	
	def contact
		@meta_title = "Contact :: Mobile Marketplace";
		@right_column = Page.find(8).column 1
	end
end
