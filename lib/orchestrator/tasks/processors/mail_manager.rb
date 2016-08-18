module Orchestrator
  module Tasks

    module Processors
      class MailManager
        def initialize(date, link_to_pdf, name)
          @date = R18n.l(Date.parse(date), '%A %d %B')
          @name = name
          @link_to_pdf = link_to_pdf
          
          @template_id  = ENV['JSON2TEMPLATE_HTML_TEMPLATE_ID']
          @api_key      = ENV['JSON2TEMPLATE_HTML_API_KEY']
          @url          = URI("#{ENV['JSON2TEMPLATE_URL']}/api/v1")
        end

        # return html which will be used in comcenter to send email to user
        # @return [HTML]
        def content
          @result ||= http.request(request)
          @result.body
        end

        # @return [Net::HTTP]
        def http
          @http ||= Net::HTTP.new(@url.host, @url.port)
        end

        # Prepear all data (headers and body) will send via Net::HTTP
        # @return [Net::HTTP::Post]
        def request
          request = Net::HTTP::Post.new(@url)
          headers.each do |header_name, header_value|
            request[header_name] = header_value
          end
          request.body = body
          request
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
            id: @template_id,
            name: @name,
            data: {
              date: @date,
              link_to_pdf: @link_to_pdf
            }
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

