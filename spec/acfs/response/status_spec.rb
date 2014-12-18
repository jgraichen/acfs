require 'spec_helper'

describe Acfs::Response::Status do
  let(:status)    { 200 }
  let(:mime_type) { 'application/unknown' }
  let(:headers)   { {'Content-Type' => mime_type} }
  let(:request)   { Acfs::Request.new 'fubar' }
  let(:body)      { nil }
  let(:response)  { Acfs::Response.new request, status: status, headers: headers, body: body }

  describe '#status_code alias #code' do
    context 'when given' do
      let(:status) { 200 }

      it 'should return status code' do
        expect(response.code).to be == 200
        expect(response.status_code).to be == 200
      end
    end

    context 'when nil' do
      let(:status) { nil }

      it 'should return zero' do
        expect(response.code).to be == 0
        expect(response.status_code).to be == 0
      end
    end
  end

  describe '#success?' do
    context 'with success status code' do
      let(:status) { 200 }
      it { expect(response).to be_success }
    end

    context 'with error status code' do
      let(:status) { 500 }
      it { expect(response).to_not be_success }
    end

    context 'with zero status code' do
      let(:status) { nil }
      it { expect(response).to_not be_success }
    end
  end

  describe '#modified?' do
    context 'with success status code' do
      let(:status) { 200 }
      it { expect(response).to be_modified }
    end

    context 'with not modified status code' do
      let(:status) { 304 }
      it { expect(response).to_not be_modified }
    end

    context 'with error status code' do
      let(:status) { 500 }
      it { expect(response).to be_modified }
    end

    context 'with zero status code' do
      let(:status) { nil }
      it { expect(response).to be_modified }
    end
  end
end
