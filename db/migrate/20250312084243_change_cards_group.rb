class ChangeCardsGroup < ActiveRecord::Migration[7.1]
  def change
    remove_column :cards, :groupgerman, :string
    rename_column :cards, :groupenglish, :group

    change_column_null :cards, :client_id, true # Change client_id to allow null values
  end
end
