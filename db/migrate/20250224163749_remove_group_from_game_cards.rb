class RemoveGroupFromGameCards < ActiveRecord::Migration[7.1]
  def change
    remove_column :game_cards, :group, :integer
  end
end
