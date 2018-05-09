require "emit"

@result = []
def action(message: nil)
  @result << message
end

def p1(cout, n)
  n.times { |i| cout << i }
end

def p2(cin1, cin2, n)
  n.times do
    Emit.select(
      Emit::InputGuard.new(cin1, action: method(:action)),
      Emit::InputGuard.new(cin2, action: method(:action))
    )
  end
end

ch1 = Emit.channel
ch2 = Emit.channel

Emit.parallel(
  Emit.process(-ch1, 50, &method(:p1)),
  Emit.process(-ch2, 50, &method(:p1)),
  Emit.process(+ch1, +ch2, 100, &method(:p2))
)

puts @result.inspect
