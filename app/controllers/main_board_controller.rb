class MainBoardController < ApplicationController

  def hello
    @extra_text = params[:extra_text]
  end

  def setup
    store_board_in_session_cookie(Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH))
  end

  def start_game
    begin
      board = Board.new(params[:board_size_input].to_i, params[:row_length_input].to_i)
      store_board_in_session_cookie(board)
      render(:action => 'wait_for_move', :locals => { :board => board })
    rescue InvalidBoardException => e
      debugger
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
      render(:action => 'error', :locals => { :error_msg => "Invalid board" })
    end
  end

  def error
  end

  def wait_for_move
  end

  def move_made
    move = parse_move(params)
    if move
      logger.debug("Make move: #{move}")
      begin
        board_params = session[:board]
        board = Board.new(board_params[:board_size].to_i, board_params[:row_length].to_i,
                          board_params[:moves] + [move])
        store_board_in_session_cookie(board)
        render(:action => 'wait_for_move', :locals => { :board => board })
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

:private

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

end
