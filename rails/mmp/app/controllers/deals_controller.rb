class DealsController < ApplicationController
	before_filter :authenticate_user!
	def index
		@meta_title = "Deals :: Mobile Marketplace"
		@deals = Deal.active_deals.order( 'end_date desc' )
		render 'index', :layout => 'myaccount'
	end

	def show
		@meta_title = "Deal Details :: Mobile Marketplace"
		@deal = Deal.find( params[:id] ) rescue redirect_to( home_path )
	end
end
