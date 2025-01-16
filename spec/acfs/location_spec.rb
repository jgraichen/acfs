# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Location do
  let(:location) { described_class.new(uri, args) }
  let(:uri)      { 'http://localhost/users/:id' }
  let(:args)     { {'id' => 4} }

  describe '#str' do
    subject(:str) { location.str }

    it 'replaces variables with values' do
      expect(str).to eq 'http://localhost/users/4'
    end

    context 'with special characters' do
      let(:args) { {'id' => '4 [@(\/!^$'} }

      it 'escapes special characters' do
        expect(str).to eq 'http://localhost/users/4+%5B%40%28%5C%2F%21%5E%24'
      end
    end
  end
end
