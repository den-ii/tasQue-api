class FixColumnName < ActiveRecord::Migration[7.1]
  def change
    rename_column :users, :photo_string, :photo
  end
end
