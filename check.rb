require 'xcodeproj'
project = Xcodeproj::Project.open('DailyMath.xcodeproj')
target = project.targets.first

puts "Target name: #{target.name}"
build_phase = target.source_build_phase
puts "Number of files in compile sources: #{build_phase.files.count}"

build_phase.files.each do |f|
    puts "- #{f.file_ref.path || f.file_ref.name}" if f.file_ref
end
