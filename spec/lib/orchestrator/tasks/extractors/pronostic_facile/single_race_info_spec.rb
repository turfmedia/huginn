require 'rails_helper'

RSpec.describe Orchestrator::Tasks::Extractors::PronosticFacile::SingleRaceInfo do
  let(:subject) { described_class.new 'fake_course_id' }
  let(:fake_response) do
     "{\"course\":{\"heure\":\"2000-01-01T13:47:00+00:00\",\"nom\":\"Prix du Pays Niçois\",\"numero\":3,\"distance\":2100,\"partants\":[{\"numero\":4,\"cheval\":{\"nom\":\"Toumai\"}},{\"numero\":3,\"cheval\":{\"nom\":\"Ut D'ostal\"}},{\"numero\":2,\"cheval\":{\"nom\":\"Vista De Carsac\"}},{\"numero\":1,\"cheval\":{\"nom\":\"Ugo D'urzy\"}},{\"numero\":5,\"cheval\":{\"nom\":\"Trento Rosso\"}}],\"reunion\":{\"numero\":1}}}"
  end

  let(:expected_info) do
    {
      "course": {
        "heure": "2000-01-01T13:47:00+00:00", # time of race, only HH:MM is relevant
        "nom": "Prix du Pays Niçois",         # name of the race
        "numero": 3,                          # number of the race in the meeting
        "distance": 2100,
        "partants": [                         # array of runners
          {
            "numero": 4,                      # number of runner
            "cheval": {                       # horse
              "nom": "Toumai"                 # name
            }
          },
          {
            "numero": 3,
            "cheval": {
              "nom": "Ut D'ostal"
            }
          },
          {
            "numero": 2,
            "cheval": {
              "nom": "Vista De Carsac"
            }
          },
          {
            "numero": 1,
            "cheval": {
              "nom": "Ugo D'urzy"
            }
          },
          {
            "numero": 5,
            "cheval": {
              "nom": "Trento Rosso"
            }
          }
        ],
        "reunion": {
          "numero": 1
        }
      }
    }
  end

  before do
    allow(Net::HTTP).to receive(:get).and_return(fake_response)
  end

  it '#info returns expected info' do
    expect(subject.content).to eq(expected_info)
  end
end
