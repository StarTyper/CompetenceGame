class AddIndexToGamesChallengeCode < ActiveRecord::Migration[7.1]
  def change
    add_index :games, :challenge_code, unique: true
  end
end
