class AddNumToComment < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :num, :integer, {default: 0}
  end
end
