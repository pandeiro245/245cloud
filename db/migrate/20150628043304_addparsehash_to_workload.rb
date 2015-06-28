class AddparsehashToWorkload < ActiveRecord::Migration
  def change
    add_column :workloads, :parsehash, :string
    add_column :comments, :parsehash, :string
  end
end
