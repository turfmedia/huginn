require 'rails_helper'

describe Agents::PronosticResultsAgent do
  before do
    Event.destroy_all
    Agent.destroy_all
  end

  context '#Gazette' do
    before do
      @valid_params = {
                  date: "2016-08-19",
                  data: {
                    "file_name" => 'file_name',
                  },
                  pipeline_name: 'Gazette'
                }
      @checker = Agents::PronosticResultsAgent.new(:name => "somename", :options => @valid_params)
      @checker.user = users(:jane)
      @checker.save!
    end

    describe "#check" do
      context 'with not blank date' do
        before do
          fake_object = PublisherTask::Tasks::Pipelines::Results::Gazette.new(@valid_params[:date], data: @valid_params[:data])
          stub(fake_object).launch! { true } 

          stub(PublisherTask::Tasks::Pipelines::Results::Gazette).new((@valid_params[:date].to_date - 1.day).to_s, data: @valid_params[:data]) do
            fake_object
          end
          stub(PublisherTask::Tasks::Pipelines::Results::Gazette).new(@valid_params[:date], data: @valid_params[:data]) do
            fake_object
          end
        end

        it "should check that initial run creates an event" do
          expect { @checker.check }.to change { Event.count }.by(1)
        end

        it "runs PublisherTask::Tasks::Pipelines::Results::Gazette pipeline with given data if this date present" do
          fake_object = PublisherTask::Tasks::Pipelines::Results::Gazette.new(@valid_params[:date], data: @valid_params[:data])
          stub(fake_object).launch!{ true }.times(2)
          stub(PublisherTask::Tasks::Pipelines::Results::Gazette).new((@valid_params[:date].to_date - 1.day).to_s, data: @valid_params[:data]) do
            fake_object
          end
          stub(PublisherTask::Tasks::Pipelines::Results::Gazette).new(@valid_params[:date], data: @valid_params[:data]) do
            fake_object
          end

          @checker.check
        end
      end

      it 'runs PublisherTask::Tasks::Pipelines::Results::Gazette pipeline for yesterday if given date is blank' do
        fake_object = PublisherTask::Tasks::Pipelines::Results::Gazette.new(Date.yesterday.to_s, data: @valid_params[:data])
        stub(fake_object).launch!{ true }.times(2)

        stub(PublisherTask::Tasks::Pipelines::Results::Gazette).new((Date.yesterday - 1.day).to_s, data: @valid_params[:data]) do
          fake_object
        end
        stub(PublisherTask::Tasks::Pipelines::Results::Gazette).new(Date.yesterday.to_s, data: @valid_params[:data]) do
          fake_object
        end

        @valid_params = {data: {"file_name" => 'file_name'}, pipeline_name: 'Gazette'}
        @checker = Agents::PronosticResultsAgent.new(:name => "somename", :options => @valid_params)
        @checker.user = users(:jane)
        @checker.save!

        @checker.check
      end
    end

    describe "#working?" do
      it "returns true if valid data" do
        fake_object = PublisherTask::Tasks::Pipelines::Results::Gazette.new(@valid_params[:date], data: @valid_params[:data])
        stub(fake_object).launch! { true } 
        stub(PublisherTask::Tasks::Pipelines::Results::Gazette).new((@valid_params[:date].to_date - 1.day).to_s, data: @valid_params[:data]) do
          fake_object
        end
        stub(PublisherTask::Tasks::Pipelines::Results::Gazette).new(@valid_params[:date], data: @valid_params[:data]) do
          fake_object
        end

        @checker.check
        expect(@checker.reload).to be_working
      end
    end
  end


  context '#TurfistarSimple' do
    before do
      @valid_params = {
                  date: "2016-08-30",
                  data: {
                    "file_name" => 'file_name',
                  },
                  pipeline_name: 'TurfistarSimple'
                }
      @checker = Agents::PronosticResultsAgent.new(:name => "somename", :options => @valid_params)
      @checker.user = users(:jane)
      @checker.save!
    end

    describe "#check" do
      before do
        fake_object = PublisherTask::Tasks::Pipelines::Results::TurfistarSimple.new(@valid_params[:date], data: @valid_params[:data])
        stub(fake_object).launch! { true } 
        stub(PublisherTask::Tasks::Pipelines::Results::TurfistarSimple).new((@valid_params[:date].to_date - 1.day).to_s, data: @valid_params[:data]) do
          fake_object
        end
        stub(PublisherTask::Tasks::Pipelines::Results::TurfistarSimple).new(@valid_params[:date], data: @valid_params[:data]) do
          fake_object
        end
      end

      it "should check that initial run creates an event" do
        expect { @checker.check }.to change { Event.count }.by(1)
      end

    end

    describe "#working?" do
      it "returns true if valid data" do
        fake_object = PublisherTask::Tasks::Pipelines::Results::TurfistarSimple.new(@valid_params[:date], data: @valid_params[:data])
        stub(fake_object).launch! { true } 

        stub(PublisherTask::Tasks::Pipelines::Results::TurfistarSimple).new((@valid_params[:date].to_date - 1.day).to_s, data: @valid_params[:data]) do
          fake_object
        end
        stub(PublisherTask::Tasks::Pipelines::Results::TurfistarSimple).new(@valid_params[:date], data: @valid_params[:data]) do
          fake_object
        end

        @checker.check
        expect(@checker.reload).to be_working
      end
    end

  end

end
