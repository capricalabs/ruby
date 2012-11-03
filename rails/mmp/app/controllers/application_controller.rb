class ApplicationController < ActionController::Base
	protect_from_forgery
	layout :layout_by_resource
	
	def initialize
		@show_slider = false
		@meta_title = "Mobile Marketplace"
		@footer = Page.find(9)
		super
	end
	
protected
	def layout_by_resource
		if devise_controller? && resource_name == :admin
			"admin_login"
		else
			"application"
		end
	end
end
