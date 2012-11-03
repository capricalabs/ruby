class CheckoutController < ApplicationController
	before_filter :authenticate_user!
	layout 'myaccount'

	# GET /checkout/index
	def index
		begin
			@deal = Deal.find( session[:cart][:deal_id] )
			unless @deal.is_active
				flash[:notice] = "The deal in your shopping cart has expired. Please select another one."
				raise "Not active"
			end
			@qty = session[:cart][:qty]
			@warranty = ( session[:cart][:warranty] == 1 )
			session[:cart][:billing_address_id] = current_user.billing_address.id unless session[:cart][:billing_address_id]
			session[:cart][:shipping_address_id] = current_user.shipping_address.id unless session[:cart][:shipping_address_id]
			if params[:type] == 'billing'
				address = current_user.billing_addresses.where( :id => params[:address_id] ).first
				session[:cart][:billing_address_id] = address.id if address
			elsif params[:type] == 'shipping'
				address = current_user.shipping_addresses.where( :id => params[:address_id] ).first
				session[:cart][:shipping_address_id] = address.id if address
			end
			@billing_address = BillingAddress.find( session[:cart][:billing_address_id] ) rescue nil
			@shipping_address = ShippingAddress.find( session[:cart][:shipping_address_id] ) rescue nil
			unless @billing_address
				flash[:notice] = "No billing address selected, please choose one or enter a new one below."
				redirect_to choose_addresses_path( :type => 'billing' )
			end
			unless @shipping_address
				flash[:notice] = "No shipping address selected, please choose one or enter a new one below."
				redirect_to choose_addresses_path( :type => 'shipping' )
			end
		rescue
			flash[:notice] = "Your shopping cart is empty. Please choose a deal to add to your shopping cart." unless flash[:notice]
			session.delete( :cart )
			redirect_to deals_path
			return false
		end
		
	end

	# POST /checkout/add
	def add
		if params[:qty].to_i == 0
			flash[:alert] = "Please select quantity to buy."
		else
			if session[:cart] && session[:cart][:deal_id] != params[:deal_id]
				flash[:alert] = "You already have another deal in your cart. Only one deal at a time can be purchased."
			else
				begin
					deal = Deal.find( params[:deal_id] )
					raise "Not active" unless deal.is_active
				rescue
					flash[:alert] = "Invalid deal selected."
				end
			end
		end
		if flash[:alert]
			redirect_to deal_path( params[:deal_id] )
			return
		end
		session[:cart] = { :deal_id => params[:deal_id], :qty => 0 } unless session[:cart]
		session[:cart][:qty] += params[:qty].to_i
		flash[:notice] = "Deal added to your shopping cart."
		redirect_to :action => 'index'
	end

	# POST /checkout/update
	def update
		if params[:qty].to_i == 0
			flash[:alert] = "Please select quantity to buy."
		elsif session[:cart]
			session[:cart][:qty] = params[:qty].to_i
			session[:cart][:warranty] = params[:warranty].to_i
			flash[:notice] = "Shopping cart updated."
		end
		redirect_to checkout_path
	end

	# DELETE /checkout/destroy
	def destroy
		flash[:notice] = "Shopping cart cleared."
		session.delete( :cart )
		redirect_to deals_path
	end

	def commit
		# ensure we have a deal and everything necessary in our shopping cart
		index or return
		
	end
end
