class Wholesaler < User
	def initialize( params = nil )
		super params
		self.dealer = false
	end
	
	def self.form_fields
		[ :name, :email, :password, :company, :phone, :bank_name, :account_name, :account_number, :swift_code, :admin_id, :active ]
	end
end
