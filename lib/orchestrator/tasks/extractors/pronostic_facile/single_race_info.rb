module Orchestrator
  module Tasks
    module Extractors
      module PronosticFacile

        # Gets information about specific race.
        # Use to get details for JS/CDJ tips.
        # @return [Hash]
        class SingleRaceInfo
          URL = 'https://www.pronostic-facile.fr/courses'


          # @param [Integer] race_id from pronostic-facile.fr
          # @return [Orchestrator::Tasks::Extractors::PronosticFacile::SingleRaceInfo]
          def initialize(race_id)
            @race_id = race_id
          end

          # Make request to pronostic-facile.fr api
          # @return [Hash]
          def content
            return @content if @content
            @contet ||= Orchestrator::HTTP.new(url).get
          end

          private
            def url
              @url ||= "#{URL}/#{@race_id}.json"
              
            end
        end
      
      end 
    end 
  end 
end
