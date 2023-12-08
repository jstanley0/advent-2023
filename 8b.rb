dirs, mapp = ARGF.read.split("\n\n")
dirs = dirs.chars.map { _1 == 'L' ? 0 : 1 }
nodes = {}
mapp.split("\n").each do |line|
  name, left, right = line.scan(/[A-Z0-9]+/)
  nodes[name] = [left, right]
end

def run(nodes, dirs, pos)
  visited = {}
  start = pos
  steps = 0
  di = 0
  until visited[[pos, di]]
    visited[[pos, di]] = steps

    pos = nodes[pos][dirs[di]]
    di += 1; di = 0 if di >= dirs.size
    steps += 1
  end
  cycle_start = visited[[pos, di]]
  cycle_length = steps - cycle_start
  puts "#{start} => #{pos}: #{cycle_start}; cycle length #{cycle_length}"
  puts visited.select { |k, _| k.first.end_with?('Z') }.inspect
  # through extremely fortuitous coincidence, exactly one Z node is reached from each A node,
  # and the number of steps it takes to reach it is exactly the same as the cycle length
  # *and* we reach it after a whole number of iterations through the direction list!
  # so I don't need to fiddle with offsets and can just return...
  cycle_length
end

puts nodes.keys.select { _1.end_with?('A') }.map { run(nodes, dirs, _1) }.inject(:lcm)
