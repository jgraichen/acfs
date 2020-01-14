# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Collection do
  let(:model) { MyUser }

  describe 'Pagination' do
    let(:params) { {} }
    let!(:collection) { model.all params }

    subject { Acfs.run; collection }

    context 'without explicit page parameter' do
      before do
        stub_request(:get, 'http://users.example.org/users')
          .to_return response([{id: 1, name: 'Anon', age: 12, born_at: 'Berlin'}],
            headers: {
              'X-Total-Pages' => '2',
              'X-Total-Count' => '10'
            })
      end

      its(:total_pages) { should eq 2 }
      its(:current_page) { should eq 1 }
      its(:total_count) { should eq 10 }
    end

    context 'with page parameter' do
      let(:params) { {page: 2} }
      before do
        stub_request(:get, 'http://users.example.org/users?page=2')
          .to_return response([{id: 1, name: 'Anon', age: 12, born_at: 'Berlin'}],
            headers: {
              'X-Total-Pages' => '2',
              'X-Total-Count' => '10'
            })
      end

      its(:total_pages) { should eq 2 }
      its(:current_page) { should eq 2 }
      its(:total_count) { should eq 10 }
    end

    context 'with non-numerical page parameter' do
      let(:params) { {page: 'e546f5'} }
      before do
        stub_request(:get, 'http://users.example.org/users?page=e546f5')
          .to_return response([{id: 1, name: 'Anon', age: 12, born_at: 'Berlin'}],
            headers: {
              'X-Total-Pages' => '2',
              'X-Total-Count' => '10'
            })
      end

      its(:total_pages) { should eq 2 }
      its(:current_page) { should eq 'e546f5' }
      its(:total_count) { should eq 10 }
    end

    describe '#next_page' do
      before do
        stub_request(:get, 'http://users.example.org/users')
          .to_return response([{id: 1, name: 'Anon', age: 12, born_at: 'Berlin'}],
            headers: {
              'X-Total-Pages' => '2',
              'Link' => '<http://users.example.org/users?page=2>; rel="next"'
            })
      end
      let!(:req) do
        stub_request(:get, 'http://users.example.org/users?page=2').to_return response([])
      end
      let!(:collection) { model.all }
      subject { Acfs.run; collection.next_page }

      it { should be_a Acfs::Collection }

      it 'should have fetched page 2' do
        subject
        Acfs.run
        expect(req).to have_been_requested
      end
    end

    describe '#prev_page' do
      before do
        stub_request(:get, 'http://users.example.org/users?page=2')
          .to_return response([{id: 2, name: 'Anno', age: 1604, born_at: 'Santa Maria'}],
            headers: {
              'X-Total-Pages' => '2',
              'Link' => '<http://users.example.org/users>; rel="prev"'
            })
      end
      let!(:req) do
        stub_request(:get, 'http://users.example.org/users').to_return response([])
      end
      let!(:collection) { model.all page: 2 }
      subject { Acfs.run; collection.prev_page }

      it { should be_a Acfs::Collection }

      it 'should have fetched page 1' do
        subject
        Acfs.run
        expect(req).to have_been_requested
      end
    end

    describe '#first_page' do
      before do
        stub_request(:get, 'http://users.example.org/users?page=2')
          .to_return response([{id: 2, name: 'Anno', age: 1604, born_at: 'Santa Maria'}],
            headers: {
              'X-Total-Pages' => '2',
              'Link' => '<http://users.example.org/users>; rel="first"'
            })
      end
      let!(:req) do
        stub_request(:get, 'http://users.example.org/users').to_return response([])
      end
      let!(:collection) { model.all page: 2 }
      subject { Acfs.run; collection.first_page }

      it { should be_a Acfs::Collection }

      it 'should have fetched page 1' do
        subject
        Acfs.run
        expect(req).to have_been_requested
      end
    end

    describe '#last_page' do
      before do
        stub_request(:get, 'http://users.example.org/users?page=2')
          .to_return response([{id: 2, name: 'Anno', age: 1604, born_at: 'Santa Maria'}],
            headers: {
              'X-Total-Pages' => '2',
              'Link' => '<http://users.example.org/users?page=12>; rel="last"'
            })
      end
      let!(:req) do
        stub_request(:get, 'http://users.example.org/users?page=12').to_return response([])
      end
      let!(:collection) { model.all page: 2 }
      subject { Acfs.run; collection.last_page }

      it { should be_a Acfs::Collection }

      it 'should have fetched page 1' do
        subject
        Acfs.run
        expect(req).to have_been_requested
      end
    end
  end
end
