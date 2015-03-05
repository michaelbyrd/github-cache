class RepositoriesController < ApplicationController

  def index
  end

  def show
    @profile = Profile.get_updated_profile(params[:username])
  end

end
