class HomeController < ApplicationController
  def index
    @screen_id = params[:screen_id]
  end
end
