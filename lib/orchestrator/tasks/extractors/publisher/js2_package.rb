module Orchestrator
  module Tasks
    module Extractors
      module Publisher
        # Gets information about js and cdj tips (This is used instead of deprecatig js, cdj  from pronostic-facile).
        # @return [Array]
        class JS2Package
          def initialize(date)
            @date = date
          end

          # Make request to publisher api. Get information about tips for js2 package.
          # Returns information about tips for given data with bet type = Simple Gagnant.
          # @return [Array]
          def content
            return @content if @content
            @contet ||= Orchestrator::HTTP.new(url).get
          end

          private
            def url
              @url ||= "#{ENV['PUBLISHER_URL']}/api/packages/js2/#{@date}.json"
            end

        end
      
      end
    end 
  end
end
