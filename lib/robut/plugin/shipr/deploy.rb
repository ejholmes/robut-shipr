module Robut::Plugin
  class Shipr::Deploy
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
      @branch ||= configuration.branch[environment]
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

    def configuration
      Robut::Plugin::Shipr.configuration
    end
  end
end
