require 'spec_helper'

describe Acfs::Resource::Attributes::Symbol do
  let(:model) { Class.new Acfs::Resource }
  subject { described_class.new }

  describe 'cast' do
    it 'should cast a string to a symbol' do
      expect(subject.cast('symbol')).to eq :symbol
    end

    it 'returns a symbol if fed with a symbol' do
      expect(subject.cast(:symbol)).to eq :symbol
    end
  end
end
