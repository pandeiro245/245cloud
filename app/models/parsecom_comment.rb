class ParsecomComment < ParseResource::Base
  fields :body, :room_id, :user

  def self.hoge!
    Comment.delete_all
    ActiveRecord::Base.connection.execute('ALTER TABLE comments AUTO_INCREMENT = 0')
  end

  def self.sync refresh = false
    limit = refresh ? 99999 : 100
    self.limit(limit).each do |parse_comment|
      comment = parse_comment.attributes

      comment2 = Comment.find_or_create_by(
        parsecomhash: comment['objectId']
      )

      comment2.content = comment['body']
      begin
        comment2.user_id = User.find_by(parsecomhash: comment['user']['objectId'])
      rescue
      end
      comment2.room_id = Room.find_by(parsecomhash: comment['room_id'])

      comment2.save!
    end
  end
end
