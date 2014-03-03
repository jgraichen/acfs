require 'spec_helper'

class NullAdapter < Acfs::Adapter::Base

  # Start processing queued requests.
  #
  def start
  end

  # Abort running and queued requests.
  #
  def abort
  end

  # Run request right now skipping queue.
  #
  def run(_)
  end

  # Enqueue request to be run later.
  #
  def queue(_)
  end
end

class NotificationCollector
  def call(*args)
    events << ActiveSupport::Notifications::Event.new(*args)
  end

  def events
    @events ||= []
  end
end

describe ::Acfs::Runner do
  let(:adapter) { ::NullAdapter.new }
  let(:runner) { ::Acfs::Runner.new adapter }
  let(:collector) { NotificationCollector.new }

  after do
    ::ActiveSupport::Notifications.notifier = \
      ::ActiveSupport::Notifications::Fanout.new
  end

  describe '#instrumentation' do
    before do
      ::ActiveSupport::Notifications.subscribe /^acfs\.runner/, collector
    end

    describe '#start' do
      it 'should trigger event' do
        runner.start
        expect(collector.events).to have(1).items
      end
    end

    describe '#process' do
      it 'should trigger event' do
        runner.process ::Acfs::Operation.new MyUser, :read, params: {id: 0}
        expect(collector.events).to have(2).items
      end
    end

    describe '#run' do
      it 'should trigger event' do
        runner.run ::Acfs::Operation.new MyUser, :read, params: {id: 0}
        expect(collector.events).to have(1).items
      end
    end

    describe '#enqueue' do
      it 'should trigger event' do
        runner.run ::Acfs::Operation.new MyUser, :read, params: {id: 0}
        expect(collector.events).to have(1).items
      end
    end
  end
end
