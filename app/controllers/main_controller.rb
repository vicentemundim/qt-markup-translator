class MainController < RuGUI::BaseMainController
  def setup_models
    register_model :manager
  end

  def setup_controllers
    #register_controller :translator_controller
  end

  def setup_views
    register_view :main_view
    register_view :about_view
  end

  on :action_new, 'activated()' do
    puts 'new'
  end

  on :action_about, 'activated()' do
    self.about_view.about_dialog.show
  end

  on :action_quit, 'activated()' do
    quit
  end
end