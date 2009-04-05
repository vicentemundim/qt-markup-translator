class MainView < ApplicationView
  use_builder

  def setup_widgets
    self.files_notebook.clear
  end

  def add_new_file_page(file_id, translator_root_widget)
    self.helper.open_file(file_id)

    add_page(translator_root_widget, new_page_label)
  end

  def add_page(page_widget, label)
    self.files_notebook.add_tab(page_widget, label)
  end

  def new_page_label
    "Unsaved-#{self.helper.new_page_number}"
  end

  def current_file_id
    current_index = self.files_notebook.current_index
    self.helper.file_id_for(current_index) unless current_index.blank?
  end

  def contents_updated_file_label_for(file)
    page_number = self.helper.page_index_for(file.file_id)

    if file.is_new?
      label = self.files_notebook.tab_text(page_number)
    else
      label = file.file_id.dup
    end
    
    if file.unsaved_changes?
      label << "*" unless label.end_with?("*")
    else
      label.chop if label.end_with?("*")
    end

    self.files_notebook.set_tab_text(page_number, label)
  end

  def update_file_id(old_file_id, new_file_id)
    self.helper.update_file_id(old_file_id, new_file_id)
  end

  def prompt_for_save_filesystem_path(current_path)
    Qt::FileDialog.get_save_file_name(
      self.main_window,
      'Save File',
      current_path,
      "Markup (*.textile);; All (*)"
    )
  end
end
