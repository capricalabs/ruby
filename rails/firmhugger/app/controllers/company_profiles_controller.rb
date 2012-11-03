class CompanyProfilesController < ApplicationController
  before_filter :authenticate_company_admin!
  before_filter :ensure_company_association
  
  def edit
  end
  
  def update
    if @company.update_attributes( params[:company] ) and params[:reload_only].nil?
      redirect_to @company, :flash => {:success => "Your company profile has been updated."}
    else
      render :action => :edit
    end
  end

  protected
    def ensure_company_association
      @company = current_company_admin.company
      unless @company
        current_company_admin.associate_with_company
        @company = current_company_admin.company
      end
      unless @company
        redirect_to root_url, :flash => {:error => "System could not create a company profile for you. Please contact support."}
      end
      @picture = SlideshowPicture.new
    end
end