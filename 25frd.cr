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

  def count_edge_traversal(from, to)
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
    n = 0
    bfs(from) do |node|
      n += 1
      false
    end
    n
  end

  def search(from, to)
    path = bfs(from) { |node| to == node }
    path.each_cons(2) { |(from, to)| count_edge_traversal(from, to) }
    path.any?
  end

  def stats(top = 10)
    @stats.to_a.sort_by { |(_edge, count)| -count }.first(top)
  end

  private def build_path(path_links, start_node, target_node)
    node = target_node
    path = [node]
    while (node = path_links[node]?)
      path.unshift node
      break if node == start_node
    end
    path
  end
  
  # yields each node in order of traversal
  # return true from the block if the target is found; in this case, bfs will return the path
  # otherwise it will return an empty array
  def bfs(from)
    visited = Set(String).new
    path_links = {} of String => String
    fringe = [from]
    until fringe.empty?
      next_fringe = [] of String
      fringe.each do |node|
        next if visited.includes?(node)
        visited << node
        return build_path(path_links, from, node) if yield node
        @links[node].each do |connection|
          unless visited.includes?(connection)
            next_fringe << connection 
            path_links[connection] ||= node
          end
        end
      end
      fringe = next_fringe
    end
    [] of String
  end
end

graph = Graph.new
File.each_line(ARGV.first) do |line|
  from, to = line.split(": ")
  targets = to.split
  targets.each do |target|
    graph.add_edge(from, target)
  end
end

# traverse paths between pairs of random nodes and count traffic on each edge
# the "bridges" will tend to have the most
1000.times { graph.search(graph.random_vertex, graph.random_vertex) }

p! graph.stats

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