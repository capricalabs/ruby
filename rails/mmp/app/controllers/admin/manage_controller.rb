class Admin::ManageController < Admin::BaseController
	before_filter :resolve
	
	def index
		# check order field for security
		if params[:order] && !@class.listing_fields.include?( params[:order].to_sym )
			params[:order] = nil
		end
		# default values
		params[:order] = 'id' if( params[:order].nil? or params[:order].empty? )
		params[:dir] = 'asc' if params[:dir] != 'desc'
		params[:per_page] = 20 if( params[:per_page].nil? or params[:per_page].empty? )
		# special where clause if needed
		@objects = @class
		@objects = @objects.where( :dealer => @dealer ) if !@dealer.nil?
		@objects = @objects.where( :user_id => @user ) if @user
		@objects = @objects.where( :product_id => @product ) if @product
		@objects = @objects.where( :billing => @billing ) if !@billing.nil?
		@objects = @objects.paginate( :page => params[:page], :per_page => params[:per_page] ).order( '`'+params[:order].to_s+'` '+params[:dir].to_s )
		@per_page = params[:per_page]
	end
	
	def show
		@object = @class.find( params[:id] )
		render 'show', :layout => false
	end
	
	def new
		@object = @class.new
	end
	
	def edit
		@object = @class.find( params[:id] )
	end
	
	def create
		@object = @class.new( params[@form_type] )
		@object.user = @user if @user
		if @object.save
			redirect_to( { :action => 'index' }, :notice => @type.singularize.humanize+' was successfully created.' )
		else
			render :action => "new"
		end
	end
	
	def update
		@object = @class.find( params[:id] )
		if @object.update_attributes( params[@form_type] )
			redirect_to( { :action => 'index' }, :notice => @type.singularize.humanize+' was successfully updated.' )
		else
			render :action => "edit"
		end
	end
	
	def destroy
		if params[:objects]
			for id in params[:objects]
				@class.find( id ).destroy
			end
		elsif( params[:id] and !params[:id].blank? )
			@object = @class.find( params[:id] )
			@object.destroy
		end
		redirect_to( { :action => 'index' }, :notice => "Selected "+@type.humanize+" deleted." )
	end
	
	def activate
		@object = @class.find( params[:id] )
		@object.toggle! :active
		render :nothing => true
	end
	
	# retrieve deals per product
	def product
		@product = Product.find( params[:id] )
		index
		render :action => 'index'
	end
	
	# retrieve deals per user
	def user
		@user = User.find( params[:id] )
		index
		render :action => 'index'
	end
	
	protected
	
	def resolve
		@type = @form_type = params[:type]
#		if [ 'wholesalers', 'dealers' ].include? @type
#			@class = User
#			@form_type = :user
#			@dealer = ( @type == 'dealers' ? true : false )
#			params[@form_type][:dealer] = @dealer if params[@form_type]
		if [ 'billing_addresses', 'shipping_addresses' ].include? @type
			@class = Address
			@form_type = :address
			@billing = ( @type == 'billing_addresses' ? true : false )
			params[@form_type][:billing] = @billing if params[@form_type]
		else
			@class = @type.classify.constantize
			@form_type = @type.singularize.to_sym
			@dealer = ( @type == 'dealers' ? true : ( @type == 'wholesalers' ? false : nil ) )
		end
		if params[:utype]
			@utype = params[:utype]
			@user = User.find( params[:uid] )
		end
	end
end
