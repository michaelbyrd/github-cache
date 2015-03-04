class Repository
  def initialize(content)
    @content = content
  end

  def name
    @content["name"]
  end

  def url
    @content["url"]
  end

  def number_of_forks
    @content["forks_count"].to_i
  end

  def number_of_stars
    @content["stargazers_count"].to_i
  end

  def updated_at
    @content["updated_at"].to_datetime
  end

  def language
    @content["language"]
  end
end
