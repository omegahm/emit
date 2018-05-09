require "emit"

def master(cout)
  100000.times do |i|
    cout << i
  end
  Emit.poison(cout)
end

def worker(cin, cout)
  loop do
    cout << 2*cin.()
  end
rescue Emit::ChannelPoisonedException
  Emit.poison(cout)
end

def sink(cin)
  loop do
    cin.()
  end
rescue Emit::ChannelPoisonedException
  # no-op
end

ch1 = Emit.channel
ch2 = Emit.channel

t1 = Time.now
Emit.parallel(
  Emit.master(-ch1),
  10 * Emit.worker(+ch1, -ch2),
  Emit.sink(+ch2)
)
t2 = Time.now

puts "Total time elapsed = %.6fs" % (t2-t1)
