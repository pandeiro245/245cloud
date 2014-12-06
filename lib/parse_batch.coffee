class @ParseBatch
  @do: () ->
    console.log "rooms in the batch"
    ParseParse.all("Room", (rooms) ->
      for room in rooms
        ParseParse.where("Comment", [['room_id', room.id]], (room, comments) ->
          room.set('comments_count', comments.length)
          room.save()
        , room, 1000000)
    )

    console.log "kpi in the batch"
    cond = [
      ['is_done', true]
      ['synchro_start', null]
      ['user', Parse.User.current()]
    ]
    ParseParse.where("Workload", cond, (workloads) ->
      for workload in workloads
        console.log 'workload in kpi batch', workload
        # 開始29分前〜開始時間
        cond = [
          ['is_done', true]
          ['createdAt', '>', Util.minAgo(24 + 5, workload.createdAt)]
          ['createdAt', '<', workload.createdAt]
        ]
        ParseParse.where('Workload', cond, (workload, workloads2) ->
          workload.set('synchro_start', workloads2.length + 1)
          workload.save()
        , workload, 1000)

        # 終了29分前（＝開始時間）〜終了時間
        cond = [
          ['is_done', true]
          ['createdAt', '>', workload.createdAt]
          ['createdAt', '<', Util.minAgo(-24 -5, workload.createdAt)]
        ]
        ParseParse.where('Workload', cond, (workload, workloads3) ->
          workload.set('synchro_end', workloads3.length + 0)
          workload.save()
        , workload, 1000)
    , null, 30)

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
