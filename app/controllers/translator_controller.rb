class TranslatorController < ApplicationController
  def setup_models
    register_model main_controller.manager
  end

  def new_translator
    new_markup_translator_file
    register_markup_translator_file
    add_file_page(:new => true)
  end

  def open
    prompt_for_file
    if open_markup_translator_file
      add_file_page
    end
  end

  def save
    if has_current_markup_translator_file?
      if current_markup_translator_file.is_new?
        save_as
      else
        save_current_markup_translator_file
      end
    end
  end

  def save_as
    if has_current_markup_translator_file?
      save_old_file_id
      if prompt_for_save_filesystem_path
        save_current_markup_translator_file
        update_references_for_file
      end
    end
  end

  def close
    close_file(current_markup_translator_file.file_id) if has_current_markup_translator_file?
  rescue CanceledAction
    # do nothing
  end

  def close_file(file_id, options = {})
    if options[:prompt_for_override]
      prompt_for_override_opened_file
    elsif has_unsaved_changes?(file_id) and not is_new?(file_id)
      prompt_for_save_changes(file_id)
    end
    
    close_markup_translator_file(file_id)
    close_file_view(file_id)
  end

  def new_translator_view(file_id)
    register_view :translator_view, file_id
  end

  def connect_translator_contents_changed_signal_for(file_id)
    view_for_file(file_id).plain_text_edit.connect(SIGNAL('textChanged()')) { update_browser_preview(file_id) }
  end

  def disconnect_translator_contents_changed_signal_for(file_id)
    view_for_file(file_id).plain_text_edit.disconnect(SIGNAL('textChanged()'))
  end

  def update_browser_preview(file_id)
    self.manager.save_temp_markup_file(file_id, view_for_file(file_id).plain_text_edit.to_plain_text)
    display_browser_preview(file_id)
  end

  def add_file_page_for(file_id, options = {})
    main_controller.main_view.add_file_page(file_id, view_for_file(file_id).root_widget, options)
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

  def has_same_file_opened?(file_id)
    self.manager.has_opened_file?(file_id)
  end

  def has_unsaved_changes?(file_id)
    self.manager.markup_translator_file(file_id).unsaved_changes?
  end

  def is_new?(file_id)
    self.manager.markup_translator_file(file_id).is_new?
  end

  def current_markup_translator_file
    self.manager.markup_translator_file(main_controller.main_view.current_file_id)
  end

  def save_old_file_id
    @old_file_id = current_markup_translator_file.file_id
  end

  def prompt_for_file
    @filesystem_path = main_controller.main_view.prompt_for_open_filesystem_path
  end

  def prompt_for_save_filesystem_path
    @filesystem_path = main_controller.main_view.prompt_for_save_filesystem_path(current_markup_translator_file.filesystem_path)

    unless @filesystem_path.blank?
      @filesystem_path << ".#{current_markup_translator_file.markup_type}" unless @filesystem_path.end_with?(".#{current_markup_translator_file.markup_type}")
      close_file(File.basename(@filesystem_path), :prompt_for_override => true) if has_same_file_opened?(File.basename(@filesystem_path))
      current_markup_translator_file.filesystem_path = @filesystem_path
    end
  rescue CanceledAction
    false
  end

  def prompt_for_save_changes(file_id)
    result = main_controller.main_view.prompt_for_save_changes(file_id)
    case result
    when Qt::MessageBox::Save
      save_markup_translator_file(file_id)
    when Qt::MessageBox::Cancel
      raise CanceledAction.new("Canceled Action")
    when Qt::MessageBox::Discard
      # do nothing
    end
  end

  def prompt_for_override_opened_file
    result = main_controller.main_view.prompt_for_override_opened_file
    case result
    when Qt::MessageBox::Yes
      # continue
    when Qt::MessageBox::No
      raise CanceledAction.new("Canceled Action")
    end
  end

  def save_markup_translator_file(file_id)
    self.manager.opened_files[file_id].save
  end

  def save_current_markup_translator_file
    save_markup_translator_file(current_markup_translator_file.file_id)
  end

  def update_references_for_file
    @new_file_id = File.basename(@filesystem_path)
    disconnect_file_signals
    update_opened_file_id
    update_file_view_id
    connect_file_signals
    update_view_file_label
  end

  def update_opened_file_id
    self.manager.update_opened_file_id(@old_file_id, @new_file_id)
  end

  def update_file_view_id
    self.views[@new_file_id.to_sym] = self.views.delete(@old_file_id.to_sym)
  end

  def disconnect_file_signals
    disconnect_translator_contents_changed_signal_for(@old_file_id)
  end

  def connect_file_signals
    connect_translator_contents_changed_signal_for(@new_file_id)
  end

  def update_view_file_label
    main_controller.main_view.update_file_id(@old_file_id, @new_file_id)
    main_controller.main_view.contents_updated_file_label_for(self.manager.markup_translator_file(@new_file_id))
  end

  def close_markup_translator_file(file_id)
    self.manager.close_file(file_id)
  end

  def close_file_view(file_id)
    main_controller.main_view.close_file_page(file_id)
  end

  def new_markup_translator_file
    @file = main_controller.manager.new_file
  end

  def open_markup_translator_file
    @file = main_controller.manager.open_file(@filesystem_path)
  end

  def register_markup_translator_file
    register_model @file, @file.file_id
  end

  def add_file_page(options = {})
    new_translator_view(@file.file_id)
    add_file_page_for(@file.file_id, options)
    update_file_page_contents_for(@file)
    connect_translator_contents_changed_signal_for(@file.file_id)
  end

  def update_file_page_contents_for(file)
    view_for_file(file.file_id).plain_text_edit.plain_text = file.contents
    update_browser_preview(file.file_id)
  end
end
