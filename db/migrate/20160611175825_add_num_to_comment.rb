class AddNumToComment < ActiveRecord::Migration
  def change
    add_column :comments, :num, :integer, {default: 0}
  end
end
