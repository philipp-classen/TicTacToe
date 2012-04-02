require 'test_helper'

class MainBoardHelperTest < ActionView::TestCase

  test "should create a board with default settings" do
    board = Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH)
    assert_equal(DEFAULT_BOARD_SIZE, board.board_size)
    assert_equal(DEFAULT_ROW_LENGTH, board.row_length)
    assert_equal([], board.moves)
    assert_nil(board.winner?)
    assert(!board.is_game_over?)
  end

  ##
  # x x x
  # o o
  #
  test "should detect a horizontal win by 'x' on a 3x3 board" do
    moves = [[0,0], [1,0], [0,1], [1,1], [0,2]]
    board = Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH, moves)

    assert_equal(moves, board.moves)
    assert_equal('x', board.winner?)
    assert(board.is_game_over?)
  end

  ##
  # x x x
  # o o
  #
  test "should detect a horizontal win by 'x' on a 3x3 board (verbose)" do
    board = Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH)
    moves = [[0,0], [1,0], [0,1], [1,1], [0,2]]

    move_list = []
    moves.each do |row, column|
      assert_nil(board.winner?)
      assert_equal(move_list, board.moves)
      assert(!board.is_game_over?)

      board.make_move(:row => row, :column => column)

      move_list << [row, column]
      assert_equal(board.moves, move_list)
      if move_list.size == moves.size
        assert(board.winner?)
        assert_equal('x', board.winner?)
        assert(board.is_game_over?)
      else
        assert_nil(board.winner?)
        assert(!board.is_game_over?)
      end
    end
  end

  ##
  # x x 
  # o o o
  # x
  test "should detect a horizontal win by 'o' on a 3x3 board" do
    moves = [[0,0], [1,0], [0,1], [1,1], [2,0], [1,2]]
    board = Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH, moves)

    assert_equal(moves, board.moves)
    assert_equal('o', board.winner?)
    assert(board.is_game_over?)
  end

  ##
  # x x o
  # o o x
  # x o x
  test "should detect a draw on a 3x3 board (xxo_oox_xox)" do
    moves = [[0,0], [1,0], [0,1], [1,1], [2,0], [2,1], [1,2], [0,2], [2,2]]
    board = Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH, moves)

    assert_equal(moves, board.moves)
    assert_nil(board.winner?)
    assert(board.is_game_over?)
  end

  ##
  # x o
  # x o
  # x
  test "should detect a vertical win by 'x' on a 3x3 board" do
    moves = [[0,0], [0,1], [1,0], [1,1], [2,0]]
    board = Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH, moves)

    assert_equal(moves, board.moves)
    assert_equal('x', board.winner?)
    assert(board.is_game_over?)
  end

  ##
  # x o x
  # x o
  #   o
  test "should detect a vertical win by 'o' on a 3x3 board" do
    moves = [[0,0], [0,1], [1,0], [1,1], [0,2], [2,1]]
    board = Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH, moves)

    assert_equal(moves, board.moves)
    assert_equal('o', board.winner?)
    assert(board.is_game_over?)
  end

  ##
  # x x x
  # o x
  # o   o
  test "should detect a row win by 'x' on a 3x3 board (xxx_ox?_o?o)" do
    moves = [[1,1], [1,0], [0,2], [2,0], [0,0], [2,2], [0,1]]
    board = Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH, moves)

    assert_equal(moves, board.moves)
    assert_equal('x', board.winner?)
    assert(board.is_game_over?)
  end

  ##
  # x   x
  # o x x
  # o o o
  test "should detect a row win by 'o' on a 3x3 board (x?x_oxx_ooo)" do
    moves = [[1,1], [1,0], [0,2], [2,0], [0,0], [2,2], [1,2], [2,1]]
    board = Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH, moves)

    assert_equal(moves, board.moves)
    assert_equal('o', board.winner?)
    assert(board.is_game_over?)
  end

  ##
  # x o x
  # o x x
  # o x o
  test "should detect a draw on a 3x3 board (xox_oxx_oxo)" do
    moves = [[1,1], [1,0], [0,2], [2,0], [0,0], [2,2], [1,2], [0,1], [2,1]]
    board = Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH, moves)

    assert_equal(moves, board.moves)
    assert_nil(board.winner?)
    assert(board.is_game_over?)
  end

  ##
  #     x
  # o x
  # x   o
  test "should detect a diagonal win by 'x' on a 3x3 board (??x_ox?_x?o)" do
    moves = [[2,0], [1,0], [2,0], [2,2], [1,1]]
    board = Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH, moves)

    assert_equal(moves, board.moves)
    assert_equal('x', board.winner?)
    assert(board.is_game_over?)
  end

  ##
  # x   o
  # x o
  # o   x
  test "should detect a diagonal win by 'o' on a 3x3 board (x?o_xo?_o?x)" do
    moves = [[0,0], [2,0], [1,0], [2,0], [2,2], [1,1]]
    board = Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH, moves)

    assert_equal(moves, board.moves)
    assert_equal('o', board.winner?)
    assert(board.is_game_over?)
  end

  ##
  # x o o
  #   x
  #     x
  test "should detect an anti-diagonal win by 'x' on a 3x3 board (xoo_?x?_??x)" do
    moves = [[0,0], [0,1], [1,1], [0,2], [2,2]]
    board = Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH, moves)

    assert_equal(moves, board.moves)
    assert_equal('x', board.winner?)
    assert(board.is_game_over?)
  end

  ##
  # o x x
  # x o
  #     o
  test "should detect an anti-diagonal win by 'o' on a 3x3 board (oxx_xo?_??o)" do
    moves = [[1,0], [0,0], [0,1], [1,1], [0,2], [2,2]]
    board = Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH, moves)

    assert_equal(moves, board.moves)
    assert_equal('o', board.winner?)
    assert(board.is_game_over?)
  end

end