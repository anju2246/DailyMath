require 'xcodeproj'
project = Xcodeproj::Project.open('DailyMath.xcodeproj')
target = project.targets.first
build_phase = target.source_build_phase
puts "Compile sources:"
build_phase.files.each do |f|
  puts "- #{f.file_ref ? (f.file_ref.name || f.file_ref.path) : 'nil ref'}"
end
