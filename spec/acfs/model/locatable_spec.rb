require 'spec_helper'

describe Acfs::Model::Locatable do
  let(:model) { MyUser }
  before do
    stub_request(:get, 'http://users.example.org/users/1').to_return response({id: 1, name: 'Anon', age: 12})
    stub_request(:get, 'http://users.example.org/users/1/profile').to_return response({user_id: 2, twitter_handle: '@anon'})
  end

  describe '.url' do
    it 'should return URL' do
      expect(model.url).to be == 'http://users.example.org/users'
    end

    it 'should return URL with id path part if specified' do
      expect(model.url(5)).to be == 'http://users.example.org/users/5'
    end

    context 'with attribute in path' do
      let(:model) { Profile }

      it 'should replace placeholder' do
        expect(model.url(user_id: 1)).to eq 'http://users.example.org/users/1/profile'
      end

      context 'without attributes' do
        it 'should raise an error if attribute is missing' do
          expect{ model.url }.to raise_error ArgumentError
        end
      end
    end
  end

  describe '#url' do
    context 'new resource' do
      let(:m) { model.new }

      it 'should return nil' do
        expect(m.url).to be == nil
      end

      context 'new resource with id' do
        let(:m) { model.new id: 475 }

        it 'should return resource URL' do
          expect(m.url).to be == 'http://users.example.org/users/475'
        end
      end

      context 'with attribute in path' do
        it 'should return nil' do
          expect(m.url).to be == nil
        end
      end
    end

    context 'loaded resource' do
      let(:m) { model.find 1 }
      before { m; Acfs.run }

      it "should return resource's URL" do
        expect(m.url).to be == 'http://users.example.org/users/1'
      end

      context 'with attribute in path' do
        let(:model) { Profile }
        let(:m) { model.find user_id: 1 }

        it "should return resource's URL" do
          expect(m.url).to be == 'http://users.example.org/users/2/profile'
        end
      end
    end
  end
end
