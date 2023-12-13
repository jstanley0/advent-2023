require_relative 'skim'

def detect_mirror(map, but_not: nil)
  rows = map.rows
  mirrored_rows = (1...rows.size).select do |y|
    (0...rows.size).all? do |dy|
      y + dy >= rows.size || y - dy - 1 < 0 || rows[y + dy] == rows[y - dy - 1]
    end
  end

  cols = map.cols
  mirrored_cols = (1...cols.size).select do |x|
    (0...cols.size).all? do |dx|
      x + dx >= cols.size || x - dx - 1 < 0 || cols[x + dx] == cols[x - dx - 1]
    end
  end

  opts = mirrored_cols + mirrored_rows.map { _1 * 100 }
  opts -= [but_not] if but_not
  opts.first
end

maps = Skim.read_many
mirror_lines = maps.map { detect_mirror(_1) }
puts mirror_lines.sum

unsmudged_sum = 0
maps.each_with_index do |map, i|
  unsmudged_line = nil
  map.each do |c, x, y|
    map[x, y] = c.tr '.#', '#.'
    mc = detect_mirror(map, but_not: mirror_lines[i])
    unsmudged_line = mc if mc
    map[x, y] = c
    break if unsmudged_line
  end
  unless unsmudged_line
    map.print
    puts "orig mirror line: #{mirror_lines[i]}"
    raise ":("
  end
  unsmudged_sum += unsmudged_line
end
puts unsmudged_sum
