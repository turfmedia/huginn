require 'rails_helper'

describe Agents::PronosticResultsAgent do
  before do
    Event.destroy_all
    Agent.destroy_all
    @valid_params = {
                      date: "2016-08-19",
                      file_name: 'file_name'
                    }

    @checker = Agents::PronosticResultsAgent.new(:name => "somename", :options => @valid_params)
    @checker.user = users(:jane)
    @checker.save!
  end

  describe "#check" do
    context 'with not blank date' do
      before do
        fake_object = Orchestrator::Tasks::Pipelines::Results::Gazette.new(@valid_params[:date], @valid_params[:file_name])
        stub(fake_object).launch! { true } 
        stub(Orchestrator::Tasks::Pipelines::Results::Gazette).new(@valid_params[:date], @valid_params[:file_name]) do
          fake_object
        end
      end

      it "should check that initial run creates an event" do
        expect { @checker.check }.to change { Event.count }.by(1)
      end

      it "runs Orchestrator::Tasks::Pipelines::Results::Gazette pipeline with given data if this date present" do
        fake_object = Orchestrator::Tasks::Pipelines::Results::Gazette.new(@valid_params[:date], @valid_params[:file_name])
        stub(fake_object).launch!{ true }.times(1)
        stub(Orchestrator::Tasks::Pipelines::Results::Gazette).new(@valid_params[:date], @valid_params[:file_name]) do
          fake_object
        end

        @checker.check
      end
    end

    it 'runs Orchestrator::Tasks::Pipelines::Results::Gazette pipeline for yesterday if given date is blank' do
      fake_object = Orchestrator::Tasks::Pipelines::Results::Gazette.new(Date.yesterday.to_s, @valid_params[:file_name])
      stub(fake_object).launch!{ true }.times(1)
      stub(Orchestrator::Tasks::Pipelines::Results::Gazette).new(Date.yesterday.to_s, @valid_params[:file_name]) do
        fake_object
      end
      @valid_params = {file_name: 'file_name'}
      @checker = Agents::PronosticResultsAgent.new(:name => "somename", :options => @valid_params)
      @checker.user = users(:jane)
      @checker.save!

      @checker.check
    end
  end

  describe "#working?" do
    it "returns true if valid data" do
      fake_object = Orchestrator::Tasks::Pipelines::Results::Gazette.new(@valid_params[:date], @valid_params[:file_name])
      stub(fake_object).launch! { true } 
      stub(Orchestrator::Tasks::Pipelines::Results::Gazette).new(@valid_params[:date], @valid_params[:file_name]) do
        fake_object
      end

      @checker.check
      expect(@checker.reload).to be_working
    end
  end
end
