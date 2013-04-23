Hydra::Collections::Engine.routes.draw do 
  resources :collections, except: :index
end