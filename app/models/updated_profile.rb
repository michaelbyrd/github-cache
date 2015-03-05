class UpdatedProfile
  def initialize(username)
    @username = username
    @profile = profile
    repositories
  end

  def info
    return @profile
  end


  def repositories
    Repository.update_from_api(@username) if @profile.update_repos?
  end

end
