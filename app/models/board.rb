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

  def make_move(move)
    row    = move[:row]
    column = move[:column]
    raise InvalidMoveException, "row=#{row}, column=#{column}" unless is_valid_move?(row, column)

    @squares[row][column] = next_to_move?
    @moves << [row, column]
    @winner = compute_winner
  end


  def undo_move
    raise InvalidMoveException, "no move to undo" if @moves.empty?

    row, column = @moves[-1]
    @squares[row][column] = ' '
    @moves = @moves[0..-2]
    @winner = nil
  end

  ##
  # If the winner can be deduced by a static analysis,
  # the function will 'x' or 'o'. Otherwise, nil is returned.
  #
  def move_is_decisive?(move)
    begin
      make_move(move)
      if @winner
        return @winner
      else
        return double_threat_analysis
      end
    ensure
      undo_move
    end
    return nil
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

  ##
  # The last move is always winning if the other side -- the defender --
  # has no immediate winning move, but the attacker has two wins.
  #
  # Simplifications:
  # - One of the winning moves must be connected to the last move
  # - For the second move, only the connected moves are considered
  #
  def double_threat_analysis

    attacker = next_to_move?
    defender = attacker == 'x' ? 'o' : 'x'

    all_attacker_moves_loose = true
    generate_legal_moves?.each do |attackers_move|
      begin
        make_move(attackers_move)
        if winner?
          raise RuntimeError, "board=#{self.to_s}" unless @winner == attacker
          return attacker
        end

        defender_wins = generate_legal_moves?.any? { |m| is_win(m, defender) }
        unless defender_wins
          all_attacker_moves_loose = false
          get_neighbor_squares(attackers_move[:row], attackers_move[:column]).each do |m|
            if is_win(m, attacker)
              double_thread_found = get_connected_squares(m[:row], m[:column]).any? do |m2|
                is_win(m2, attacker)
              end
              if double_thread_found
                return attacker
              else
                break
              end
            end
          end
        end
      ensure
        undo_move
      end
    end

    return all_attacker_moves_loose ? defender : nil
  end

  def is_win(move, side)
    if @squares[move[:row]][move[:column]] != ' '
      raise InvalidMoveException, 'Square #{move} is already occupied'
    end

    for dx in [-1,0,1]
      for dy in [-1,0,1]
        if dx != 0 || dy != 0
          win = (1..@row_length-1).all? do |i|
            x = i * dx + move[:row]
            y = i * dy + move[:column]
            (0..@board_size-1) === x && (0..@board_size-1) === y && @squares[x][y] == side
          end
          return true if win
        end
      end
    end
    return false
  end

  ##
  # Returns the list of squares with a distance of one.
  # ("King"-like moves from the current square)
  #
  #  -------
  # | - N N |
  # | - N # |
  # | - N N |
  #  -------
  def get_neighbor_squares(row, column)
    result = []
    for dx in [-1,0,1]
      for dy in [-1,0,1]
        x, y = row + dx, column + dy
        if (dx != 0 || dy != 0) && (0..@board_size-1) === x && (0..@board_size-1) === y
          result << { :row => x, :column => y } if @squares[x][y] == ' '
        end
      end
    end
    return result
  end

  ##
  # Queen-like moves from the current square.
  #
  #  -------
  # | - N N |
  # | N N # |
  # | - N N |
  #  -------
  def get_connected_squares(row, column)
    result = []
    for dx in [-1,0,1]
      for dy in [-1,0,1]
        if dx != 0 || dy != 0
          sq_x = row + dx
          sq_y = column + dy
          while (0..@board_size-1) === sq_x && (0..@board_size-1) === sq_y
            result << { :row => sq_x, :column => sq_y } if @squares[sq_x][sq_y] == ' '
            sq_x += dx
            sq_y += dy
          end
        end
      end
    end
    return result
  end

end

