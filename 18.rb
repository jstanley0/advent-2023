require_relative 'skim'

DIRS = {
  U: [0, -1],
  D: [0, 1],
  L: [-1, 0],
  R: [1, 0]
}.freeze

Dig = Data.define(:dir, :dist, :color)

dig_plan = ARGF.readlines.map do |line|
  dir, dist, color = line.scan(/[A-Za-z0-9]+/)
  dir = dir.to_sym
  dist = dist.to_i
  Dig.new(dir:, dist:, color:)
end

x = y = x0 = y0 = x1 = y1 = 0
dig_plan.each do |dig|
  x += DIRS[dig.dir][0] * dig.dist
  y += DIRS[dig.dir][1] * dig.dist
  x0 = [x, x0].min
  y0 = [y, y0].min
  x1 = [x, x1].max
  y1 = [y, y1].max
end
puts "#{x0},#{y0} - #{x1},#{y1} => #{x},#{y}"
raise "not a closed loop" unless x == 0 && y == 0

map = Skim.new(x1 - x0 + 3, y1 - y0 + 3, ' ')
x = 1 - x0
y = 1 - y0
map[x, y] = '#'
dig_plan.each do |dig|
  dx = DIRS[dig.dir][0]
  dy = DIRS[dig.dir][1]
  dig.dist.times do
    x += dx
    y += dy
    map[x, y] = '#'
  end
end

map.print if map.width < 100
map.flood_fill!(0, 0, '.')
map.transform! { _1.tr(' ', '#') }
puts map.count('#')

# --- well played, Eric
# I thought I was gonna do some color math, but nope
# it's just another classic AoC part 2 middle finger

digs_frd = dig_plan.map do |dig|
  dist = dig.color[0..4].to_i(16)
  dir = %i[R D L U][dig.color[-1].to_i]
  Dig.new(dir:, dist:, color: nil)
end

class Part2
  VSeg = Data.define(:x, :h)
  HSeg = Data.define(:x, :w)
  ScanThing = Data.define(:x, :w, :transition)
  attr_reader :segs

  def initialize(digs)
    @segs = {}

    x = y = 0
    digs.each do |dig|
      dx = DIRS[dig.dir][0] * dig.dist
      dy = DIRS[dig.dir][1] * dig.dist
      if dx == 0
        y0 = [y, y + dy].min
        h = dy.abs + 1
        @segs[y0] ||= []
        @segs[y0] << VSeg.new(x:, h:)
      else
        x0 = [x, x + dx].min
        w = dx.abs + 1
        @segs[y] ||= []
        @segs[y] << HSeg.new(x: x0, w:)
      end
      x += dx
      y += dy
    end
    raise "not a closed loop frd" unless x == 0 && y == 0

    @segs = segs.sort.to_h
  end

  def area
    area = 0
    verticals = {}
    segs.keys.each_cons(2) do |y0, y1|
      # remove vertical lines that end on row y0
      verticals.delete_if { |_x, end_y| y0 == end_y }

      # add area of row y0
      things = verticals.keys.map { ScanThing.new(x: _1, w: 1, transition: true) }
      segs[y0].select { _1.is_a?(HSeg) }.each do |hseg|
        transition = segs[y0].count { _1.is_a?(VSeg) && (_1.x == hseg.x || _1.x == hseg.x + hseg.w - 1) }.odd?
        things << ScanThing.new(x: hseg.x, w: hseg.w, transition:)
      end
      int_start = nil # start of current interior section
      things.sort_by { _1.x }.each do |thing|
        if int_start
          area += thing.x - int_start
          area += thing.w
          int_start = thing.transition ? nil : thing.x + thing.w
        else
          area += thing.w
          int_start = thing.x + thing.w if thing.transition
        end
      end
      raise "zomg" unless int_start.nil?

      # add vertical lines starting on row y0 (mapped to row where they end)
      segs[y0].select { _1.is_a?(VSeg) }.each do |vseg|
        verticals[vseg.x] = y0 + vseg.h - 1
      end

      # add area of rows y0 + 1..y1 - 1, where there are only vertical lines
      if y1 > y0 + 1
        raise "onoz" unless verticals.keys.size.even?
        row_size = verticals.keys.sort.each_slice(2).sum { |(x0, x1)| x1 - x0 + 1 }
        area += row_size * (y1 - y0 - 1)
      end
    end
    # the last y has only horizontal lines
    area += segs[segs.keys.last].sum { _1.w }
    area
  end
end

puts Part2.new(dig_plan).area
puts Part2.new(digs_frd).area
