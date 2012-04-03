RESULT_DRAW   = 0
RESULT_X_WINS = 1
RESULT_O_WINS = 2

class Position < ActiveRecord::Base
  attr_accessible :board, :board_size, :result, :row_length

  def self.get_best_move(board)
    packed_board = board.pack_board

    moves = board.generate_legal_moves?.shuffle
    known_positions = {}
    winning_moves = []
    drawing_moves = []
    unknown_moves = []

    moves.each do |m|
      new_packed_board = board.make_move_on_packed_board(packed_board, m)
      position = where(:board_size => board.board_size,
                       :row_length => board.row_length,
                       :board      => new_packed_board).first
      if position
        known_positions[new_packed_board] = { :position => position, :move => m }
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
        unknown_moves << m
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

      pos = Position.new(:board      => packed_board,
                         :board_size => board.board_size,
                         :row_length => board.row_length,
                         :result     => result)
      pos.save
    end

    return winning_moves[rand(winning_moves.size)] if !winning_moves.empty?
    return unknown_moves[rand(unknown_moves.size)] if !unknown_moves.empty?
    return drawing_moves[rand(drawing_moves.size)] if !drawing_moves.empty?

    if !moves.empty?
      return moves[rand(moves.size)]
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
