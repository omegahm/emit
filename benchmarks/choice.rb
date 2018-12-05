require "emit"

$result = []

def selector(cin1, cin2, n)
  n.times do
    _, msg = Emit.choice(cin1, cin2)
    $result << msg
  end
end

ch1 = Emit.channel
ch2 = Emit.channel

n = 100
Emit.parallel(
  Emit.process { n.times { -ch1 << 0 } },
  Emit.process { n.times { -ch2 << 1 } },
  Emit.selector(+ch1, +ch2, 2*n)
)

puts $result.inspect
