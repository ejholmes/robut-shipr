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

  VERSION = '0.0.1'

  desc "deploy <repo> - Fuck it! We'll do it live!"
  match /^deploy (\S+)$/, :sent_to_me => true do |repo|
    deploy repo
  end

  desc "deploy <repo> to <environment> - Fuck it! We'll do it live!"
  match /^deploy (\S+) to (\S+)$/, :sent_to_me => true do |repo, environment|
    deploy repo, :environment => environment
  end

private

  def deploy(*args)
    deploy = Deploy.new(*args)
    response = deploy.perform
    reply "Deploying #{deploy.repo} to #{deploy.environment}: " +
      "#{Deploy.base}/deploy/#{response.parsed_response['uuid']}"
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
        :config => { 'ENVIRONMENT' => environment }
      }

      body.merge!(:branch => branch)

      HTTParty.post endpoint,
        :body => body.to_json,
        :headers => { 'Content-Type' => 'application/json' },
        :basic_auth => self.class.basic_auth
    end

    def environment
      options[:environment] || 'production'
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
      "#{self.class.base}/api/deploy"
    end

    def nwo
      repo =~ /\// ? repo : "#{ENV['SHIPR_GITHUB_ORG']}/#{repo}"
    end

    def repo_uri
      "git@github.com:#{nwo}.git"
    end

  end
end

