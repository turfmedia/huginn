require 'rails_helper'

describe Agents::PublisherTasks do
  before do
    Event.destroy_all
    Agent.destroy_all
    stub_request(:get, /parse/).to_return(:body => File.read(Rails.root.join("spec/data_fixtures/adioso_parse.json")), :status => 200, :headers => {"Content-Type" => "text/json"})
    stub_request(:get, /fares/).to_return(:body => File.read(Rails.root.join("spec/data_fixtures/adioso_fare.json")),  :status => 200, :headers => {"Content-Type" => "text/json"})
    @valid_params = {
                      date: '2016-08-15',
                      package_type: 'js2'
                    }

    @checker = Agents::PublisherTasks.new(:name => "somename", :options => @valid_params)
    @checker.user = users(:jane)
    @checker.save!
  end

  describe "#check" do
    it "should check that initial run creates an event" do
      expect { @checker.check }.to change { Event.count }.by(1)
    end
  end

  describe '#receive' do
    before do
      @webhook = Agents::WebhookAgent.new( :name => 'webhook',
                                            :options => { 'secret' => 'foobar', 'payload_path' => '.' })
      @webhook.user = @checker.user
      @webhook.save!
      @events = []
    end

    it 'does not run Orchestrator::Tasks::Pipelines::Gazette if events are blank' do
      expect(Orchestrator::Tasks::Pipelines::Gazette).to_not receive(:new)
      @checker.receive(@events)
    end

    it 'does not run Orchestrator::Tasks::Pipelines::Gazette if given events is a first event from publisher/api' do
      js2_event = Event.new payload: @valid_params
      js2_event.agent = @webhook
      js2_event.user  = @webhook.user
      js2_event.save!
      @events.push(js2_event)
      expect(Orchestrator::Tasks::Pipelines::Gazette).to_not receive(:new)
      @checker.receive(@events)
    end

    it 'does not run Orchestrator::Tasks::Pipelines::Gazette if given events is a first event from publisher/api if all events before and current events are from the same package' do
      q2_event = Event.new payload: @valid_params.merge(package_type: 'q2')
      q2_event.agent = @webhook
      q2_event.user  = @webhook.user
      q2_event.save!

      q2_event_again = Event.new payload: @valid_params.merge(package_type: 'q2')
      q2_event_again.agent = @webhook
      q2_event_again.user  = @webhook.user
      q2_event_again.save!
      @events.push(q2_event_again)

      expect(Orchestrator::Tasks::Pipelines::Gazette).to_not receive(:new)
      @checker.receive(@events)
    end

    it 'does not run Orchestrator::Tasks::Pipelines::Gazette if given events is a second event from publisher/api and they both from different packages but the first was yestreday the second was today' do
      q2_event = Event.new payload: @valid_params.merge(package_type: 'q2', date: '2016-08-14')
      q2_event.agent = @webhook
      q2_event.user  = @webhook.user
      q2_event.save!

      js2_event = Event.new payload: @valid_params.merge(package_type: 'js2', date: '2016-08-15')
      js2_event.agent = @webhook
      js2_event.user  = @webhook.user
      js2_event.save!
      @events.push(js2_event)

      expect(Orchestrator::Tasks::Pipelines::Gazette).to_not receive(:new)
      @checker.receive(@events)
    end

    it 'runs Orchestrator::Tasks::Pipelines::Gazette if given events is a second event from publisher/api and they both from different packages' do
      q2_event = Event.new payload: @valid_params.merge(package_type: 'q2')
      q2_event.agent = @webhook
      q2_event.user  = @webhook.user
      q2_event.save!

      js2_event = Event.new payload: @valid_params.merge(package_type: 'js2')
      js2_event.agent = @webhook
      js2_event.user  = @webhook.user
      js2_event.save!
      @events.push(js2_event)

      allow(Orchestrator::Tasks::Pipelines::Gazette).to receive(:new) do
        mock = double
        expect(mock).to receive(:launch!)
        mock
      end

      @checker.receive(@events)
    end

    it 'createns new event if given events is a second event from publisher/api and they both from different packages' do
      q2_event = Event.new payload: @valid_params.merge(package_type: 'q2')
      q2_event.agent = @webhook
      q2_event.user  = @webhook.user
      q2_event.save!

      js2_event = Event.new payload: @valid_params.merge(package_type: 'js2')
      js2_event.agent = @webhook
      js2_event.user  = @webhook.user
      js2_event.save!
      @events.push(js2_event)

      allow(Orchestrator::Tasks::Pipelines::Gazette).to receive(:new) do
        mock = double
        allow(mock).to receive(:launch!).and_return(true)
        mock
      end
      expect {@checker.receive(@events)}.to change { Event.count }.by(1)
    end

    it 'creates new event which contains information about pdf_link' do
      q2_event = Event.new payload: @valid_params.merge(package_type: 'q2')
      q2_event.agent = @webhook
      q2_event.user  = @webhook.user
      q2_event.save!

      js2_event = Event.new payload: @valid_params.merge(package_type: 'js2')
      js2_event.agent = @webhook
      js2_event.user  = @webhook.user
      js2_event.save!
      @events.push(js2_event)

      allow(Orchestrator::Tasks::Pipelines::Gazette).to receive(:new) do
        mock = double
        allow(mock).to receive(:launch!).and_return(true)
        allow(mock).to receive(:pdf_link).and_return('pdf_link')
        mock
      end

      @checker.receive(@events)
      just_created_event = Event.find_by_agent_id(@checker.id)
      expect(just_created_event.payload[:pdf_link]).to eq('pdf_link')
    end
  end

  describe "#working?" do
    it "returns true if valid data" do
      @checker.check
      expect(@checker.reload).to be_working
    end
  end
end
