GeocodeAPI::Application.routes.draw do
  resources :searches
  resources :regions
  resources :districts
  resources :settlements
  resources :city_districts
  resources :official_neighborhoods
  resources :streets
  resources :cities
  #resources :streets, :defaults => { :format => 'xml' }
  #resources :cities, :defaults => { :format => 'xml' }

  root :to => "searches#index"
  match '/search' => "searches#index"
  match '/index' => "searches#index"
  match '/about' => "searches#about"
  match '/how_to' => "searches#how_to"

  match '/geo' => "geocodes#create"
  
#/maps/geo?key=AIzaSyBTItXCdVBstzYcH_7INBg__mYZ5A_AMrQ&output=xml&q=Rustaveli+Ave+Tbilisi

  resources :users
  match '/register' => "users#new", :as => "register"  

  resource :session
  match '/login' => "sessions#new", :as => "login"
  match '/logout' => "sessions#destroy", :as => "logout"  

  

match "/jeff" => "searches#do_it"

end
