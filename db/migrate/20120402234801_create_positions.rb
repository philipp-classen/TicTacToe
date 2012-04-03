class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.string :board
      t.integer :board_size
      t.integer :row_length
      t.integer :result

      t.timestamps
    end

    add_index(:positions, :board)
  end
end
