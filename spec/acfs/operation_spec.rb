# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Operation do
  let(:operation) { described_class.new MyUser, :read, params: {id: 0} }

  describe '#request' do
    subject(:op_request) { operation.request }

    it { expect(op_request.operation).to eq operation }
  end
end
