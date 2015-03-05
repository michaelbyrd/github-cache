class Profile < ActiveRecord::Base
  has_many :repositories

  HEADER = {:headers => {"Authorization" => "token #{ENV['GITHUB_TOKEN']}",
               "User-Agent" => "anyone"}}

  def repos_response
    HTTParty.get(self.repos_url, HEADER)
  end

  def profile_response
    HTTParty.get("https://api.github.com/users/#{self.username}", HEADER)
  end


  def self.get_updated_profile(username)
    profile = Profile.find_by(username: username) ||
              Profile.create_from_api(username)

    profile.update_if_needed
  end

  def update_from_api
    response = profile_response

    self.update(
      username: username,
      repos_url: response["repos_url"],
      avatar_url: response["avatar_url"],
      location: response["location"],
      company_name: response["company"],
      number_of_followers: response["followers"].to_i,
      number_following: response["following"].to_i,
      github_updated_at: response["updated_at"].to_datetime
    )
  end

  def self.create_from_api(username)
    response = HTTParty.get("https://api.github.com/users/#{username}", HEADER)
    if response["login"] == username
      profile = Profile.create(
        username: username,
        repos_url: response["repos_url"],
        avatar_url: response["avatar_url"],
        location: response["location"],
        company_name: response["company"],
        number_of_followers: response["followers"].to_i,
        number_following: response["following"].to_i,
        github_updated_at: response["updated_at"].to_datetime
      )
      Repository.create_or_update_from_api(profile)
      profile
    else
      raise
    end
  end


  def update_if_needed
    if self.update?
      self.update_from_api
      Repository.create_or_update_from_api(self)
    elsif self.update_repos?
      self.update_repos_from_api
    end
    self
  end

  def update?
    (DateTime.now.to_i - updated_at.to_i) > 1.day
  end

  def update_repos?
    self.repositories.any? {|r| r.update? }
  end

  def update_repos_from_api
    self.repositories.each do |r|
      r.update_from_api if r.update?
    end
  end

end
