class AddPileAndPositiveToGame < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :pile, :integer, default: 0, null: false
    add_column :games, :positive, :boolean, default: true, null: false
  end
end
