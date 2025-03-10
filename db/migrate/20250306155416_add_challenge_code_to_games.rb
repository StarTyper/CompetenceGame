class AddChallengeCodeToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :challenge_code, :string
  end
end
