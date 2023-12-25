class Graph
  @links = {} of String => Array(String)
  @stats = {} of Tuple(String, String) => Int32

  def add_edge(from, to)
    @links[from] ||= [] of String
    @links[from] << to
    @links[to] ||= [] of String
    @links[to] << from
  end

  def cut_edge(from, to)
    @links[from].delete(to)
    @links[to].delete(from)
  end

  def canonical_edge(from, to)
    from < to ? {from, to} : {to, from}
  end

  def count_visit(from, to)
    return if from.nil?

    edge = canonical_edge(from, to)
    @stats[edge] ||= 0
    @stats[edge] += 1
  end

  def vertices
    @links.keys
  end

  def random_vertex
    @links.keys.sample
  end

  def count(from)
    # naive increment would count edges, not vertices
    vertices = Set(String).new
    bfs(from) do |_, to|
      vertices << to
      false
    end
    vertices.size
  end

  def search(from, to)
    bfs(from) do |a, b|
      count_visit(a, b)
      to == b
    end
  end

  def stats(top = 10)
    @stats.to_a.sort_by { |(_edge, count)| -count }.first(top)
  end

  # yields source vertex, dest vertex for each edge traversal (source vertex is nil for initial node)
  # return true from the block to stop the search; in this case bfs will return true
  def bfs(from)
    visited = Set(String).new
    fringe = [{nil, from}]
    until fringe.empty?
      next_fringe = [] of Tuple(String, String)
      while (edge = fringe.shift?)
        from, to = edge
        visited << to
        return true if yield from, to
        @links[to].each do |connection|
          next_fringe << {to, connection} unless visited.includes?(connection)
        end
      end
      fringe = next_fringe
    end
    false
  end
end

graph = Graph.new
File.read_lines(ARGV.first).each do |line|
  from, to = line.split(": ")
  targets = to.split
  targets.each do |target|
    graph.add_edge(from, target)
  end
end

# bfs between pairs of random nodes and count traffic on each edge
# the "bridges" will tend to have the most
1000.times { graph.search(graph.random_vertex, graph.random_vertex) }

graph.stats.map(&.first).each_combination(3) do |cut_candidates|
  puts "attempting cuts: #{cut_candidates.inspect}"
  cut_candidates.each { |edge| graph.cut_edge(edge.first, edge.last) }
  unless graph.search(cut_candidates.first.first, cut_candidates.first.last)
    a = graph.count(cut_candidates.first.first)
    b = graph.count(cut_candidates.first.last)
    puts "bisected graph by cutting #{cut_candidates.inspect}"
    puts "#{cut_candidates.first.first} side: #{a}; #{cut_candidates.first.last} side: #{b}"
    puts a * b
    exit
  end

  # graph is still connected, so reconnect the edges and try a new combination
  cut_candidates.each { |edge| graph.add_edge(edge.first, edge.last) }
end

puts ":("