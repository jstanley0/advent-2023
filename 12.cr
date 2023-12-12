def count_in_extent(pattern, extents, remaining)
  if remaining > 0
    return 0i64 if pattern.empty? || pattern.starts_with?('.')
    count_in_extent(pattern[1..], extents, remaining - 1)
  else
    return (extents.empty? ? 1i64 : 0i64) if pattern.empty?
    return 0i64 if pattern[0] == '#'
    count_possibilities(pattern[1..], extents)
  end
end

def count_possibilities(pattern, extents)
  hash_count = pattern.count('#')
  if extents.empty?
    return hash_count > 0 ? 0i64 : 1i64
  end
  return 0i64 if pattern.size < extents.sum + extents.size - 1
  return 0i64 if hash_count > extents.sum

  if pattern[0] == '.'
    count_possibilities(pattern[1..], extents)
  else
    if pattern[0] == '#'
      count_in_extent(pattern[1..], extents[1..], extents[0] - 1)
    else
      count_possibilities(pattern[1..], extents) +
        count_in_extent(pattern[1..], extents[1..], extents[0] - 1)
    end
  end
end

sum = 0i64
ARGF.each_line do |line|
  pattern, extent_text = line.split(" ")
  extents = extent_text.split(",").map(&.to_i)
  sum += count_possibilities(pattern, extents)
end
puts sum
