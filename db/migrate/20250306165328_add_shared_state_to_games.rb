class AddSharedStateToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :shared_state, :integer, default: 0, null: false
  end
end
