require "z3"

Vector = Data.define(:x, :y, :z, :dx, :dy, :dz)

data = File.open(ARGV.first).readlines.map { |line| Vector[*line.scan(/-?\d+/).map(&:to_i)] }
test_area = ARGV.first.include?(".ex") ? 7..27 : 200000000000000..400000000000000

def paths_cross_in_test_area?(a, b, test_area)
  m1 = a.dy.to_r / a.dx
  m2 = b.dy.to_r / b.dx
  return false if m1 == m2

  b1 = a.y - m1 * a.x
  b2 = b.y - m2 * b.x
  x = (b2 - b1) / (m1 - m2)
  y = m1 * x + b1
  return false unless test_area.include?(x) && test_area.include?(y)

  (x - a.x <=> 0) == (a.dx <=> 0) && (y - a.y <=> 0) == (a.dy <=> 0) &&
    (x - b.x <=> 0) == (b.dx <=> 0) && (y - b.y <=> 0) == (b.dy <=> 0)
end

puts data.combination(2).count { |a, b| paths_cross_in_test_area?(a, b, test_area) }

# -- part deux

solver = Z3::Solver.new
rx = Z3.Real("rx"); ry = Z3.Real("ry"); rz = Z3.Real("rz")
rdx = Z3.Real("rdx"); rdy = Z3.Real("rdy"); rdz = Z3.Real("rdz")
data.each_with_index do |vec, i|
  ti = Z3.Real("t#{i}")
  solver.assert(rx + ti * rdx == vec.x + ti * vec.dx)
  solver.assert(ry + ti * rdy == vec.y + ti * vec.dy)
  solver.assert(rz + ti * rdz == vec.z + ti * vec.dz)
end
puts [rx, ry, rz].sum { solver.model[_1].to_s.to_i } if solver.satisfiable?
