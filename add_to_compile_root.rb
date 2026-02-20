require 'xcodeproj'
project = Xcodeproj::Project.open('DailyMath.xcodeproj')
target = project.targets.first

def add_swift_files(dir_path, group, target)
  count = 0
  Dir.foreach(dir_path) do |entry|
    next if ['.', '..', '.DS_Store'].include?(entry)
    full_path = File.join(dir_path, entry)
    
    if File.directory?(full_path)
      # Find or create subgroup
      # Safely find existing group, ignoring PBXFileSystemSynchronizedRootGroup which doesn't have name
      subgroup = group.children.find do |c|
        begin
          (c.respond_to?(:name) && c.name == entry) || (c.respond_to?(:path) && c.path == entry)
        rescue
          false
        end
      end
      
      subgroup ||= group.new_group(entry, entry)
      count += add_swift_files(full_path, subgroup, target)
    elsif full_path.end_with?('.swift') || full_path.end_with?('.sql')
      # Find or create file reference
      file_ref = group.children.find do |c|
        begin
          (c.respond_to?(:name) && c.name == entry) || (c.respond_to?(:path) && c.path == entry)
        rescue
          false
        end
      end
      
      file_ref ||= group.new_file(full_path)
      
      # Now add to build phase if it's swift
      if full_path.end_with?('.swift')
        existing = target.source_build_phase.files.find { |f| f.file_ref && f.file_ref.uuid == file_ref.uuid }
        unless existing
          target.source_build_phase.add_file_reference(file_ref, true)
          puts "Compiled: #{full_path}"
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
    group = project.main_group.children.find do |c|
      begin
        (c.respond_to?(:name) && c.name == folder_name) || (c.respond_to?(:path) && c.path == folder_name)
      rescue
        false
      end
    end
    
    group ||= project.main_group.new_group(folder_name, folder_name)
    total_count += add_swift_files(dir_path, group, target)
  end
end

project.save
puts "Successfully added #{total_count} Swift files to compilation!"
