require "emit"

c = Emit.channel
d = Emit.channel

def p(cout, cin)
  puts "START"
  cout << 1
  puts "WRITE"
  cin.()
  puts "DONE"
end

def q(cout, cin)
  cout << 1
  cin.()
end

Emit.parallel(
  Emit.p(-c, +d),
  Emit.q(-d, +c)
)
