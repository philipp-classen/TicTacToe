class GameHistory < ActiveRecord::Base
  attr_accessible :board, :board_size, :row_length, :wins, :draws, :losses, :computer_on_move

  def self.store_game(board, computer_side)
    tmp_board = Board.new(board.board_size, board.row_length)

    board.moves.each do |m|
      move = { :row => m[0], :column => m[1] }
      computer_on_move = tmp_board.next_to_move? == computer_side
      tmp_board.make_move(move)
      packed_board = tmp_board.pack_board
      
      stats = where(:board_size       => tmp_board.board_size,
                    :row_length       => tmp_board.row_length,
                    :board            => packed_board,
                    :computer_on_move => computer_on_move).first
      stats ||= GameHistory.new(:board            => packed_board,
                                :board_size       => tmp_board.board_size,
                                :row_length       => tmp_board.row_length,
                                :wins             => 0,
                                :draws            => 0,
                                :losses           => 0,
                                :computer_on_move => computer_on_move)

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
      stats = where(:board_size       => board.board_size,
                    :row_length       => board.row_length,
                    :board            => packed_boards[m],
                    :computer_on_move => true).first
      if stats
        own_wins, own_losses, own_draws = stats.wins, stats.losses, stats.draws
      else
        own_wins, own_losses, own_draws = 0, 0, 0
      end

      enemy_stats = where(:board_size       => board.board_size,
                          :row_length       => board.row_length,
                          :board            => packed_boards[m],
                          :computer_on_move => false).first
      if enemy_stats
        enemy_wins   = enemy_stats.losses
        enemy_losses = enemy_stats.wins
        enemy_draws  = enemy_stats.draws
      else
        enemy_wins, enemy_losses, enemy_draws = 0, 0, 0
      end

      score = compute_score(own_wins, own_losses, own_draws,
                            enemy_wins, enemy_losses, enemy_draws)

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

  def self.compute_score(wins, losses, draws, enemy_wins, enemy_losses, enemy_draws)

    own_score   = compute_score_helper(wins, losses, draws)
    enemy_score = compute_score_helper(enemy_wins, enemy_losses, enemy_draws)

    return (3 * own_score + 2 * enemy_score) / 5.0
  end

  def self.compute_score_helper(wins, losses, draws)
    total = wins + losses + draws
    return 0.1 if total == 0

    if wins > losses
      wins += Math::log(wins)
      total = wins + losses + draws
    elsif wins < losses
      losses += Math::log(losses)
      total = wins + losses + draws
    end

    return (5 * wins + 3 * draws) / (8 * total).to_f
  end

end
