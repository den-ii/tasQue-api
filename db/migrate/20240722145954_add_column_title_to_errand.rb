class AddColumnTitleToErrand < ActiveRecord::Migration[7.1]
  def change
    add_column :errands, :title, :string
  end
end
