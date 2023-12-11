require_relative 'skim'

class Space
  attr_accessor :galaxies

  def initialize
    self.galaxies = {}
  end

  def self.read
    space = Space.new
    Skim.read.each do |val, x, y|
      if val == '#'
        space.galaxies[x] ||= []
        space.galaxies[x] << y
      end
    end
    space
  end

  def expand(factor = 2)
    expand_horizontally(factor).transpose.expand_horizontally(factor).transpose
  end

  def expand_horizontally(factor = 2)
    ret = Space.new
    cols = galaxies.keys.sort
    x0 = cols.shift
    ret.galaxies[x0] = galaxies[x0]
    expansion = 0
    while (x = cols.shift)
      expansion += (x - x0 - 1) * (factor - 1)
      ret.galaxies[x + expansion] = galaxies[x]
      x0 = x
    end
    ret
  end

  def transpose
    ret = Space.new
    galaxies.each do |x, ys|
      ys.each do |y|
        ret.galaxies[y] ||= []
        ret.galaxies[y] << x
      end
    end
    ret
  end

  def plot
    space = Skim.new(galaxies.keys.max + 1, galaxies.values.flatten.max + 1, '.')
    galaxies.each do |x, ys|
      ys.each do |y|
        space[x, y] = '#'
      end
    end
    space.print
  end

  def flat_coords
    ret = []
    galaxies.each do |x, ys|
      ys.each do |y|
        ret << [x, y]
      end
    end
    ret
  end

  def distances
    total = 0
    coords = flat_coords
    (0...coords.size).each do |i|
      (i + 1...coords.size).each do |j|
        total += (coords[j][0] - coords[i][0]).abs + (coords[j][1] - coords[i][1]).abs
      end
    end
    total
  end
end

space = Space.read

space1 = space.expand
#space1.plot
puts space1.distances

puts space.expand(10).distances
puts space.expand(100).distances
puts space.expand(1_000_000).distances
