class MainViewHelper < ApplicationViewHelper
  observable_property :opened_files, :initial_value => {}

  def post_registration(view)
    @view = view
  end

  def open_file(file_id)
    self.opened_files[file_id] = {:page_number => new_page_number}
  end

  def close_file(file_id)
    closed_file_options = self.opened_files.delete(file_id)
    self.opened_files.each do |file_id, file_options|
      if file_options[:page_number] > closed_file_options[:page_number]
        file_options[:page_number] -= 1
      end
    end
  end

  def page_number_for(file_id)
    self.opened_files[file_id][:page_number] unless self.opened_files[file_id].blank?
  end

  def page_index_for(file_id)
    page_number_for(file_id) - 1
  end

  def file_id_for(page_index)
    opened_file_opts = self.opened_files.select { |file_id, options| options[:page_number] == page_index + 1 }.first
    opened_file_opts.blank? ? nil : opened_file_opts[0]
  end

  def update_file_id(old_file_id, new_file_id)
    self.opened_files[new_file_id] = self.opened_files.delete(old_file_id)
  end

  def new_page_number
    @view.files_notebook.count + 1
  end
end
