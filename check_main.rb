require 'xcodeproj'
project = Xcodeproj::Project.open('DailyMath.xcodeproj')

puts "Main group name: #{project.main_group.name || '<none>'}"
puts "Main group path: #{project.main_group.path || '<none>'}"
puts "Main group children classes:"
project.main_group.children.each do |c|
  puts "- #{c.name || c.path} (#{c.class})"
end
