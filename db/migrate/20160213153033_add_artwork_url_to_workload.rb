class AddArtworkUrlToWorkload < ActiveRecord::Migration
  def change
    add_column :workloads, :artwork_url, :string
  end
end
