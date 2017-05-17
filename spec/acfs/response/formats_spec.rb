require 'spec_helper'

describe Acfs::Response::Formats do
  let(:status)    { 200 }
  let(:mime_type) { 'application/unknown' }
  let(:headers)   { {'Content-Type' => mime_type} }
  let(:request)   { Acfs::Request.new 'fubar' }
  let(:body)      { nil }
  let(:response)  { Acfs::Response.new request, status: status, headers: headers, body: body }

  context 'without Content-Type header' do
    let(:headers)   { {} }

    it "should fallback on 'text/plain'" do
      expect(response.content_type).to be == Mime[:text]
    end
  end

  context 'with JSON mimetype' do
    let(:mime_type) { 'application/json' }

    describe '#content_type' do
      it 'should return Mime::JSON' do
        expect(response.content_type).to be == Mime[:json]
      end
    end

    describe '#json?' do
      it 'should return true' do
        expect(response).to be_json
      end
    end

    context 'with charset option' do
      let(:mime_type) { 'application/json; charset=utf8' }

      describe '#content_type' do
        it 'should return Mime::JSON' do
          expect(response.content_type).to be == Mime[:json]
        end
      end

      describe '#json?' do
        it 'should return true' do
          expect(response).to be_json
        end
      end
    end
  end
end
