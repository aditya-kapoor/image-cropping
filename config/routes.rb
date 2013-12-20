ImageCropping::Application.routes.draw do
  resources :uploads do 
    get :crop, on: :member
  end
  root to: "welcome#index"
end
