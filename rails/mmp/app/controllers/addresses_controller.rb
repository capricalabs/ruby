class AddressesController < ApplicationController
	before_filter :authenticate_user!
	before_filter :address_type
	layout 'myaccount'

	# GET /addresses
	# GET /addresses.json
	def index
		@addresses = ( @type == 'shipping' ? current_user.shipping_addresses : current_user.billing_addresses )
	
		respond_to do |format|
			format.html # index.html.erb
			format.json { render :json => @addresses }
		end
	end

	# GET /addresses/new
	# GET /addresses/new.json
	def new
		@address = Address.new
		@address.billing = ( @type == 'billing' )
		
		respond_to do |format|
			format.html # new.html.erb
			format.json { render :json => @address }
		end
	end
	
	# GET /addresses/1/edit
	def edit
		@address = Address.find(params[:id])
		check_user or return
	end

	# POST /addresses
	# POST /addresses.json
	def create
		@address = Address.new(params[:address])
		@address.user_id = current_user.id
		@type = ( @address.billing ? 'billing' : 'shipping' )
		@meta_title = @type.humanize+" Addresses :: Mobile Marketplace"
		
		respond_to do |format|
			if @address.save
				format.html { redirect_to ( params[:from] == 'checkout' ? choose_addresses_url( :type => @type ) : addresses_url( :type => @type ) ), :notice => 'Address was successfully created.' }
				format.json { render :json => @address, :status => :created, :location => addresses_url( :type => @type ) }
			else
				format.html { render :action => "new" }
				format.json { render :json => @address.errors, :status => :unprocessable_entity }
			end
		end
	end

	# PUT /addresses/1
	# PUT /addresses/1.json
	def update
		@address = Address.find(params[:id])
		check_user or return
		
		respond_to do |format|
			if @address.update_attributes(params[:address])
				format.html { redirect_to addresses_url( :type => @type ), :notice => @type.humanize+' address was successfully updated.' }
				format.json { head :no_content }
			else
				format.html { render :action => "edit" }
				format.json { render :json => @address.errors, :status => :unprocessable_entity }
			end
		end
	end

	# PUT /addresses/1/default
	# PUT /addresses/1/default.json
	def default
		@address = Address.find(params[:id])
		check_user or return
		
		respond_to do |format|
			@address.toggle!(:default)
			format.html { redirect_to addresses_url( :type => @type ), :notice => 'Default '+@type.humanize.downcase+' address was successfully set.' }
			format.json { head :no_content }
		end
	end

	# DELETE /addresses/1
	# DELETE /addresses/1.json
	def destroy
		@address = Address.find(params[:id])
		check_user or return
		@address.destroy
		
		respond_to do |format|
			format.html { redirect_to addresses_url( :type => @type ) }
			format.json { head :no_content }
		end
	end

	# GET /addresses/choose
	def choose
		@addresses = ( @type == 'shipping' ? current_user.shipping_addresses : current_user.billing_addresses )
	end

private
	def address_type
		@type = params[:type] || 'shipping'
		@meta_title = @type.humanize+" Addresses :: Mobile Marketplace"
	end

	def check_user
		@type = ( @address.billing ? 'billing' : 'shipping' )
		@meta_title = @type.humanize+" Addresses :: Mobile Marketplace"
		if !@address or @address.user_id != current_user.id
			redirect_to addresses_url( :type => @type )
			return false
		end
		return true
	end
end
