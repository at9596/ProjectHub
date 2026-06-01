class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.string :action, null: false
      t.string :subject_type
      t.bigint :subject_id
      t.references :user, null: false, foreign_key: true
      t.references :project, null: true, foreign_key: true
      t.jsonb :metadata, default: {}

      t.timestamps
    end
    add_index :activities, [ :subject_type, :subject_id ]
    add_index :activities, :created_at
  end
end
