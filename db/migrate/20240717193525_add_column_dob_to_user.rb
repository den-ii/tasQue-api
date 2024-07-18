class AddColumnDobToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :dob, :date
  end
end
