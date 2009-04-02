require 'RedCloth'

class MarkupTranslatorFile < RuGUI::BaseModel
  observable_property :file_id
  observable_property :contents
  observable_property :markup_type, :initial_value => 'textile'
  observable_property :unsaved_changes, :boolean => true

  def save_temp_markup_file(contents)
    self.contents = contents
    self.unsaved_changes = true
    save_as_file(temp_markup_file_path)
  end

  def temp_markup_file_path
    File.expand_path(File.join(RuGUI.root, 'app', 'resources', 'temp', "#{self.file_id}.#{self.markup_type}"))
  end

  def temp_markup_file_uri
    "file://#{temp_markup_file_path}"
  end

  def markup_contents
    respond_to?(markup_contents_method) ? send(markup_contents_method) : self.contents
  end

  def textile_contents
    RedCloth.new(self.contents).to_html
  end
  
  private
    def save_as_file(path)
      File.open(path, 'w') do |file|
        file.write self.markup_contents
      end
    end

    def markup_contents_method
      "#{self.markup_type || 'textile'}_contents"
    end
end
