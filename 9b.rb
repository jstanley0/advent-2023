def extrapolate(nums)
  r = [nums]
  loop do
    d = r.last.each_cons(2).map { _2 - _1 }
    break if d.all?(&:zero?)
    r << d
  end
  r.reverse.inject(0) { |s, row| row.first - s }
end
data = ARGF.each_line.map { _1.split.map(&:to_i) }
puts data.sum { extrapolate(_1) }
