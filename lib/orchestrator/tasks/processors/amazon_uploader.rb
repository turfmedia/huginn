module Orchestrator
  module Tasks
    module Processors
      class AmazonUploader

        attr_reader :region, :bucket, :access_key, :secret, :folder

        def initialize(name, file_content)
          assign_credentials!
          @file_content = file_content
          @name         = name
        end
        
        # Link to file in AWS. This is link will be used in mail.
        # @return [String]
        def public_url
          object.public_url
        end

        # Upload pdf to the AWS. 
        # @return [Boolean]
        def upload!
          begin
            object.upload_file(file.to_io, acl: 'public-read')
          rescue Exception => e
            puts e # TODO change to logging
          ensure
            file.close
            file.unlink
          end
        end

        private

          def credentials
            @credentials ||= Aws::Credentials.new(access_key, secret)
          end

          def client
            @client ||= Aws::S3::Resource.new(region: region, credentials: credentials)
          end

          def object
            @object ||= client.bucket(bucket).object(compose_object)
          end

          # Save pdf content to tempfile and then this file will be used for uploading pdf to AWS
          # @return [Tempfile]
          def file
            return @file if @file
            @file = Tempfile.new('foo')
            @file.path
            @file.write(@file_content)
            @file
          end

          # @return [String]
          def compose_object
            @compose_object ||= "#{ENV['ENVIRONMENT']}/#{folder}/#{SecureRandom.uuid.gsub!("-", "")}/#{@name}.pdf"
          end

        protected

          def assign_credentials!
            @region     = ENV['AWS_REGION']
            @bucket     = ENV['AWS_BUCKET']
            @access_key = ENV['AWS_ACCESS_KEY']
            @secret     = ENV['AWS_SECRET']
            @folder     = 'attachments'
          end

      end
    end
  end
end
