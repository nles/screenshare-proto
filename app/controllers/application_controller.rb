class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_language
  after_action :allow_iframe

  private
  def set_language
      I18n.locale = params[:lang].to_sym if params[:lang]
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
    #response.headers['X-Frame-Options'] = 'ALLOW-FROM http://alpha.ymme.info'
  end
end
