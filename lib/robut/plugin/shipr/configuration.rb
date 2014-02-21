module Robut::Plugin
  class Shipr::Configuration
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
  end
end
