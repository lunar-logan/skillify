class ApplicationController < ActionController::Base
  protect_from_forgery

  def have_user(key)
    user = User.find_by_name(key)
    if user.nil?
      user = User.find_by_username(key)
      if user.nil?
        user = User.find_by_email(key)
        if user.nil?
          return nil
        end
      end
    end
    return user
  end

  def have_users(key)
    <<-DOC
    looks for all the user(s) with name or username similar to the key
    DOC
    user = @user = User.where('name OR username LIKE ?', "%#{key}%")
    return user
  end

  # @param [JSON] info
  def add_user(info)
    user = User.new({:username => info["login"],
                     :name => info["name"],
                     :git_id => info["id"],
                     :gravatar_id => info["gravatar_id"],
                     :followers => info["followers"],
                     :following => info["following"],
                     :public_repos => info["public_repos"],
                     :public_gists => info["public_gists"],
                     :email => info["email"],
                     :html_url => info["html_url"],
                     :blog => info["blog"],
                     :company => info["company"],
                     :location => info["location"],
                     :bio => info["bio"]
                    })
    user.save
  end

  def add_users(users)
    #users = users["users"]
    users.each do |usr|
      add_user usr
    end
  end

  def get_top_repo_from_cache(skill)
    <<-DOC
    Finds and gets the top repo from the cache
    DOC
    repo = TopSkillRepo.find_by_skill(skill)
    if repo.nil? or repo.blank?
      return nil
    end
    return JSON.load(repo[:repo_content])
  end

  def get_top_repo_by_skill(skill = "Java")
    <<-DOC
    Finds the top repo with the given skill and stores it into the cache
    DOC
    topRepo = get_top_repo_from_cache(skill)
    if !topRepo.nil? and !topRepo.blank?
      return topRepo
    end
    git = GithubUtil.new "ac80650e2f9d292fda4c539649f16f4e12aa842c"
    #key = "https://api.github.com/legacy/repos/search/&language="+skill
    repo = JSON.load git.search("repos", '', skill)
    if repo.nil? or repo["repositories"].length == 0
      return nil
    end
    #lets take out just the top repo
    topRepo = repo["repositories"][0]
    topRepo = git.repo topRepo["owner"], topRepo["name"]
    #store this into the top_repo_cache
    tsr = TopSkillRepo.new ({skill: skill, repo_content: topRepo.to_json})
    tsr.save
    return topRepo
  end

  def rate_repo_by_skill(repo, topRepo, scale=5.0)
    exp = 2.7182818284590452353602874
    a = topRepo["watchers_count"].to_i
    b = topRepo["forks_count"].to_i
    c = topRepo["open_issues_count"].to_i
    d = topRepo["contributors_count"].to_i
    e = topRepo["collaborators_count"].to_i
    f = topRepo["commits_count"].to_i
    #raise topRepo.to_json #(a.to_s + " " + b.to_s + " "+ c.to_s + " " + d.to_s + " "+ e.to_s + " " + f.to_s + " " + "").to_json
    alpha = (a * 16 + b * 16 + c * 8 + d * 28 + e * 28 + f*2)/6.0

    a1 = repo["watchers_count"].to_i
    b1 = repo["forks_count"].to_i
    c1 = repo["open_issues_count"].to_i
    d1 = repo["contributors_count"].to_i
    e1 = repo["collaborators_count"].to_i
    f1 = repo["commits_count"].to_i
    beta = (a1 * 16 + b1 * 16 + c1 * 8 + d1 * 28 + e1 * 28 + f1*2)/6.0

    rho = -((alpha-beta).abs/alpha)
    val = (1.0 - (1.0/(1.0 + exp ** rho))) * 10.0
    return val
  end

  def get_repo_score(repo)
    a1 = repo["watchers_count"].to_i
    b1 = repo["forks_count"].to_i
    c1 = repo["open_issues_count"].to_i
    d1 = repo["contributors_count"].to_i
    e1 = repo["collaborators_count"].to_i
    f1 = repo["commits_count"].to_i
    beta = (a1 * 16 + b1 * 16 + c1 * 8 + d1 * 28 + e1 * 28 + f1*2)/6.0
    return beta
  end

  def get_top_x_repos_of_user_from_cache(user)
    usrRepo = UserRepo.find_by_username(user)
    if usrRepo.blank? or usrRepo.nil?
      return nil
    end
    return JSON.load(usrRepo[:repos])
  end

  def get_top_x_repos_of_user(user, x=10)
    repos = get_top_x_repos_of_user_from_cache user
    if !repos.nil? and !repos.blank?
      return repos
    end
    git = GithubUtil.new "ac80650e2f9d292fda4c539649f16f4e12aa842c"
    repos = JSON.load (git.user_repos user)
    if repos.nil?
      return nil
    end
    repos.each do |repo|
      repo[:score] = get_repo_score(repo)
    end
    #Now sort it according to the score
    topRepos = []
    repoCount = 0
    threshHold = x
    repos.sort_by { |entry| -entry[:score] }.each do |repo|
      if repoCount > threshHold
        break
      end
      topRepos << repo
      repoCount += 1
    end
    usrRepos = UserRepo.new({username: user, repos: topRepos.to_json})
    usrRepos.save
    return topRepos
  end

  def get_user_info_by_username(usr)
    user = User.find_by_username(usr)
    git = GithubUtil.new "ac80650e2f9d292fda4c539649f16f4e12aa842c"
    if user.nil? or user.blank?
      val = git.user usr
      user = JSON.load val
      user["username"] = user["login"]
      add_user user
    end
    return user
  end

  def get_user_info_by_email(user)
    user = User.find_by_email(user)
    git = GithubUtil.new("ac80650e2f9d292fda4c539649f16f4e12aa842c")
    if user.nil? or user.blank?
      val = git.search("email", user)
      user = JSON.load(val)
      add_user user
    else
      user = JSON.load(user)
    end
    return user
  end

  def skillify(skillSet = ["Java", "Python", "Ruby", "JavaScript", "C", "Objective-C"])
    username = params[:uname]
    if username.nil?
      skillRating = "If your are good at something, never do it for free..."
    else
      #raise username.to_json
      @user = get_user_info_by_username username
      @repos = get_top_x_repos_of_user username
      skillRating = {}
      sk =[]
      skillSet.each do |skill|
        topRepo = JSON.load(get_top_repo_by_skill skill)
        skillScore = 0
        count = 0

        @repos.each do |repo|
          if repo["language"] == skill
            a = rate_repo_by_skill(repo, topRepo)
            if a > skillScore
              skillScore = a
            end
            count += 1
          end
        end

        if count > 0
          sk << [skill, skillScore] #/count]
        else
          sk << [skill, "Unrated"]
        end

      end
      skillRating["skills"] = sk
      #raise skillRating.to_json
      skillRating["user"] = @user #get_user_info_by_username(username)
      skillRating["top_repos"] = @repos #get_top_x_repos_of_user(username)
    end

    respond_to do |format|
      format.json { render json: skillRating.to_json }
    end
  end

  def lookup
    <<-DOC
      Does the params name looks too cryptic ? Haa..
      n=name, u=username, r=repo, o=optional args, t=type, k=key
    DOC
    git = GithubUtil.new "ac80650e2f9d292fda4c539649f16f4e12aa842c"
    #val = git.search("repos", "api", [["language", "Java"]])
    type = params[:type]
    if type.nil?
      val = 'Type not specified...'
    else
      if type == 'user'
        key = params[:n]
        val = have_user key
        if val.nil?
          val = git.user key
          add_user JSON.load val
        end
      elsif type == 'repo'
        val = git.repo params[:u], params[:r]
      elsif type == 'search'
        t=params[:t]
        if t == 'user' or t == 'users'
          val = have_users params[:k]
          if val.nil? or val.blank?
            val = git.search t, params[:k]
            add_users (JSON.load val)["users"]
          end
        elsif t == 'repos'
          opt_param = ["language", params[:l]]
          if params[:l].nil?
            opt_param = nil
          end
          val = git.search t, params[:k], opt_param
        end
      end
    end
    respond_to do |format|
      format.json { render json: val }
    end
  end

end
