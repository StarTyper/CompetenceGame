class AddUniqueIndexToGamesShareCode < ActiveRecord::Migration[7.1]
  def change
    add_index :games, :share_code, unique: true
  end
end
