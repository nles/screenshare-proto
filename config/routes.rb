Proto::Application.routes.draw do
  root 'home#index'
  get '/:screen_id' => 'home#index'
end
