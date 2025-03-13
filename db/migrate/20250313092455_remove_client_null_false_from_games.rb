class RemoveClientNullFalseFromGames < ActiveRecord::Migration[7.1]
  def change
    change_column_null :games, :client_id, true
  end
end
