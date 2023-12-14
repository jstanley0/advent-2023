require 'digest'
require_relative 'skim'

class Skim
  def roll(dx, dy)
    m = dup
    loop do
      moved = false
      m.each do |c, x, y|
        if c == 'O' && m.in_bounds?(x + dx, y + dy) && m[x + dx, y + dy] == '.'
          m[x + dx, y + dy] = 'O'
          m[x, y] = '.'
          moved = true
        end
      end
      break unless moved
    end
    m
  end

  def spin_cycle
    roll(0, -1).roll(-1, 0).roll(0, 1).roll(1, 0)
  end

  def load
    v = 0
    load_factor = height
    height.times do |y|
      v += data[y].count('O') * load_factor
      load_factor -= 1
    end
    v
  end
end

map = Skim.read
puts map.roll(0, -1).load

cycles = 0
loads = []
sigs = { map.hash => cycles }
loop do
  map = map.spin_cycle
  cycles += 1
  loads << map.load
  sig = map.hash
  break if sigs.key?(sig)
  sigs[sig] = cycles
end
cycle_start = sigs[map.hash]
cycle_length = cycles - cycle_start
puts loads[cycle_start + (1000000000 - cycle_start - 1) % cycle_length]
