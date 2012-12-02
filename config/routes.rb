Rails.application.routes.draw do
  put 'mercury_pages_update' => 'mercury_pages#update'
  get 'pages/*id' => 'pages#show'
end
