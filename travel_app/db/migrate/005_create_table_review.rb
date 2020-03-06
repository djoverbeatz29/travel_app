class CreateTableReview < ActiveRecord::Migration[5.2]
    def change
        create_table :reviews do |t|
            t.text :content
            t.integer :rating
            t.integer :user_id
            t.integer :site_id
        end
    end
end