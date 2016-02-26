class Comment < ActiveRecord::Base
  scope :roots, -> {
    where(parent_id: nil)
  }

  def self.sync
    self.fetch.each do |room|
      self.sync_one(room)
      self.fetch(room['id']).each do |cmnt|
        self.sync_one(cmnt)
      end
    end
    puts 'done'
  end

  def self.fetch parent_id = nil
    url = 'http://245cloud.com/api/comments.json'
    url += "?parent_id=#{parent_id}" if parent_id.present?
    uri = URI.parse(url)
    json = Net::HTTP.get(uri)
    JSON.parse(json)
  end

  def self.sync_one cmnt
    comment = Comment.find_or_create_by(
      id: cmnt['id']
    )
    created_at = Time.at(cmnt['created_at']/1000)
    comment.created_at =  created_at
    %w(body facebook_id parent_id).each do |key|
      comment.send("#{key}=", cmnt[key])
    end
    comment.save!
  end
end

