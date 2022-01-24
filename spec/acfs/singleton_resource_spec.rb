# frozen_string_literal: true

require 'spec_helper'

describe Acfs::SingletonResource do
  let(:model) { Single }

  describe '.find' do
    before do
      stub_request(:get, 'http://users.example.org/singles')
        .to_return response id: 1
    end

    let(:action) { ->(cb) { model.find(&cb) } }

    it_behaves_like 'a query method with multi-callback support'
  end
end
