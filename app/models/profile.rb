class Profile < ActiveRecord::Base
  has_many :repositories

  def self.get_updated_profile(username)
    profile = Profile.find_by(username: username)
    if profile
      if profile.update?
        profile.update_from_api
        Repository.create_from_api(username)
      elsif profile.update_repos?
        profile.update_repos_from_api
      end
    else
      Profile.create_from_api(username)
      Repository.create_from_api(username)
    end


    return Profile.find_by(username: username)
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

  def update_from_api
    response = HTTParty.get(
        "https://api.github.com/users/#{self.username}",
        :headers => {"Authorization" => "token #{ENV['GITHUB_TOKEN']}",
                     "User-Agent" => "anyone"
                    }
    )
    self.update(
      body: response,
      username: username,
      avatar_url: response["avatar_url"],
      location: response["location"],
      company_name: response["company"],
      number_of_followers: response["followers"].to_i,
      number_following: response["following"].to_i,
      github_updated_at: response["updated_at"].to_datetime
    )
  end

  def self.create_from_api(username)
    response = HTTParty.get(
        "https://api.github.com/users/#{username}",
        :headers => {"Authorization" => "token #{ENV['GITHUB_TOKEN']}",
                     "User-Agent" => "anyone"
                    }
    )
    if response["login"] == username
      Profile.create(
        body: response,
        username: username,
        avatar_url: response["avatar_url"],
        location: response["location"],
        company_name: response["company"],
        number_of_followers: response["followers"].to_i,
        number_following: response["following"].to_i,
        github_updated_at: response["updated_at"].to_datetime
      )
    else
      raise
    end
  end
end
