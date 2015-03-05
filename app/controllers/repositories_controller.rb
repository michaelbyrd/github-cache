class RepositoriesController < ApplicationController

  def index
  end

  def show
    @profile = UpdatedProfile.new(params[:username]).info
  end

end
