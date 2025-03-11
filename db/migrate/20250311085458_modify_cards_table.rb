class ModifyCardsTable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :cards, :namegerman, true
    change_column_null :cards, :groupgerman, true
    change_column_null :cards, :groupenglish, true
    rename_column :cards, :categoryenglish, :category
    remove_column :cards, :categorygerman
  end
end
