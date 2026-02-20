require 'xcodeproj'

project = Xcodeproj::Project.open('DailyMath.xcodeproj')
target = project.targets.first
build_phase = target.source_build_phase

# Get all current UUIDs in the compile sources phase
existing_uuids = build_phase.files.map { |f| f.file_ref&.uuid }.compact

# Iterate through all files in the project
count = 0
project.files.each do |file_ref|
  path = file_ref.path || file_ref.name
  if path && path.end_with?('.swift')
    # Skip test files and UI test files specifically
    next if path.include?('Tests') || path.include?('UITests')
    
    # Check if the file is already in the compile sources phase
    unless existing_uuids.include?(file_ref.uuid)
      build_phase.add_file_reference(file_ref, true)
      puts "Added to Compile Sources: #{path}"
      count += 1
    end
  end
end

project.save
puts "Successfully added #{count} Swift files to the target build phase."
