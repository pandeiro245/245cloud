class CreateIssueWorkloads < ActiveRecord::Migration
  def change
    create_table :issue_workloads do |t|
      t.references :issue, index: true
      t.references :workload, index: true

      t.timestamps null: false
    end
    add_foreign_key :issue_workloads, :issues
    add_foreign_key :issue_workloads, :workloads
  end
end
