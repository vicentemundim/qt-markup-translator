class TranslatorView < ApplicationView
  root :translator_frame
  use_builder

  def display_browser_preview(path)
    self.browser.html = File.read(path)
  end
end
