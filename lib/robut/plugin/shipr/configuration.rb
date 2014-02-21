module Robut::Plugin
  class Shipr::Configuration
    # A Proc object used to determine the branch to deploy based on an
    # environment.
    attr_accessor :branch

    # A string used to delimit the repo name and the branch name
    attr_accessor :branch_delimiter

    # The base url where shipr is located.
    attr_accessor :api_base

    # The basic auth credentials.
    attr_accessor :credentials

    # The github organization to use when determining the repo.
    attr_accessor :github_organization

    def initialize
      @branch_delimiter = '#'.freeze
      @api_base = ENV['SHIPR_BASE'] || 'https://shipr.herokuapp.com'
      @github_organization = ENV['SHIPR_GITHUB_ORG']
    end

    def branch
      @branch ||= lambda { |environment|
        case environment.to_sym
        when :staging
          :develop
        else
          :master
        end
      }
    end

    def credentials
      @credentials ||= begin
        auth = ENV['SHIPR_AUTH'].to_s.split(':')
        { username: auth[0], password: auth[1] }
      end
    end
  end
end
