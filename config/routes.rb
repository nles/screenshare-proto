Proto::Application.routes.draw do
  root 'home#index'
  get '/extension-just-installed' => 'home#extension_just_installed'
  get '/:screen_id' => 'home#view'
end
