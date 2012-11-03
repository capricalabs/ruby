class DealQuantity < ActiveRecord::Base
	belongs_to :deal
	
	attr_accessible :deal_id, :qty, :price_change
	validates_presence_of :qty
	validates_numericality_of :qty, :only_integer => true
	validates_numericality_of :price_change, :allow_nil => true
end
