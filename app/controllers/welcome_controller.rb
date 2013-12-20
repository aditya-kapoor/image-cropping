class WelcomeController < ApplicationController
  def index
    @upload = Upload.new
  end
end
