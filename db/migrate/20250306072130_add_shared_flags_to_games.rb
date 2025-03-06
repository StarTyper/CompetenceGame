class AddSharedFlagsToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :shared, :boolean
    add_column :games, :shared_with_user_id, :integer
  end
end
