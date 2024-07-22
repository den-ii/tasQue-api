class RemovePhoneNoAsPrivateKey < ActiveRecord::Migration[7.1]
  def change
    change_table :otps do |t|
      t.change :phone_no, :string
      t.change :otp, :string, default: "43125"

    end
    remove_index :otps, :phone_no, unique: true
  end
end
