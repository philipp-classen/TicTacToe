class CreateGameLogs < ActiveRecord::Migration
  def change
    create_table :game_logs do |t|
      t.integer :board_size
      t.integer :row_length
      t.integer :result
      t.boolean :first_move

      t.timestamps
    end
  end
end
