class AddLanguageToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :language, :string, default: 'english', null: false
  end
end
