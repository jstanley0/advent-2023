require 'set'
require_relative 'skim'

map = Skim.read
x, y = map.find_coords('S')
map[x, y] = '.'

positions = Set.new([[x, y]])

64.times do
  next_positions = Set.new
  positions.each do |(x, y)|
    map.nabes(x, y, diag: false) do |c, a, b|
      next_positions << [a, b] if c == '.'
    end
  end
  positions = next_positions
end

puts positions.size
