mlkcca = new MilkCocoa("https://io-ui2n0gy4p.mlkcca.com:443")

@socket = mlkcca.dataStore('workload')

@socket.on( 'workload', (params) ->
  console.log 'mlkcca', params
  if params.type == 'comment'
    @addComment(params.id, params.comment, params.is_countup)
  else if params.type == 'doing'
    @addDoing(params.workload)
  else if params.type == 'chatting'
    @addChatting(params.workload)
  else if params.type == 'finish'
    @stopUser(params.workload.user.objectId)
)

