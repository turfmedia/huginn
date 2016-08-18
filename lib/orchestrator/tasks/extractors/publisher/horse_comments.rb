module Orchestrator
  module Tasks
    module Extractors
      module Publisher
        # Gets information about horse comments (This is used instead of deprecatig horse comments from pronostic-facile).
        # @return [Array]
        class HorseComments
          def initialize(race_id)
            @race_id = race_id
          end

          # Make request to publisher api. Get information about horse comments by given race_id
          # @return [Array]
          def content
            return @content if @content
            @contet ||= Orchestrator::HTTP.new(url).get
          end

          private
            def url
              @url ||= "#{ENV['PUBLISHER_URL']}/api/horse_comments/#{@race_id}.json"
            end
        end
      
      end
    end 
  end 
end
