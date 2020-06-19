# frozen_string_literal: true

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
        headers: {'Content-Type' => 'application/json'}
      )
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

    context 'with an empty result for a find_by call' do
      before do
        stub_request(:get, %r{http://users.example.org/users})
          .with(query: {id: '2'})
          .to_return(
            status: 200,
            body: '{}',
            headers: {'Content-Type' => 'application/json'}
          )
      end

      it 'invokes once both requests are finished' do
        user1 = MyUser.find 1
        user2 = MyUser.find_by id: 2

        expect do |cb|
          Acfs.on(user1, user2, &cb)
          Acfs.run
        end.to yield_with_args(user1, be_nil)
      end

      it 'invokes once remaining requests are finished' do
        user1 = MyUser.find 1
        Acfs.run # Finish the first request

        user2 = MyUser.find_by id: 2

        expect do |cb|
          Acfs.on(user1, user2, &cb)
          Acfs.run
        end.to yield_with_args(user1, be_nil)
      end

      it 'invokes immediately when all requests have already been finished' do
        user1 = MyUser.find 1
        user2 = MyUser.find_by id: 2
        Acfs.run

        expect do |cb|
          Acfs.on(user1, user2, &cb)
        end.to yield_with_args(user1, be_nil)
      end
    end
  end

  describe '#runner' do
    it 'returns per-thread runner' do
      runner1 = Thread.new { acfs.runner }.value
      runner2 = Thread.new { acfs.runner }.value

      expect(runner1).to_not equal runner2
    end

    it 'uses configurated adapter' do
      adapter = double :adapter
      expect(Acfs::Configuration.current).to receive(:adapter).and_return(-> { adapter })

      runner = Thread.new { acfs.runner }.value

      expect(runner.adapter).to equal adapter
    end
  end
end
