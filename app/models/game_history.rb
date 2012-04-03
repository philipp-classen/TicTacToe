class GameHistory < ActiveRecord::Base
  attr_accessible :board, :board_size, :draws, :losses, :row_length, :wins

  def self.store_game(board, computer_side)
    tmp_board = Board.new(board.board_size, board.row_length)

    board.moves.each do |m|
      move = { :row => m[0], :column => m[1] }
      tmp_board.make_move(move)
      packed_board = tmp_board.pack_board
      
      stats = where(:board_size => tmp_board.board_size,
                    :row_length => tmp_board.row_length,
                    :board      => packed_board).first
      stats ||= GameHistory.new(:board      => packed_board,
                                :board_size => tmp_board.board_size,
                                :row_length => tmp_board.row_length,
                                :draws      => 0,
                                :losses     => 0,
                                :wins       => 0)

      if board.is_game_over? && !board.winner?
        stats.draws += 1
      elsif board.winner? == computer_side
        stats.wins += 1
      else board.winner?
        stats.losses += 1
      end
      stats.save
    end
  end

  def self.pick_most_promising_move(board, moves = nil, packed_boards = nil)
    moves ||= board.generate_legal_moves?
    if packed_boards == nil
      packed_boards = {}
      tmp_packed_board = board.pack_board
      moves.each do |m|
        packed_boards[m] = board.make_move_on_packed_board(tmp_packed_board, m)
      end
    end

    best_score = nil
    best_moves = []

    moves.each do |m|
      stats = where(:board_size => board.board_size,
                    :row_length => board.row_length,
                    :board      => packed_boards[m]).first
      if stats
        score = compute_score(stats.wins, stats.losses, stats.draws)
      else
        score = compute_score(0, 0, 0)
      end
      if best_score == nil || score >= best_score
        if best_score == nil || score > best_score
          best_moves = []
          best_score = score
        end
        best_moves << m
      end
    end
    logger.info("best_score=#{best_score}")
    return best_moves[rand(best_moves.size)]
  end

  :private

  def self.compute_score(wins, losses, draws)
    total = wins + losses + draws
    if total == 0
      return 0.2
    else
      return (3 * wins + draws) / (4 * total).to_f
    end
  end

end
