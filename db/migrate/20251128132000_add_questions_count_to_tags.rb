class AddQuestionsCountToTags < ActiveRecord::Migration[6.1]
  def change
    add_column :tags, :questions_count, :integer, default: 0, null: false
    
    # Update the counter cache for existing tags
    Tag.find_each do |tag|
      Tag.reset_counters(tag.id, :questions)
    end
  end
end
