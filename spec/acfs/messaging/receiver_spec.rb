require 'spec_helper'

module My
  class CustomReceiver
    include Acfs::Messaging::Receiver
  end
end

describe Acfs::Messaging::Receiver do
  let(:rcv_class) { My::CustomReceiver }
  after { rcv_class.queue nil }

  describe '.queue' do
    it 'should return queue name based on class name' do
      expect(rcv_class.queue).to be == 'my.custom_receiver'
    end

    it 'should set and return custom queue name' do
      rcv_class.queue 'special.queue.name'

      expect(rcv_class.queue).to be == 'special.queue.name'
    end
  end

  describe '.receive' do
    context 'with routed message' do
      context 'with exact routing key match' do
        it 'should receive messages' do
          rcv_class.instance.should_receive(:receive).with(anything, anything, { message: 'Hello!'})

          Acfs::Messaging::Client.instance.publish('my.custom_receiver', { message: 'Hello!' })
          sleep 1 # Nothing better?
        end
      end

      context 'with partial routing key match' do
        it 'should receive messages' do
          rcv_class.instance.should_receive(:receive).with(anything, anything, { message: 'Hello!'})

          Acfs::Messaging::Client.instance.publish('my.different', { message: 'Hello!' })
          sleep 1 # Nothing better?
        end
      end
    end

    context 'with not routed message' do
      it 'should not receive messages' do
        rcv_class.instance.should_not_receive(:receive)

        Acfs::Messaging::Client.instance.publish('abc.cde', { message: 'Hello!' })
        sleep 1 # Nothing better?
      end
    end
  end
end
