require_relative 'skim'
require_relative 'search'

class SearchNode < Search::Node
  attr_accessor :map, :x, :y, :from_dir, :from_count
  def initialize(map, x, y, from_dir = nil, from_count = 0)
    self.map = map
    self.x = x
    self.y = y
    self.from_dir = from_dir
    self.from_count = from_count
  end

  def goal?
    x == map.width - 1 && y == map.height - 1
  end

  def backtrack?(from_dir, to_dir)
    case from_dir
    when :l then to_dir == :r
    when :u then to_dir == :d
    when :r then to_dir == :l
    when :d then to_dir == :u
    end
  end

  def do_edge(dir, x1, y1)
    return if backtrack?(from_dir, dir)
    return if from_dir == dir && from_count == 3

    yield [map[x1, y1].to_i, SearchNode.new(map, x1, y1, dir, from_dir == dir ? from_count + 1 : 1)]
  end

  def enum_edges(&)
    do_edge(:l, x - 1, y, &) if x > 0
    do_edge(:u, x, y - 1, &) if y > 0
    do_edge(:r, x + 1, y, &) if x < map.width - 1
    do_edge(:d, x, y + 1, &) if y < map.height - 1
  end

  def hash
    [x, y, from_dir, from_count].join('/').hash
  end
end


map = Skim.read
start_node = SearchNode.new(map, 0, 0)
cost, path = Search.bfs(start_node)

vis = Skim.new(map.width, map.height, '.')
path.each do |node|
  vis[node.x, node.y] = '#'
end
vis.print
puts cost
