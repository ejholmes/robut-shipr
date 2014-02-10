require File.expand_path('../../lib/robut/plugin/shipr', __FILE__)
require 'webmock/rspec'
require 'securerandom'
require 'net/http'
require 'rack/test'

Robut::Web.set :show_exceptions, false
Robut::Web.set :raise_errors, true

RSpec.configure do |config|
  config.before do
    ENV['SHIPR_GITHUB_ORG'] = 'remind101'
    ENV['SHIPR_AUTH'] = ':Ak6th'
    ENV['BASE_URL'] = 'http://robut.test'
  end

  config.include(Module.new do
    def stub_shipr_request(options = {})
      body = {
        :repo   => "git@github.com:remind101/#{options[:app]}.git",
        :config => options[:config] || { 'ENVIRONMENT' => options[:env] },
        :branch => options[:branch],
        :notify => ['http://robut.test/shipr/deploy']
      }
      stub_request(:post, "https://:Ak6th@shipr.herokuapp.com/api/deploys")
        .with(body: body.to_json)
        .to_return(body: { id: ':id' }.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    def expect_reply(reply)
      reply_to.should_receive(:reply).with(reply, nil)
    end
  end)
end
