require 'rails_helper'

describe Agents::AgentsStatus do
  before do
    Event.destroy_all
    Agent.destroy_all
    @valid_params = {
                    agents: 'all',
                    except: [],
                    expected_update_period_in_days: 1
                  }
    @checker = described_class.new(name: 'Agents status', options: @valid_params)
    @checker.user = users(:jane)
    @checker.save!
  end

 

  describe "#check" do
    it "should crete an event if some of agents does not working" do
      options = {
                date: '2016-08-15',
                pipeline_name: 'Gazette',
                packages: { required: ['js2', 'q1'] },
                html_template_id: 'html_template_id',
                comcenter_channel_id: 'comcenter_channel_id',
                comcenter_api_key: 'comcenter_api_key',
                expected_update_period_in_days: 1
              }
      agent = Agents::PublisherTasks.new(:name => "Gazette", :options => options)
      agent.user = users(:jane)
      agent.save!
      expect(agent.working?).to eq(false)
      expect { @checker.check }.to change { Event.count }.by(1)
    end

    it 'should not create an event if all agents are working' do
      options = {
                date: '2016-08-15',
                pipeline_name: 'Gazette',
                packages: { required: ['js2', 'q1'] },
                html_template_id: 'html_template_id',
                comcenter_channel_id: 'comcenter_channel_id',
                comcenter_api_key: 'comcenter_api_key',
                expected_update_period_in_days: 1
              }
      agent = Agents::PublisherTasks.new(:name => "Gazette", :options => options)
      agent.user = users(:jane)
      agent.save!
      agent.create_event(payload: {status: 'ok', date: Date.today})
      expect(agent.working?).to eq(true)
      expect { @checker.check }.to change { Event.count }.by(0)
    end

    it 'should not create an event if agent is not working but it is in except list' do
      @checker.destroy
      options = {
                date: '2016-08-15',
                pipeline_name: 'Gazette',
                packages: { required: ['js2', 'q1'] },
                html_template_id: 'html_template_id',
                comcenter_channel_id: 'comcenter_channel_id',
                comcenter_api_key: 'comcenter_api_key',
                expected_update_period_in_days: 1
              }
      agent = Agents::PublisherTasks.new(:name => "Gazette", :options => options)
      agent.user = users(:jane)
      agent.save!
      expect(agent.working?).to eq(false)

      @valid_params[:except] = ['Gazette']

      @checker = described_class.new(name: 'Agents status', options: @valid_params)
      @checker.user = users(:jane)
      @checker.save!

      expect { @checker.check }.to change { Event.count }.by(0)
    end

    it 'should not create an event if agent is not working but it is not in agents list' do
      @checker.destroy
      options = {
                date: '2016-08-15',
                pipeline_name: 'Gazette',
                packages: { required: ['js2', 'q1'] },
                html_template_id: 'html_template_id',
                comcenter_channel_id: 'comcenter_channel_id',
                comcenter_api_key: 'comcenter_api_key',
                expected_update_period_in_days: 1
              }
      agent = Agents::PublisherTasks.new(:name => "Gazette", :options => options)
      agent.user = users(:jane)
      agent.save!
      expect(agent.working?).to eq(false)

      @valid_params[:agents] = ['MiT']

      @checker = described_class.new(name: 'Agents status', options: @valid_params)
      @checker.user = users(:jane)
      @checker.save!

      expect { @checker.check }.to change { Event.count }.by(0)
    end

    it 'does not create new event if was create before' do
      options = {
                date: '2016-08-15',
                pipeline_name: 'Gazette',
                packages: { required: ['js2', 'q1'] },
                html_template_id: 'html_template_id',
                comcenter_channel_id: 'comcenter_channel_id',
                comcenter_api_key: 'comcenter_api_key',
                expected_update_period_in_days: 1
              }
      agent = Agents::PublisherTasks.new(:name => "Gazette", :options => options)
      agent.user = users(:jane)
      agent.save!
      expect(agent.working?).to eq(false)
      expect { @checker.check }.to change { Event.count }.by(1)
      expect { @checker.check }.to change { Event.count }.by(0)
    end

    it 'does not create new event if was create before' do
      options = {
                date: '2016-08-15',
                pipeline_name: 'Gazette',
                packages: { required: ['js2', 'q1'] },
                html_template_id: 'html_template_id',
                comcenter_channel_id: 'comcenter_channel_id',
                comcenter_api_key: 'comcenter_api_key',
                expected_update_period_in_days: 1
              }
      agent = Agents::PublisherTasks.new(:name => "Gazette", :options => options)
      agent.user = users(:jane)
      agent.save!
      expect(agent.working?).to eq(false)
      agent.create_event(payload: {status: 'failure', date: Date.today, agent_name: agent.name})
      expect { @checker.check }.to change { Event.count }.by(1)
    end

  end

  describe "#working?" do
    it "returns true if last event is not longer than 1 day" do
      @checker.create_event(payload: {data: 'test'})
      expect(@checker.reload).to be_working
    end

    it "returns false if there is no any events" do
      expect(@checker.reload).not_to be_working
    end

    it "returns false if last event is longer than 1 day" do
      @checker.create_event(payload: {data: 'test'})
      @checker.last_event_at = Time.now - 2.days and @checker.save!
      expect(@checker.reload).not_to be_working
    end

  end
  
end
