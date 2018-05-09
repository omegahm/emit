require "emit"

describe Emit::Channel do
  context "new channel" do
    before do
      @channel = Emit.channel
    end

    it "starts non-poisoned" do
      expect(@channel).not_to be_poisoned
    end

    it "starts non-retired" do
      expect(@channel).not_to be_retired
    end

    it "can get a read end" do
      # We can't use `be_a` as `Emit::ChannelEndRead` is a private class
      expect((+@channel).class.to_s).to eq("Emit::ChannelEndRead")
      expect(@channel.reader.class.to_s).to eq("Emit::ChannelEndRead")
    end

    it "can get a write end" do
      # We can't use `be_a` as `Emit::ChannelEndWrite` is a private class
      expect((-@channel).class.to_s).to eq("Emit::ChannelEndWrite")
      expect(@channel.writer.class.to_s).to eq("Emit::ChannelEndWrite")
    end
  end

  context "communication" do
    before do
      @channel = Emit.channel
      @processA = Emit.process(-@channel) { |ch| ch << 42 }
      @processB = Emit.process(+@channel) { |ch| ch.() }
    end

    it "communicates the value across channel ends" do
      Emit::Scheduler.reset!
      Emit.parallel(@processA, @processB)
      expect(@processB.return_value).to eq(42)
    end
  end
end
