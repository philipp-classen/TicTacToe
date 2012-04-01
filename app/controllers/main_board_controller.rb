class MainBoardController < ApplicationController

  def hello
    @extra_text = params[:extra_text]
  end

  def setup
  end

  def start_game
    @extra_text = "Setup is finished"
    render(:action => 'hello', :params => { :extra_text => 'Game starting...' })
  end

end
