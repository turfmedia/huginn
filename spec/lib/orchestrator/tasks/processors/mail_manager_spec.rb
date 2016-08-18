require 'rails_helper'

RSpec.describe Orchestrator::Tasks::Processors::MailManager do
  let(:subject) { described_class.new date, link_to_pdf, 'random_name'}
  let(:date) { '2016-08-16' }
  let(:expected_date) { "mardi 16 août" }
  let(:link_to_pdf) { 'some_url'} 

  let(:expected_html) { File.read("spec/fixtures/simple_html.html") }

  before do
    allow(Net::HTTP).to receive(:new).with(anything, anything) do
      mock = double
      allow(mock).to receive(:request) do
        mock_response = double
        allow(mock_response).to receive(:body).and_return(expected_html)
        mock_response
      end
      mock
    end
    expect(Net::HTTP.new(anything, anything).request.body).to eq(expected_html) #check that mock works fine
  end

  context '#content' do
    it 'retuns expected html file' do
      expect(subject.content).to eq(expected_html)
    end
  end

  it '#headers returns expected headers' do
    expected_headers = {}
    expected_headers["authorization"] = "Basic #{Base64.encode64("#{ENV['JSON2TEMPLATE_HTML_API_KEY']}:").strip}"

    expected_headers["content-type"] = 'application/json'
    expected_headers["accept"] = 'application/json'

    expect(subject.headers).to eq(expected_headers)
  end

  it '#body returns expected body' do
    expected_body = {
      id: ENV['JSON2TEMPLATE_HTML_TEMPLATE_ID'],
      name: 'random_name',
      data: {
        date: expected_date,
        link_to_pdf: link_to_pdf
      }
    }.to_json

    expect(subject.body).to eq(expected_body)
  end

end
