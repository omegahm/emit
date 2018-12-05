require "emit"

def prefix(cin, cout, item)
  loop do
    cout << item
    item = cin.()
  end
end

def delta2(cin, cout1, cout2)
  loop do
    t = cin.()
    cout1 << t
    cout2 << t
  end
end

def successor(cin, cout)
  loop do
    cout << cin.() + 1
  end
end

def consumer(cin, n)
  cin.()

  cin.()
  t1 = Time.now
  n.times { cin.() }
  t2 = Time.now

  dt = t2 - t1
  tchan = dt.fdiv(4 * n)

  puts "Total time elapsed          = %.6fs" % dt
  puts "Avg. time per communication = %.6fs = %.6fµs" % [tchan, tchan * 1_000_000]
  puts

  Emit.poison(cin)
end

n = 3
comms = 125_000
n.times do |i|
  puts "Running with #{4*comms} communications"
  puts

  begin
    puts "---------- run: #{i+1} / #{n} ----------"

    a = Emit.channel
    b = Emit.channel
    c = Emit.channel
    d = Emit.channel
    puts "Running commstime"

    Emit.parallel(
      Emit.prefix(+c, -a, 0),
      Emit.delta2(+a, -b, -d),
      Emit.successor(+b, -c),
      Emit.consumer(+d, comms)
    )
  rescue Emit::ChannelPoisonedException
    Emit::Scheduler.reset!
  end
end
