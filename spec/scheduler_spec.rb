require "emit"

describe "Emit::Scheduler" do
  it "will be a singleton instance" do
    expect(Emit::Scheduler.class.to_s).to eq("Emit::Scheduler")
  end

  it "will start with MainProcess as current" do
    expect(Emit::Scheduler.current.class).to eq(Emit::MainProcess)
  end

  context "enqueue process" do
    before do
      @process = Emit.process { true }
      @process.start
      Emit::Scheduler << @process
    end

    after do
      Emit::Scheduler.reset!
    end

    it "will get main loop fiber as next" do
      expect(Emit::Scheduler.get_next).to be_a(Fiber)
    end
  end

  context "activate process" do
    before do
      @process = Emit.process { true }
      @process.start
      Emit::Scheduler.activate(@process)
    end

    after do
      Emit::Scheduler.reset!
    end

    it "will get next process" do
      expect(Emit::Scheduler.get_next).to eq(@process)
      expect(Emit::Scheduler.current).to eq(@process)
    end
  end
end
