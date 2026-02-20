require 'xcodeproj'
project = Xcodeproj::Project.open('DailyMath.xcodeproj')
puts "Main group children:"
project.main_group.children.each do |c|
  puts "- #{c.name || c.path}"
end
