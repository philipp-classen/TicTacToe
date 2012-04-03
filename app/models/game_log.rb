# used within the database
RESULT_WIN  = 1
RESULT_DRAW = 0
RESULT_LOSS = -1

require 'position'

class GameLog < ActiveRecord::Base
  attr_accessible :board_size, :row_length, :first_move, :result

  def self.store_game(board, computer_side)
    return unless board.is_game_over?

    first_move = computer_side == 'x'

    if board.winner?
      result = board.winner? == computer_side ? RESULT_WIN : RESULT_LOSS
    else
      result = RESULT_DRAW
    end

    game_log = GameLog.new(:board_size => board.board_size,
                           :row_length => board.row_length,
                           :first_move => first_move,
                           :result     => result)
    game_log.save
  end

end
