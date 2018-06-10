Rails.application.routes.draw do
  root 'application#hello'
  post '/lines/message'
end
