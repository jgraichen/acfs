# frozen_string_literal: true

require 'spec_helper'

describe ::Acfs::Operation do
  let(:operation) { described_class.new MyUser, :read, params: {id: 0} }

  describe '#request' do
    subject { operation.request }

    its(:operation) { is_expected.to eq operation }
  end
end
