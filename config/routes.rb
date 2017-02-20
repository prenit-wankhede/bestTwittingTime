Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root "home#index"

  post "get_best_twit_time" => "home#get_best_twit_time"
end
