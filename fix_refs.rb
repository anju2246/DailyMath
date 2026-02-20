require 'xcodeproj'
project = Xcodeproj::Project.open('DailyMath.xcodeproj')
target = project.targets.first
build_phase = target.source_build_phase

# Remove broken references
to_remove = build_phase.files.select { |f|
  ref = f.file_ref
  ref && ref.path && ref.path.include?('/')
}

to_remove.each do |bf|
  puts "Removing broken ref: #{bf.file_ref.path}"
  build_phase.files.delete(bf)
end

# Now add correctly with just the filename
files_to_add = {
  'Services' => ['FlashcardStore.swift', 'NotificationService.swift'],
  'Views' => ['FlashcardQuizView.swift', 'CreateFlashcardView.swift']
}

added = 0
files_to_add.each do |group_name, filenames|
  group = project.main_group[group_name]
  next unless group
  
  filenames.each do |filename|
    # Check if already correctly in compile sources
    already = build_phase.files.any? { |f| f.file_ref&.path == filename }
    next if already
    
    # Find existing file ref in the group tree
    file_ref = nil
    group.recursive_children.each do |child|
      if child.is_a?(Xcodeproj::Project::Object::PBXFileReference) && child.path == filename
        file_ref = child
        break
      end
    end
    
    unless file_ref
      # Find the right sub-group
      if filename.include?('Flashcard') || filename.include?('Create')
        subgroup = group.children.find { |c| c.is_a?(Xcodeproj::Project::Object::PBXGroup) && c.path == 'Today' }
        if subgroup
          file_ref = subgroup.new_file(filename)
        else
          file_ref = group.new_file(filename)
        end
      else
        file_ref = group.new_file(filename)
      end
    end
    
    build_phase.add_file_reference(file_ref)
    added += 1
    puts "Added: #{filename}"
  end
end

project.save
puts "Done! Fixed refs and added #{added} files."
