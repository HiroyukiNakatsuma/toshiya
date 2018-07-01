class ApplicationController < ActionController::Base

  def hello
    render 'hello/index'
  end
end
