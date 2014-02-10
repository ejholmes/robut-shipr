require 'robut'
require 'json'
require 'httparty'

##
# Get the current status of and issues affecting the heroku platform.
class Robut::Plugin::Shipr
  include Robut::Plugin

  class << self
    attr_reader :determine_branch

    # A lambda to determine what branch should be deployed for the given
    # environment, by default.
    def determine_branch
      @determine_branch ||= lambda { |environment|
        case environment
        when 'staging'
          'develop'
        else
          'master'
        end
      }
    end
  end

  def usage
    [
      "#{at_nick} deploy <repo> - Fuck it! We'll do it live!",
      "#{at_nick} deploy <repo> to <environment> - Deploy the repo to the specified environment.",
      "#{at_nick} retry deploy - Retry the last deploy command."
    ]
  end

  def handle(time, sender_nick, message)
    if sent_to_me?(message)
      message = without_nick message
      force = !!message.gsub!(/(.*)!$/, '\1') ? '1' : false
      if message =~ /^deploy (\S+)$/
        deploy $1, :force => force
      elsif message =~ /^deploy (\S+) to (\S+)$/
        deploy $1, :environment => $2, :force => force
      elsif message =~ /^(retry|restart) deploy/ && @last_deploy
        @last_deploy[1].merge!(:force => force)
        deploy *@last_deploy
      end
    end
  end

private

  def deploy(*args)
    deploy = Deploy.new(*args)
    response = deploy.perform.parsed_response
    reply "Deploying #{deploy.repo} to #{deploy.environment}: " +
      "#{Deploy.base}/deploys/#{response['id']}"
    @last_deploy = args
  end
  
  class Deploy
    attr_reader :repo
    attr_reader :branch
    attr_reader :options

    def initialize(repo, options = {})
      @repo, @branch = repo.split('#')
      @options = options
    end

    def perform
      body = {
        :repo   => repo_uri,
        :config => { 'ENVIRONMENT' => environment },
        :branch => branch
      }

      body[:config].merge!('FORCE' => force) if force

      HTTParty.post endpoint,
        :body => body.to_json,
        :headers => { 'Content-Type' => 'application/json' },
        :basic_auth => self.class.basic_auth
    end

    def environment
      options[:environment] || 'production'
    end

    def force
      options[:force] || false
    end

    def branch
      @branch ||= Robut::Plugin::Shipr.determine_branch[environment]
    end

    def self.base
      ENV['SHIPR_BASE'] || "https://shipr.herokuapp.com"
    end

    def self.basic_auth
      auth = ENV['SHIPR_AUTH'].to_s.split(':')
      { :username => auth[0], :password => auth[1] }
    end

  private

    def endpoint
      "#{self.class.base}/api/deploys"
    end

    def nwo
      repo =~ /\// ? repo : "#{ENV['SHIPR_GITHUB_ORG']}/#{repo}"
    end

    def repo_uri
      "git@github.com:#{nwo}.git"
    end

  end
end

