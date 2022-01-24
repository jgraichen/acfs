# frozen_string_literal: true

shared_examples 'a query method with multi-callback support' do
  let(:cb) { Proc.new }

  it 'invokes callback' do
    expect do |cb|
      action.call cb
      Acfs.run
    end.to yield_with_args
  end

  it 'invokes multiple callbacks' do
    expect do |cb|
      object = action.call cb
      Acfs.add_callback object, &cb
      Acfs.run
    end.to yield_control.exactly(2).times
  end

  describe 'callback' do
    it 'is invoked with resource' do
      proc = proc {}
      object = nil

      expect(proc).to receive(:call) do |res|
        expect(res).to equal object
        expect(res).to be_loaded
      end

      object = action.call proc
      Acfs.run
    end

    it 'invokes multiple callback with loaded resource' do
      proc1 = proc {}
      proc2 = proc {}
      object = nil

      expect(proc1).to receive(:call) do |user|
        expect(user).to equal object
        expect(user).to be_loaded
      end
      expect(proc2).to receive(:call) do |user|
        expect(user).to equal object
        expect(user).to be_loaded
      end

      object = action.call proc1
      Acfs.add_callback(object, &proc2)
      Acfs.run
    end
  end
end
