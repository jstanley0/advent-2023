record Condition, prop : Char, op : Char, value : Int32 do
  def match_part?(part)
    cv = part[prop]?
    return false unless cv

    case op
    when '<' then cv < value
    when '>' then cv > value
    else raise "bad comparator #{op}"
    end
  end
end

record Rule, cond : (Condition | Nil), target : String
alias Workflow = Array(Rule)
alias Part = Hash(Char, Int32)

workflow_text, part_text = ARGF.gets_to_end.split("\n\n")

workflows = {} of String => Workflow
workflow_text.split('\n').each do |workflow_line|
  id, rule_list_text = workflow_line.split(/[{}]/)
  workflows[id] = rule_list_text.split(',').map do |rule_text|
    parts = rule_text.split(':')
    if parts.size == 1
      Rule.new(nil, parts[0])
    else
      Rule.new(
        Condition.new(parts[0][0], parts[0][1], parts[0][2..].to_i),
        parts[1]
      )
    end
  end
end

parts = [] of Part
part_text.split("\n").each do |part_line|
  h = {} of Char => Int32
  part_line.strip("{}").split(',').each { |part_text|
    part_text.split(',', 2).map do |prop_text|
      h[prop_text[0]] = prop_text[2..].to_i
    end
  }
  parts << h
end
 
sum = parts.sum do |part|
  #print part.inspect + " "
  flow = "in"
  until flow == "A" || flow == "R"
    #print flow + " -> "
    workflows[flow].each do |rule|
      if rule.cond.nil? || rule.cond.not_nil!.match_part?(part)
        flow = rule.target
        break
      end
    end
  end
  #puts flow
  flow == "A" ? part.values.sum : 0
end

puts sum

# -- part deux

def quantum_search(workflows, flow, ranges = {'x' => 1..4000, 'm' => 1..4000, 'a' => 1..4000, 's' => 1..4000})
  return ranges.values.map { |r| r.size.to_i64 }.reduce{ |a, b| a * b } if flow == "A"
  return 0i64 if flow == "R"

  count = 0i64
  local_ranges = ranges.dup
  workflows[flow].each do |rule|
    if rule.cond.nil?
      count += quantum_search(workflows, rule.target, local_ranges)
    else
      cond = rule.cond.not_nil!  # srsly Crystal, here in the else block we *know* cond isn't nil. I am disappoint
      if_range, else_range = apply_condition(local_ranges, cond) 
      count += quantum_search(workflows, rule.target, local_ranges.merge({cond.prop => if_range})) unless if_range.empty?
      break if else_range.empty?
      local_ranges.merge!({cond.prop => else_range})
    end
  end
  count
end

def apply_condition(ranges, condition) 
  range = ranges[condition.prop]
  if condition.op == '<'
    if_range = range.begin..condition.value - 1
    else_range = condition.value..range.end
  else
    if_range = condition.value + 1..range.end
    else_range = range.begin..condition.value
  end
  { if_range, else_range }
end

puts quantum_search(workflows, "in")