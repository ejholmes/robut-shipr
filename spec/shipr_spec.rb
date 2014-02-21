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

    describe 'retry' do
      context 'when there is no previous deploy' do
        it 'does not break' do
          plugin.handle(Time.now, 'eric', '@robut retry deploy')
        end
      end

      context 'when there is a previous deploy' do
        before do
          @request = stub_shipr_request(app: 'app', config: { 'ENVIRONMENT' => 'staging' }, branch: 'develop')
          plugin.handle(Time.now, 'eric', '@robut deploy app to staging')
        end

        it 'retries the last deploy' do
          plugin.handle(Time.now, 'eric', '@robut retry deploy')
          expect(@request).to have_been_requested.twice
        end

        context 'with a bang' do
          it 'retries the last deploy with force enabled' do
            stub_shipr_request(app: 'app', config: { 'ENVIRONMENT' => 'staging', 'FORCE' => '1' }, branch: 'develop')
            plugin.handle(Time.now, 'eric', '@robut restart deploy!')
          end
        end
      end
    end
  end
end
