class BillingAddress < Address
	def initialize( params = nil )
		super params
		self.billing = true
	end
end
