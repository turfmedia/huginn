module Orchestrator
  class HTTP
    def initialize(url)
      @uri = URI(url)
    end

    # Make get request and serialize response to symbolize Hash
    # @return [Hash]
    def get
      response = Net::HTTP.get(@uri)
      @content = JSON.parse(response, symbolize_names: true)
    end
  end
end
