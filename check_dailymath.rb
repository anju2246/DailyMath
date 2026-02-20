require 'xcodeproj'
project = Xcodeproj::Project.open('DailyMath.xcodeproj')
dailymath_group = project.main_group['DailyMath']
puts "Children of DailyMath group:"
dailymath_group.children.each do |c|
  puts "- #{c.name || c.path} (#{c.class})"
end
