require 'rails_helper'

describe Agents::EmailReportAgent, :vcr do
  let(:valid_params) do
    {
      expected_receive_period_in_days: "2",
      data: {
        "html_template_id" => 'd4d96b15cd78461ce894',
        "messenger_recurring_id" => '8a52f53a06cf4a90',
        "messenger_api_key" => 'b3f1d576813e49b2b4e02112658c71cd',

      }
    }
  end

  before do
    @checker = described_class.new(:name => "somename", :options => valid_params)
    @checker.user = users(:jane)
    @checker.save!
  end

  describe "#check" do
    let!(:fake_object) do
      mock = PublisherTask::Tasks::Pipelines::Reporter::Statistics.new(Date.yesterday.to_s, data: valid_params[:data])
      stub(mock).launch!{ true }.times(1)
      stub(mock).response { {} }
      mock
    end

    before do
      stub(PublisherTask::Tasks::Pipelines::Reporter::Statistics).new(Date.yesterday.to_s, data: valid_params[:data]) do
        fake_object
      end
    end
    
    it "should check that initial run creates an event" do
      expect { @checker.check }.to change { Event.count }.by(1)
    end

    it 'runs PublisherTask::Tasks::Pipelines::Reporter::Statistics pipeline' do
      @checker.check
    end

  end
end
