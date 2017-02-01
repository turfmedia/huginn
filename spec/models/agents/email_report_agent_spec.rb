require 'rails_helper'

describe Agents::EmailReportAgent, :vcr do
  let(:valid_params) do
    {
      recipients: 'alexey@turfmedia.com',
      from: 'alexey@turfmedia.com',
      headline: "Rspec:",
      period: 'yesterday',
      subject: 'daily report',
      expected_receive_period_in_days: "2",
      data: {
        html_template_id: 'd4d96b15cd78461ce894',
        messenger_recurring_id: '8a52f53a06cf4a90',
        messenger_api_key: 'b3f1d576813e49b2b4e02112658c71cd',

      }
    }
  end

  before do
    @checker = described_class.new(:name => "somename", :options => valid_params)
    @checker.user = users(:jane)
    @checker.save!
  end

  describe "#check" do
    it "should check that initial run creates an event" do
      expect { @checker.check }.to change { Event.count }.by(1)
    end

    it 'sends email' do
      expect { @checker.check }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

  end
end
