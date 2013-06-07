require File.expand_path('../../lib/robut/plugin/shipr', __FILE__)
require 'webmock/rspec'
require 'securerandom'
require 'net/http'

RSpec.configure do |config|
  config.before do
    ENV['SHIPR_GITHUB_ORG'] = 'remind101'
    ENV['SHIPR_AUTH'] = ':Ak6th'
  end

  config.include(Module.new do
    def stub_shipr_request(options = {})
      stub_request(:post, "https://:Ak6th@shipr.herokuapp.com/api/deploys")
        .with(body: "{\"repo\":\"git@github.com:remind101/#{options[:app]}.git\",\"config\":{\"ENVIRONMENT\":\"#{options[:env]}\"},\"branch\":\"#{options[:branch]}\"}")
        .to_return(body: { id: ':id' }.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    def expect_reply(reply)
      reply_to.should_receive(:reply).with(reply, nil)
    end
  end)
end
