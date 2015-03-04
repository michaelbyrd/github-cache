class RepositoriesController < ApplicationController

  def index
  end

  def show
    @profile = Profile.find_by(username: params[:username])||
      Profile.create_from_username(params[:username])
    @repositories = RepositoryList.new(params[:username]).repositories
  end

end
