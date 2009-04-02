class TranslatorController < ApplicationController
  def setup_models
    register_model main_controller.manager
  end

  def new_translator
    new_file = main_controller.manager.new_file
    register_model new_file, new_file.file_id
    new_translator_view(new_file.file_id)
    add_new_file_page_for(new_file.file_id)
  end

  def new_translator_view(file_id)
    register_view :translator_view, file_id
    view_for_file(file_id).plain_text_edit.connect(SIGNAL('textChanged()')) { translator_contents_changed(file_id) }
  end

  def translator_contents_changed(file_id)
    self.manager.save_temp_markup_file(file_id, view.plain_text_edit.to_plain_text)
      display_browser_preview(file_id)
  end

  def add_new_file_page_for(file_id)
    main_controller.main_view.add_new_file_page(file_id, view_for_file(file_id).root_widget)
  end

  def property_markup_translator_file_unsaved_changes_changed(model, new_value, old_value)
    main_controller.main_view.contents_updated_file_label_for(model.file_id) if new_value
  end

  def view_for_file(file_id)
    self.views[file_id.to_sym]
  end

  def display_browser_preview(file_id)
    path = self.manager.markup_translator_file(file_id).temp_markup_file_path
    view_for_file(file_id).display_browser_preview(path)
  end
end
