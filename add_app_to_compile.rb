require 'xcodeproj'
project = Xcodeproj::Project.open('DailyMath.xcodeproj')
target = project.targets.first

file_ref = project.main_group.files.find { |f| f.path == 'DailyMathApp.swift' || f.name == 'DailyMathApp.swift' }

unless file_ref
  file_ref = project.main_group.new_file('DailyMathApp.swift')
end

build_phase = target.source_build_phase
unless build_phase.files.map(&:file_ref).include?(file_ref)
  build_phase.add_file_reference(file_ref)
  project.save
  puts "Added DailyMathApp.swift to compile sources!"
else
  puts "DailyMathApp.swift is already in compile sources."
end
