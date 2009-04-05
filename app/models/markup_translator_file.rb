require 'RedCloth'

class MarkupTranslatorFile < RuGUI::BaseModel
  observable_property :file_id
  observable_property :contents
  observable_property :markup_type, :initial_value => 'textile'
  observable_property :filesystem_path
  observable_property :unsaved_changes, :boolean => true
  observable_property :is_new, :boolean => true, :initial_value => true

  def save
    self.is_new = false
    self.unsaved_changes = false

    save_to_filesystem
  end

  def save_temp_markup_file(contents)
    self.contents = contents
    self.unsaved_changes = true
    save_as_file(temp_markup_file_path, self.markup_contents)
  end

  def temp_markup_file_path
    File.expand_path(File.join(RuGUI.root, 'app', 'resources', 'temp', temp_markup_file_name))
  end

  def temp_markup_file_uri
    "file://#{temp_markup_file_path}"
  end

  def temp_markup_file_name
    self.file_id.end_with?(self.markup_type) ? self.file_id : "#{self.file_id}.#{self.markup_type}"
  end

  def markup_contents
    respond_to?(markup_contents_method) ? send(markup_contents_method) : self.contents
  end

  def textile_contents
    RedCloth.new(self.contents).to_html
  end
  
  private
    def save_to_filesystem
      save_as_file(self.filesystem_path, self.contents)
    end

    def save_as_file(path, contents)
      File.open(path, 'w') do |file|
        file.write contents
      end unless path.nil?
    end

    def markup_contents_method
      "#{self.markup_type || 'textile'}_contents"
    end
end
