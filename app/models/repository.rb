class Repository < ActiveRecord::Base
  belongs_to :profile
  validates :name, presence: :true
  validates_uniqueness_of :url, presence: :true
  validates_uniqueness_of :github_id

  def repo_response
    HTTParty.get( self.url, HEADER )
  end

  def update?
    (DateTime.now.to_i - updated_at.to_i) > 2.hours
  end

  def update_from_api
    response = repo_response
    if response["message"] =="Not Found"
      self.destroy!
    else
      self.update( name: response["name"],
        url: response["url"], html_url: response["html_url"],
        number_of_forks: response["forks_count"].to_i,
        number_of_stars: response["stargazers_count"].to_i,
        github_updated_at: response["updated_at"].to_datetime,
        language: response["language"]
      )
    end
  end

  def self.create_or_update_from_api(profile)
    response = profile.repos_response
    response.each do |hash|
      repo = Repository.find_by(github_id: hash["id"])
      if repo && repo.update?
        repo.update_from_hash(hash)
      else
        Repository.create_from_hash(hash)
      end
    end
  end

  def update_from_hash(hash)
    self.update( name: hash["name"], language: hash["language"],
      url: hash["url"], html_url: hash["html_url"],
      number_of_forks: hash["forks_count"].to_i,
      number_of_stars: hash["stargazers_count"].to_i,
      github_updated_at: hash["updated_at"].to_datetime

    )
  end

  def self.create_from_hash(hash)
    profile = Profile.find_by(username: hash["owner"]["login"])
    Repository.create( profile: profile, language: hash["language"],
      name: hash["name"], url: hash["url"],
      html_url: hash["html_url"],
      number_of_forks: hash["forks_count"].to_i,
      number_of_stars: hash["stargazers_count"].to_i,
      github_updated_at: hash["updated_at"].to_datetime,
      github_id: hash["id"].to_i
    )
  end

end
