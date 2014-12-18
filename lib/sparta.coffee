@addDoing = (workload) ->
  console.log 'addDoing', workload
  if workload.user.objectId == Parse.User.current().id
    Util.countDown(@env.pomotime*60*1000)
    alert '24分頑張ってください！'

@addChatting = (workload) ->
  console.log 'addChatting', workload

@stopUser = (workload) ->
  console.log 'stopUser', workload

@addComment = (params) ->
  console.log 'addComment', params

