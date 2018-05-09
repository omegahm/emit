require "emit"

describe Emit::Process do
  context "no block given" do
    it "will fail" do
      expect { Emit::Process.new }.to raise_error(ArgumentError)
    end

    it "will fail with arguments supplied" do
      expect { Emit::Process.new("one", "two", three: true) }.to raise_error(ArgumentError)
    end
  end

  it "will allow a proc" do
    my_proc = proc { |a| a }
    expect { Emit::Process.new("one", &my_proc).run }.not_to raise_error
  end

  it "will allow a lambda" do
    my_lambda = lambda { |a| a }
    expect { Emit::Process.new("one", &my_lambda).run }.not_to raise_error
  end

  it "will allow a method as block" do
    def my_method(a)
      a
    end
    expect { Emit::Process.new("one", &method(:my_method)).run }.not_to raise_error
  end

  it "will allow a block" do
    expect { Emit::Process.new("one") { |a| a }.run }.not_to raise_error
  end

  context "new process" do
    before do
      @process = Emit.process { true }
    end

    it "will not be active" do
      expect(@process.active?).to be_falsey
    end

    it "will not have been executed" do
      expect(@process.executed?).to be_falsey
    end

    it "will not have a return value" do
      expect(@process.return_value).to be_nil
    end

    it "will not have a fiber" do
      expect(@process.fiber).to be_nil
    end
  end

  context "return_value" do
    before do
      @process = Emit.process { 42 }
    end

    it "has a return value after run" do
      Emit::Scheduler.reset!
      Emit.parallel(@process)
      expect(@process.return_value).to eq(42)
    end
  end
end
