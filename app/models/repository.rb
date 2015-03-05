class Repository < ActiveRecord::Base
  belongs_to :profile
  validates_uniqueness_of :name, :scope => :profile_id

  def update?
    (DateTime.now.to_i - updated_at.to_i) > 2.hours
  end

  def update_from_api
    response = HTTParty.get(
        self.url,
        :headers => {"Authorization" => "token #{ENV['GITHUB_TOKEN']}",
                     "User-Agent" => "anyone"
                    }
    )
    if response["message"] =="Not Found"
      self.destroy!
      return true
    end
    self.update(
      url: response["url"],
      html_url: response["html_url"],
      number_of_forks: response["forks_count"].to_i,
      number_of_stars: response["stargazers_count"].to_i,
      github_updated_at: response["updated_at"].to_datetime,
      language: response["language"]
    )
  end


  def self.create_from_api(username)
    response = HTTParty.get(
          "https://api.github.com/users/#{username}/repos",
          :headers => {"Authorization" => "token #{ENV['GITHUB_TOKEN']}",
                       "User-Agent" => "anyone"
                      }
      )
    response.each do |hash|
      repo = Repository.find_by(github_id: hash["id"])
      if repo && repo.update?
        repo.update(
          url: hash["url"],
          html_url: hash["html_url"],
          number_of_forks: hash["forks_count"].to_i,
          number_of_stars: hash["stargazers_count"].to_i,
          github_updated_at: hash["updated_at"].to_datetime,
          language: hash["language"]
        )
      else
        Repository.create_from_hash(hash)
      end
    end
  end

  def self.create_from_hash(hash)
    profile = Profile.find_by(username: hash["owner"]["login"]) ||
      Profile.create_from_username(hash["owner"]["login"])

    Repository.create(
      profile: profile,
      name: hash["name"],
      url: hash["url"],
      html_url: hash["html_url"],
      number_of_forks: hash["forks_count"].to_i,
      number_of_stars: hash["stargazers_count"].to_i,
      github_updated_at: hash["updated_at"].to_datetime,
      github_id: hash["id"].to_i,
      language: hash["language"]
    )
  end
end
