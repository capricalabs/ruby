class ShippingAddress < Address
	def initialize( params = nil )
		super params
		self.billing = false
	end
end
