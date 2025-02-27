class AddGroupCountsToGame < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :group_positive, :integer, default: 0, null: false
    add_column :games, :group_negative, :integer, default: 0, null: false
  end
end
