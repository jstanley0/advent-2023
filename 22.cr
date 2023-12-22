record Point, x : Int32, y : Int32

record Brick, id : Int32, footprint : Array(Point), dz = 0, top = false do
  def top_clone
    Brick.new(id, footprint, dz, true)
  end
end

class Well
  property levels = [] of Array(Brick)

  def initialize(bricks : Array(Tuple(Int32, Brick)))
    max_z = bricks.max_by { |tuple| tuple.first }.first
    (max_z + 2).times { @levels << [] of Brick }
    bricks.each do |z, brick|
      add_brick(z, brick)
    end
  end

  def initialize(other : Well)
    self.levels = other.levels.map(&.dup)
  end

  def add_brick(z, brick)
    @levels[z] << brick
    @levels[z + brick.dz] << brick.top_clone if brick.dz > 0
  end

  def remove_brick(z, brick)
    raise "not the canonical brick" if brick.top
    remove_brick_impl(z, brick.id)
    remove_brick_impl(z + brick.dz, brick.id) if brick.dz > 0
  end

  def remove_brick_impl(z, id)
    ix = @levels[z].index { |b| b.id == id }
    raise "brick #{id} not found at level #{z}" unless ix
    @levels[z].delete_at(ix)
  end

  def clear?(z, footprint)
    return true if z >= @levels.size
    @levels[z].all? { |brick| (brick.footprint & footprint).empty? }
  end

  def intersecting_bricks(z, footprint)
    return [] of Brick if z >= @levels.size
    @levels[z].select { |brick| (brick.footprint & footprint).size > 0 }
  end

  def unsupported_bricks(z)
    return [] of Brick if z < 2
    @levels[z].reject(&.top).select { |brick| clear?(z - 1, brick.footprint) }
  end

  def drop_brick(z, brick)
    raise "brick #{brick.id} already at the bottom of the well" if z == 1
    remove_brick(z, brick)
    while(z > 1 && clear?(z - 1, brick.footprint))
      z -= 1
    end
    add_brick(z, brick)
  end

  def safe_to_remove?(z, brick)
    raise "not the canonical brick" if brick.top
    intersecting_bricks(z + brick.dz + 1, brick.footprint).all? do |higher_brick|
      intersecting_bricks(z + brick.dz, higher_brick.footprint).any? { |hb| hb.id != brick.id }
    end
  end

  def settle!(level = 1)
    count = 0
    while level < @levels.size
      unsupported_bricks(level).each do |brick|
        drop_brick(level, brick)
        count += 1
      end
      level += 1
    end
    count
  end

  def jenga!(brick)
    z = find_brick(brick.id)
    raise "brick #{brick.id} not found" unless z
    remove_brick(z, brick)
    settle!(z + 1)
  end

  def find_brick(id)
    @levels.index do |level|
      level.find { |b| b.id == id }
    end
  end

  def count_bricks(&block)
    n = 0
    @levels.each_index do |z|
      @levels[z].each do |brick|
        next if brick.top
        n += 1 if yield z, brick
      end
    end
    n
  end

  def count_safe
    count_bricks { |z, brick| safe_to_remove?(z, brick) }
  end
end  

bricks = [] of Tuple(Int32, Brick)
ARGF.each_line.reject(&.empty?).each_with_index do |line, ix|
  c0, _, c1 = line.partition('~')
  x0, y0, z0 = c0.split(',').map(&.to_i)
  x1, y1, z1 = c1.split(',').map(&.to_i)
  x0, y0, z0, x1, y1, z1 = x1, y1, z1, x0, y0, z0 if x0 > x1 || y0 > y1 || z0 > z1
  dz = 0
  footprint = if x0 != x1
    (x0..x1).map { |x| Point.new(x, y0) }
  elsif y0 != y1
    (y0..y1).map { |y| Point.new(x0, y) }
  else
    dz = z1 - z0
    [Point.new(x0, y0)]
  end
  bricks << {z0, Brick.new(ix + 1, footprint, dz, false)}
end

well = Well.new(bricks)
well.settle!
puts well.count_safe

puts bricks.map { |z, brick| Well.new(well).jenga!(brick) }.sum

