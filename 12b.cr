def count_in_extent(pattern, extents, remaining)
  if remaining > 0
    return 0i64 if pattern.empty? || pattern[0] == '.'
    count_in_extent(pattern[1..], extents, remaining - 1)
  else
    return (extents.empty? ? 1i64 : 0i64) if pattern.empty?
    return 0i64 if pattern[0] == '#'
    count_possibilities(pattern[1..], extents)
  end
end

def n_choose_k(n, k)
  return 0i64 if k > n
  result = 1i64
  1.upto(k) do |d|
    result *= n
    result //= d
    n -= 1
  end
  result
end

# how many ways can the given extents fit into a run of question marks bounded by a . or EOF
def q_fit_count(q_run_length, extents)
  return 1i64 if extents.empty?

  extra_spaces = q_run_length - extents.sum - extents.size + 1
  raise "oops" if extra_spaces < 0
  return 1i64 if extra_spaces == 0

  n_choose_k(extra_spaces + extents.size, extents.size)
end

def count_possibilities(pattern, extents)
  hash_count = pattern.count('#')
  if extents.empty?
    return hash_count > 0 ? 0i64 : 1i64
  end
  return 0i64 if pattern.size < extents.sum + extents.size - 1
  return 0i64 if hash_count > extents.sum

  # optimize runs of ? long enough for one or more whole extents to fit
  q_length = (0...pattern.size).find { |i| pattern[i] != '?' } || pattern.size
  evil = q_length < pattern.size && pattern[q_length] == '#'
  fit_length = q_length - (evil ? 1 : 0)
  if fit_length >= extents[0]
    fit_extents = 1
    q_rem = fit_length - extents[0] - 1
    while fit_extents < extents.size && q_rem >= extents[fit_extents]
      q_rem -= extents[fit_extents] + 1
      fit_extents += 1
    end
    c = (0..fit_extents).sum do |num_extents|
      q_fit_count(fit_length, extents[0...num_extents]) * count_possibilities(pattern[q_length..], extents[num_extents..])
    end
    if evil
      # we have already counted possibilities where the last ? is .; now we need to count where it is #
      # ... so, uh, ... let's try replacing it with # and seeing what happens
      c += count_possibilities(pattern.dup.tap { |p| p[fit_length] = '#' }, extents)
    end
    return c
  end

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

sum1 = 0i64
sum2 = 0i64
ARGF.each_line.with_index do |line, index|
  pattern, extent_text = line.split(" ")
  extents = extent_text.split(",").map(&.to_i)
  p1 = count_possibilities(pattern.chars, extents)
  p2 = count_possibilities(([pattern] * 5).join('?').chars, extents * 5)
  sum1 += p1
  sum2 += p2
  puts "#{index + 1}: #{p1} #{p2}"
end
puts "#{sum1} #{sum2}"
