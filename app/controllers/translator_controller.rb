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

  def save_current_translator
    if has_current_markup_translator_file?
      if current_markup_translator_file.is_new?
        save_current_translator_as
      else
        current_markup_translator_file.save
      end
    end
  end

  def save_current_translator_as
    if has_current_markup_translator_file?
      old_file_id = current_markup_translator_file.file_id
      filesystem_path = Qt::FileDialog.get_save_file_name
      unless filesystem_path.blank?
        current_markup_translator_file.filesystem_path = filesystem_path
        current_markup_translator_file.save
        new_file_id = File.basename(filesystem_path)
        update_file_id(old_file_id, new_file_id) unless old_file_id == new_file_id
      end
    end
  end

  def new_translator_view(file_id)
    register_view :translator_view, file_id
    connect_translator_contents_changed_signal_for(file_id)
  end

  def connect_translator_contents_changed_signal_for(file_id)
    view_for_file(file_id).plain_text_edit.connect(SIGNAL('textChanged()')) { translator_contents_changed(file_id) }
  end

  def disconnect_translator_contents_changed_signal_for(file_id)
    view_for_file(file_id).plain_text_edit.disconnect(SIGNAL('textChanged()'))
  end

  def translator_contents_changed(file_id)
    self.manager.save_temp_markup_file(file_id, view_for_file(file_id).plain_text_edit.to_plain_text)
    display_browser_preview(file_id)
  end

  def add_new_file_page_for(file_id)
    main_controller.main_view.add_new_file_page(file_id, view_for_file(file_id).root_widget)
  end

  def property_markup_translator_file_unsaved_changes_changed(model, new_value, old_value)
    main_controller.main_view.contents_updated_file_label_for(model)
  end

  def view_for_file(file_id)
    self.views[file_id.to_sym]
  end

  def display_browser_preview(file_id)
    path = self.manager.markup_translator_file(file_id).temp_markup_file_path
    view_for_file(file_id).display_browser_preview(path)
  end

  def has_current_markup_translator_file?
    self.manager.has_opened_files?
  end

  def current_markup_translator_file
    self.manager.opened_files[main_controller.main_view.current_file_id]
  end

  def update_file_id(old_file_id, new_file_id)
    disconnect_translator_contents_changed_signal_for(old_file_id)
    self.manager.opened_files[old_file_id].file_id = new_file_id
    self.manager.opened_files[new_file_id] = self.manager.opened_files.delete(old_file_id)
    self.views[new_file_id.to_sym] = self.views.delete(old_file_id.to_sym)
    connect_translator_contents_changed_signal_for(new_file_id)
    main_controller.main_view.update_file_id(old_file_id, new_file_id)
    main_controller.main_view.contents_updated_file_label_for(self.manager.opened_files[new_file_id])
  end
end
