require 'spec_helper'

describe Acfs::Model::Attributes::UUID do
  let(:model) { Class.new.tap { |c| c.send :include, Acfs::Model }}
  let(:params) { {} }
  let(:instance) { described_class.new params }
  subject { instance }

  describe '#cast_type' do
    let(:param) { '450b7a40-94ad-11e3-baa8-0800200c9a66' }
    let(:action) { instance.cast param }
    subject { action }

    context 'with String as param' do
      context 'with valid UUID' do
        let(:param) { '450b7a40-94ad-11e3-baa8-0800200c9a66' }
        it { should be_a String }
        it { should eq param }
      end

      context 'with invalid UUID' do
        subject { -> { action } }

        context 'with random non-empty string' do
          let(:param) { 'invalid string' }
          it { should raise_error }
        end

        context 'with string in UUID format but containing invalid characters' do
          let(:param) { 'xxxxxxxx-yyyy-11e3-baa8-0800200c9a66' }
          it { should raise_error }
        end

        context 'with empty string' do
          let(:param) { '' }

          context 'with allow_nil option' do
            let(:params) { {allow_nil: true} }
            subject { action }
            it { should eq nil }
          end

          context 'without allow_nil option' do
            let(:params) { {allow_nil: false} }
            it { should raise_error }
          end
        end
      end
    end

    context 'with non-String as param' do
      subject { -> { action } }

      invalid_params = { fixnum: 1, float: 3.2, symbol: :invalid, boolean: true }
      invalid_params.each do |klass, incorrect_param|
        context "with #{klass.to_s} as param" do
          let(:param) { incorrect_param }
          it { should raise_error }
        end
      end
    end
  end
end
