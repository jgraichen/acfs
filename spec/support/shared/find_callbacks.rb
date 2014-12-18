shared_examples 'a query method with multi-callback support' do
  let(:cb) { Proc.new }

  it 'should invoke callback' do
    expect do |cb|
      action.call cb
      Acfs.run
    end.to yield_with_args
  end

  it 'should invoke multiple callbacks' do
    expect do |cb|
      object = action.call cb
      Acfs.add_callback object, &cb
      Acfs.run
    end.to yield_control.exactly(2).times
  end

  describe 'callback' do
    it 'should be invoked with resource' do
      proc = proc {}
      expect(proc).to receive(:call) do |res|
        expect(res).to equal @object
        expect(res).to be_loaded
      end

      @object = action.call proc
      Acfs.run
    end

    it 'should invoke multiple callback with loaded resource' do
      proc1 = proc {}
      proc2 = proc {}
      expect(proc1).to receive(:call) do |user|
        expect(user).to equal @object
        expect(user).to be_loaded
      end
      expect(proc2).to receive(:call) do |user|
        expect(user).to equal @object
        expect(user).to be_loaded
      end

      @object = action.call proc1
      Acfs.add_callback(@object, &proc2)
      Acfs.run
    end
  end
end
