class ParsecomComment < ParseResource::Base
  fields :body, :room_id, :user

  def self.hoge!
    Comment.delete_all
    ActiveRecord::Base.connection.execute('ALTER TABLE comments AUTO_INCREMENT = 1')
    self. sync true
  end

  def self.sync refresh = false
    limit = refresh ? 99999 : 100
    self.limit(limit).order('createdAt desc').each do |parse_comment|
      parse_comment.save_with_ar!
    end
  end
  
  def save_with_ar!
    comment = self.attributes

    comment2 = Comment.find_or_create_by(
      parsecomhash: comment['objectId']
    )

    comment2.content = comment['body']



    # 立ちあげ当初はコメントにuser_id保存していなかった
    begin
    comment2.user = User.find_by(parsecomhash: comment['user']['objectId'])
    rescue
    end

    raise comment2.user.inspect

    comment2.room = Room.find_by(parsecomhash: comment['room_id']) || Room.first
    comment2.created_at =  comment['createdAt'].to_time

    comment2.save!
  end
end

