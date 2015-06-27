class Room < ActiveRecord::Base

  def comments
    Comment.where(room_id: self.id).order('created_at desc').limit(100)
  end
end
