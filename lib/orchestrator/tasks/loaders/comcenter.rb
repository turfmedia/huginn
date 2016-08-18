module Orchestrator
  module Tasks
    module Loaders

      # Load information about mail to Comcenter.
      # Here is an example how to check comcenter via curl - 
      #   curl -XPOST 'http://messenger.turfmedia.com/api/channels/:channel_id/campaigns' -H "Authorization: Basic BaseAuthToken" -d'{
      #     "subject": "test",
      #     "body": "<html><body>Hello</body></html>"
      #   }'
      class Comcenter

        def initialize(email_subject, email_body)
          @email_subject = email_subject
          @email_body    = email_body
          @channel_id    = ENV['COMCENTER_CHANNEL_KEY']
          @api_key       = ENV['COMCENTER_API_KEY']
        end

        # sends information about email to comcenter
        # @return [true/false]
        def send!
          @result ||= http.request(request)

          if @result.kind_of? Net::HTTPSuccess
            true
          else
            false
          end
        end

        # @return [Net::HTTP]
        def http
          @http ||= Net::HTTP.new(uri.host, uri.port)
        end

        # Prepear all data (headers and body) will send via Net::HTTP
        # @return [Net::HTTP::Post]
        def request
          request = Net::HTTP::Post.new(uri)
          headers.each do |header_name, header_value|
            request[header_name] = header_value
          end
          request.body = body
          request
        end

        def uri
          @uri ||= URI("#{ENV['COMCENTER_URL']}/api/channels/#{ENV['COMCENTER_CHANNEL']}/campaigns")
        end

        # this is the headers which are used in request
        # @return [Hash]
        def headers
          {
            'authorization' => base_token,
            'content-type' => 'application/json',
            'accept'       => 'application/json'
          }
        end

        # this is the body which are used in request
        # @return [JSON]
        def body
          {
            subject: @email_subject,
            body: @email_body.force_encoding('UTF-8'),
          }.to_json
        end

        private
          def base_token
            "Basic #{Base64.encode64("#{@api_key}:").strip}"
          end
      end
    end
  end
end

