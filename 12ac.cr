def count_in_extent(pattern, extents, remaining, memo)
  if remaining > 0
    return 0i64 if pattern.empty? || pattern[0] == '.'
    count_in_extent(pattern[1..], extents, remaining - 1, memo)
  else
    return (extents.empty? ? 1i64 : 0i64) if pattern.empty?
    return 0i64 if pattern[0] == '#'
    count_possibilities(pattern[1..], extents, memo)
  end
end

def count_possibilities(pattern, extents, memo = {} of { String, Array(Int32) } => Int64)
  memo[{pattern, extents}] ||= begin
    if extents.empty?
      pattern.includes?('#') ? 0i64 : 1i64
    elsif pattern.size < extents.sum + extents.size - 1
      0i64
    elsif pattern[0] == '.'
      count_possibilities(pattern[1..], extents, memo)
    elsif pattern[0] == '#'
      count_in_extent(pattern[1..], extents[1..], extents[0] - 1, memo)
    else
      count_possibilities(pattern[1..], extents, memo) +
        count_in_extent(pattern[1..], extents[1..], extents[0] - 1, memo)
    end
  end
end

sum1 = 0i64
sum2 = 0i64
ARGF.each_line.with_index do |line, index|
  pattern, extent_text = line.split(" ")
  extents = extent_text.split(",").map(&.to_i)
  p1 = count_possibilities(pattern, extents)
  p2 = count_possibilities(([pattern] * 5).join('?'), extents * 5)
  sum1 += p1
  sum2 += p2
  puts "#{index + 1}: #{p1} #{p2}"
end
puts "#{sum1} #{sum2}"
