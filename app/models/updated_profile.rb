class UpdatedProfile
  def initialize(username)
    @username = username
  end

  def info
    return profile
  end

  def profile
    profile = Profile.find_by(username: @username)
    if profile

    else
      Profile.create_from_username(@username)
  end

  def repositories

  end

end
