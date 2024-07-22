class GreetingsController < ApplicationController

  def index
    # render file: 'app/views/index.html.erb', layout: false
    render html: 'Welome to TasQue API'
  end

end