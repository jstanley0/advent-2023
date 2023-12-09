def extrapolate(nums)
  r = [nums]
  loop do
    d = r.last.each_cons(2).map { _2 - _1 }
    break if d.all?(&:zero?)
    r << d
  end
  r.sum(&:last)
end
data = ARGF.each_line.map { _1.split.map(&:to_i) }
puts data.sum { extrapolate(_1) }
