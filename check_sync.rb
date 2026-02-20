require 'xcodeproj'
project = Xcodeproj::Project.open('DailyMath.xcodeproj')

# Imprimir todo lo que existe y ver qué properties tienen
project.main_group.children.each do |c|
  if c.class.name.include?('PBXFileSystemSynchronizedRootGroup')
    puts "Sync Group Path: #{c.path}"
  else
    puts "Normal Group/File: #{c.path || c.name}"
  end
end

