class Dealer < User
	def initialize( params = nil )
		super params
		self.dealer = true
	end
end
