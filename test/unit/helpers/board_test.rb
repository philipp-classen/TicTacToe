require 'test_helper'

class MainBoardHelperTest < ActionView::TestCase

  test "should create a board with default settings" do
    board = Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH)
    assert_equal(DEFAULT_BOARD_SIZE, board.board_size)
    assert_equal(DEFAULT_ROW_LENGTH, board.row_length)
    assert_equal([], board.moves)
    assert_nil(board.winner?)
  end

  test "should detect a simple vertical column win on a 3x3 board" do
    moves = [[0,0], [1,0], [0,1], [1,1], [0,2]]
    board = Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH, moves)

    assert_equal(moves, board.moves)
    assert_equal('x', board.winner?)
  end

  test "should detect a simple vertical column win on a 3x3 board (verbose)" do
    board = Board.new(DEFAULT_BOARD_SIZE, DEFAULT_ROW_LENGTH)
    moves = [[0,0], [1,0], [0,1], [1,1], [0,2]]

    move_list = []
    moves.each do |row, column|
      assert_nil(board.winner?)
      assert_equal(move_list, board.moves)
      board.make_move(:row => row, :column => column)

      move_list << [row, column]
      assert_equal(board.moves, move_list)
      if move_list.size == moves.size
        assert(board.winner?)
        assert_equal('x', board.winner?)
      else
        assert_nil(board.winner?)
      end
    end
  end

end
