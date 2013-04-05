require 'sinatra/base'
require 'sinatra/auth/github'
require 'sinatra/partial'
require 'haml'
require 'octokit'
module GithubResume 
  class ResumeApp < Sinatra::Base
    register Sinatra::Partial

    CLIENT_ID = ENV['GH_RES_CLI_ID'] 
    SECRET = ENV['GH_RES_SECRET']

    enable :sessions

    set :github_options, {
      :scopes => "repo",
      :secret => SECRET,
      :client_id => CLIENT_ID,
      :callback_url => "/callback"
    }
    register Sinatra::Auth::Github


    get "/" do 
      # if !authenticated?
      #   authenticate!
      # end

      # @res = Resume.new(github_user)
      # haml :resume
      haml :test
    end 

    get "/callback" do
      authenticate!
     redirect to("/")
    end


  end 

  class Resume 
    @api = nil
    @user = nil
    def initialize(gh_user)
      @user = gh_user
      @api = Octokit::Client.new(:login=>gh_user.login, :oauth_token => gh_user.token)
    end

    def languages
      languages = {}
      @repos ||= @api.repositories.select {|r| !r.private}
      @repos.each do |repo|
        langs = @api.languages("#{repo.full_name}")
        langs.each do |lang,count|

          if !languages[lang]
            languages[lang] = count.to_f / @repos.count
          else
            languages[lang] += count.to_f / @repos.count
          end
        end
      end
      languages
    end

    def popular_projects(n)
      @repos ||= @api.repositories
      @repos.sort_by {|repo| repo.forks_count*2 + repo.watchers_count}.first(n)
    end
    def info
      @api.user
    end
  end

end