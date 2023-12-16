require_relative 'skim'

def trace_bit(dx, dy)
  case [dx, dy]
  when [-1, 0] then 1
  when [1, 0] then 2
  when [0, -1] then 4
  when [0, 1] then 8
  end
end

def draw_beam(map, x, y, dx, dy, beam = nil)
  beam ||= Skim.new(map.width, map.height, ' ')
  while map.in_bounds?(x, y)
    b = trace_bit(dx, dy)
    v = beam[x, y].ord
    break if (v & b) != 0
    beam[x, y] = (v | b).chr

    cont = false
    case map[x, y]
    when '/'
      if dx == 0
        draw_beam(map, x - dy, y, -dy, 0, beam)
      else
        draw_beam(map, x, y - dx, 0, -dx, beam)
      end
    when '\\'
      if dx == 0
        draw_beam(map, x + dy, y, dy, 0, beam)
      else
        draw_beam(map, x, y + dx, 0, dx, beam)
      end
    when '-'
      if dy != 0
        draw_beam(map, x - 1, y, -1, 0, beam)
        draw_beam(map, x + 1, y, 1, 0, beam)
      else
        cont = true
      end
    when '|'
      if dx != 0
        draw_beam(map, x, y - 1, 0, -1, beam)
        draw_beam(map, x, y + 1, 0, 1, beam)
      else
        cont = true
      end
    else
      cont = true
    end
    break unless cont

    x += dx
    y += dy
  end
  beam
end

map = Skim.read
beam = draw_beam(map, 0, 0, 1, 0)
puts beam.count{ _1 != ' ' }

best = 0
test_beam = ->(beam) { best = [beam.count { _1 != ' ' }, best].max }
map.width.times do |x|
  test_beam.(draw_beam(map, x, 0, 0, 1))
  test_beam.(draw_beam(map, x, map.height - 1, 0, -1))
end
map.height.times do |y|
  test_beam.(draw_beam(map, 0, y, 1, 0))
  test_beam.(draw_beam(map, map.width - 1, y, -1, 0))
end
puts best
