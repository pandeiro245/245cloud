class Util
  def self.sync_parsecom
    ParsecomUser.sync(true)
    ParsecomWorkload.sync(false)
    ParsecomComment.sync(false)
  end

  def self.reset!
    User.delete_all
    Workload.delete_all
    Music.delete_all
    Room.delete_all
    Comment.delete_all

    Room.create_default_room
    ParsecomUser.sync
    ParsecomRoom.sync
    ParsecomComment.sync
    ParsecomWorkload.sync
  end
end
