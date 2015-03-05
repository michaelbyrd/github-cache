class RepositoriesController < ApplicationController

  def index
  end

  def show
    @profile = Profile.get_updated_profile(params[:username])
    redirect_to root_path if @profile.nil?
  end

end
