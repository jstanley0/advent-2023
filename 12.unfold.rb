ARGF.each_line do |line|
  pattern, counts = line.split(' ')
  puts "#{([pattern] * 5).join('?')} #{([counts] * 5).join(',')}"
end