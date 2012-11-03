class Deal < ActiveRecord::Base
	belongs_to :user
	belongs_to :product
	has_many :deal_quantities, :order => :qty, :dependent => :destroy
	accepts_nested_attributes_for :deal_quantities, :allow_destroy => true
	
	attr_accessible :user_id, :product_id, :qty, :price, :currency, :start_date, :end_date, :active, :customs_duty_price, :warranty_cost, :addon_commission, :deal_quantities_attributes
	validates_presence_of :user_id, :product_id, :qty, :price, :currency, :start_date, :end_date
	validates_numericality_of :qty, :only_integer => true
	validates_numericality_of :price
	validates_numericality_of :customs_duty_price, :warranty_cost, :addon_commission, :allow_nil => true
	validates_each :start_date, :end_date do |record, att, value|
		begin
			d = Date.parse( value.to_s )
			if record.new_record? or att == :end_date
				record.errors.add att, "must not be in the past" if d < Date.today
			end
		rescue
			record.errors.add att, "is not a valid date"
		end
	end
	
	def initialize( params = nil )
		super( params )
		if new_record? and ( params.nil? or params['deal_quantities_attributes'].nil? )
			for qty in [ 2, 5, 10, 20, 50, 100, 200, 300 ]
				self.deal_quantities << DealQuantity.new( :qty => qty )
			end
		end
		self
	end

	# check if deal is active now
	def is_active
		self.active and self.start_date <= Date.today and self.end_date >= Date.today
	end
	
	# returns the first selling quantity that is not adding to the price
	def min_qty
		no_price_change = self.deal_quantities.where( :price_change => nil )
		if no_price_change.size > 0
			no_price_change.first.qty
		else
			0
		end
	end

	def quantities_for_select( qty = 0 )
		res = self.deal_quantities.order(:qty).map{ |dq| dq.qty }
		if qty > 0
			[ qty ] + res
		else
			res
		end
	end

	def price_for( qty )
		if qty.nil? or qty.to_i <= 0
			qty = self.min_qty
		end
		self.price + self.price_change_for( qty )
	end

	def price_change_for( qty )
		dq = self.deal_quantities.where( 'qty <= ?', qty ).last
		dq ? dq.price_change.to_f : 0
	end
	
	def self.listing_fields
		[ :user, :product, :qty, :price, :currency, :start_date, :end_date ]
	end
	
	def self.form_fields
		[ :user_id, :product_id, :qty, :price, :currency, :start_date, :end_date, :customs_duty_price, :warranty_cost, :addon_commission, :active ]
	end
	
	def self.active_deals
		self.where( "active = 1 and start_date <= ? and end_date >= ?", Date.today, Date.today )
	end
	
	def self.right_pane
		'deal_quantities'
	end
end
