class LinksController < ApplicationController
  before_action :find_url, only: [:show, :shortened]

  def new
    @link = Link.new
  end

  def show
    redirect_to @link.clean_url
  end

  def create
    @link = Link.new(url_params)
    @link.clean_up_url
    if @link.new_url?
      @link.save
      redirect_to shortened_path(@link.short_url)
    else
      flash[:notice] = "Given URL was already shortened in our database"
      redirect_to shortened_path(@link.find_duplicate_url.short_url)
    end
  end

  def shortened
    hostname = request.host_with_port
    @original_url = @link.clean_url
    @short_url = hostname + '/' + @link.short_url
  end

  private

  def find_url
    @link = Link.find_by_short_url(params[:short_url])
  end

  def url_params
    params.require(:link).permit(:original_url)
  end

end
