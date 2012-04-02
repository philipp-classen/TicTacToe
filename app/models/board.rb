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
  end

:private

  def is_setup_valid?
    return (MIN_BOARD_SIZE..MAX_BOARD_SIZE) === @board_size &&
           (MIN_ROW_LENGTH..MAX_ROW_LENGTH) === @row_length &&
           @row_length <= @board_size
  end

  def is_valid_move?(row, column)
    return (0..@board_size-1) === row && (0..@board_size-1) === column &&
      @squares[row][column] == ' '
  end

end
