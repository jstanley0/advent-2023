dirs, mapp = ARGF.read.split("\n\n")
nodes = {}
mapp.split("\n").each do |line|
  name, left, right = line.scan(/[A-Z]+/)
  nodes[name] = [left, right]
end

pos = 'AAA'
di = 0
steps = 0
until pos == 'ZZZ'
  ni = dirs[di] == 'L' ? 0 : 1
  di += 1; di = 0 if di >= dirs.size
  pos = nodes[pos][ni]
  steps += 1
end
puts steps
