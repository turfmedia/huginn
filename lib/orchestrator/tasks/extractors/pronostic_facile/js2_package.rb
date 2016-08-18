module Orchestrator
  module Tasks
    module Extractors
      module PronosticFacile

        # Extract all general information for report.
        # Contains pronostic, some titles
        #
        # There are 4 deprecated fields:
        #   cdj - get from publisher api
        #   js  - get from publisher api
        #   horse comments - get from publisher api
        #   race_comment   - get from publisher api
        # @return [Orchestrator::Tasks::Extractors::PronosticFacile::JS2Package]
        class JS2Package
          URL = 'https://www.pronostic-facile.fr/quintes'

          # @param [String, Date] date for which will be returned pronostic
          # @return [Orchestrator::Tasks::Extractors::Extractors::JS2Package]
          def initialize(date)
            @date = date
          end

          # Make request to pronostic-facile.fr api
          # @return [Hash]
          def content
            return @content if @content
            @contet ||= Orchestrator::HTTP.new(url).get
          end

          # Returns information about race_id for current pronostic
          # @return [Integer]
          def race_id
            content[:race_id]
          end

          private
            def url
              @url ||= "#{URL}/json?date=#{@date}"
            end
        end
      
      end 
    end 
  end 
end
