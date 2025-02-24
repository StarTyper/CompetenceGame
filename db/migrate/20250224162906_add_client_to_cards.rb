class AddClientToCards < ActiveRecord::Migration[7.1]
  def change
    add_reference :cards, :client, null: false, foreign_key: true
  end
end
