class Room < ActiveRecord::Base

  def comments
    room_id = self.id || 0
    Comment.where(room_id: room_id).order('created_at desc').limit(100)
  end
end
