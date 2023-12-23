alias Coord = Tuple(Int32, Int32)
alias Edge = NamedTuple(len: Int32, node: Int32)
alias DAG = Array(Array(Edge))

class MazeRunner
  @map : Array(Array(Char))
  @graph = DAG.new
  @node_map = {} of Coord => Int32
  @next_node = 0
  @end_node_num : (Int32|Nil) = nil
  @longest_hike = 0

  def initialize(map, @climb_uphill = false)
    @map = map.map(&.dup)
    end_x = @map[-1].index('.').not_nil!
    @map[-1][end_x] = '*'

    start_x = @map[0].index('.').not_nil!
    @map[0][start_x] = '#'
    generate_graph({start_x, 1}, next_node_num)
  end

  def next_node_num
    raise "too many nodes for bitmask" if @next_node >= 128
    ret = @next_node
    @next_node += 1
    ret
  end

  def end_node_num
    @end_node_num ||= next_node_num
  end

  SLOPES = {
    '<' => {-1, 0},
    '>' => {1, 0},
    '^' => {0, -1},
    'v' => {0, 1}
  }

  def enum_neighbors(coord, visited)
    x, y = coord
    unless @climb_uphill
      slope = SLOPES[@map[y][x]]?
      if slope
        next_coord = {x + slope[0], y + slope[1]}
        return visited.includes?(next_coord) ? [] of Coord : [next_coord]
      end
    end

    neighbors = [] of Coord
    check_neighbor = ->(x : Int32, y : Int32) do
      neighbors << {x, y} if @map[y][x] != '#' unless visited.includes?({x, y}) 
    end
    check_neighbor.call(x, y - 1)
    check_neighbor.call(x - 1, y)
    check_neighbor.call(x + 1, y)
    check_neighbor.call(x, y + 1)
    neighbors
  end

  def add_edge(from, to, len)
    @graph << [] of Edge if @graph.size <= from
    @graph << [] of Edge if @graph.size <= to
    @graph[from] << { len: len, node: to }
    @graph[to] << { len: len, node: from } if @climb_uphill
    nil
  end

  def reached_end?(coord)
    x, y = coord
    @map[y][x] == '*'
  end  

  def generate_graph(coord, from_node, visited = Set(Coord).new)
    len = 1
    loop do
      if reached_end?(coord)
        add_edge(from_node, end_node_num, len)
        break
      end

      neighbors = enum_neighbors(coord, visited)
      visited << coord
      break if neighbors.empty?

      if neighbors.size > 1
        if @node_map.has_key?(coord)
          add_edge(from_node, @node_map[coord], len)
        else
          new_node = @node_map[coord] = next_node_num
          add_edge(from_node, new_node, len)
          neighbors.each do |coord|
            generate_graph(coord, new_node, visited.dup)
          end
        end
        break
      end

      coord = neighbors.first
      len += 1
    end
    nil
  end

  def search(from = 0, visited = 0u128, cumulative_len = 0)
    @graph[from].select { |edge| (visited & (1u128 << edge[:node])) == 0 }.each do |edge|
      if edge[:node] == end_node_num
        @longest_hike = {@longest_hike, cumulative_len + edge[:len]}.max
        break
      end
      search(edge[:node], visited | (1u128 << edge[:node]), cumulative_len + edge[:len])
    end
    self
  end

  def result
    @longest_hike
  end
end

map = ARGF.gets_to_end.split('\n').reject(&.empty?).map(&.chars)
puts MazeRunner.new(map).search.result
puts MazeRunner.new(map, climb_uphill: true).search.result
