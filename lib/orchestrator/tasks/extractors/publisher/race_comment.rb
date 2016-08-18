module Orchestrator
  module Tasks
    module Extractors
      module Publisher
        # Gets information about race comment (This is used instead of deprecatig race comment from pronostic-facile js2 package).
        # @return [Array]
        class RaceComment
          def initialize(race_id)
            @race_id = race_id
          end

          # Make request to publisher api. Get information about race comment by given in constructor race_id
          # @return [Hash]
          def content
            return @content if @content
            @contet ||= Orchestrator::HTTP.new(url).get
          end

          # Returns information about race comment from publisher api
          # @return [String]
          def comment
            content[:comment]
          end

          private
            def url
              @url ||= "#{ENV['PUBLISHER_URL']}/api/tips/#{@race_id}.json"
            end
        end
      
      end
    end 
  end
end
