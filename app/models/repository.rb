class Repository < ActiveRecord::Base
  # TODO if github_updated_at
  belongs_to :profile

  def self.create_from_response(username)
    response = HTTParty.get(
          "https://api.github.com/users/#{username}/repos",
          :headers => {"Authorization" => "token #{ENV['GITHUB_TOKEN']}",
                       "User-Agent" => "anyone"
                      }
      )
    response.each do |hash|
      Repository.create_from_hash(hash)
    end
  end

  def self.create_from_hash(hash)
    profile = Profile.find_by(username: hash["owner"]["login"]) ||
      Profile.create_from_username(hash["owner"]["login"])

    Repository.create(
      profile: profile,
      name: hash["name"],
      url: hash["html_url"],
      number_of_forks: hash["forks_count"],
      number_of_stars: hash["stargazers_count"],
      github_updated_at: hash["updated_at"],
      language: hash["language"]
    )
  end

  # TODO write a time to update method
end
