require 'xcodeproj'
project = Xcodeproj::Project.open('DailyMath.xcodeproj')
target = project.targets.first

folders_to_add = ['App', 'Auth', 'Components', 'Config', 'Create', 'Duel', 'Explore', 'Models', 'Moderator', 'Profile', 'Services', 'Today', 'Utilities', 'ViewModels', 'Views', 'Agility']

# 1. Clean the build phase
target.source_build_phase.files_references.dup.each do |file_ref|
  if file_ref && file_ref.respond_to?(:path) && file_ref.path&.end_with?('.swift')
    target.source_build_phase.remove_file_reference(file_ref)
  end
end

# 2. Delete our manual groups
project.main_group.children.dup.each do |c|
  begin
    name_or_path = (c.respond_to?(:name) ? c.name : nil) || (c.respond_to?(:path) ? c.path : nil)
    if name_or_path && folders_to_add.include?(name_or_path)
      c.remove_from_project
    end
  rescue NoMethodError => e
    # Skip
  end
end

project.save
puts "Cleaned project."

# 3. Reload project to avoid ghost Objects
project = Xcodeproj::Project.open('DailyMath.xcodeproj')
target = project.targets.first

# 4. Rebuild groups and files properly
def add_swift_files(dir_path, parent_group, target)
  Dir.foreach(dir_path) do |entry|
    next if ['.', '..', '.DS_Store'].include?(entry)
    full_path = File.join(dir_path, entry)
    
    if File.directory?(full_path)
      subgroup = parent_group.new_group(entry, entry)
      add_swift_files(full_path, subgroup, target)
    elsif full_path.end_with?('.swift') || full_path.end_with?('.sql')
      file_ref = parent_group.new_file(entry)
      
      if full_path.end_with?('.swift')
        target.source_build_phase.add_file_reference(file_ref, true)
        puts "Compiled: #{full_path}"
      end
    end
  end
end

folders_to_add.each do |folder_name|
  dir_path = File.join('.', folder_name)
  if File.directory?(dir_path)
    group = project.main_group.new_group(folder_name, folder_name)
    add_swift_files(dir_path, group, target)
  end
end

project.save
puts "Project rebuilt correctly!"
