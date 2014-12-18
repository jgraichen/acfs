require 'spec_helper'

class NotificationCollector
  def call(*args)
    events << ActiveSupport::Notifications::Event.new(*args)
  end

  def events
    @events ||= []
  end
end

describe ::Acfs::Global do
  let(:adapter) { ::NullAdapter.new }
  let(:runner) { double 'runner' }
  let(:collector) { NotificationCollector.new }
  let(:acfs) { Object.new.tap {|o| o.extend ::Acfs::Global } }

  describe 'instrumentation' do
    before do
      # allow(runner).to receive(:start)
      allow(acfs).to receive(:runner).and_return runner
    end

    describe '#run' do
      before do
        ::ActiveSupport::Notifications.subscribe 'acfs.run', collector
      end
      it 'should trigger event' do
        Acfs.run
        expect(collector.events).to have(1).items
      end
    end

    describe '#reset' do
      before do
        ::ActiveSupport::Notifications.subscribe 'acfs.reset', collector
      end
      it 'should trigger event' do
        Acfs.reset
        expect(collector.events).to have(1).items
      end
    end
  end

  describe '#on' do
    before do
      stub_request(:get, %r{http://users.example.org/users/\d+}).to_return(
        status: 200,
        body: '{}',
        headers: {'Content-Type' => 'application/json'})
    end

    it 'should invoke when both resources' do
      user1 = MyUser.find 1
      user2 = MyUser.find 2

      expect do |cb|
        Acfs.on(user1, user2, &cb)
        Acfs.run
      end.to yield_with_args(user1, user2)
    end

    it 'should invoke when both resources when loaded' do
      user1 = MyUser.find 1
      user2 = MyUser.find 2

      Acfs.on(user1, user2) do |u1, u2|
        expect(u1).to be_loaded
        expect(u2).to be_loaded
      end
      Acfs.run
    end
  end
end
