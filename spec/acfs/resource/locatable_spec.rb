# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Resource::Locatable do
  let(:model) { MyUser }

  before do
    stub_request(:get, 'http://users.example.org/users/1')
      .to_return response id: 1, name: 'Anon', age: 12
    stub_request(:get, 'http://users.example.org/users/1/profile')
      .to_return response user_id: 2, twitter_handle: '@anon'
  end

  describe '.url' do
    it 'returns URL' do
      expect(model.url).to eq 'http://users.example.org/users'
    end

    it 'returns URL with id path part if specified' do
      expect(model.url(5)).to eq 'http://users.example.org/users/5'
    end

    context 'with attribute in path' do
      let(:model) { Profile }

      it 'replaces placeholder' do
        expect(model.url(user_id: 1))
          .to eq 'http://users.example.org/users/1/profile'
      end

      context 'without attributes' do
        it 'raises an error if attribute is missing' do
          expect { model.url }.to raise_error ArgumentError
        end
      end
    end

    describe 'custom paths' do
      subject(:location) { Session.location(action: action) }

      let(:model) { Session }

      context ':list location' do
        let(:action) { :list }

        its(:raw_uri) do
          is_expected.to eq 'http://users.example.org/users/:user_id/sessions'
        end
      end

      context ':create location' do
        let(:action) { :create }

        its(:raw_uri) { is_expected.to eq 'http://users.example.org/sessions' }
      end

      context ':read location' do
        let(:action) { :read }

        its(:raw_uri) { is_expected.to eq 'http://users.example.org/sessions/:id' }
      end

      context ':update location' do
        let(:action) { :update }

        its(:raw_uri) do
          expect { location }.to raise_error ArgumentError, /update.*disabled/
        end
      end

      context ':delete location' do
        let(:action) { :delete }

        its(:raw_uri) do
          is_expected.to eq 'http://users.example.org/users/:user_id/sessions/del/:id'
        end
      end
    end
  end

  describe '#url' do
    context 'new resource' do
      let(:m) { model.new }

      it 'returns nil' do
        expect(m.url).to be_nil
      end

      context 'new resource with id' do
        let(:m) { model.new id: 475 }

        it 'returns resource URL' do
          expect(m.url).to eq 'http://users.example.org/users/475'
        end
      end

      context 'with attribute in path' do
        it 'returns nil' do
          expect(m.url).to be_nil
        end
      end
    end

    context 'loaded resource' do
      let(:m) { model.find 1 }

      before { m && Acfs.run }

      it "returns resource's URL" do
        expect(m.url).to eq 'http://users.example.org/users/1'
      end

      context 'with attribute in path' do
        let(:model) { Profile }
        let(:m) { model.find user_id: 1 }

        it "returns resource's URL" do
          expect(m.url).to eq 'http://users.example.org/users/2/profile'
        end
      end
    end
  end
end
