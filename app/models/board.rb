class BoardException < Exception
end

class InvalidMoveException < BoardException
end

class InvalidBoardException < BoardException
end

class Board

  attr_reader :board_size, :row_length
  
  def initialize(board_size, row_length, moves = [])
    @board_size = board_size
    @row_length = row_length
    raise InvalidBoardException unless is_setup_valid?

    @squares = (1..board_size).map { (1..board_size).map { ' ' } }
    @moves = []
    @winner = nil

    moves.each do |m|
      raise InvalidMoveException if m.class != Array || m.size != 2
      make_move(:row => m[0], :column => m[1])
    end
  end

  def [](row)
    @squares[row].dup
  end

  def moves
    @moves.dup
  end

  def next_to_move?
    @moves.size % 2 == 0 ? 'x' : 'o'
  end

  def make_move(params)
    row    = params[:row]
    column = params[:column]
    raise InvalidMoveException, "row=#{row}, column=#{column}" unless is_valid_move?(row, column)

    @squares[row][column] = next_to_move?
    @moves << [row, column]
    @winner = compute_winner
  end

  def generate_legal_moves?
    return [] if is_game_over?

    moves = []
    for row in (0..@board_size-1)
      for column in (0..@board_size-1)
        moves << { :row => row, :column => column } if @squares[row][column] == ' '
      end
    end
    return moves
  end

  def winner?
    @winner
  end

  def is_game_over?
    @winner || @moves.size == @board_size * @board_size
  end

  def to_s
    (0..@board_size-1).map { |row| @squares[row].join(' ') }.join("\n")
  end

  def pack_board
    @squares.flatten.join
  end

  def make_move_on_packed_board(packed_board, move)
    result = packed_board.dup
    index  = move[:row] * @board_size + move[:column]
    result[index] = next_to_move?
    return result
  end

:private

  def is_setup_valid?
    return (MIN_BOARD_SIZE..MAX_BOARD_SIZE) === @board_size &&
           (MIN_ROW_LENGTH..MAX_ROW_LENGTH) === @row_length &&
           @row_length <= @board_size
  end

  def is_valid_move?(row, column)
    return (0..@board_size-1) === row && (0..@board_size-1) === column &&
      @squares[row][column] == ' ' && !winner?
  end

  def compute_winner
    return nil if @moves.size < @row_length

    return 'x' if find_win_for('x')
    return 'o' if find_win_for('o')
    return nil
  end

  def find_win_for(side)
    # check for horizontal wins:
    for row in (0..@board_size-1)
      counter = 0
      for col in (0..@board_size-1)
        if @squares[row][col] == side
          counter += 1
          return true if counter >= @row_length
        else
          counter = 0
        end
      end
    end

    # check for vertical wins:
    for col in (0..@board_size-1)
      counter = 0
      for row in (0..@board_size-1)
        if @squares[row][col] == side
          counter += 1
          return true if counter >= @row_length
        else
          counter = 0
        end
      end
    end

    lower_left  = [@board_size-1, 0]
    lower_right = [@board_size-1, @board_size-1]

    one_up    = [-1, 0]
    one_right = [ 0, 1]
    one_left  = [ 0,-1]

    one_up_and_left  = [-1, -1]
    one_up_and_right = [-1,  1]

    # check for diagonal wins
    for type in [:diagonal, :anti_diagonal]
      if type == :diagonal
        start_point = lower_left
        delta_options = [one_up, one_right]
        x_step, y_step = one_up_and_right
      else
        start_point   = lower_right
        delta_options = [one_up, one_left]
        x_step, y_step = one_up_and_left
      end

      for i in (0..@board_size-@row_length)
        delta = i == 0 ? [[0,0]] : delta_options
        for delta in delta_options
          x = start_point[0] + delta[0] * i
          y = start_point[1] + delta[1] * i

          counter = @squares[x][y] == side ? 1 : 0
          while (0..@board_size-1) === (x + x_step) && (0..@board_size-1) === (y + y_step)
            x += x_step
            y += y_step
            if @squares[x][y] == side
              counter += 1
              return true if counter >= @row_length
            else
              counter = 0
            end
          end
        end
      end
    end

    return false
  end

end
