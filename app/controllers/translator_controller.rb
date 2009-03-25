class TranslatorController < ApplicationController
  def setup_models
    register_model main_controller.manager
  end

  def new_translator
    file_id = main_controller.manager.new_file
    new_translator_view(file_id)
    main_controller.main_view.add_new_file_page(file_id, view_for_file(file_id).root_widget)
  end

  def new_translator_view(file_id)
    register_view :translator_view, file_id
    view = view_for_file(file_id)

    view.plain_text_edit.connect(SIGNAL('textChanged()')) do
      self.manager.save_temp_markup_file(file_id, view.plain_text_edit.to_plain_text)
      display_browser_preview(file_id)
    end
  end

  def view_for_file(file_id)
    self.views[file_id.to_sym]
  end

  def display_browser_preview(file_id)
    path = self.manager.markup_translator_file(file_id).temp_markup_file_path
    view_for_file(file_id).display_browser_preview(path)
  end
end
