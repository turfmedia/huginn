require 'rails_helper'

RSpec.describe Orchestrator::Tasks::Processors::AmazonUploader do # FIXME in spec_helper switched on test mode
  let(:subject) { described_class.new 'rspec', pdf_content }
  let(:pdf_content) { File.read("spec/fixtures/simple_pdf.pdf") }

  context '#upload!' do
    let(:mock_file) do
      mock_file = double
      allow(mock_file).to receive(:unlink)
      allow(mock_file).to receive(:close)
      mock_file
    end

    # let(:mock_file) do # tried to use rr gem
    #   mock_file = Tempfile.new('foo')
    #   mock(mock_file).unlink
    #   mock(mock_file).close
    #   mock_file
    # end


    it 'returns true if everything is ok' do
      expect(subject.upload!).to eq(true)
    end

    it 'closes file after upload!' do
      allow(subject).to receive(:file).and_return(mock_file)
      expect(mock_file).to receive(:close)
      subject.upload!
    end

    it 'unlink file after upload!' do
      allow(subject).to receive(:file).and_return(mock_file)
      expect(mock_file).to receive(:unlink)
      subject.upload!
    end

    # it 'unlink file after upload!' do # tried to use rr gem for this test-case
    #   mock(subject).file { mock_file }

    #   # allow(subject).to receive(:file).and_return(mock_file)
    #   # expect(mock_file).to receive(:unlink)
    #   # mock(mock_file).unlink

    #   subject.upload!
    # end

  end
  
end
