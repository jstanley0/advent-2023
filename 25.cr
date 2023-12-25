# hack: convert the data to Graphviz format
# and visually determine where to cut

graph = [] of Tuple(String, String)
# puts "graph {"
File.read_lines(ARGV.first).each do |line|
  src, dst = line.split(": ")
  targets = dst.split
  targets.each do |target|
    graph << {src, target}
    graph << {target, src}    
    # puts "  #{src} -- #{target};"
  end
end
# puts "}"

puts graph.size

graph.delete({"jkn", "cfn"})
graph.delete({"cfn", "jkn"})

graph.delete({"gst", "rph"})
graph.delete({"rph", "gst"})

graph.delete({"ljm", "sfd"})
graph.delete({"sfd", "ljm"})

def count_connected(graph, from, visited = Set(String).new)
  visited << from
  sum = 1
  graph.each do |(src, target)|
    if src == from
      sum += count_connected(graph, target, visited) unless visited.includes?(target)
    end
  end
  sum
end

a = count_connected(graph, "jkn")
b = count_connected(graph, "sfd")
puts a
puts b
puts a * b


