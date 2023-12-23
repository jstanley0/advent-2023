alias Coord = Tuple(Int32, Int32)
alias VisitedSet = Set(Coord)
alias Edge = Tuple(Int32, String)
alias DAG = Hash(String, Array(Edge))

class MazeRunner
  @map : Array(Array(Char))
  @graph = DAG.new
  @node_map = {} of Coord => String
  @next_node = "A"
  @longest_hike = 0

  def initialize(map, @climb_uphill = false)
    @map = map.map(&.dup)
    end_x = @map[-1].index('.').not_nil!
    @map[-1][end_x] = '*'

    start_x = @map[0].index('.').not_nil!
    @map[0][start_x] = '#'
    generate_graph({start_x, 1}, "start")
  end

  def next_node_name
    ret = @next_node
    @next_node = ret.succ
    ret
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
    @graph[from] ||= [] of Edge
    @graph[from] << {len + 1, to}
    if @climb_uphill
      @graph[to] ||= [] of Edge
      @graph[to] << {len + 1, from}
    end
    nil
  end

  def reached_end?(coord)
    x, y = coord
    @map[y][x] == '*'
  end  

  def generate_graph(coord, from_node, visited = VisitedSet.new)
    len = 0
    loop do
      if reached_end?(coord)
        add_edge(from_node, "end", len)
        break
      end

      neighbors = enum_neighbors(coord, visited)
      visited << coord
      break if neighbors.empty?

      if neighbors.size > 1
        if @node_map.has_key?(coord)
          add_edge(from_node, @node_map[coord], len)
        else
          new_node = @node_map[coord] = next_node_name
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

  def search(from = "start", visited = Set(String).new, cumulative_len = 0)
    #if from == "start"
    #  p! @graph
    #  p! @node_map
    #end
    @graph[from].reject { |edge| visited.includes?(edge.last) }.each do |len, node|
      # puts "considering #{from} => #{node} having seen #{visited}"
      if node == "end"
        @longest_hike = {@longest_hike, cumulative_len + len}.max
        break
      end
      search(node, visited.dup.add(node), cumulative_len + len)
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
