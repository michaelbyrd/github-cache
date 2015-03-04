class RepositoriesController < ApplicationController

  def index
  end

  def show
    @profile = Profile.new(params[:username])
    if @profile.username.blank?
      redirect_to root_path
    else
      @repositories = RepositoryList.new(params[:username]).repositories
    end
  end

end
