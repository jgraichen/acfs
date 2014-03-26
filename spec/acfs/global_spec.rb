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
  let(:acfs) { Object.new.tap { |o| o.extend ::Acfs::Global } }

  describe 'instrumentation' do
    before do
      #allow(runner).to receive(:start)
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
end
