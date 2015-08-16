class ParsecomComment < ParseResource::Base
  fields :body, :room_id, :user

  def self.sync
    self.limit(999999).each do |parse_comment|
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
