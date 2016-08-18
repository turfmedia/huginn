module Orchestrator
  module Tasks
    module Pipelines
      # Pipeline for js2 package
      #
      # It uses http://www.pronostic-facile.fr/quintes/json?:date api as a core for pdf report.
      # All deprecated fields will be gotten from publisher.turfirm.com api.
      # In the last step will be pushed mail subject and mail body with treport to Comcenter
      #
      #
      #   date = 2016-08-13
      #
      #
      # Extractor part
      #
      # step #1) http://www.pronostic-facile.fr/courses/2016-08-13.json - get info about meetings and races
      #
      # step #2) http://www.pronostic-facile.fr/quintes/json?date=2016-08-13.json - get json for pdf with some deprecated data
      #
      #  As the result we will have all data except 
      #   horse comments;
      #   cdj;
      #   js;
      #   race_comment;
      #
      # step #3) http://publisher.turfmedia.com/api/horse_comments/:race_id - get horse comments
      #
      # step #4) http://publisher.turfmedia.com/api/packages/js2?date=2016-08-13 - cdj and js from js2 package in publisher api
      #
      # step #5) http://publisher.turfmedia.com/api/race_comment/:race_id - get race_comment
      #
      #
      # Transform part
      #
      # step #6) Change all deprecated fields from (2) to data from publisher api
      #
      # step #7) Generate pdf using json2template and valid json from (6)
      #
      # step #8) Save pdf to amazon and get url to this file
      #
      # step #9) Generate mail via json2template 
      #
      #
      # Load part
      #
      # step #10) send this email to ComCenter
      class Gazette

        attr_reader :json

        # @param [String, Date] date which will be used to generate tips from JS2, Q2 packages
        # @return [Orchestrator::Tasks::Pipeline::Gazette]
        def initialize(date)
          byebug
          @date = date
        end

        # run pipeline (extract data then transform data and finally - load data.)
        # @return [true/false]
        def launch!
          extract_data! and transform_data! and load_data!
        end

        private
          # get data from pronostic-facile.fr and from publisher.turfmedia.com
          # return [true/false]
          def extract_data!
            begin
              @quintes_info = Orchestrator::Tasks::Extractors::PronosticFacile::JS2Package.new(@date)
              @courses_info = Orchestrator::Tasks::Extractors::PronosticFacile::RacesInfo.new(@date)
              @js2          = Orchestrator::Tasks::Extractors::Publisher::JS2Package.new(@date)
              true
            rescue Exception => e
              puts e
              false
            end
          end

          # transform data to valid format
          # create pdf. save it to AWS S3
          # generate mail 
          # return [true/false]
          def transform_data!
            begin
              @json = Orchestrator::Tasks::Processors::JS2PackageManager.new(
                @date,
                @quintes_info,
                @courses_info,
                @js2
              ).json
              @pdf_content = Orchestrator::Tasks::Processors::PdfManager.new(@json, 'La Gazette Turf').content
              @uploader = Orchestrator::Tasks::Processors::AmazonUploader.new("La Gazette Turf #{@date}", @pdf_content)
              if @uploader.upload!
                @link_to_pdf = @uploader.public_url
              else
                raise 'something wrong when tried to upload pdf to AWS S3'
              end

              @mail_body = Orchestrator::Tasks::Processors::MailManager.new(@date, @link_to_pdf, "La Gazette Turf #{@date}").content

              true
            rescue Exception => e
              false
            end
          end

          # push mail to comcenter channel
          # return [true/false]
          def load_data!
            Orchestrator::Tasks::Loaders::Comcenter.new("Turfmedia JS2 package", @mail_body).send!
          end

      end
    end
  end
end

