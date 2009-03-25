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
    "Unsaved-#{self.helper.new_page_id}"
  end
end
