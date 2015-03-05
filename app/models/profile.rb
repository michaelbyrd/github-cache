class Profile < ActiveRecord::Base
  has_many :repositories

  def update?
    (DateTime.now.to_i - github_updated_at.to_i) > 1.day
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

  def self.create_from_username(username)
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
