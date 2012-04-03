class MainBoardController < ApplicationController

  def hello
    @extra_text = params[:extra_text]
  end

  def setup
    store_board_in_session_cookie(Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH))
  end

  def start_game
    board_size = params[:board_size_input].to_i
    row_size   = params[:row_length_input].to_i
    first_move = params[:first_move_input]

    start_game_helper(board_size, row_size, first_move)
  end

  def error
  end

  def wait_for_move
  end

  def game_over
  end

  def move_made
    move = parse_move(params)
    if move
      logger.debug("Make move: #{move}")
      begin
        board_params = session[:board]
        move_number = params[:move_number].to_i
        if move_number > 0
          move_list = board_params[:moves][0..move_number-1]
        else
          move_list = []
        end
        move_list << move
        board = Board.new(board_params[:board_size].to_i, board_params[:row_length].to_i, move_list)
        board = make_computer_move(board) unless board.is_game_over?

        store_board_in_session_cookie(board)
        render(:action => 'wait_for_move', :locals => { :board => board, :title => compute_title(board) })

        if board.is_game_over?
          Position.store_game(board)
          GameHistory.store_game(board, session[:computer])
        end

      rescue InvalidBoardException => e
        logger.error("board_params=#{board_params.inspect}")
        logger.error(e.message)
        logger.error(e.backtrace.join("\n"))
        render(:action => 'error', :locals => { :error_msg => "Invalid board" })
      rescue InvalidMoveException => e
        logger.error(e.message)
        logger.error(e.backtrace.join("\n"))
        render(:action => 'error', :locals => { :error_msg => "Invalid move" })
      rescue e
        logger.error(e.message)
        logger.error(e.backtrace.join("\n"))
        render(:action => 'error', :locals => { :error_msg => "Unknown error" })
      end

    else
      logger.error("Failed to parse move: params=#{params.inspect}")
      render(:action => 'error', :locals => { :error_msg => "Could not parse move" })
    end
  end

  def next_game
    board_size = session[:board][:board_size]
    row_size   = session[:board][:row_length]
    first_move = session[:computer] == 'x' ? 'o' : 'x'

    start_game_helper(board_size, row_size, first_move)
  end

  def back_to_setup
    render(:action => 'setup')
  end

:private

  def start_game_helper(board_size, row_size, first_move)
    begin
      board = Board.new(board_size, row_size)
      computer_side = first_move == 'x' ? 'x' : 'o'
      board = make_computer_move(board) if computer_side == 'x'

      session[:computer] = computer_side
      store_board_in_session_cookie(board)
      render(:action => 'wait_for_move', :locals => { :board => board, :title => compute_title(board) })
    rescue InvalidBoardException => e
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
      render(:action => 'error', :locals => { :error_msg => "Invalid board" })
    end
  end

  def store_board_in_session_cookie(board)
    session[:board] = { :board_size => board.board_size, :row_length => board.row_length, :moves => board.moves }
  end

  def parse_move(request_params)
    moves = request_params.keys.map { |x| if x =~ /move_([0-9]+)_([0-9]+)/ then [$1, $2] else nil end }.select { |x| x }
    if moves.size == 1
      row, column = moves[0]
      return [row.to_i, column.to_i]
    else
      return nil # failed to parse move
    end
  end

  def compute_title(board)
    if board.winner?
      return session[:computer] == board.winner? ? 'Computer won!' : 'Player won!'
    else
      return board.is_game_over? ? "It's a draw." : "It's your turn..."
    end
  end

  def make_computer_move(board)
    move = Position.get_best_move(board)
    board.make_move(move)
    return board
  end

end
