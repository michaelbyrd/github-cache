class Profile

  def initialize(username)
    @content = HTTParty.get(
        "https://api.github.com/users/#{username}",
        :headers => {"Authorization" => "token #{ENV['GITHUB_TOKEN']}",
                     "User-Agent" => "anyone"
                    }
    )
  end

  def username
    @content["login"]
  end

  def avatar_url
    @content["avatar_url"]
  end

  def location
    @content["location"]
  end

  def company_name
    @content["company"]
  end

  def number_of_followers
    @content["followers"]
  end

  def number_following
    @content["following"]
  end

end
