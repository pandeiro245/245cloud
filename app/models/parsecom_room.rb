class ParsecomRoom < ParseResource::Base
  fields :title, :img_off, :img_on

  def self.sync
    self.limit(100).each do |parse_room|
      room = parse_room.attributes

      room2 = Room.find_or_create_by(
        parsecomhash: room['objectId']
      )

      room2.title = room['title']
      room2.image_off = room['img_off']
      room2.image_on = room['img_on']

      room2.save!
    end
  end
end
