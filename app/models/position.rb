class Position < ActiveRecord::Base

  attr_accessible :board, :board_size, :result, :row_length

  RESULT_DRAW   = 0
  RESULT_X_WINS = 1
  RESULT_O_WINS = 2

  def self.get_best_move(board)
    packed_board = board.pack_board

    moves = board.generate_legal_moves?
    winning_moves = []
    drawing_moves = []
    unknown_moves = []

    moves_to_packed_board = {}

    moves.each do |m|
      new_packed_board = board.make_move_on_packed_board(packed_board, m)
      moves_to_packed_board[m] = new_packed_board

      position = where(:board_size => board.board_size,
                       :row_length => board.row_length,
                       :board      => new_packed_board).first
      if position
        case position.result
        when RESULT_DRAW
          drawing_moves << m
        when RESULT_X_WINS
          winning_moves << m if board.next_to_move? == 'x'
        when RESULT_O_WINS
          winning_moves << m if board.next_to_move? == 'o'
        else
          raise 'Corrupted database entry found.'
        end
      else
        d = Time.new
        logger.debug("Calling board.move_is_decisive?(m)...")
        winner = board.move_is_decisive?(m)
        logger.debug("Calling board.move_is_decisive?(m)...done #{Time.new - d} sec")
        if winner
          if board.next_to_move? == winner
            logger.debug("Winning move found: #{m}")
            winning_moves << m
          else
            logger.debug("Skipping loosing move: #{m}")
          end
        else
          unknown_moves << m
        end
      end
    end

    if unknown_moves.empty? && where(:board_size => board.board_size,
                                     :row_length => board.row_length,
                                     :board      => packed_board).first == nil
      if !winning_moves.empty?
        result = board.next_to_move? == 'x' ? RESULT_X_WINS : RESULT_O_WINS
      elsif !drawing_moves.empty?
        result = RESULT_DRAW
      else
        result = board.next_to_move? == 'x' ? RESULT_O_WINS : RESULT_X_WINS
      end


      logger.info("Learned new position:\n#{board}\nresult=#{result}")
      Position.create(:board      => packed_board,
                      :board_size => board.board_size,
                      :row_length => board.row_length,
                      :result     => result)
    end

    pick = lambda { |choices|
      GameHistory.pick_most_promising_move(board, choices, moves_to_packed_board)
    }

    return winning_moves[rand(winning_moves.size)] if !winning_moves.empty?
    return pick.call(unknown_moves) if !unknown_moves.empty?
    return pick.call(drawing_moves) if !drawing_moves.empty?

    if !moves.empty?
      return pick.call(moves)
    else
      raise 'No legal move found.'
    end
  end

  def self.store_game(board)
    return unless board.is_game_over?

    packed_board = board.pack_board
    if where(:board_size => board.board_size,
             :row_length => board.row_length,
             :board      => packed_board).first == nil
      case board.winner?
      when 'x'
        result = RESULT_X_WINS
      when 'o'
        result = RESULT_O_WINS
      else
        result = RESULT_DRAW
      end

      pos = Position.new(:board      => packed_board,
                         :board_size => board.board_size,
                         :row_length => board.row_length,
                         :result     => result)
      pos.save

      # also remember that the last position is also won
      if result != RESULT_DRAW
        prev_board = Board.new(board.board_size, board.row_length, board.moves[0..-2])
        prev_packed_board = prev_board.pack_board
        if where(:board_size => prev_board.board_size,
                 :row_length => prev_board.row_length,
                 :board      => prev_packed_board).first == nil
          prev_pos = Position.new(:board      => prev_packed_board,
                                  :board_size => prev_board.board_size,
                                  :row_length => prev_board.row_length,
                                  :result     => result)
          prev_pos.save
        end
      end
            
    end
  end

end
