require "emit"

def deadlock_process(cout, cin)
  cout << 1
  cin.()
end

c = Emit.channel
d = Emit.channel

Emit.parallel(
  Emit.deadlock_process(-c, +d),
  Emit.deadlock_process(-d, +c)
)
