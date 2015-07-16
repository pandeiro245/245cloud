class Room < ActiveRecord::Base
  def self.create_default_room
    return Room.first unless Room.count.zero?
    return Room.create!(
      title: 'いつもの部屋',
      image_off: 'https://ruffnote.com/attachments/24832',
      image_on: 'https://ruffnote.com/attachments/24831',
    )
  end

  def comments
    Comment.where(room_id: self.id).order('created_at desc').limit(100)
  end
end
