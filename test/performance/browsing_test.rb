require 'test_helper'
require 'rails/performance_test_help'

class BrowsingTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { :runs => 5, :metrics => [:wall_time, :memory]
  #                          :output => 'tmp/performance', :formats => [:flat] }

  def test_homepage
    get '/'
  end

  def test_first_move_on_6_6_row4_board
    post '/main_board/start_game', :board_size => 6, :row_size => 4, :first_move => 'x'
  end

  def test_first_move_on_10_10_row6_board
    return if MAX_BOARD_SIZE < 10
    post '/main_board/start_game', :board_size => 10, :row_size => 6, :first_move => 'x'
  end

end
