module Orchestrator
  module Tasks
    module Processors
      class JS2PackageManager
        
        attr_reader :date
        def initialize(date, js2_pronostic_facile_package, races_info, js2_publisher_package)
          @date = R18n.l(Date.parse(date), '%d %B %Y')
          @js2_pronostic_facile_package = js2_pronostic_facile_package
          @races_info = races_info
          @js2_publisher_package  = js2_publisher_package
        end

        # Merge data from pronostic_facile and publisher and return json for js2 package which will be used in json2pdf temmplate
        # @return [Hash]
        def json
          {
            date: date,
            race_title: race_title,
            pronostic: pronostic,
            race_comment: race_comment,
            js: js,
            cdj: cdj,
            partants: partants
          }
        end

        private

          def publisher_horse_comments_info
            @publisher_horse_comments_info ||= Orchestrator::Tasks::Extractors::Publisher::HorseComments.new(@js2_pronostic_facile_package.race_id)
          end

          def race_comment_info
            @race_comment_info ||= Orchestrator::Tasks::Extractors::Publisher::RaceComment.new(@js2_pronostic_facile_package.race_id)
          end

          def single_race_info(race_id)
            @single_race_info ||= {}
            @single_race_info[race_id] ||= Orchestrator::Tasks::Extractors::PronosticFacile::SingleRaceInfo.new(race_id)
          end

          def pronostic
            @js2_pronostic_facile_package.content[:pronostic].to_s.split("-").map(&:strip).join(" - ")
          end

          def race_title
            @js2_pronostic_facile_package.content[:race_title]
          end

          # return CDJ string - "R1 105 Horse Name" where
          #   R1 - meeting number
          #   1 - race number
          #   05 - number of the horse 
          #   Horse name - horse name
          # @return [String]
          def cdj
            return @cdj if @cdj
            tip = @js2_publisher_package.content.find {|tip| tip[:bet_type] == "Simple Gagnant" && tip[:special_type].downcase == 'cdj' }
            horse_number   = tip[:tip_bases].first
            horse_name     = find_horsename_by_horse_number_and_race_id(horse_number, tip[:race_id])
            horse_number   = "0#{horse_number}" if horse_number.to_s.length == 1
            meeting_number = find_meeting_number(tip)
            race_number    = find_race_number(tip)
            
            @cdj = "R#{meeting_number} #{race_number}#{horse_number} #{horse_name}"
          end

          # return JS string - "R1 VICHY 417 VERTIGO DU KLAU\r\nR1 VICHY 803 ALTESSE KILY", where:
          #   VICHY - meeting name
          #   4     - race number
          #   17    - horse number
          #   VERTIGO DU KLAU - horse name
          # @return [String]
          def js
            tips = @js2_publisher_package.content.select {|tip| tip[:bet_type] == "Simple Gagnant" && (tip[:special_type].downcase == 'reussite' ||  tip[:special_type].to_s == '') }
            tips.map do |tip|
              horse_number = tip[:tip_bases].first
              horse_name   = find_horsename_by_horse_number_and_race_id(horse_number, tip[:race_id])
              horse_number   = "0#{horse_number}" if horse_number.to_s.length == 1
              race_number  = find_race_number(tip)
              meeting_number = find_meeting_number(tip)
              meeting_name = find_meeting_name(tip)
              "R#{meeting_number} #{meeting_name} #{race_number}#{horse_number} #{horse_name}"
            end.join("\r\n")
          end

          def race_comment
            race_comment_info.content[:comment]
          end

          def partants
            @js2_pronostic_facile_package.content[:partants].map do |item|
              {
                numero: item[:numero],
                nom: item[:nom],
                group: item[:group],
                note: item[:note],
                comment: get_comment_for_horse(item[:numero], item[:nom]),
              }
            end
          end

          def get_comment_for_horse(number, horsename)
            horse   = publisher_horse_comments_info.content.find {|h| h[:comments] && h[:comments][:horsename] == horsename && h[:comments][:number].to_i == number.to_i}
            horse ||= {comments: {}}
            horse[:comments][:comment]
          end

          def find_horsename_by_horse_number_and_race_id(horse_number, race_id)
            horse   = single_race_info(race_id).content[:course][:partants].find {|h| h[:numero].to_i == horse_number.to_i}
            horse ||= {cheval: {}}
            horse[:cheval][:nom]
          end

          def find_meeting_number(tip)
            meeting   = @races_info.content.find{|item| item[:reunion][:id].to_i == tip[:meeting_id].to_i }
            meeting ||= {reunion: {}}
            meeting[:reunion][:numero]
          end

          def find_race_number(tip)
            meeting = @races_info.content.find{|item| item[:reunion][:id].to_i == tip[:meeting_id].to_i }
            race    = meeting[:reunion][:courses].find {|item| item[:id].to_i == tip[:race_id].to_i }
            race ||= {}
            race[:numero]
          end

          def find_meeting_name(tip)
            meeting = @races_info.content.find{|item| item[:reunion][:id] == tip[:meeting_id]}
            meeting ||= {reunion: {hippodrome: {}}}
            meeting[:reunion][:hippodrome][:nom]
          end

      end
    end 
  end
end
