class MoodboardController < ApplicationController

  before_filter :authenticate

  def list
    @moodboards = MoodBoard.where(MoodBoard.arel_table[:status].not_eq('template'))
  end

  def new
    @templates = MoodBoard.where(:status => 'template')
    @moodboards = MoodBoard.where(MoodBoard.arel_table[:status].not_eq('template'))
  end

  def create
    template = MoodBoard.find(params[:id])
    moodboard = template.do_clone
    redirect_to :action => :edit, :id => moodboard.id
  end

  def edit
    @moodboard = MoodBoard.find(params[:id])
    @images = PhotoCategory.get_all_data
  end

  def save
    moodboard = MoodBoard.find(params[:id])
    data = JSON.parse(params[:json])
    moodboard.from_hash(data)
    render :json => '"ok"'
  end

  def show
    @moodboard = MoodBoard.find(params[:id])
  end

  def download
    moodboard = MoodBoard.find(params[:id])
    redirect_to moodboard.main_storage.get_url
  end

  def delete
    moodboard = MoodBoard.find(params[:id])
    moodboard.destroy

    redirect_to :action => :list
  end

private

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "moodboard" && password == "classic"
    end
  end
end
