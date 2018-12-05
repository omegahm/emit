require "emit"

c = Emit.channel
d = Emit.channel

def p(cout, cin)
  cout << 1
  cout << 1
  cin.()
end

def q(cout, cin)
  cin.()
  cout << 1
end

Emit.parallel(
  Emit.p(-c, +d),
  Emit.q(-d, +c)
)
