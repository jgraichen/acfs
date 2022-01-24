# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Resource::Loadable do
  let(:model) { MyUser.find 1 }

  before do
    stub_request(:get, 'http://users.example.org/users/1')
      .to_return response id: 1, name: 'Anon', age: 12
  end

  describe '#loaded?' do
    context 'before Acfs#run' do
      it { expect(model).not_to be_loaded }
    end

    context 'afer Acfs#run' do
      before { model && Acfs.run }

      it { expect(model).to be_loaded }
    end
  end
end
