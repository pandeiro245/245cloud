class Integer2stringInFacebookId < ActiveRecord::Migration
  def change
    change_column :users, :facebook_id, :string
    change_column :workloads, :facebook_id, :string
    change_column :comments, :facebook_id, :string
  end
end
