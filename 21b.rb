require_relative 'skim'

FACTOR=17
FO=FACTOR/2

raise "need step count" unless ARGV.size > 0
steps = ARGV.pop.to_i

map = Skim.read
x, y = map.find_coords('S')
map[x, y] = '.'

emap = Skim.new(map.width * FACTOR, map.height * FACTOR)
FACTOR.times do |ex|
  FACTOR.times do |ey|
    emap.paste(ex * map.width, ey * map.height, map)
  end
end
x += map.width * FO
y += map.height * FO

spill_ex = FO
subcount = ->(mx, c) do
  emap.count_window(mx * map.width, FO * map.height, 1, map.height, c)
end

edge_counts = []
step_counts = []
fringe = Set.new([[x, y]])
(steps + 1).times do |step|
  step_char = step.even? ? 'O' : 'o'
  next_fringe = Set.new
  fringe.each do |(x, y)|
    emap[x, y] = step_char
    emap.nabes(x, y, diag: false) do |c, a, b|
      next_fringe << [a, b] if c == '.'
    end
  end
  fringe = next_fringe

  if subcount.(spill_ex, step_char) > 0
    step_counts << step
    edge_counts << emap.count(step_char)
    puts "reached edge at step #{step}; count #{edge_counts.last}"
    spill_ex -= 1
    if spill_ex < 0
      c = edge_counts[0]
      b = (4 * edge_counts[1] - edge_counts[2] - 3 * c) / 2
      a = edge_counts[1] - c - b
      n = (steps - step_counts[0]) / (step_counts[1] - step_counts[0])
      puts a * n * n + b * n + c
      exit
    end
  end

end

emap.print(highlights: %w[O o], chunk: [map.width, map.height]) if map.width < 15
puts emap.count(steps.even? ? 'O' : 'o')
