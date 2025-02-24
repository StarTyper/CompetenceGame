class AddGroupToCards < ActiveRecord::Migration[7.1]
  def change
    add_column :cards, :group, :string, null: false
  end
end
