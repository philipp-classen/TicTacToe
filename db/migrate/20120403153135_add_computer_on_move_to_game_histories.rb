class AddComputerOnMoveToGameHistories < ActiveRecord::Migration
  def change
    add_column :game_histories, :computer_on_move, :boolean
  end
end
