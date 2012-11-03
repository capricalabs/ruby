class Admin::BaseController < ApplicationController
	layout 'admin'
	WillPaginate.per_page = 20
	before_filter :authenticate_admin!
end
