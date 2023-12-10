require 'set'
require_relative 'skim.rb'

def enum_connections(tile)
  case tile
  when '|' then [[0, -1], [0, 1]]
  when '-' then [[-1, 0], [1, 0]]
  when 'F' then [[0, 1], [1, 0]]
  when '7' then [[-1, 0], [0, 1]]
  when 'L' then [[0, -1], [1, 0]]
  when 'J' then [[0, -1], [-1, 0]]
  else []
  end
end


map = Skim.read
sx, sy = map.find_coords('S')
u_conn = enum_connections(map[sx, sy - 1]).include?([0, 1]) if sy > 0
l_conn = enum_connections(map[sx - 1, sy]).include?([1, 0]) if sx > 0
r_conn = enum_connections(map[sx + 1, sy]).include?([-1, 0]) if sx < map.width - 1
d_conn = enum_connections(map[sx, sy + 1]).include?([0, -1]) if sy < map.height - 1

shape = if u_conn
          if l_conn
            'J'
          elsif r_conn
            'L'
          elsif d_conn
            '|'
          end
        elsif d_conn
          if l_conn
            '7'
          else r_conn
            'F'
          end
        else
          '-'
        end
map[sx, sy] = shape
puts "found start at (#{sx}, #{sy}); inferred starting shape: #{shape}"

visited = Set.new
visited << [sx, sy]
positions = enum_connections(shape).map { |(dx, dy)| [sx + dx, sy + dy] }
steps = 1
done = false
loop do
  positions.each_with_index do |(x, y), i|
    adjacents = enum_connections(map[x, y]).select { |dx, dy| !visited.include?([x + dx, y + dy]) }
    if adjacents.empty?
      visited << [x, y]
      done = true
      break
    elsif adjacents.size > 1
      map.print
      puts "positions: #{positions.inspect}"
      puts "adjacents: #{adjacents.inspect}"
      puts "visited: #{visited.inspect}"
      raise "oops"
    else
      positions[i] = [x + adjacents[0][0], y + adjacents[0][1]]
      visited << [x, y]
    end
  end
  break if done
  steps += 1
end
puts steps
puts "--"

# .x.
# xxx
# .x.
cmap = Skim.new(map.width * 3, map.height * 3, ' ')
visited.each do |(x, y)|
  cx = x * 3 + 1
  cy = y * 3 + 1
  cmap[cx, cy] = 'x'
  enum_connections(map[x, y]).each do |(dx, dy)|
    cmap[cx + dx, cy + dy] = 'x'
  end
end

def flood_fill(cmap, x0, y0)
  cq = Set.new
  cq << [x0, y0]
  until cq.empty?
    x, y = cq.first
    cq.delete cq.first
    cmap[x, y] = 'O'
    cq << [x - 1, y] if x > 0 && cmap[x - 1, y] == ' '
    cq << [x + 1, y] if x < cmap.width - 1 && cmap[x + 1, y] == ' '
    cq << [x, y - 1] if y > 0 && cmap[x, y - 1] == ' '
    cq << [x, y + 1] if y < cmap.height - 1 && cmap[x, y + 1] == ' '
  end
end
flood_fill(cmap, 0, 0)

inside = 0
(0...map.width).each do |x|
  (0...map.height).each do |y|
    cx = x * 3 + 1
    cy = y * 3 + 1
    if cmap[cx, cy] == ' '
      cmap[cx, cy] = '*'
      inside += 1
    end
  end
end
cmap.print
puts inside


