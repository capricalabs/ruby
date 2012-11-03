class SlideshowPicturesController < ApplicationController
  before_filter :authenticate_company_admin!, :find_company

  def create
    @picture = SlideshowPicture.new( params[:slideshow_picture] )
    @company.slideshow_pictures << @picture
    respond_to do |format|
      if @picture.errors.size == 0
        format.html { redirect_to profile_url, :flash => {:success => "Slideshow image added."} }
        format.json { head :ok }
      else
        format.html { redirect_to profile_url, :flash => {:error => @picture.errors.full_messages.join( ' ' )} }
        format.json { render :json => @picture.errors.full_messages, :status => :unprocessable_entity }
      end
      format.js
    end
  end

  protected
    def find_company
      @company = current_company_admin.company
    end
end