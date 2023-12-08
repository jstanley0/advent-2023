dirs, mapp = ARGF.gets_to_end.split("\n\n")
nodes = {} of String => Tuple(String, String)
mapp.split("\n").each do |line|
  match_data = line.match(/([A-Z0-9]+) = \(([A-Z0-9]+), ([A-Z0-9]+)\)/)
  break unless match_data

  name, left, right = match_data.captures
  nodes[name.not_nil!] = {left.not_nil!, right.not_nil!}
end

poses = nodes.keys.select { |k| k[-1] == 'A' }
puts poses.join(" ")
di = 0
steps = 0i64
until poses.all? { |p| p[-1] == 'Z' }
  ni = dirs[di] == 'L' ? 0 : 1
  di += 1
  di = 0 if di >= dirs.size
  poses = poses.map { |p| nodes[p][ni] }
  steps += 1
end
puts steps