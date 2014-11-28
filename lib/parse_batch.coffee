class @ParseBatch
  @do: () ->
    console.log "this is test"
    ParseParse.all("Room", (rooms) ->
      for room in rooms
        ParseParse.where("Comment", [['room_id', room.id]], (room, comments) ->
          room.set('comments_count', comments.length)
          room.save()
        , room, 1000000)
    )

  @repeat: (sec=60) ->
    @do()
    setTimeout("ParseBatch.repeat()", sec * 1000)
