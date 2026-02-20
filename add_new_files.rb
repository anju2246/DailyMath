require 'xcodeproj'
project = Xcodeproj::Project.open('DailyMath.xcodeproj')
target = project.targets.first
build_phase = target.source_build_phase

existing_paths = build_phase.files.map { |f| f.file_ref&.path }.compact

new_files = [
  { path: 'Services/FlashcardStore.swift', group_path: 'Services' },
  { path: 'Services/NotificationService.swift', group_path: 'Services' },
  { path: 'Views/Today/FlashcardQuizView.swift', group_path: 'Views' },
  { path: 'Views/Today/CreateFlashcardView.swift', group_path: 'Views' },
]

added = 0
new_files.each do |file_info|
  path = file_info[:path]
  basename = File.basename(path)
  
  # Check if already in compile sources
  already_exists = build_phase.files.any? { |f| 
    ref = f.file_ref
    ref && (ref.path == path || ref.path == basename || (ref.name && ref.name == basename))
  }
  
  next if already_exists
  
  # Find or create file reference in the appropriate group
  group_name = file_info[:group_path]
  group = project.main_group[group_name]
  
  if group
    # Check if file ref already exists in the group tree
    file_ref = nil
    # Search recursively
    group.recursive_children.each do |child|
      if child.is_a?(Xcodeproj::Project::Object::PBXFileReference) && 
         (child.path == basename || child.path == path)
        file_ref = child
        break
      end
    end
    
    unless file_ref
      file_ref = group.new_file(path)
    end
    
    build_phase.add_file_reference(file_ref)
    added += 1
    puts "Added: #{path}"
  else
    puts "Warning: Group '#{group_name}' not found for #{path}"
  end
end

if added > 0
  project.save
end
puts "Done! Added #{added} files to compile sources."
