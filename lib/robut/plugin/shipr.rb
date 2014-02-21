require 'robut'
require 'json'
require 'httparty'
require 'hashie'

module Robut::Plugin
  class Shipr
    include Robut::Plugin

    autoload :Configuration, 'robut/plugin/shipr/configuration'
    autoload :Deploy, 'robut/plugin/shipr/deploy'

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
  end

end
