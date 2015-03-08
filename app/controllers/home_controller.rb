class HomeController < ApplicationController
  def view
    @screen_id = params[:screen_id]
  end
end
