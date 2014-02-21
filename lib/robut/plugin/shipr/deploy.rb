module Robut::Plugin
  class Shipr::Deploy
    attr_reader :name, :branch, :options

    def initialize(name, options = {})
      @name, @branch = name.split(configuration.branch_delimiter)
      @options = options
    end

    def perform
      body = {
        repo: repo,
        config: config,
        branch: branch
      }

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
    
    def config
      config = { 'ENVIRONMENT' => environment }
      config.merge!('FORCE' => '1') if force
      config
    end

    def endpoint
      "#{configuration.api_base}/api/deploys"
    end

    def nwo
      name =~ /\// ? name : "#{configuration.github_organization}/#{name}"
    end

    def repo
      "git@github.com:#{nwo}.git"
    end

    def configuration
      Robut::Plugin::Shipr.configuration
    end
  end
end
