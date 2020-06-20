Rails.application.routes.draw do
  post '/callback' => 'scandals#callback'
end
