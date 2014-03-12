require 'spec_helper'

describe Acfs::Collection do
  describe 'Pagination' do
    let(:params) { Hash.new }
    let!(:collection) { MyUser.all params }

    subject { Acfs.run; collection }

    context 'without explicit page parameter' do
      before do
        stub_request(:get, 'http://users.example.org/users').to_return response([{id: 1, name: 'Anon', age: 12, born_at: 'Berlin'}],
                                                                                headers: {'X-Total-Pages' => '2'})
      end

      its(:total_pages) { should eq 2 }
      its(:current_page) { should eq 1 }
    end

    context 'with page parameter' do
      let(:params) { {page: 2} }
      before do
        stub_request(:get, 'http://users.example.org/users?page=2').to_return response([{id: 1, name: 'Anon', age: 12, born_at: 'Berlin'}],
                                                                                       headers: {'X-Total-Pages' => '2'})
      end

      its(:total_pages) { should eq 2 }
      its(:current_page) { should eq 2 }
    end

    context 'with non-numerical page parameter' do
      let(:params) { {page: 'e546f5'} }
      before do
        stub_request(:get, 'http://users.example.org/users?page=e546f5').to_return response([{id: 1, name: 'Anon', age: 12, born_at: 'Berlin'}],
                                                                                       headers: {'X-Total-Pages' => '2'})
      end

      its(:total_pages) { should eq 2 }
      its(:current_page) { should eq 'e546f5' }
    end
  end
end
