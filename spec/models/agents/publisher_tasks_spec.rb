require 'rails_helper'

describe Agents::PublisherTasks do
  before do
    Event.destroy_all
    Agent.destroy_all
    @valid_params = {
                    date: '2016-08-15',
                    pipeline_name: 'Gazette',
                    packages: 'js2, q1',
                    html_template_id: 'html_template_id',
                    comcenter_channel_id: 'html_template_id'
                  }
  end

  describe "" do
    before do
      @checker = Agents::PublisherTasks.new(:name => "somename", :options => @valid_params)
      @checker.user = users(:jane)
      @checker.save!
    end

    describe "#check" do
      it "should check that initial run creates an event" do
        expect { @checker.check }.to change { Event.count }.by(1)
      end
    end

    describe "#working?" do
      it "returns true if valid data" do
        @checker.check
        expect(@checker.reload).to be_working
      end
    end
  end

  describe '#receive' do
    context '#Gazette' do
      before do
        @valid_params = {
                    date: '2016-08-15',
                    pipeline_name: 'Gazette',
                    packages: 'js2, q2',
                    html_template_id: 'html_template_id',
                    comcenter_channel_id: 'html_template_id'
                  }
        @checker = Agents::PublisherTasks.new(:name => "somename", :options => @valid_params)
        @checker.user = users(:jane)
        @checker.save!
        @webhook = Agents::WebhookAgent.new( :name => 'webhook',
                                              :options => { 'secret' => 'foobar', 'payload_path' => '.' })
        @webhook.user = @checker.user
        @webhook.save!
        @events = []
      end

      it 'does not run Orchestrator::Tasks::Pipelines::Gazette if events are blank' do
        stub(Orchestrator::Tasks::Pipelines::Gazette).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id]).times(0)
        @checker.receive(@events)
      end

      it 'does not run Orchestrator::Tasks::Pipelines::Gazette if given events is a first event from publisher/api' do
        js2_event = Event.new payload: { date: '2016-08-15', package_type: 'js1'}
        js2_event.agent = @webhook
        js2_event.user  = @webhook.user
        js2_event.save!
        @events.push(js2_event)

        stub(Orchestrator::Tasks::Pipelines::Gazette).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id]).times(0)
        @checker.receive(@events)
      end

      it 'does not run Orchestrator::Tasks::Pipelines::Gazette if given events is a first event from publisher/api if all events before and current events are from the same package' do
        q2_event = Event.new payload: { date: '2016-08-15', package_type: 'q2'}

        q2_event.agent = @webhook
        q2_event.user  = @webhook.user
        q2_event.save!

        q2_event_again = Event.new payload: { date: '2016-08-15', package_type: 'q2'}
        q2_event_again.agent = @webhook
        q2_event_again.user  = @webhook.user
        q2_event_again.save!
        @events.push(q2_event_again)

        stub(Orchestrator::Tasks::Pipelines::Gazette).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id]).times(0)

        @checker.receive(@events)
      end

      it 'does not run Orchestrator::Tasks::Pipelines::Gazette if given events is a second event from publisher/api and they both from different packages but the first was yestreday the second was today' do
        q2_event = Event.new payload: { date: '2016-08-14', package_type: 'q2'}
        q2_event.agent = @webhook
        q2_event.user  = @webhook.user
        q2_event.save!

        js2_event = Event.new payload: { date: '2016-08-15', package_type: 'js2'}
        js2_event.agent = @webhook
        js2_event.user  = @webhook.user
        js2_event.save!
        @events.push(js2_event)

        stub(Orchestrator::Tasks::Pipelines::Gazette).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id]).times(0)

        @checker.receive(@events)
      end

      it 'does not run Orchestrator::Tasks::Pipelines::Gazette if given events from other package' do
        q2_event = Event.new payload: { date: '2016-08-15', package_type: 'q1'}
        q2_event.agent = @webhook
        q2_event.user  = @webhook.user
        q2_event.save!

        js2_event = Event.new payload: { date: '2016-08-15', package_type: 'js1'}
        js2_event.agent = @webhook
        js2_event.user  = @webhook.user
        js2_event.save!
        @events.push(js2_event)

        stub(Orchestrator::Tasks::Pipelines::Gazette).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id]).times(0)

        @checker.receive(@events)
      end

      it 'runs Orchestrator::Tasks::Pipelines::Gazette if given events is a second event from publisher/api and they both from different packages' do
        q2_event = Event.new payload: { date: '2016-08-15', package_type: 'q2'}
        
        q2_event.agent = @webhook
        q2_event.user  = @webhook.user
        q2_event.save!

        js2_event = Event.new payload: { date: '2016-08-15', package_type: 'js2'}

        js2_event.agent = @webhook
        js2_event.user  = @webhook.user
        js2_event.save!
        @events.push(js2_event)

        fake_object = Orchestrator::Tasks::Pipelines::Gazette.new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id])
        stub(fake_object).launch!{ true }.times(1)
        stub(fake_object).response { {} }

        stub(Orchestrator::Tasks::Pipelines::Gazette).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id]) do
          fake_object
        end
        @checker.receive(@events)
      end

      it 'createns new event if given events is a second event from publisher/api and they both from different packages' do
        q2_event = Event.new payload: { date: '2016-08-15', package_type: 'q2'}

        q2_event.agent = @webhook
        q2_event.user  = @webhook.user
        q2_event.save!

        js2_event = Event.new payload: { date: '2016-08-15', package_type: 'js2'}

        js2_event.agent = @webhook
        js2_event.user  = @webhook.user
        js2_event.save!
        @events.push(js2_event)

        fake_object = Orchestrator::Tasks::Pipelines::Gazette.new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id])
        stub(fake_object).launch! { true }
        stub(fake_object).response { {} }

        stub(Orchestrator::Tasks::Pipelines::Gazette).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id]) do
          fake_object
        end

        expect {@checker.receive(@events)}.to change { Event.count }.by(1)
      end

      it 'creates new event which contains information about pdf_link' do
        q2_event = Event.new payload: { date: '2016-08-15', package_type: 'q2'}

        q2_event.agent = @webhook
        q2_event.user  = @webhook.user
        q2_event.save!

        js2_event = Event.new payload: { date: '2016-08-15', package_type: 'js2'}

        js2_event.agent = @webhook
        js2_event.user  = @webhook.user
        js2_event.save!
        @events.push(js2_event)

        fake_object = Orchestrator::Tasks::Pipelines::Gazette.new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id])
        stub(fake_object).launch! { true } 
        stub(fake_object).response { {pdf_link: 'pdf_link'} }

        stub(Orchestrator::Tasks::Pipelines::Gazette).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id]) do
          fake_object
        end

        @checker.receive(@events)
        just_created_event = Event.find_by_agent_id(@checker.id)
        expect(just_created_event.payload[:pdf_link]).to eq('pdf_link')
      end
    end

    context '#Turfistar::Quinte' do
      before do
        @valid_params = {
                    date: '2016-08-15',
                    pipeline_name: 'Turfistar::Quinte',
                    packages: 'q1',
                    html_template_id: 'html_template_id',
                    comcenter_channel_id: 'html_template_id'
                  }
        @checker = Agents::PublisherTasks.new(:name => "somename", :options => @valid_params)
        @checker.user = users(:jane)
        @checker.save!
        @webhook = Agents::WebhookAgent.new( :name => 'webhook',
                                              :options => { 'secret' => 'foobar', 'payload_path' => '.' })
        @webhook.user = @checker.user
        @webhook.save!
        @events = []
      end

      it 'does not run Orchestrator::Tasks::Pipelines::Quinte if given event is not from q1 package' do
        q2_event = Event.new payload: { date: '2016-08-15', package_type: 'q2'}

        q2_event.agent = @webhook
        q2_event.user  = @webhook.user
        q2_event.save!

        @events.push(q2_event)

        stub(Orchestrator::Tasks::Pipelines::Turfistar::Quinte).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id]).times(0)

        @checker.receive(@events)
      end

      it 'runs Orchestrator::Tasks::Pipelines::Quinte if given event is from q1 package' do
        q1_event = Event.new payload: { date: '2016-08-15', package_type: 'q1'}

        q1_event.agent = @webhook
        q1_event.user  = @webhook.user
        q1_event.save!

        @events.push(q1_event)

        fake_object = Orchestrator::Tasks::Pipelines::Turfistar::Quinte.new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id])
        stub(fake_object).launch!{ true }.times(1)
        stub(fake_object).response { {} }


        stub(Orchestrator::Tasks::Pipelines::Turfistar::Quinte).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id]) do
          fake_object
        end
        @checker.receive(@events)
      end
    end


    context '#Turfistar::Simple' do
      before do
        @valid_params = {
                    date: '2016-08-15',
                    pipeline_name: 'Turfistar::Simple',
                    packages: 'js1, q1',
                    html_template_id: 'html_template_id',
                    comcenter_channel_id: 'html_template_id'
                  }
        @checker = Agents::PublisherTasks.new(:name => "somename", :options => @valid_params)
        @checker.user = users(:jane)
        @checker.save!
        @webhook = Agents::WebhookAgent.new( :name => 'webhook',
                                              :options => { 'secret' => 'foobar', 'payload_path' => '.' })
        @webhook.user = @checker.user
        @webhook.save!
        @events = []
      end

      it 'does not run Orchestrator::Tasks::Pipelines::Simple if given events are not from q1 and js1 packages' do
        q2_event = Event.new payload: { date: '2016-08-15', package_type: 'q2'}

        q2_event.agent = @webhook
        q2_event.user  = @webhook.user
        q2_event.save!

        js1_event = Event.new payload: { date: '2016-08-15', package_type: 'js1'}

        js1_event.agent = @webhook
        js1_event.user  = @webhook.user
        js1_event.save!

        @events.push(js1_event)
        stub(Orchestrator::Tasks::Pipelines::Turfistar::Simple).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id]).times(0)

        @checker.receive(@events)
      end

      it 'runs Orchestrator::Tasks::Pipelines::Simple if given events are from q1 and js1 packages' do
        q1_event = Event.new payload: { date: '2016-08-15', package_type: 'q1'}

        q1_event.agent = @webhook
        q1_event.user  = @webhook.user
        q1_event.save!

        js1_event = Event.new payload: { date: '2016-08-15', package_type: 'js1'}

        js1_event.agent = @webhook
        js1_event.user  = @webhook.user
        js1_event.save!

        @events.push(q1_event)

        fake_object = Orchestrator::Tasks::Pipelines::Turfistar::Simple.new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id])
        stub(fake_object).launch!{ true }.times(1)
        stub(fake_object).response { {} }


        stub(Orchestrator::Tasks::Pipelines::Turfistar::Simple).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id]) do
          fake_object
        end
        @checker.receive(@events)
      end

    end


  end

end
