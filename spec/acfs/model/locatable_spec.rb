require 'spec_helper'

describe Acfs::Model::Locatable do
  let(:model) { MyUser }
  before do
    stub_request(:get, "http://users.example.org/users/1").to_return response({ id: 1, name: "Anon", age: 12 })
  end

  describe '.url' do
    it 'should return URL' do
      expect(model.url).to be == 'http://users.example.org/users'
    end

    it 'should return URL with id path part if specified' do
      expect(model.url(5)).to be == 'http://users.example.org/users/5'
    end
  end

  describe '#url' do
    context 'new resource' do
      let(:m) { model.new }

      it "should return nil" do
        expect(m.url).to be == nil
      end

      context 'new resource with id' do
        let(:m) { model.new id: 475 }

        it "should return resource URL" do
          expect(m.url).to be == 'http://users.example.org/users/475'
        end
      end
    end

    context 'loaded resource' do
      let(:m) { model.find 1 }
      before { m; Acfs.run }

      it "should return resource's URL" do
        expect(m.url).to be == 'http://users.example.org/users/1'
      end
    end
  end
end
