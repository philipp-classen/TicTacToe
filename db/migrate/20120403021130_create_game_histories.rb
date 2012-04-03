class CreateGameHistories < ActiveRecord::Migration
  def change
    create_table :game_histories do |t|
      t.string :board
      t.integer :board_size
      t.integer :row_length
      t.integer :wins
      t.integer :losses
      t.integer :draws

      t.timestamps
    end

    add_index(:game_histories, :board)
  end
end
