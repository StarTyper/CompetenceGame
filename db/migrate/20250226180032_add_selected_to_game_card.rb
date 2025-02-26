class AddSelectedToGameCard < ActiveRecord::Migration[7.1]
  def change
    add_column :game_cards, :selected, :boolean, default: false
  end
end
