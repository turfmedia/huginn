require 'rails_helper'

describe Agents::EmailReportAgent, :vcr do
  let(:valid_params) do
    {
      expected_receive_period_in_days: "2",
      expected_time_in_hours: (Time.now - 1.hour).hour,
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

  describe "#working?" do
    it "returns true if last event is success" do
      @checker.create_event(payload: { date: Date.today, status: "ok" }, date: Date.today)
      expect(@checker.reload).to be_working
    end

    it "returns false if last event is failure" do
      @checker.create_event(payload: { date: Date.today, status: "failure" })
      expect(@checker.reload).not_to be_working
    end

    it "should be sent today in time less then #{Time.now.hour} hours (returns true if yes)" do
      event = @checker.create_event(payload: { date: Date.today, status: "ok" })
      event.update_column :date, Date.today
      expect(@checker.reload).to be_working
    end
    
    it "should be sent today in time less then #{Time.now.hour} hours (returns false if not)" do
      event = @checker.create_event(payload: { date: Date.yesterday, status: "ok" })
      event.update_column :date, Date.yesterday
      expect(@checker.reload).not_to be_working
    end

    it "should be sent today in time less then #{Time.now.hour} hours (returns false if yes but failure)" do
      event = @checker.create_event(payload: { date: Date.today, status: "failure" })
      event.update_column :date, Date.today
      expect(@checker.reload).not_to be_working
    end

  end

end
