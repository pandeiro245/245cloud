class Room < ActiveRecord::Base
  def id2
    id || 0
  end

  def title2
    title || 'いつもの部屋'
  end

  def comments
    Comment.where(room_id: self.id).order('created_at desc').limit(100)
  end
end
