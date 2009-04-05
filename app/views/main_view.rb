class MainView < ApplicationView
  use_builder

  def setup_widgets
    self.files_notebook.clear
  end

  def add_new_file_page(file_id, translator_root_widget)
    self.helper.open_file(file_id)

    add_page(translator_root_widget, new_page_label)
    focus_page(file_id)
  end

  def add_page(page_widget, label)
    self.files_notebook.add_tab(page_widget, label)
  end

  def focus_page(file_id)
    self.files_notebook.current_index = self.helper.page_index_for(file_id)
  end

  def close_file_page(file_id)
    page_index = self.helper.page_index_for(file_id)
    self.helper.close_file(file_id)
    tab_page = self.files_notebook.widget(page_index)
    self.files_notebook.remove_tab(page_index)
    tab_page.dispose
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

  def prompt_for_save_changes(file_id)
    message_box = Qt::MessageBox.new
    message_box.text = "<h1>Save changes to #{file_id}?</h1>"
    message_box.informative_text = "You have unsaved changes in your documents, choose whether to save it."
    message_box.standard_buttons = Qt::MessageBox::Save | Qt::MessageBox::Cancel | Qt::MessageBox::Discard
    message_box.default_button = Qt::MessageBox::Save
    message_box.icon = Qt::MessageBox::Question
    message_box.exec
  end

  def prompt_for_override_opened_file
    message_box = Qt::MessageBox.new
    message_box.text = "<h1>Override opened file?</h1>"
    message_box.informative_text = "This will close the other file and override it with the new one, are you sure?"
    message_box.standard_buttons = Qt::MessageBox::Yes | Qt::MessageBox::No
    message_box.default_button = Qt::MessageBox::No
    message_box.icon = Qt::MessageBox::Question
    message_box.exec
  end
end
