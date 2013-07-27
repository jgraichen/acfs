require 'spec_helper'

describe Acfs::Model::Attributes::Float do
  let(:model) { Class.new.tap { |c| c.send :include, Acfs::Model }}

  describe 'cast' do
    it 'should return same object, if obj is already of float class' do
      retval = Acfs::Model::Attributes::Float.cast(1.3)
      expect(retval).to be == 1.3
    end

    it 'should return parsed object, if obj is of Fixnum class' do
      retval = Acfs::Model::Attributes::Float.cast(7)
      expect(retval).to be == 7.0
    end

    it 'should return parsed object, if obj is of String class containing a float' do
      retval = Acfs::Model::Attributes::Float.cast('1.7')
      expect(retval).to be == 1.7
    end
  end
end
