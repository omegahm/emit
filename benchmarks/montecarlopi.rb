require "emit"

def producer(job_out, bagsize, bags)
  bags.times { job_out << bagsize }
  Emit.retire(job_out)
end

def worker(job_in, result_out)
  loop do
    cnt = job_in.()
    sum = cnt.times.count { (rand**2 + rand**2) < 1 }
    result_out << (4.0 * sum) / cnt
  end
rescue Emit::ChannelRetiredException
  Emit.retire(result_out)
end

def consumer(result_in)
  cnt = 0
  sum = result_in.()
  loop do
    cnt += 1
    sum = (sum * cnt + result_in.()) / (cnt+1)
  end
rescue Emit::ChannelRetiredException
  puts sum
end

jobs    = Emit.channel
results = Emit.channel

t1 = Time.now
Emit.parallel(
  Emit.producer(-jobs, 1000, 10000),
  10.times.map { Emit.worker(+jobs, -results) },
  Emit.consumer(+results)
)
t2 = Time.now

puts "Total time elapsed = %.6fs" % (t2-t1)
