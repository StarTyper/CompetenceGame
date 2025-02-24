class CreateGameCards < ActiveRecord::Migration[7.1]
  def change
    create_table :game_cards do |t|
      t.references :game, null: false, foreign_key: true
      t.references :card, null: false, foreign_key: true
      t.integer :pile, null: false
      t.integer :group, null: false

      t.timestamps
    end
  end
end
