class ChangeSharedWithUserIdAndRemoveSharedInGames < ActiveRecord::Migration[7.1]
  def change
    # Rename the shared_with_user_id column to shared_from_user_id
    rename_column :games, :shared_with_user_id, :shared_from_user_id

    # Remove the shared column
    remove_column :games, :shared
  end
end
