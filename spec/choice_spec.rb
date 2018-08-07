require "emit"

describe "Emit.choice" do
  describe "selecting on two input channels with defined input guards" do
    before do
      def select_action(message)
        message
      end

      def selector(cin1, cin2)
        Emit.choice(
          Emit::InputGuard.new(cin1, method(:select_action)),
          Emit::InputGuard.new(cin2, method(:select_action))
        )
      end

      ch1 = Emit.channel
      ch2 = Emit.channel
      @process1 = Emit.process(-ch1) { |ch| ch << 1 }
      @process2 = Emit.process(-ch2) { |ch| ch << 2 }
      @selector = Emit.process(+ch1, +ch2) do |cin1, cin2|
        _, a = selector(cin1, cin2)
        _, b = selector(cin1, cin2)
        [a, b].sort
      end
    end

    it "is selected input" do
      Emit.parallel(@process1, @process2, @selector)
      expect(@selector.return_value).to eq([1, 2])
    end
  end

  describe "selecting on two channels with arrays" do
    before do
      def select_action(message)
        message
      end

      def selector(cin1, cin2)
        Emit.choice(
          [cin1, method(:select_action)],
          [cin2, method(:select_action)]
        )
      end

      ch1 = Emit.channel
      ch2 = Emit.channel
      @process1 = Emit.process(-ch1) { |ch| ch << 1 }
      @process2 = Emit.process(-ch2) { |ch| ch << 2 }
      @selector = Emit.process(+ch1, +ch2) do |cin1, cin2|
        _, a = selector(cin1, cin2)
        _, b = selector(cin1, cin2)
        [a, b].sort
      end
    end

    it "is selected input" do
      Emit.parallel(@process1, @process2, @selector)
      expect(@selector.return_value).to eq([1, 2])
    end
  end

  describe "selecting on two channels with arrays and lambdas" do
    before do
      def select_action(message)
        message
      end

      def selector(cin1, cin2)
        Emit.choice(
          [cin1, ->(message) { message }],
          [cin2, ->(message) { message }]
        )
      end

      ch1 = Emit.channel
      ch2 = Emit.channel
      @process1 = Emit.process(-ch1) { |ch| ch << 1 }
      @process2 = Emit.process(-ch2) { |ch| ch << 2 }
      @selector = Emit.process(+ch1, +ch2) do |cin1, cin2|
        _, a = selector(cin1, cin2)
        _, b = selector(cin1, cin2)
        [a, b].sort
      end
    end

    it "is selected input" do
      Emit.parallel(@process1, @process2, @selector)
      expect(@selector.return_value).to eq([1, 2])
    end
  end
end
