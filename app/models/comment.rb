class Comment < ActiveRecord::Base

  belongs_to :user
  def room
    Room.find(self.room_id)
  end

  def icon_url
    "https://ruffnote.com/attachments/24311"
  end

  def user_name
    ''
  end
end
