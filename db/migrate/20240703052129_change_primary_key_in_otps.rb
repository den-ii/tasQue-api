class ChangePrimaryKeyInOtps < ActiveRecord::Migration[7.1]
  def change
    remove_column :otps, :phone_no, :string, primary_key: true
    
    add_column :otps, :phone_no, :string
    
    add_column :otps, :id, :primary_key
    
    add_index :otps, :phone_no, unique: true, where: 'verified != true'
  end
end
