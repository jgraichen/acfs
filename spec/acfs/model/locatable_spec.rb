require 'spec_helper'

describe 'Acfs::Model::Locatable' do
  let(:model) { MyUser }

  describe '.url' do
    it 'should return URL' do
      expect(model.url).to be == 'http://users.example.org/users'
    end

    it 'should return URL with id path part if specified' do
      expect(model.url(5)).to be == 'http://users.example.org/users/5'
    end
  end
end
