require 'rails_helper'

RSpec.describe Orchestrator::Tasks::Pipelines::Gazette do # in spec_helper switched on test mode
  let(:subject)          { described_class.new date }
  let(:date)             { '2016-08-15' }
  let(:race_id)          { 143761 }
  let(:cdj_race_id)      { 143764 } 
  let(:reussite_race_id) { 143809 } 
  let(:simple_race_id )  { 143865 } 

  #########################################
  #########################################
  #########################################
  #########################################
  #########################################
  #########################################

  ### FAKE RESPONSES ####
  let(:fake_quintes_response) do
    "{\"race_id\":#{race_id},\"date\":\"2016-08-15\",\"pronostic\":\"9 - 4 - 2 - 5 - 8 - 11 - 7 - 10\",\"race_comment\":\"Il faut s'adapter au terrain léger sur ce parcours, il faut partir partir vite et prendre le bon wagon\",\"partants\":[{\"note\":79,\"numero\":9,\"nom\":\"Babel's Book\",\"comment\":\"Va essayer de battre ses aînés\",\"group\":\"0\"},{\"note\":76,\"numero\":4,\"nom\":\"Mount Isa\",\"comment\":\"2ème de cette course l'an passé. Vise le podium\",\"group\":\"0\"},{\"note\":68,\"numero\":2,\"nom\":\"Magari\",\"comment\":\"Poids élevé à ce niveau\",\"group\":\"0\"},{\"note\":68,\"numero\":5,\"nom\":\"Bronze Swan\",\"comment\":\"Passe un test ici. A voir.\",\"group\":\"0\"},{\"note\":68,\"numero\":8,\"nom\":\"Heavensong\",\"comment\":\"Dernier échec excusable\",\"group\":\"0\"},{\"note\":65,\"numero\":11,\"nom\":\"Aprilios\",\"comment\":\"En grande forme. Vise la gagne\",\"group\":\"0\"},{\"note\":64,\"numero\":7,\"nom\":\"Iron Spirit\",\"comment\":\"Cherche visiblement sa course\",\"group\":\"0\"},{\"note\":63,\"numero\":10,\"nom\":\"Cheeky Lady\",\"comment\":\"Forme douteuse\",\"group\":\"0\"},{\"note\":62,\"numero\":14,\"nom\":\"Mads' Dream\",\"comment\":\"Débute dans les handicaps et sur la distance\",\"group\":\"0\"},{\"note\":61,\"numero\":1,\"nom\":\"Zlatan In Paris\",\"comment\":\"Mieux placé et œillères pour la 1ère fois\",\"group\":\"0\"},{\"note\":59,\"numero\":3,\"nom\":\"Indian Walk\",\"comment\":\"A toujours échoué à ce niveau\",\"group\":\"0\"},{\"note\":57,\"numero\":12,\"nom\":\"Come And Find Me\",\"comment\":\"Pas de marge à ce niveau\",\"group\":\"0\"},{\"note\":55,\"numero\":6,\"nom\":\"Olanthia\",\"comment\":\"Régulière. Peut se placer\",\"group\":\"0\"},{\"note\":55,\"numero\":15,\"nom\":\"Zanhill\",\"comment\":\"Plus confirmé sur la PSF\",\"group\":\"0\"},{\"note\":55,\"numero\":13,\"nom\":\"C D'argent\",\"comment\":\"Lot relevé ici\",\"group\":\"0\"},{\"note\":51,\"numero\":16,\"nom\":\"Family Album\",\"comment\":\"Peut causer une belle surprise\",\"group\":\"0\"}],\"cdj\":\"R1 603 New Bay\",\"js\":\"R1 504 Almanzor\\r\\nR2 706 Bali Verderie\",\"race_title\":\"R1C1 - Prix du Hong Kong Jockey Club à Deauville <b>13:47</b> — <b>1600m</b>\"}"
  end

  let(:fake_courses_response) do
    "[{\"reunion\":{\"id\":20294,\"numero\":1,\"courses\":[{\"distance\":1600,\"id\":#{race_id},\"nom\":\"Prix du Hong Kong Jockey Club\",\"numero\":1},{\"distance\":1500,\"id\":143762,\"nom\":\"Prix de Louviers-en-Auge\",\"numero\":2},{\"distance\":1000,\"id\":143763,\"nom\":\"Prix de la Vallée d'Auge\",\"numero\":3},{\"distance\":1600,\"id\":#{cdj_race_id},\"nom\":\"Prix de Lieurey\",\"numero\":4},{\"distance\":2000,\"id\":143765,\"nom\":\"Prix Guillaume d'Ornano - Haras du Logis Saint-Germain\",\"numero\":5},{\"distance\":2000,\"id\":143766,\"nom\":\"Prix Gontaut-Biron Hong Kong Jockey Club\",\"numero\":6},{\"distance\":1900,\"id\":143767,\"nom\":\"Prix de Bois Carrouges\",\"numero\":7},{\"distance\":1600,\"id\":143768,\"nom\":\"Prix de Crépon\",\"numero\":8}],\"hippodrome\":{\"nom\":\"Deauville\"}}},{\"reunion\":{\"id\":20292,\"numero\":2,\"courses\":[{\"distance\":2750,\"id\":143745,\"nom\":\"Prix Groupement des Professionnels Trot\",\"numero\":1},{\"distance\":2000,\"id\":143746,\"nom\":\"Prix Pacha du Ponthieu\",\"numero\":2},{\"distance\":2700,\"id\":143747,\"nom\":\"Prix du Centre d'Entraînement\",\"numero\":3},{\"distance\":2700,\"id\":143748,\"nom\":\"Prix du Centre Equestre de la Capelle\",\"numero\":4},{\"distance\":2700,\"id\":143749,\"nom\":\"Prix du Pôle d'Excellence Rurale\",\"numero\":5},{\"distance\":2700,\"id\":143750,\"nom\":\"Prix Ecole de Lads-Jockeys\",\"numero\":6},{\"distance\":2700,\"id\":143751,\"nom\":\"Prix Ville de la Capelle En Thiérache\",\"numero\":7},{\"distance\":2700,\"id\":143752,\"nom\":\"Prix Europole de Competitivité\",\"numero\":8}],\"hippodrome\":{\"nom\":\"La Capelle\"}}},{\"reunion\":{\"id\":20300,\"numero\":3,\"courses\":[{\"distance\":4300,\"id\":143807,\"nom\":\"Prix René Couetil\",\"numero\":1},{\"distance\":4300,\"id\":143808,\"nom\":\"Prix Hubert Nouvellet\",\"numero\":2},{\"distance\":3900,\"id\":#{reussite_race_id},\"nom\":\"Prix Grande Course de Haies de Vichy\",\"numero\":3},{\"distance\":3300,\"id\":143810,\"nom\":\"Prix d'Huriel\",\"numero\":4},{\"distance\":3300,\"id\":143811,\"nom\":\"Prix de Randan\",\"numero\":5},{\"distance\":3500,\"id\":143812,\"nom\":\"Prix Jean-Dominique Alquie\",\"numero\":6},{\"distance\":3500,\"id\":143813,\"nom\":\"Prix Maurice de Dampierre\",\"numero\":7}],\"hippodrome\":{\"nom\":\"Vichy\"}}},{\"reunion\":{\"id\":20293,\"numero\":4,\"courses\":[{\"distance\":2875,\"id\":143753,\"nom\":\"Grand Prix du Groupe Romet\",\"numero\":1},{\"distance\":2875,\"id\":143754,\"nom\":\"Prix Yves Peslier\",\"numero\":2},{\"distance\":2875,\"id\":143755,\"nom\":\"Prix Kazire de Guez\",\"numero\":3},{\"distance\":2875,\"id\":143756,\"nom\":\"Prix LBC Assurances\",\"numero\":4},{\"distance\":2875,\"id\":143757,\"nom\":\"Prix Claude Chaumond\",\"numero\":5},{\"distance\":2875,\"id\":143758,\"nom\":\"Prix des Bénévoles\",\"numero\":6},{\"distance\":2875,\"id\":143759,\"nom\":\"Prix Louis Chrétien\",\"numero\":7},{\"distance\":2875,\"id\":143760,\"nom\":\"Prix de la CCI de la Mayenne\",\"numero\":8}],\"hippodrome\":{\"nom\":\"Meslay Du Maine\"}}},{\"reunion\":{\"id\":20303,\"numero\":5,\"courses\":[{\"distance\":2400,\"id\":143822,\"nom\":\"Copa de Oro de San Sebastian\",\"numero\":3}],\"hippodrome\":{\"nom\":\"San Sebastian\"}}},{\"reunion\":{\"id\":20311,\"numero\":6,\"courses\":[{\"distance\":2150,\"id\":143877,\"nom\":\"Prix Jean Leroy\",\"numero\":1},{\"distance\":2950,\"id\":143878,\"nom\":\"Prix Bellino II\",\"numero\":2},{\"distance\":2950,\"id\":143879,\"nom\":\"Prix Ourasi (Gr A)\",\"numero\":3},{\"distance\":2950,\"id\":143880,\"nom\":\"Prix Ourasi (Gr B)\",\"numero\":4},{\"distance\":2950,\"id\":143881,\"nom\":\"Prix Yvonnick Et Jean-Yves Bodin\",\"numero\":5},{\"distance\":2950,\"id\":143882,\"nom\":\"Prix Philippe Baudron\",\"numero\":6},{\"distance\":2950,\"id\":143883,\"nom\":\"Prix Henri Levesque\",\"numero\":7},{\"distance\":2950,\"id\":143884,\"nom\":\"Prix de Saint-Lunaire\",\"numero\":8},{\"distance\":2950,\"id\":143885,\"nom\":\"Prix des Bénévoles\",\"numero\":9}],\"hippodrome\":{\"nom\":\"Saint Malo\"}}},{\"reunion\":{\"id\":20309,\"numero\":7,\"courses\":[{\"distance\":2550,\"id\":143863,\"nom\":\"Prix de la Ville de Bracquemont\",\"numero\":1},{\"distance\":2550,\"id\":143864,\"nom\":\"Prix Philippe Siour\",\"numero\":2},{\"distance\":2550,\"id\":#{simple_race_id},\"nom\":\"Prix de la Société des Courses des Andelys\",\"numero\":3},{\"distance\":2550,\"id\":143866,\"nom\":\"Prix de la Ville de Luneray\",\"numero\":4},{\"distance\":2550,\"id\":143867,\"nom\":\"Prix de la Ville de Dieppe\",\"numero\":5},{\"distance\":2550,\"id\":143868,\"nom\":\"Prix Abraham Duquesne\",\"numero\":6},{\"distance\":2550,\"id\":143869,\"nom\":\"Prix Etienne Rimbert\",\"numero\":7},{\"distance\":2550,\"id\":143870,\"nom\":\"Prix Camille Pissaro\",\"numero\":8}],\"hippodrome\":{\"nom\":\"Dieppe\"}}},{\"reunion\":{\"id\":20310,\"numero\":8,\"courses\":[{\"distance\":2925,\"id\":143871,\"nom\":\"Prix du Vieux Nice\",\"numero\":1},{\"distance\":2925,\"id\":143872,\"nom\":\"Prix du Mont Agel\",\"numero\":2},{\"distance\":2925,\"id\":143873,\"nom\":\"Prix de la Corniche Fleurie\",\"numero\":3},{\"distance\":2700,\"id\":143874,\"nom\":\"Prix des Vautours\",\"numero\":4},{\"distance\":2925,\"id\":143875,\"nom\":\"Prix du Mont Doré\",\"numero\":5},{\"distance\":2925,\"id\":143876,\"nom\":\"Prix des Corbeaux\",\"numero\":6}],\"hippodrome\":{\"nom\":\"Cagnes Sur Mer\"}}}]"
  end

  let(:fake_horse_comments_response) do
     "[{\"id\":57,\"race_id\":#{race_id},\"comments\":{\"comment\":\"will be in price\",\"horsename\":\"Olanthia\",\"number\":\"6\"},\"created_at\":\"2016-08-15T04:28:30.363Z\",\"updated_at\":\"2016-08-15T04:28:30.363Z\"},{\"id\":58,\"race_id\":143761,\"comments\":{\"comment\":\"bad horse\",\"horsename\":\"Iron Spirit\",\"number\":\"7\"},\"created_at\":\"2016-08-15T04:28:35.572Z\",\"updated_at\":\"2016-08-15T04:28:35.572Z\"},{\"id\":59,\"race_id\":143761,\"comments\":{\"comment\":\"last win was in 2014\",\"horsename\":\"Heavensong\",\"number\":\"8\"},\"created_at\":\"2016-08-15T04:28:49.458Z\",\"updated_at\":\"2016-08-15T04:28:49.458Z\"},{\"id\":60,\"race_id\":143761,\"comments\":{\"comment\":\"ill whole last month\",\"horsename\":\"Babel's Book\",\"number\":\"9\"},\"created_at\":\"2016-08-15T04:29:19.848Z\",\"updated_at\":\"2016-08-15T04:29:33.227Z\"},{\"id\":61,\"race_id\":143761,\"comments\":{\"comment\":\"will be in price\",\"horsename\":\"Cheeky Lady\",\"number\":\"10\"},\"created_at\":\"2016-08-15T04:29:40.730Z\",\"updated_at\":\"2016-08-15T04:29:40.730Z\"},{\"id\":62,\"race_id\":143761,\"comments\":{\"comment\":\"will be in 5th\",\"horsename\":\"Aprilios\",\"number\":\"11\"},\"created_at\":\"2016-08-15T04:29:52.199Z\",\"updated_at\":\"2016-08-15T04:30:06.999Z\"},{\"id\":64,\"race_id\":143761,\"comments\":{\"comment\":\"will be last horse\",\"horsename\":\"Family Album\",\"number\":\"16\"},\"created_at\":\"2016-08-15T04:30:18.602Z\",\"updated_at\":\"2016-08-15T04:30:18.602Z\"},{\"id\":63,\"race_id\":143761,\"comments\":{\"comment\":\"very bad jokey\",\"horsename\":\"Come And Find Me\",\"number\":\"12\"},\"created_at\":\"2016-08-15T04:30:13.329Z\",\"updated_at\":\"2016-08-15T04:30:30.434Z\"},{\"id\":65,\"race_id\":143761,\"comments\":{\"comment\":\"a dark horse\",\"horsename\":\"C D'argent\",\"number\":\"13\"},\"created_at\":\"2016-08-15T04:30:56.732Z\",\"updated_at\":\"2016-08-15T04:31:05.511Z\"},{\"id\":66,\"race_id\":143761,\"comments\":{\"comment\":\"a dark horse as well\",\"horsename\":\"Mads' Dream\",\"number\":\"14\"},\"created_at\":\"2016-08-15T04:31:09.287Z\",\"updated_at\":\"2016-08-15T04:31:09.287Z\"},{\"id\":67,\"race_id\":143761,\"comments\":{\"comment\":\"has a good shape\",\"horsename\":\"Zanhill\",\"number\":\"15\"},\"created_at\":\"2016-08-15T04:31:22.047Z\",\"updated_at\":\"2016-08-15T04:31:22.047Z\"},{\"id\":52,\"race_id\":143761,\"comments\":{\"comment\":\"Has a bad shape\",\"horsename\":\"Zlatan In Paris\",\"number\":\"1\"},\"created_at\":\"2016-08-15T04:26:50.915Z\",\"updated_at\":\"2016-08-15T04:26:50.915Z\"},{\"id\":53,\"race_id\":143761,\"comments\":{\"comment\":\"not bad\",\"horsename\":\"Magari\",\"number\":\"2\"},\"created_at\":\"2016-08-15T04:26:54.268Z\",\"updated_at\":\"2016-08-15T04:27:00.076Z\"},{\"id\":54,\"race_id\":143761,\"comments\":{\"comment\":\"favorite of this race\",\"horsename\":\"Indian Walk\",\"number\":\"3\"},\"created_at\":\"2016-08-15T04:27:14.380Z\",\"updated_at\":\"2016-08-15T04:27:25.697Z\"},{\"id\":55,\"race_id\":143761,\"comments\":{\"comment\":\"debut race\",\"horsename\":\"Mount Isa\",\"number\":\"4\"},\"created_at\":\"2016-08-15T04:27:43.437Z\",\"updated_at\":\"2016-08-15T04:27:57.252Z\"},{\"id\":56,\"race_id\":143761,\"comments\":{\"comment\":\"new jockey\",\"horsename\":\"Bronze Swan\",\"number\":\"5\"},\"created_at\":\"2016-08-15T04:28:04.905Z\",\"updated_at\":\"2016-08-15T04:28:14.540Z\"}]"
  end

  let(:fake_js2_package_response) do
    "[{\"id\":74,\"race_id\":#{cdj_race_id},\"tip_bases\":[\"2\"],\"tip_complements\":[],\"bet_type\":\"Simple Gagnant\",\"special_type\":\"CDJ\",\"comment\":\"1\",\"created_at\":\"2016-08-15T04:32:12.023Z\",\"updated_at\":\"2016-08-15T04:32:12.023Z\",\"race_rc\":\"R1C4\",\"tip_set_id\":26,\"race_title\":\"Prix de Lieurey\",\"meeting_id\":20294},{\"id\":75,\"race_id\":#{reussite_race_id},\"tip_bases\":[\"5\"],\"tip_complements\":[],\"bet_type\":\"Simple Gagnant\",\"special_type\":\"Reussite\",\"comment\":\"2\",\"created_at\":\"2016-08-15T04:32:21.994Z\",\"updated_at\":\"2016-08-15T04:32:21.994Z\",\"race_rc\":\"R3C3\",\"tip_set_id\":26,\"race_title\":\"Prix Grande Course de Haies de Vichy\",\"meeting_id\":20300},{\"id\":76,\"race_id\":#{simple_race_id},\"tip_bases\":[\"8\"],\"tip_complements\":[],\"bet_type\":\"Simple Gagnant\",\"special_type\":\"\",\"comment\":\"3\",\"created_at\":\"2016-08-15T04:32:30.285Z\",\"updated_at\":\"2016-08-15T04:32:30.285Z\",\"race_rc\":\"R7C3\",\"tip_set_id\":26,\"race_title\":\"Prix de la Société des Courses des Andelys\",\"meeting_id\":20309}]"
  end

  let(:fake_race_comment_response) do
    "{\"id\":73,\"race_id\":#{race_id},\"tip_bases\":[\"3\",\"6\",\"10\"],\"tip_complements\":[],\"bet_type\":\"Couplé Ordre\",\"special_type\":\"Ring A\",\"comment\":\"Very interesting race\",\"created_at\":\"2016-08-15T04:31:41.777Z\",\"updated_at\":\"2016-08-15T04:31:41.777Z\",\"race_rc\":\"R1C1\",\"tip_set_id\":26,\"race_title\":\"Prix du Hong Kong Jockey Club\",\"meeting_id\":20294}"
  end

  let(:fake_course_response_for_race_id) do
    "{\"course\":{\"distance\":1600,\"heure\":\"2000-01-01T13:47:00+01:00\",\"nom\":\"Prix du Hong Kong Jockey Club\",\"numero\":1,\"partants\":[{\"numero\":15,\"cheval\":{\"nom\":\"Zanhill\"}},{\"numero\":12,\"cheval\":{\"nom\":\"Come And Find Me\"}},{\"numero\":11,\"cheval\":{\"nom\":\"Aprilios\"}},{\"numero\":9,\"cheval\":{\"nom\":\"Babel's Book\"}},{\"numero\":8,\"cheval\":{\"nom\":\"Heavensong\"}},{\"numero\":7,\"cheval\":{\"nom\":\"Iron Spirit\"}},{\"numero\":6,\"cheval\":{\"nom\":\"Olanthia\"}},{\"numero\":5,\"cheval\":{\"nom\":\"Bronze Swan\"}},{\"numero\":3,\"cheval\":{\"nom\":\"Indian Walk\"}},{\"numero\":14,\"cheval\":{\"nom\":\"Mads' Dream\"}},{\"numero\":4,\"cheval\":{\"nom\":\"Mount Isa\"}},{\"numero\":1,\"cheval\":{\"nom\":\"Zlatan In Paris\"}},{\"numero\":2,\"cheval\":{\"nom\":\"Magari\"}},{\"numero\":10,\"cheval\":{\"nom\":\"Cheeky Lady\"}},{\"numero\":13,\"cheval\":{\"nom\":\"C D'argent\"}},{\"numero\":16,\"cheval\":{\"nom\":\"Family Album\"}}],\"reunion\":{\"numero\":1}}}"
  end
  
  let(:fake_course_response_for_cdj_race_id) do
    "{\"course\":{\"distance\":1600,\"heure\":\"2000-01-01T15:25:00+01:00\",\"nom\":\"Prix de Lieurey\",\"numero\":4,\"partants\":[{\"numero\":15,\"cheval\":{\"nom\":\"Aim To Please\"}},{\"numero\":14,\"cheval\":{\"nom\":\"Trixia\"}},{\"numero\":12,\"cheval\":{\"nom\":\"Kenriya\"}},{\"numero\":11,\"cheval\":{\"nom\":\"Chartreuse\"}},{\"numero\":8,\"cheval\":{\"nom\":\"Come Alive\"}},{\"numero\":7,\"cheval\":{\"nom\":\"Mise En Rose\"}},{\"numero\":6,\"cheval\":{\"nom\":\"Silver Step\"}},{\"numero\":5,\"cheval\":{\"nom\":\"Rosay\"}},{\"numero\":4,\"cheval\":{\"nom\":\"Light Up Our World\"}},{\"numero\":3,\"cheval\":{\"nom\":\"Gherdaiya\"}},{\"numero\":2,\"cheval\":{\"nom\":\"Midweek\"}},{\"numero\":1,\"cheval\":{\"nom\":\"Antonoe\"}},{\"numero\":13,\"cheval\":{\"nom\":\"Surava\"}},{\"numero\":10,\"cheval\":{\"nom\":\"Magnanime\"}},{\"numero\":9,\"cheval\":{\"nom\":\"Switching\"}}],\"reunion\":{\"numero\":1}}}"
  end
  
  let(:fake_course_response_for_reussite_race_id) do
    "{\"course\":{\"distance\":3900,\"heure\":\"2000-01-01T18:10:00+01:00\",\"nom\":\"Prix Grande Course de Haies de Vichy\",\"numero\":3,\"partants\":[{\"numero\":6,\"cheval\":{\"nom\":\"Blushing Bere\"}},{\"numero\":3,\"cheval\":{\"nom\":\"Kemaliste\"}},{\"numero\":1,\"cheval\":{\"nom\":\"Attalco\"}},{\"numero\":5,\"cheval\":{\"nom\":\"Amour'ela\"}},{\"numero\":8,\"cheval\":{\"nom\":\"Vinga\"}},{\"numero\":2,\"cheval\":{\"nom\":\"Biway\"}},{\"numero\":9,\"cheval\":{\"nom\":\"Lavalloise\"}},{\"numero\":10,\"cheval\":{\"nom\":\"Petite Dune\"}},{\"numero\":7,\"cheval\":{\"nom\":\"Paris Clermont\"}},{\"numero\":4,\"cheval\":{\"nom\":\"Urka De Thaix\"}}],\"reunion\":{\"numero\":3}}}"
  end

  let(:fake_course_response_for_simple_race_id) do
    "{\"course\":{\"distance\":2550,\"heure\":\"2000-01-01T15:30:00+01:00\",\"nom\":\"Prix de la Société des Courses des Andelys\",\"numero\":3,\"partants\":[{\"numero\":13,\"cheval\":{\"nom\":\"Cyclopede\"}},{\"numero\":12,\"cheval\":{\"nom\":\"Carat Des Corvees\"}},{\"numero\":11,\"cheval\":{\"nom\":\"Castelnuovo\"}},{\"numero\":10,\"cheval\":{\"nom\":\"Crystal Sky\"}},{\"numero\":9,\"cheval\":{\"nom\":\"Cash De Calendes\"}},{\"numero\":8,\"cheval\":{\"nom\":\"Comte De Monteil\"}},{\"numero\":7,\"cheval\":{\"nom\":\"Cyberespace\"}},{\"numero\":6,\"cheval\":{\"nom\":\"Cooper Gibus\"}},{\"numero\":5,\"cheval\":{\"nom\":\"Caviar Du Gade\"}},{\"numero\":4,\"cheval\":{\"nom\":\"Cosmos Ringeat\"}},{\"numero\":3,\"cheval\":{\"nom\":\"Capital Risk\"}},{\"numero\":2,\"cheval\":{\"nom\":\"Cygnus Doti\"}},{\"numero\":1,\"cheval\":{\"nom\":\"Caid Du Relais\"}}],\"reunion\":{\"numero\":7}}}"
  end

  ### EXPECTED DATA

  let(:expected_pronostic_facile_quintes_content) do
    JSON.parse(fake_quintes_response, symbolize_names: true)
  end

  let(:expected_pronostic_facile_single_course_content) do
    {
      :course=>{
        :heure=>"2000-01-01T13:47:00+00:00", 
        :nom=>"Prix du Pays Niçois", 
        :numero=>3, 
        :distance=>2100, 
        :partants=>[
          {:numero=>14, :cheval=>{:nom=>"Val Royal"}},
          {:numero=>15, :cheval=>{:nom=>"Aubrion Du Gers"}},
          {:numero=>11, :cheval=>{:nom=>"Vulcain De Vandel"}},
          {:numero=>18, :cheval=>{:nom=>"Tornade Du Digeon"}},
          {:numero=>12, :cheval=>{:nom=>"Un Diamant D'amour"}},
          {:numero=>4, :cheval=>{:nom=>"Attila Du Gabereau"}},
          {:numero=>6, :cheval=>{:nom=>"Unero Montaval"}},
          {:numero=>5, :cheval=>{:nom=>"Tiburce De Brion"}},
          {:numero=>2, :cheval=>{:nom=>"Uargane Montaval"}},
          {:numero=>8, :cheval=>{:nom=>"Vanille Du Dollar"}},
          {:numero=>1, :cheval=>{:nom=>"Boeing Du Bocage"}},
          {:numero=>9, :cheval=>{:nom=>"Ursa Major"}},
          {:numero=>16, :cheval=>{:nom=>"Seduisant Fouteau"}},
          {:numero=>3, :cheval=>{:nom=>"Airport"}},
          {:numero=>13, :cheval=>{:nom=>"Tiger Danover"}},
          {:numero=>7, :cheval=>{:nom=>"Vignia La Ravelle"}},
          {:numero=>17, :cheval=>{:nom=>"Best Of Jets"}},
          {:numero=>10, :cheval=>{:nom=>"Topaze Jef"}}
        ], 
        :reunion=>{:numero=>1}
      }
    }
  end

  let(:expected_publisher_horse_comments) do
    JSON.parse(fake_horse_comments_response, symbolize_names: true)
  end

  let(:expected_publisher_js2_package_tips) do
    JSON.parse(fake_js2_package_response, symbolize_names: true)
  end

  let(:expected_pronostic_facile_courses_content) do
    JSON.parse(fake_courses_response, symbolize_names: true)
  end

  let(:expected_race_comment_info) do
    JSON.parse(fake_race_comment_response, symbolize_names: true)
  end

  let(:expected_transformed_json) do
     {
        :date=>"15 août 2016", 
        :race_title=>"R1C1 - Prix du Hong Kong Jockey Club à Deauville <b>13:47</b> — <b>1600m</b>", 
        :pronostic=>"9 - 4 - 2 - 5 - 8 - 11 - 7 - 10", 
        :race_comment=>"Very interesting race", 
        :js=>"R3 Vichy 305 Amour'ela\r\nR7 Dieppe 308 Comte De Monteil", 
        :cdj=>"R1 402 Midweek", 
        :partants=>[
          {:numero=>9, :nom=>"Babel's Book", :group=>"0", :note=>79, :comment=>"ill whole last month"}, 
          {:numero=>4, :nom=>"Mount Isa", :group=>"0", :note=>76, :comment=>"debut race"}, 
          {:numero=>2, :nom=>"Magari", :group=>"0", :note=>68, :comment=>"not bad"}, 
          {:numero=>5, :nom=>"Bronze Swan", :group=>"0", :note=>68, :comment=>"new jockey"}, 
          {:numero=>8, :nom=>"Heavensong", :group=>"0", :note=>68, :comment=>"last win was in 2014"}, 
          {:numero=>11, :nom=>"Aprilios", :group=>"0", :note=>65, :comment=>"will be in 5th"}, 
          {:numero=>7, :nom=>"Iron Spirit", :group=>"0", :note=>64, :comment=>"bad horse"}, 
          {:numero=>10, :nom=>"Cheeky Lady", :group=>"0", :note=>63, :comment=>"will be in price"}, 
          {:numero=>14, :nom=>"Mads' Dream", :group=>"0", :note=>62, :comment=>"a dark horse as well"}, 
          {:numero=>1, :nom=>"Zlatan In Paris", :group=>"0", :note=>61, :comment=>"Has a bad shape"}, 
          {:numero=>3, :nom=>"Indian Walk", :group=>"0", :note=>59, :comment=>"favorite of this race"}, 
          {:numero=>12, :nom=>"Come And Find Me", :group=>"0", :note=>57, :comment=>"very bad jokey"}, 
          {:numero=>6, :nom=>"Olanthia", :group=>"0", :note=>55, :comment=>"will be in price"}, 
          {:numero=>15, :nom=>"Zanhill", :group=>"0", :note=>55, :comment=>"has a good shape"}, 
          {:numero=>13, :nom=>"C D'argent", :group=>"0", :note=>55, :comment=>"a dark horse"}, 
          {:numero=>16, :nom=>"Family Album", :group=>"0", :note=>51, :comment=>"will be last horse"}
        ]
    }
  end

  let(:expected_pdf_content) { File.read("spec/fixtures/simple_pdf.pdf") }

  #########################################
  #########################################
  #########################################
  #########################################
  #########################################
  #########################################




  before do
    course_uri_for_race_id = URI("#{Orchestrator::Tasks::Extractors::PronosticFacile::SingleRaceInfo::URL}/#{race_id}.json")
    allow(Net::HTTP).to receive(:get).with(course_uri_for_race_id).and_return(fake_course_response_for_race_id)
    course_uri_for_cdj_race_id = URI("#{Orchestrator::Tasks::Extractors::PronosticFacile::SingleRaceInfo::URL}/#{cdj_race_id}.json")
    allow(Net::HTTP).to receive(:get).with(course_uri_for_cdj_race_id).and_return(fake_course_response_for_cdj_race_id)
    course_uri_for_reussite_race_id = URI("#{Orchestrator::Tasks::Extractors::PronosticFacile::SingleRaceInfo::URL}/#{reussite_race_id}.json")
    allow(Net::HTTP).to receive(:get).with(course_uri_for_reussite_race_id).and_return(fake_course_response_for_reussite_race_id)
    course_uri_for_simple_race_id = URI("#{Orchestrator::Tasks::Extractors::PronosticFacile::SingleRaceInfo::URL}/#{simple_race_id}.json")
    allow(Net::HTTP).to receive(:get).with(course_uri_for_simple_race_id).and_return(fake_course_response_for_simple_race_id)
    


    courses_uri  = URI("#{Orchestrator::Tasks::Extractors::PronosticFacile::RacesInfo::URL}/#{date}.json")
    quintes_uri = URI("#{Orchestrator::Tasks::Extractors::PronosticFacile::JS2Package::URL}/json?date=#{date}")
    horse_comments_uri = URI("#{ENV['PUBLISHER_URL']}/api/horse_comments/#{race_id}.json")
    js2_package_uri    = URI("#{ENV['PUBLISHER_URL']}/api/packages/js2/#{date}.json")
    race_comment_uri   = URI("#{ENV['PUBLISHER_URL']}/api/tips/#{race_id}.json")

    allow(Net::HTTP).to receive(:get).with(courses_uri).and_return(fake_courses_response)
    allow(Net::HTTP).to receive(:get).with(quintes_uri).and_return(fake_quintes_response)
    allow(Net::HTTP).to receive(:get).with(horse_comments_uri).and_return(fake_horse_comments_response)
    allow(Net::HTTP).to receive(:get).with(js2_package_uri).and_return(fake_js2_package_response)
    allow(Net::HTTP).to receive(:get).with(race_comment_uri).and_return(fake_race_comment_response)

    pdf_uploader_uri = URI("#{ENV['JSON2TEMPLATE_URL']}/api/v1")
    allow(Net::HTTP).to receive(:new).with(pdf_uploader_uri.host, pdf_uploader_uri.port) do
      mock = double
      allow(mock).to receive(:request) do expected_pdf_content
        mock_response = double
        allow(mock_response).to receive(:body).and_return(expected_pdf_content)
        mock_response
      end
      mock
    end

    expect(Orchestrator::Tasks::Extractors::PronosticFacile::SingleRaceInfo.new(race_id).content).to eq(JSON.parse(fake_course_response_for_race_id, symbolize_names: true))
    expect(Orchestrator::Tasks::Extractors::PronosticFacile::SingleRaceInfo.new(cdj_race_id).content).to eq(JSON.parse(fake_course_response_for_cdj_race_id, symbolize_names: true))
    expect(Orchestrator::Tasks::Extractors::PronosticFacile::SingleRaceInfo.new(reussite_race_id).content).to eq(JSON.parse(fake_course_response_for_reussite_race_id, symbolize_names: true))
    expect(Orchestrator::Tasks::Extractors::PronosticFacile::SingleRaceInfo.new(simple_race_id).content).to eq(JSON.parse(fake_course_response_for_simple_race_id, symbolize_names: true))

    expect(Orchestrator::Tasks::Extractors::PronosticFacile::RacesInfo.new(date).content).to eq(JSON.parse(fake_courses_response, symbolize_names: true))
    expect(Orchestrator::Tasks::Extractors::PronosticFacile::JS2Package.new(date).content).to eq(JSON.parse(fake_quintes_response, symbolize_names: true))
    expect(Orchestrator::Tasks::Extractors::Publisher::HorseComments.new(race_id).content).to eq(JSON.parse(fake_horse_comments_response, symbolize_names: true))
    expect(Orchestrator::Tasks::Extractors::Publisher::JS2Package.new(date).content).to eq(JSON.parse(fake_js2_package_response, symbolize_names: true))
    expect(Orchestrator::Tasks::Extractors::Publisher::RaceComment.new(race_id).content).to eq(JSON.parse(fake_race_comment_response, symbolize_names: true))

    expect(Net::HTTP.new(pdf_uploader_uri.host, pdf_uploader_uri.port).request.body).to eq(expected_pdf_content) #check that mock works fine
  end

  context '#launch!' do
    before do
      allow(subject).to receive(:extract_data!).and_return(true)
      allow(subject).to receive(:transform_data!).and_return(true)
      allow(subject).to receive(:load_data!).and_return(true)
    end

    it 'runs extract_data!' do
      expect(subject).to receive(:extract_data!).and_return(true)
      subject.launch!
    end

    it 'runs transform_data!' do
      expect(subject).to receive(:transform_data!).and_return(true)
      subject.launch!
    end

    it 'runs load_data!' do
      expect(subject).to receive(:load_data!).and_return(true)
      subject.launch!
    end
  end

  context '#extract_data!' do
    it 'returns true' do
      expect(subject.send(:extract_data!)).to eq(true)
    end

    it 'saves instance of quintes info to quintes_info variable' do
      subject.send(:extract_data!)
      expect(subject.instance_variable_get(:@quintes_info).content).to eq(expected_pronostic_facile_quintes_content)
    end

    it 'saves instance of courses information to courses_info variable' do
      subject.send(:extract_data!)
      expect(subject.instance_variable_get(:@courses_info).content).to eq(expected_pronostic_facile_courses_content)
    end

    it 'saves instance of js2 package to js2 variable' do
      subject.send(:extract_data!)
      expect(subject.instance_variable_get(:@js2).content).to eq(expected_publisher_js2_package_tips)
    end
  end

  context '#transform_data!' do
    before do
      subject.send(:extract_data!)
    end

    it 'returns true' do
      expect(subject.send(:transform_data!)).to eq(true)
    end

    it 'saves updated json to json variable' do
      subject.send(:transform_data!)
      expect(subject.instance_variable_get(:@json)).to eq(expected_transformed_json)
    end

    it 'saves pdf_content to pdf_content variable' do
      subject.send(:transform_data!)
      expect(subject.instance_variable_get(:@pdf_content)).to eq(expected_pdf_content)
    end

    it 'saves url_to_aws_pdf_file to link_to_pdf variable' do
      allow(SecureRandom).to receive(:uuid).and_return("a-b-c-d")
      subject.send(:transform_data!)
      expect(subject.instance_variable_get(:@link_to_pdf)).to eq("https://s3.#{ENV['AWS_REGION']}.amazonaws.com/#{ENV['AWS_BUCKET']}/test/attachments/abcd/La%20Gazette%20Turf%20#{date}.pdf")
    end

  end

end
