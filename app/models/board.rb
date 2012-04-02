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

  def winner?
    @winner
  end

  def is_game_over?
    @winner || @moves.size == @board_size * @board_size
  end

  def to_s
    (0..@board_size-1).map { |row| @squares[row].join(' ') }.join("\n")
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

    # check for diagonal wins (start in the lower-left corner):
    for i in (0..@board_size-1)
      delta = i == 0 ? [[0,0]] : [[-i,0], [0,i]]
      for d in delta
        x, y = [@board_size-1, 0] # lower left
        x += d[0]
        y += d[1]

        counter = @squares[x][y] == side ? 1 : 0
        while (0..@board_size-1) === (x - 1) && (0..@board_size-1) === (y + 1)
          x -= 1
          y += 1
          if @squares[x][y] == side
            counter += 1
            return true if counter >= @row_length
          else
            counter = 0
          end
        end
      end
    end

    # check for anti-diagonal wins (start in the lower-right corner):
    for i in (0..@board_size-1)
      delta = i == 0 ? [[0,0]] : [[-i,0], [0,-i]]
      for d in delta
        x, y = [@board_size-1, @board_size-1] # lower right
        x += d[0]
        y += d[1]

        counter = @squares[x][y] == side ? 1 : 0
        while (0..@board_size-1) === (x - 1) && (0..@board_size-1) === (y - 1)
          x -= 1
          y -= 1
          if @squares[x][y] == side
            counter += 1
            return true if counter >= @row_length
          else
            counter = 0
          end
        end
      end
    end

    return false
  end

end
