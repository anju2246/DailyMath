require 'xcodeproj'
project = Xcodeproj::Project.open('DailyMath.xcodeproj')
target = project.targets.first

dailymath_group = project.main_group['DailyMath']

def add_swift_files(dir_path, group, target)
  count = 0
  Dir.foreach(dir_path) do |entry|
    next if ['.', '..', '.DS_Store'].include?(entry)
    full_path = File.join(dir_path, entry)
    
    if File.directory?(full_path)
      # Find or create subgroup
      subgroup = group.children.find { |c| c.name == entry || c.path == entry } || group.new_group(entry, entry)
      count += add_swift_files(full_path, subgroup, target)
    elsif full_path.end_with?('.swift') || full_path.end_with?('.sql')
      # Find or create file reference
      file_ref = group.children.find { |c| c.name == entry || c.path == entry }
      unless file_ref
        file_ref = group.new_file(full_path)
      end
      
      # Now add to build phase if it's swift
      if full_path.end_with?('.swift')
        # Check if already in build phase
        existing = target.source_build_phase.files.find { |f| f.file_ref && f.file_ref.uuid == file_ref.uuid }
        unless existing
          target.source_build_phase.add_file_reference(file_ref, true)
          puts "Added to Compile Sources: #{full_path}"
          count += 1
        end
      end
    end
  end
  count
end

total_count = 0
['App', 'Auth', 'Components', 'Config', 'Create', 'Duel', 'Explore', 'Models', 'Moderator', 'Profile', 'Services', 'Today', 'Utilities', 'ViewModels', 'Views', 'Agility'].each do |folder_name|
  dir_path = File.join('.', folder_name)
  if File.directory?(dir_path)
    group = dailymath_group.children.find { |c| c.name == folder_name || c.path == folder_name } || dailymath_group.new_group(folder_name, folder_name)
    total_count += add_swift_files(dir_path, group, target)
  end
end

project.save
puts "Successfully added #{total_count} missing Swift files to the compile phase!"
