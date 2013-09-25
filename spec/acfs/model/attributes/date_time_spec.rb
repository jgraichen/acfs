require 'spec_helper'

describe Acfs::Model::Attributes::DateTime do
  let(:model) { Class.new.tap { |c| c.send :include, Acfs::Model }}
  let(:params) { {} }
  subject { Acfs::Model::Attributes::DateTime.new params }

  describe 'cast' do
    it 'should return same object, if obj is already of DateTime class' do
      date_time = DateTime.now
      retval = subject.cast(date_time)
      expect(retval).to be == date_time
    end

    it 'should return parsed object, if obj is of Time class' do
      time = Time.now
      retval = subject.cast(time)
      expect(retval).to be == DateTime.iso8601(time.iso8601)
    end

    it 'should return parsed object, if obj is of Date class' do
      date = Date.today
      retval = subject.cast(date)
      expect(retval).to be == DateTime.iso8601(date.iso8601)
    end

    it 'should return parsed object, if obj is of String class in ISO-8601 format' do
      date_time_string = DateTime.now.iso8601
      retval = subject.cast(date_time_string)
      expect(retval).to be == DateTime.iso8601(date_time_string)
    end

    it 'should raise an error if obj is of String class not in valid ISO-8601 format' do
      malformed_string = 'qwe123'
      expect {
        subject.cast(malformed_string)
      }.to raise_error ArgumentError
    end

    it 'should raise an error if obj is of wrong class (Fixnum)' do
      fixnum = 12
      expect {
        subject.cast(fixnum)
      }.to raise_error TypeError
    end

    context 'with allow_nil option' do
      let(:params) { {allow_nil: true} }

      it 'should accept empty string as nil' do
        expect(subject.cast('')).to eq nil
      end
    end
  end
end
