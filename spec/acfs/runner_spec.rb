# frozen_string_literal: true

require 'spec_helper'

class NullAdapter < Acfs::Adapter::Base
  # Start processing queued requests.
  #
  def start; end

  # Abort running and queued requests.
  #
  def abort; end

  # Run request right now skipping queue.
  #
  def run(_); end

  # Enqueue request to be run later.
  #
  def queue(_); end
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
  let(:collector2) { NotificationCollector.new }

  after do
    ::ActiveSupport::Notifications.notifier = \
      ::ActiveSupport::Notifications::Fanout.new
  end

  describe '#instrumentation' do
    before do
      ::ActiveSupport::Notifications.subscribe(/^acfs\.runner/, collector)
      ::ActiveSupport::Notifications.subscribe(/^acfs\.operation/, collector2)
    end

    describe '#process' do
      it 'triggers event' do
        runner.process ::Acfs::Operation.new MyUser, :read, params: {id: 0}
        expect(collector.events).to have(1).items
        expect(collector2.events).to have(1).items
      end
    end

    describe '#run' do
      it 'triggers event' do
        runner.run ::Acfs::Operation.new MyUser, :read, params: {id: 0}
        expect(collector.events).to have(1).items
        expect(collector2.events).to have(0).items
      end
    end

    describe '#enqueue' do
      it 'triggers event' do
        runner.enqueue ::Acfs::Operation.new MyUser, :read, params: {id: 0}
        expect(collector.events).to have(1).items
        expect(collector2.events).to have(0).items
      end
    end
  end

  describe '#run' do
    before do
      expect_any_instance_of(UserService).to receive(:prepare).and_return nil
    end

    it 'does not do requests when a middleware aborted' do
      expect(adapter).not_to receive :run
      runner.run ::Acfs::Operation.new MyUser, :read, params: {id: 0}
    end
  end

  describe '#enqueue' do
    before do
      expect_any_instance_of(UserService).to receive(:prepare).and_return(nil)
    end

    it 'does not do requests when a middleware aborted' do
      expect(adapter).not_to receive(:queue)
      runner.enqueue ::Acfs::Operation.new MyUser, :read, params: {id: 0}
      runner.start
    end
  end
end
