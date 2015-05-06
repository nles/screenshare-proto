Proto::Application.routes.draw do
  root 'home#index'
  get '/demo' => 'home#portal_demo'
  get '/extension-just-installed' => 'home#extension_just_installed'
  get '/:screen_id' => 'home#view'
end
