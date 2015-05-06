class HomeController < ApplicationController
  def portal_demo
    render 'portal_demo', :layout => 'portal_demo'
  end
  def extension_just_installed
    @extension_just_installed = true
    render 'index'
  end
  def view
    @screen_id = params[:screen_id]
  end
end
