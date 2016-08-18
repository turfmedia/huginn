require 'rails_helper'

RSpec.describe Orchestrator::Tasks::Loaders::Comcenter do
  let(:subject) { described_class.new(email_subject, email_body) }
  let(:email_subject) { 'rspec mail'}
  let(:email_body) do
    "\r\n<html>\r\n    <body>\r\n        <p>\r\n            Bonjour,            \r\n        </p>\r\n        <p>\r\n            Voici la Gazette Turf, regroupant les chevaux repérés et l'analyse du Quinté, vous pouvez l'imprimer et partir au PMU avec.            \r\n        </p>\r\n\r\n        <p>\r\n            Vous trouverez la gazette au format PDF en cliquant sur le lien suivant:\r\n        </p>\r\n        <p>\r\n            <a    href=https://turfmedia-orchestrator.s3-eu-west-1.amazonaws.com/development/attachments/1db694cd622b43f3becffd914a318b74/gazette_turf.pdf>    Gazette Turf du 2016-08-15    </a>\r\n        </p>\r\n\r\n        <p>\r\n            Bons jeux à toutes et à tous\r\n        </p>\r\n        \r\n        <p>\r\n            L'équipe de la Gazette Turf.\r\n        </p>\r\n    </body>\r\n</html>\r\n"
  end
  let(:expected_url) { "#{ENV['COMCENTER_URL']}/api/channels/#{ENV['COMCENTER_CHANNEL']}/campaigns"}
  let(:success_response) { {"message":"Message sent"} }

  before do
    allow(Net::HTTP).to receive(:new).with(anything, anything) do
      mock = double
      allow(mock).to receive(:request) do
        mock_response = double(Net::HTTPCreated)
        allow(mock_response).to receive(:body).and_return(success_response)
        allow(mock_response).to receive(:kind_of?).with(Net::HTTPSuccess).and_return(true)
        mock_response
      end
      mock
    end
    expect(Net::HTTP.new(anything, anything).request.body).to eq(success_response) #check that mock works fine
  end

  context '#send!' do
    it 'returns true if everything is ok' do
      expect(subject.send!).to eq(true)
    end
  end

  it '#uri returns expected uri' do
    expect(subject.uri).to eq(URI(expected_url))
  end

  it '#headers returns expected headers' do
    expected_headers = {}
    expected_headers["authorization"] = "Basic #{Base64.encode64("#{ENV['COMCENTER_API_KEY']}:").strip}"
    expected_headers['content-type']  = 'application/json'
    expected_headers["accept"]        = 'application/json'
    expect(subject.headers).to eq(expected_headers)
  end

  it '#body returns information about subject and body' do
    expect(subject.body).to eq({subject: email_subject, body: email_body}.to_json)
  end
  
end
