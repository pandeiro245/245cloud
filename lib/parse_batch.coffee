class @ParseBatch
  @do: () ->
    console.log "in the batch"
    ParseParse.all("Room", (rooms) ->
      for room in rooms
        ParseParse.where("Comment", [['room_id', room.id]], (room, comments) ->
          room.set('comments_count', comments.length)
          room.save()
        , room, 1000000)
    )
    ###
    ParseParse.where("Workload", [['is_done', true]], (workloads) ->
      hash = {}
      arr = []
      res = {}
      html = ""
      for workload in workloads
        if key = workload.get('sc_id')
          key = "soundcloud:#{key}"
        else if key = workload.get('yt_id')
          key = "youtube:#{key}"
        else
          continue
        hash[key] = {number: 0, title: workload.get('title')} unless hash[key]
        hash[key].number += 1
      for key of hash
        item = hash[key]
        item.key = key
        arr.push(item)
       
      arr.sort (a, b) ->
        b.number - a.number
      
      for i in [0..49]
        html += "#{(i + 1)}位：<a href='##{arr[i].key}' class='fixed_start'>#{arr[i].title}</a>(#{arr[i].number}回)<br />"
      console.log html
    , null, 10000000)
    ###


  @repeat: (sec=60) ->
    @do()
    #setTimeout("ParseBatch.repeat()", sec * 1000)
