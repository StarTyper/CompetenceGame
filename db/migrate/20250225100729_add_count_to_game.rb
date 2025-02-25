class AddCountToGame < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :count_positive, :integer, default: 10, null: false
    add_column :games, :count_negative, :integer, default: 5, null: false
  end
end
