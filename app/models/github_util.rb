require 'open-uri'

class GithubUtil
  # To change this template use File | Settings | File Templates.
  def initialize(oauth_token=nil)
    @oauth_tok = "53cb12ea8d762f092fde3e7715f2604339f891f0"
  end

  def search(type, keyword, args=[])
    url = "https://api.github.com/zen"
    if type == 'user' or type == "users"
      url = "https://api.github.com/legacy/user/search/" + keyword
    elsif type == 'repos'
      url = "https://api.github.com/legacy/repos/search/" + keyword + (args == nil ? '' : '&' + URI.encode_www_form(["language", args]))
    elsif type == 'email'
      url = "https://api.github.com/legacy/user/email/" + keyword
    end
    return open(url, "Authorization" => "token " + @oauth_tok).read
  end

  def repo(owner, repo_name)
    url = "https://api.github.com/repos/"+owner + "/" + repo_name
    repo = JSON.load open(url, "Authorization" => "token " + @oauth_tok).read
    commits = JSON.load open(repo["commits_url"][0..-7], "Authorization" => "token " + @oauth_tok).read
    repo["commits_count"] = commits.length
    collab = JSON.load open(repo["collaborators_url"][0..-16], "Authorization" => "token " + @oauth_tok).read
    repo["collaborators_count"] = collab.length
    contrib = JSON.load open(repo["contributors_url"], "Authorization" => "token " + @oauth_tok).read
    repo["contributors_count"] = contrib.length
    return repo.to_json
  end

  def user(username)
    url = "https://api.github.com/users/"+username
    user = open(url, "Authorization" => "token " + @oauth_tok).read
    return user
  end

  def user_repos(username)
    url = "https://api.github.com/users/"+username + "/repos"
    #return open(url, "Authorization" => "token " + @oauth_tok).read

    repos = JSON.load open(url, "Authorization" => "token " + @oauth_tok).read
    repos.each do |repo|
      begin
        commits = JSON.load open(repo["commits_url"][0..-7], "Authorization" => "token " + @oauth_tok).read
        repo["commits_count"] = commits.length
        collab = JSON.load open(repo["collaborators_url"][0..-16], "Authorization" => "token " + @oauth_tok).read
        repo["collaborators_count"] = collab.length
        contrib = JSON.load open(repo["contributors_url"], "Authorization" => "token " + @oauth_tok).read
        repo["contributors_count"] = contrib.length
      rescue
        #raise repo["collaborators_url"][0..-16] + " " + repo["contributors_url"]
      end

    end
    return repos.to_json
  end
end