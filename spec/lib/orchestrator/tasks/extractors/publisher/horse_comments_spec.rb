require 'rails_helper'

RSpec.describe Orchestrator::Tasks::Extractors::Publisher::HorseComments do
  let(:subject) { described_class.new race_id }
  let(:race_id) { -777 }
  let(:fake_response) do
    "[{\"id\":1,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 01\",\"horsename\":\"Boeing Du Bocage\",\"number\":1}},{\"id\":2,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 02\",\"horsename\":\"Uargane Montaval\",\"number\":2}},{\"id\":3,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 03\",\"horsename\":\"Airport\",\"number\":3}},{\"id\":4,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 04\",\"horsename\":\"Attila Du Gabereau\",\"number\":4}},{\"id\":5,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 05\",\"horsename\":\"Tiburce De Brion\",\"number\":5}},{\"id\":6,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 06\",\"horsename\":\"Unero Montaval\",\"number\":6}},{\"id\":7,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 07\",\"horsename\":\"Vignia La Ravelle\",\"number\":7}},{\"id\":8,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 08\",\"horsename\":\"Vanille Du Dollar\",\"number\":8}},{\"id\":9,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 09\",\"horsename\":\"Ursa Major\",\"number\":9}},{\"id\":10,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 10\",\"horsename\":\"Topaze Jef\",\"number\":10}},{\"id\":11,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 11\",\"horsename\":\"Vulcain De Vandel\",\"number\":11}},{\"id\":12,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 12\",\"horsename\":\"Un Diamant D'amour\",\"number\":12}},{\"id\":13,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 13\",\"horsename\":\"Tiger Danover\",\"number\":13}},{\"id\":14,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 14\",\"horsename\":\"Val Royal\",\"number\":14}},{\"id\":15,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 15\",\"horsename\":\"Aubrion Du Gers\",\"number\":15}},{\"id\":16,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 16\",\"horsename\":\"Seduisant Fouteau\",\"number\":16}},{\"id\":17,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 17\",\"horsename\":\"Best Of Jets\",\"number\":17}},{\"id\":18,\"race_id\":\"#{race_id}\",\"comments\":{\"comment\":\"comment 18\",\"horsename\":\"Tornade Du Digeon\",\"number\":18}}]"
  end

  context '#content' do

    let(:expected_info) do
      [
        {id: 1, race_id: "#{race_id}", comments: { comment: "comment 01", horsename: "Boeing Du Bocage", number: 1}},
        {id: 2, race_id: "#{race_id}", comments: { comment: "comment 02", horsename: "Uargane Montaval", number: 2}},
        {id: 3, race_id: "#{race_id}", comments: { comment: "comment 03", horsename: "Airport", number: 3}},
        {id: 4, race_id: "#{race_id}", comments: { comment: "comment 04", horsename: "Attila Du Gabereau", number: 4}},
        {id: 5, race_id: "#{race_id}", comments: { comment: "comment 05", horsename: "Tiburce De Brion", number: 5}},
        {id: 6, race_id: "#{race_id}", comments: { comment: "comment 06", horsename: "Unero Montaval", number: 6}},
        {id: 7, race_id: "#{race_id}", comments: { comment: "comment 07", horsename: "Vignia La Ravelle", number: 7}},
        {id: 8, race_id: "#{race_id}", comments: { comment: "comment 08", horsename: "Vanille Du Dollar", number: 8}},
        {id: 9, race_id: "#{race_id}", comments: { comment: "comment 09", horsename: "Ursa Major", number: 9}},
        {id: 10, race_id: "#{race_id}", comments: { comment: "comment 10", horsename: "Topaze Jef", number: 10}},
        {id: 11, race_id: "#{race_id}", comments: { comment: "comment 11", horsename: "Vulcain De Vandel", number: 11}},
        {id: 12, race_id: "#{race_id}", comments: { comment: "comment 12", horsename: "Un Diamant D'amour", number: 12}},
        {id: 13, race_id: "#{race_id}", comments: { comment: "comment 13", horsename: "Tiger Danover", number: 13}},
        {id: 14, race_id: "#{race_id}", comments: { comment: "comment 14", horsename: "Val Royal", number: 14}},
        {id: 15, race_id: "#{race_id}", comments: { comment: "comment 15", horsename: "Aubrion Du Gers", number: 15}},
        {id: 16, race_id: "#{race_id}", comments: { comment: "comment 16", horsename: "Seduisant Fouteau", number: 16}},
        {id: 17, race_id: "#{race_id}", comments: { comment: "comment 17", horsename: "Best Of Jets", number: 17}},
        {id: 18, race_id: "#{race_id}", comments: { comment: "comment 18", horsename: "Tornade Du Digeon", number: 18}}
      ]
      end

    before do
      allow(Net::HTTP).to receive(:get).and_return(fake_response)
    end

    it 'returns expected info' do
      expect(subject.content).to eq(expected_info)
    end
  end

end
