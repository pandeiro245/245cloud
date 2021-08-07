class AddArtworkUrlToWorkload < ActiveRecord::Migration[4.2]
  def change
    add_column :workloads, :artwork_url, :string
  end
end
