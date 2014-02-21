module Robut::Plugin
  class Shipr::Deploy
    attr_reader :repo, :branch, :options

    def initialize(repo, options = {})
      @repo, @branch = repo.split(configuration.branch_delimiter)
      @options = options
    end

    def perform
      body = {
        repo: repo_uri,
        config: { 'ENVIRONMENT' => environment },
        branch: branch
      }

      body[:config].merge!('FORCE' => force) if force

      HTTParty.post endpoint,
        body: body.to_json,
        headers: { 'Content-Type' => 'application/json' },
        basic_auth: configuration.credentials
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

  private

    def endpoint
      "#{configuration.api_base}/api/deploys"
    end

    def nwo
      repo =~ /\// ? repo : "#{configuration.github_organization}/#{repo}"
    end

    def repo_uri
      "git@github.com:#{nwo}.git"
    end

    def configuration
      Robut::Plugin::Shipr.configuration
    end
  end
end
