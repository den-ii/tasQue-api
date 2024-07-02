class CreateOtps < ActiveRecord::Migration[7.1]
  def change
    create_table :otps, id: false do |t|
      t.string :phone_no, primary_key: true
      t.string :otp
      t.boolean :verified, default: false

      t.timestamps
    end
    add_index :otps, :phone_no, unique: true
  end
end
