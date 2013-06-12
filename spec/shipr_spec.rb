require 'spec_helper'

describe Robut::Plugin::Shipr do
  let(:reply_to) { double('reply_to').as_null_object }
  let(:plugin) { described_class.new(reply_to) }

  before do
    reply_to.stub_chain :connection, :config, mention_name: 'robut'
  end

  describe '.handle' do
    [
      {
        message: '@robut deploy app to production',
        parsed: { app: 'app', env: 'production', branch: 'master' },
        reply: 'Deploying app to production: https://shipr.herokuapp.com/deploys/:id'
      },
      {
        message: '@robut deploy app',
        parsed: { app: 'app', env: 'production', branch: 'master' },
        reply: 'Deploying app to production: https://shipr.herokuapp.com/deploys/:id'
      },
      {
        message: '@robut deploy app to staging',
        parsed: { app: 'app', env: 'staging', branch: 'develop' },
        reply: 'Deploying app to staging: https://shipr.herokuapp.com/deploys/:id'
      },
      {
        message: '@robut deploy app#topic to staging',
        parsed: { app: 'app', env: 'staging', branch: 'topic' },
        reply: 'Deploying app to staging: https://shipr.herokuapp.com/deploys/:id'
      },
      {
        message: '@robut deploy app!',
        parsed: { app: 'app', config: { 'ENVIRONMENT' => 'production', 'FORCE' => '1' }, branch: 'master' },
        reply: 'Deploying app to production: https://shipr.herokuapp.com/deploys/:id'
      },
      {
        message: '@robut deploy app to staging!',
        parsed: { app: 'app', config: { 'ENVIRONMENT' => 'staging', 'FORCE' => '1' }, branch: 'develop' },
        reply: 'Deploying app to staging: https://shipr.herokuapp.com/deploys/:id'
      }
    ].each do |test|
      context "with the message: #{test[:message]}" do
        let(:message) { test[:message] }

        it "deploys the #{test[:parsed][:branch]} branch of #{test[:parsed][:app]} to the #{test[:parsed][:env]} environment" do
          stub_shipr_request(test[:parsed])
          expect_reply(test[:reply])
          plugin.handle(Time.now, 'eric', test[:message])
        end
      end
    end
  end
end
