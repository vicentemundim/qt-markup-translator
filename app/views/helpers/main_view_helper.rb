class MainViewHelper < ApplicationViewHelper
  observable_property :opened_files, :initial_value => {}

  def post_registration(view)
    @view = view
  end

  def open_file(file_id)
    self.opened_files[file_id] = {:page_number => new_page_id}
  end

  def page_number_for(file_id)
    self.opened_files[file_id][:page_number] unless self.opened_files[file_id].blank?
  end

  def page_index_for(file_id)
    page_number_for(file_id) - 1
  end

  def new_page_id
    @view.files_notebook.count + 1
  end
end
