class HomeController < ApplicationController
  def extension_just_installed
    @extension_just_installed = true
    render 'index'
  end
  def view
    @screen_id = params[:screen_id]
  end
end
