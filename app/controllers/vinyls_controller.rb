class VinylsController < ApplicationController

  before_action :require_login, only: [:new, :create, :edit, :update, :destroy, :upvote, :downvote]

  def index
    @vinyls = Vinyl.where(nil)
    if params[:filter] == "vote"
      @vinyls = @vinyls.sort_by_votes
      @sort = "vote"
    elsif params[:filter] == "search"
      @vinyls = @vinyls.artist_starts_with("Lee")
    else
      @vinyls = @vinyls.sort_by_dates
    end
  end

  def show
    @vinyl = Vinyl.find(params[:id])
    @comments = @vinyl.comments.hash_tree(limit_depth: 2)
    #@wrapper = Discogs::Wrapper.new("needl", user_token: "ZjgMvwfSVnQhbsgXnhulvQvBHmqBbtrWtrARWUjD")
  end

  def new
    @vinyl = Vinyl.new
  end

  def edit
    @vinyl = Vinyl.find(params[:id])
  end

  def create
    @vinyl = current_user.vinyls.new(vinyl_params)
    @vinyl.votes=0
    if @vinyl.save
      @vinyl.upvote_by current_user
      redirect_to @vinyl
    else
      render 'new'
    end
  end

  def update
    @vinyl = current_user.vinyls.find(params[:id])
    if current_user.vinyls.find(params[:id]).update(vinyl_params)
      redirect_to @vinyl
    else
      render 'edit'
    end
  end

  def destroy
    current_user.vinyls.find(params[:id]).destroy
    redirect_to vinyls_path
  end

  def upvote
    @vinyl = Vinyl.find(params[:id])
    @vinyl.upvote_by current_user
    @vinyl.update(votes: @vinyl.get_upvotes.size)
    redirect_to @vinyl
  end

  def downvote
    @vinyl = Vinyl.find(params[:id])
    @vinyl.downvote_by current_user
    @vinyl.update(votes: @vinyl.get_upvotes.size)
    redirect_to @vinyl
  end

  private
  def vinyl_params
    params.require(:vinyl).permit(:album_title,:artist,:description,:image)
  end

  private
  def require_login
    unless current_user
      flash[:error] = "You must be logged in to submit a vinyl"
      redirect_to "/auth/google_oauth2" # halts request cycle
    end
  end

end
