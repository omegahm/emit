require "emit"

$result = []

def selector(cin1, cin2, n)
  n.times do
    $result << Emit.choice(
      Emit::InputGuard.new(cin1, ->(msg) { msg }),
      Emit::InputGuard.new(cin2, ->(msg) { msg })
    )
  end
end

ch1 = Emit.channel
ch2 = Emit.channel

Emit.parallel(
  Emit.process { 100.times { -ch1 << 0 } },
  Emit.process { 100.times { -ch2 << 1 } },
  Emit.selector(+ch1, +ch2, 200)
)

puts $result.inspect
