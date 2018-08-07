require "emit"

$result = []
def action(message)
  $result << message
end

def worker(cout, n, id)
  n.times { cout << id }
end

def selector(cin1, cin2, n)
  n.times do
    Emit.choice(
      Emit::InputGuard.new(cin1, method(:action)),
      Emit::InputGuard.new(cin2, method(:action))
    )
  end
end

ch1 = Emit.channel
ch2 = Emit.channel

N = 100

Emit.parallel(
  Emit.worker(-ch1, N, 0),
  Emit.worker(-ch2, N, 1),
  Emit.selector(+ch1, +ch2, N*2)
)

puts $result.inspect
