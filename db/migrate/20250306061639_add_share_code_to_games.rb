class AddShareCodeToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :share_code, :string
  end
end
