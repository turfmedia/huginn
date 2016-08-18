require 'rails_helper'

RSpec.describe Orchestrator::Tasks::Extractors::PronosticFacile::JS2Package do
  let(:subject) { described_class.new '2016-08-10' }

  let(:race_id) { -777}

  let(:fake_response) do
     "{\"race_id\":#{race_id},\"date\":\"2016-08-10\",\"pronostic\":\"14 - 15 - 11 - 18 - 12 - 4 - 6 - 5\",\"race_comment\":\"Sur ce parcours, il faut bien tourner à droite et être maniable\",\"partants\":[{\"note\":72,\"numero\":14,\"nom\":\"Val Royal\",\"comment\":\"Bonne rentrée et bien engagé\",\"group\":\"2\"},{\"note\":69,\"numero\":15,\"nom\":\"Aubrion Du Gers\",\"comment\":\"Le cheval de classe du lot\",\"group\":\"2\"},{\"note\":68,\"numero\":11,\"nom\":\"Vulcain De Vandel\",\"comment\":\"A besoin de courir\",\"group\":\"1\"},{\"note\":67,\"numero\":18,\"nom\":\"Tornade Du Digeon\",\"comment\":\"A d'autres objectifs au trot monté\",\"group\":\"1\"},{\"note\":61,\"numero\":12,\"nom\":\"Un Diamant D'amour\",\"comment\":\"En forme + E. Raffin au sulky\",\"group\":\"1\"},{\"note\":57,\"numero\":4,\"nom\":\"Attila Du Gabereau\",\"comment\":\"Bon engagement au 1er poteau\",\"group\":\"2\"},{\"note\":56,\"numero\":6,\"nom\":\"Unero Montaval\",\"comment\":\"Idéalement engagé et pieds nus\",\"group\":\"2\"},{\"note\":56,\"numero\":5,\"nom\":\"Tiburce De Brion\",\"comment\":\"Ferré. Marge réduite\",\"group\":\"1\"},{\"note\":55,\"numero\":2,\"nom\":\"Uargane Montaval\",\"comment\":\"Spécialisée au trot monté\",\"group\":\"1\"},{\"note\":55,\"numero\":8,\"nom\":\"Vanille Du Dollar\",\"comment\":\"Essaiera de profiter des défaillances\",\"group\":\"1\"},{\"note\":54,\"numero\":1,\"nom\":\"Boeing Du Bocage\",\"comment\":\"Très bien placé en tête. Attention!\",\"group\":\"1\"},{\"note\":52,\"numero\":9,\"nom\":\"Ursa Major\",\"comment\":\"Pas simple au 2ème échelon\",\"group\":\"2\"},{\"note\":52,\"numero\":16,\"nom\":\"Seduisant Fouteau\",\"comment\":\"Reste ferré\",\"group\":\"2\"},{\"note\":49,\"numero\":3,\"nom\":\"Airport\",\"comment\":\"A besoin de courir. Impasse conseillée\",\"group\":\"0\"},{\"note\":48,\"numero\":13,\"nom\":\"Tiger Danover\",\"comment\":\"Vient de bien courir et pieds nus. Une place\",\"group\":\"1\"},{\"note\":48,\"numero\":7,\"nom\":\"Vignia La Ravelle\",\"comment\":\"Peut accrocher un lot\",\"group\":\"1\"},{\"note\":46,\"numero\":17,\"nom\":\"Best Of Jets\",\"comment\":\"Spécialiste du trot monté\",\"group\":\"1\"},{\"note\":44,\"numero\":10,\"nom\":\"Topaze Jef\",\"comment\":\"Pieds nus. Visera une place\",\"group\":\"1\"}],\"cdj\":\"R1 115 Aubrion du Gers\",\"js\":\"R1 711 Bon du Lupin\\r\\nR3 408 Chérie Girl\",\"race_title\":\"R1C1 - Grand National du Trot Paris-Turf à Saint Malo <b>13:47</b> — <b>2950m</b>\"}"
  end

  let(:expected_info) do
    {
      :race_id=> race_id,
      :date=>"2016-08-10", 
      :pronostic=>"14 - 15 - 11 - 18 - 12 - 4 - 6 - 5", 
      :race_comment=>"Sur ce parcours, il faut bien tourner à droite et être maniable", 
      :partants=>[
        {:note=>72, :numero=>14, :nom=>"Val Royal", :comment=>"Bonne rentrée et bien engagé", :group=>"2"}, 
        {:note=>69, :numero=>15, :nom=>"Aubrion Du Gers", :comment=>"Le cheval de classe du lot", :group=>"2"}, 
        {:note=>68, :numero=>11, :nom=>"Vulcain De Vandel", :comment=>"A besoin de courir", :group=>"1"}, 
        {:note=>67, :numero=>18, :nom=>"Tornade Du Digeon", :comment=>"A d'autres objectifs au trot monté", :group=>"1"}, 
        {:note=>61, :numero=>12, :nom=>"Un Diamant D'amour", :comment=>"En forme + E. Raffin au sulky", :group=>"1"}, 
        {:note=>57, :numero=>4, :nom=>"Attila Du Gabereau", :comment=>"Bon engagement au 1er poteau", :group=>"2"}, 
        {:note=>56, :numero=>6, :nom=>"Unero Montaval", :comment=>"Idéalement engagé et pieds nus", :group=>"2"}, 
        {:note=>56, :numero=>5, :nom=>"Tiburce De Brion", :comment=>"Ferré. Marge réduite", :group=>"1"}, 
        {:note=>55, :numero=>2, :nom=>"Uargane Montaval", :comment=>"Spécialisée au trot monté", :group=>"1"}, 
        {:note=>55, :numero=>8, :nom=>"Vanille Du Dollar", :comment=>"Essaiera de profiter des défaillances", :group=>"1"}, 
        {:note=>54, :numero=>1, :nom=>"Boeing Du Bocage", :comment=>"Très bien placé en tête. Attention!", :group=>"1"}, 
        {:note=>52, :numero=>9, :nom=>"Ursa Major", :comment=>"Pas simple au 2ème échelon", :group=>"2"}, 
        {:note=>52, :numero=>16, :nom=>"Seduisant Fouteau", :comment=>"Reste ferré", :group=>"2"}, 
        {:note=>49, :numero=>3, :nom=>"Airport", :comment=>"A besoin de courir. Impasse conseillée", :group=>"0"}, 
        {:note=>48, :numero=>13, :nom=>"Tiger Danover", :comment=>"Vient de bien courir et pieds nus. Une place", :group=>"1"}, 
        {:note=>48, :numero=>7, :nom=>"Vignia La Ravelle", :comment=>"Peut accrocher un lot", :group=>"1"}, 
        {:note=>46, :numero=>17, :nom=>"Best Of Jets", :comment=>"Spécialiste du trot monté", :group=>"1"}, 
        {:note=>44, :numero=>10, :nom=>"Topaze Jef", :comment=>"Pieds nus. Visera une place", :group=>"1"}
      ], 
      :cdj=>"R1 115 Aubrion du Gers", 
      :js=>"R1 711 Bon du Lupin\r\nR3 408 Chérie Girl", 
      :race_title=>"R1C1 - Grand National du Trot Paris-Turf à Saint Malo <b>13:47</b> — <b>2950m</b>"
    }  
  end

  before do
    allow(Net::HTTP).to receive(:get).and_return(fake_response)
  end

  it '#content returns expected info' do
    expect(subject.content).to eq(expected_info)
  end

  it '#race_id returns race_id from content' do
    expect(subject.race_id).to eq(race_id)
  end
end
