require 'rails_helper'

describe Agents::PublisherTasks do
  before do
    Event.destroy_all
    Agent.destroy_all
    @valid_params = {
                    date: '2016-08-15',
                    pipeline_name: 'Gazette',
                    packages: { required: ['js2', 'q1'] },
                    html_template_id: 'html_template_id',
                    comcenter_channel_id: 'comcenter_channel_id',
                    comcenter_api_key: 'comcenter_api_key',
                    expected_time_in_hours: - (Time.now.hour + 1)# negative means last day
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
      it "returns true if last event is success" do
        @checker.create_event(payload: { date: @valid_params[:date], status: "ok" }, date: Date.today)
        expect(@checker.reload).to be_working
      end

      it "returns false if last event is failure" do
        @checker.create_event(payload: { date: @valid_params[:date], status: "failure" })
        expect(@checker.reload).not_to be_working
      end

      context 'MIT' do
        before do
          @valid_params[:expected_time_in_hours] = - Time.now.hour
          @checker.options = @valid_params and @checker.save!
        end

        it "should be sent today in time less then #{Time.now.hour} hours (returns true if yes)" do
          event = @checker.create_event(payload: { date: Date.tomorrow, status: "ok" })
          event.update_column :date, Date.tomorrow
          expect(@checker.reload).to be_working
        end
        
        it "should be sent today in time less then #{Time.now.hour} hours (returns false if not)" do
          event = @checker.create_event(payload: { date: Date.today, status: "ok" })
          event.update_column :date, Date.today
          expect(@checker.reload).not_to be_working
        end

        it "should be sent today in time less then #{Time.now.hour} hours (returns false if yes but failure)" do
          event = @checker.create_event(payload: { date: Date.tomorrow, status: "failure" })
          event.update_column :date, Date.tomorrow
          expect(@checker.reload).not_to be_working
        end

        it "should be sent today in time less then #{Time.now.hour} hours (returns true if yes and if wrong order)" do
          event1 = @checker.create_event(payload: { date: Date.tomorrow, status: "ok" })
          event1.update_column :date, Date.tomorrow
          event2 = @checker.create_event(payload: { date: Date.today, status: "ok" })
          event2.update_column :date, Date.today
          expect(@checker.reload).to be_working
        end
      end

      context 'Turfistart JS' do
        before do
          @valid_params[:expected_time_in_hours] = Time.now.hour
          @checker.options = @valid_params and @checker.save!
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
  end

  describe '#receive' do
    context '#Gazette' do
      before do
        @valid_params = {
                    date: '2016-08-15',
                    pipeline_name: 'Gazette',
                    packages: { required: ['js2', 'q2'] },
                    html_template_id: 'html_template_id',
                    comcenter_channel_id: 'comcenter_channel_id',
                    comcenter_api_key: 'comcenter_api_key',
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
        stub(Orchestrator::Tasks::Pipelines::Gazette).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]).times(0)
        @checker.receive(@events)
      end

      it 'does not run Orchestrator::Tasks::Pipelines::Gazette if given events is a first event from publisher/api' do
        js2_event = Event.new payload: { date: '2016-08-15', package_type: 'js1'}
        js2_event.agent = @webhook
        js2_event.user  = @webhook.user
        js2_event.save!
        @events.push(js2_event)

        stub(Orchestrator::Tasks::Pipelines::Gazette).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]).times(0)
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

        stub(Orchestrator::Tasks::Pipelines::Gazette).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]).times(0)

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

        stub(Orchestrator::Tasks::Pipelines::Gazette).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]).times(0)

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

        stub(Orchestrator::Tasks::Pipelines::Gazette).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]).times(0)

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

        fake_object = Orchestrator::Tasks::Pipelines::Gazette.new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key])
        stub(fake_object).launch!{ true }.times(1)
        stub(fake_object).response { {} }

        stub(Orchestrator::Tasks::Pipelines::Gazette).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]) do
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

        fake_object = Orchestrator::Tasks::Pipelines::Gazette.new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key])
        stub(fake_object).launch! { true }
        stub(fake_object).response { {} }

        stub(Orchestrator::Tasks::Pipelines::Gazette).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]) do
          fake_object
        end

        expect {@checker.receive(@events)}.to change { Event.count }.by(1)
        
        expect(@checker.events.count).to eq(1)
        expect(@checker.events.first.date).to eq('2016-08-15'.to_date)
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

        fake_object = Orchestrator::Tasks::Pipelines::Gazette.new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key])
        stub(fake_object).launch! { true } 
        stub(fake_object).response { {pdf_link: 'pdf_link'} }

        stub(Orchestrator::Tasks::Pipelines::Gazette).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]) do
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
                    packages: { required: ['q1'], optional: ['Erratum Turfistar Quinte'] },
                    html_template_id: 'html_template_id',
                    comcenter_channel_id: 'comcenter_channel_id',
                    comcenter_api_key: 'comcenter_api_key',
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

        stub(Orchestrator::Tasks::Pipelines::Turfistar::Quinte).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]).times(0)

        @checker.receive(@events)
      end

      it 'does not run Orchestrator::Tasks::Pipelines::Quinte if given event is not from q1 package and before we received q1 package' do
        q1_event = Event.new payload: { date: '2016-08-15', package_type: 'q1'}

        q1_event.agent = @webhook
        q1_event.user  = @webhook.user
        q1_event.save!

        q2_event = Event.new payload: { date: '2016-08-15', package_type: 'q2'}

        q2_event.agent = @webhook
        q2_event.user  = @webhook.user
        q2_event.save!

        @events.push(q2_event)

        stub(Orchestrator::Tasks::Pipelines::Turfistar::Quinte).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]).times(0)

        @checker.receive(@events)
      end


      it 'does not run Orchestrator::Tasks::Pipelines::Quinte if given event is from Erratum Turfistar Quinte package and we do not receive any q1 packages' do
        erratum_turfistar_quinte_event = Event.new payload: { date: '2016-08-15', package_type: 'Erratum Turfistar Quinte'}

        erratum_turfistar_quinte_event.agent = @webhook
        erratum_turfistar_quinte_event.user  = @webhook.user
        erratum_turfistar_quinte_event.save!

        @events.push(erratum_turfistar_quinte_event)

        stub(Orchestrator::Tasks::Pipelines::Turfistar::Quinte).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]).times(0)

        @checker.receive(@events)
      end

      it 'runs Orchestrator::Tasks::Pipelines::Quinte if given event is from q1 package' do
        q1_event = Event.new payload: { date: '2016-08-15', package_type: 'q1'}

        q1_event.agent = @webhook
        q1_event.user  = @webhook.user
        q1_event.save!

        @events.push(q1_event)

        fake_object = Orchestrator::Tasks::Pipelines::Turfistar::Quinte.new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key])
        stub(fake_object).launch!{ true }.times(1)
        stub(fake_object).response { {} }


        stub(Orchestrator::Tasks::Pipelines::Turfistar::Quinte).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]) do
          fake_object
        end
        @checker.receive(@events)
      end

      it 'runs Orchestrator::Tasks::Pipelines::Quinte if given event is from Erratum Turfistar Quinte package and we received q1 package before' do
        q1_event = Event.new payload: { date: '2016-08-15', package_type: 'q1'}
        q1_event.agent = @webhook
        q1_event.user  = @webhook.user
        q1_event.save!

        erratum_turfistar_quinte_event = Event.new payload: { date: '2016-08-15', package_type: 'Erratum Turfistar Quinte'}

        erratum_turfistar_quinte_event.agent = @webhook
        erratum_turfistar_quinte_event.user  = @webhook.user
        erratum_turfistar_quinte_event.save!

        @events.push(erratum_turfistar_quinte_event)

        fake_object = Orchestrator::Tasks::Pipelines::Turfistar::Quinte.new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key])
        stub(fake_object).launch!{ true }.times(1)
        stub(fake_object).response { {} }

        stub(Orchestrator::Tasks::Pipelines::Turfistar::Quinte).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]) do
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
                    packages: { required: ['js1', 'q1'] },
                    html_template_id: 'html_template_id',
                    comcenter_channel_id: 'comcenter_channel_id',
                    comcenter_api_key: 'comcenter_api_key',
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
        stub(Orchestrator::Tasks::Pipelines::Turfistar::Simple).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]).times(0)

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

        fake_object = Orchestrator::Tasks::Pipelines::Turfistar::Simple.new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key])
        stub(fake_object).launch!{ true }.times(1)
        stub(fake_object).response { {} }


        stub(Orchestrator::Tasks::Pipelines::Turfistar::Simple).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]) do
          fake_object
        end
        @checker.receive(@events)
      end

    end

    context 'MiT CG' do
      before do
        @valid_params = {
                    date: '2016-10-06',
                    pipeline_name: 'MIT::CG',
                    packages: { required: ['mit_cg'] },
                    html_template_id: 'html_template_id',
                    comcenter_channel_id: 'comcenter_channel_id',
                    comcenter_api_key: 'comcenter_api_key',
                  }
        @checker = Agents::PublisherTasks.new(:name => "somename", :options => @valid_params)
        @checker.user = users(:jane)
        @checker.save!
        @webhook = Agents::WebhookAgent.new( :name => 'webhook',
                                              :options => { 'secret' => 'foobar', 'payload_path' => '.' })
        @webhook.user = @checker.user
        @webhook.save!
      end

      it 'runs Orchestrator::Tasks::Pipelines::MIT::CG if received 2 events and first is not from MiT::CG' do
        mit_cdj_event = Event.new payload: {"date"=>"2016-10-06", "package_type"=>"mit_cdj"}
        mit_cdj_event.agent = @webhook
        mit_cdj_event.user  = @webhook.user
        mit_cdj_event.save!
        mit_cg_event  = Event.new payload: {"date"=>"2016-10-06", "package_type"=>"mit_cg"}
        mit_cg_event.agent = @webhook
        mit_cg_event.user  = @webhook.user
        mit_cg_event.save!

        @events = [mit_cdj_event, mit_cg_event]

        fake_object = Orchestrator::Tasks::Pipelines::MIT::CG.new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key])
        stub(fake_object).launch!{ true }.times(1)
        stub(fake_object).response { {} }

        stub(Orchestrator::Tasks::Pipelines::MIT::CG).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]) do
          fake_object
        end
        @checker.receive(@events)
      end
    end

    context 'MiT CDJ' do
      before do
        @valid_params = {
                    date: '2016-10-06',
                    pipeline_name: 'MIT::CDJ',
                    packages: { required: ['mit_cdj'] },
                    html_template_id: 'html_template_id',
                    comcenter_channel_id: 'comcenter_channel_id',
                    comcenter_api_key: 'comcenter_api_key',
                  }
        @checker = Agents::PublisherTasks.new(:name => "somename", :options => @valid_params)
        @checker.user = users(:jane)
        @checker.save!
        @webhook = Agents::WebhookAgent.new( :name => 'webhook',
                                              :options => { 'secret' => 'foobar', 'payload_path' => '.' })
        @webhook.user = @checker.user
        @webhook.save!
      end

      it 'runs Orchestrator::Tasks::Pipelines::MIT::CDJ only once if received 3 events and the first and the last are from MiT::CDJ but for same date' do
        mit_cdj_event = Event.new payload: {"date"=>"2016-10-06", "package_type"=>"mit_cdj"}
        mit_cdj_event.agent = @webhook
        mit_cdj_event.user  = @webhook.user
        mit_cdj_event.save!
        mit_cg_event  = Event.new payload: {"date"=>"2016-10-06", "package_type"=>"mit_cg"}
        mit_cg_event.agent = @webhook
        mit_cg_event.user  = @webhook.user
        mit_cg_event.save!
        mit_cdj_event2 = Event.new payload: {"date"=>"2016-10-06", "package_type"=>"mit_cdj"}
        mit_cdj_event2.agent = @webhook
        mit_cdj_event2.user  = @webhook.user
        mit_cdj_event2.save!
        

        @events = [mit_cdj_event, mit_cg_event, mit_cdj_event2]

        fake_object = Orchestrator::Tasks::Pipelines::MIT::CDJ.new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key])
        stub(fake_object).launch!{ true }.times(1)
        stub(fake_object).response { {} }

        stub(Orchestrator::Tasks::Pipelines::MIT::CDJ).new(@valid_params[:date], @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]) do
          fake_object
        end
        @checker.receive(@events)
      end

      it 'runs Orchestrator::Tasks::Pipelines::MIT::CDJ only once if received 3 events and the first and the last are from MiT::CDJ but for different date' do
        mit_cdj_event = Event.new payload: {"date"=>"2016-10-06", "package_type"=>"mit_cdj"}
        mit_cdj_event.agent = @webhook
        mit_cdj_event.user  = @webhook.user
        mit_cdj_event.save!
        mit_cg_event  = Event.new payload: {"date"=>"2016-10-06", "package_type"=>"mit_cg"}
        mit_cg_event.agent = @webhook
        mit_cg_event.user  = @webhook.user
        mit_cg_event.save!
        mit_cdj_event2 = Event.new payload: {"date"=>"2016-10-07", "package_type"=>"mit_cdj"}
        mit_cdj_event2.agent = @webhook
        mit_cdj_event2.user  = @webhook.user
        mit_cdj_event2.save!
        

        @events = [mit_cdj_event, mit_cg_event, mit_cdj_event2]

        fake_object1 = Orchestrator::Tasks::Pipelines::MIT::CDJ.new('2016-10-06', @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key])
        stub(fake_object1).launch!{ true }.times(1)
        stub(fake_object1).response { {} }


        fake_object2 = Orchestrator::Tasks::Pipelines::MIT::CDJ.new('2016-10-07', @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key])
        stub(fake_object2).launch!{ true }.times(1)
        stub(fake_object2).response { {} }

        stub(Orchestrator::Tasks::Pipelines::MIT::CDJ).new('2016-10-07', @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]) do
          fake_object2
        end

        stub(Orchestrator::Tasks::Pipelines::MIT::CDJ).new('2016-10-06', @valid_params[:html_template_id], @valid_params[:comcenter_channel_id], @valid_params[:comcenter_api_key]) do
          fake_object1
        end
        @checker.receive(@events)

      end
    end
  end



end
