require 'rails_helper'

RSpec.describe Orchestrator::Tasks::Processors::PdfManager do
  let(:subject) { described_class.new data, 'random_name' }
  let(:template_id) { ENV['JSON2TEMPLATE_PDF_TEMPLATE_ID'] }
  let(:data) do
    {
      name: "Alex"
    }
  end
  let(:expected_pdf) { File.read("spec/fixtures/simple_pdf.pdf") }

  before do
    allow(Net::HTTP).to receive(:new).with(anything, anything) do
      mock = double
      allow(mock).to receive(:request) do
        mock_response = double
        allow(mock_response).to receive(:body).and_return(expected_pdf)
        mock_response
      end
      mock
    end
    expect(Net::HTTP.new(anything, anything).request.body).to eq(expected_pdf) #check that mock works fine
  end

  context '#content' do
    it 'retuns expected pdf file' do
      expect(subject.content).to eq(expected_pdf)
    end
  end

  it '#headers returns expected headers' do
    expected_headers = {}
    expected_headers["authorization"] = "Basic #{Base64.encode64("#{ENV['JSON2TEMPLATE_PDF_API_KEY']}:").strip}"
    expected_headers["content-type"] = 'application/json'
    expected_headers["accept"] = 'application/json'

    expect(subject.headers).to eq(expected_headers)
  end

  it '#body returns expected body' do
    expected_body = {
      id: template_id,
      name: 'random_name',
      data: data
    }.to_json

    expect(subject.body).to eq(expected_body)
  end




end
