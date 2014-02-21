require 'robut'
require 'json'
require 'httparty'
require 'hashie'

module Robut::Plugin
  class Shipr
    include Robut::Plugin

    autoload :Configuration, 'robut/plugin/shipr/configuration'
    autoload :Deploy, 'robut/plugin/shipr/deploy'

    DEPLOYING = 'Deploying %s to %s: %s'

    class << self

      # Public: The plugin configuration
      #
      # Returns Robut::Plugin::Shipr::Configuration
      def configuration
        @configuration ||= Configuration.new
      end

      # Public: Configure the plugin
      #
      # Examples
      #
      #   Robut::Plugin::Shipr.configure do |config|
      #     config.endpoint = 'http://shipr.company.com'
      #   end
      def configure
        yield configuration
      end
    end

    desc "deploy <repo> - Fuck it! We'll do it live!"
    match /^deploy (\S+?)(!)?$/, sent_to_me: true do |repo, force|
      deploy repo, force: force
    end

    desc "deploy <repo> to <environment> - Deploy the repo to the specified environment."
    match /^deploy (\S+?) to (\S+?)(!)?$/, sent_to_me: true do |repo, environment, force|
      deploy repo, environment: environment, force: force
    end

  private

    def deploy(*args)
      deploy = Deploy.new(*args)
      response = deploy.perform.parsed_response
      reply DEPLOYING % [deploy.name, deploy.environment, "#{self.class.configuration.api_base}/deploys/#{response['id']}"]
    end
  end
end
