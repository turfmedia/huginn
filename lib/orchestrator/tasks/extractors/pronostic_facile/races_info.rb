module Orchestrator
  module Tasks
    module Extractors
      module PronosticFacile
        
        # Gets information about all meetings and races for given date.
        # @return [Hash]
        class RacesInfo
          URL = 'https://www.pronostic-facile.fr/courses'

          # @param [String, Date] date for which will be returned pronostic
          # @return [Orchestrator::Tasks::Extractors::PronosticFacile::RacesInfo]
          def initialize(date)
            @date = date
          end

          # Make request to pronostic-facile.fr api
          # @return [Hash]
          def content
            return @content if @content
            @contet ||= Orchestrator::HTTP.new(url).get
          end

          private
            def url
              @url ||= "#{URL}/#{@date}.json"
            end
        end
      
      end 
    end 
  end
end
