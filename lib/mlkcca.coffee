mlkcca = new MilkCocoa("https://io-ui2n0gy4p.mlkcca.com:443")

@socket = mlkcca.dataStore('workload')

@socket.on( 'push', (params) ->
  console.log 'mlkcca', params
  params = params.value
  if params.type == 'comment'
    @addComment(params.id2, params.comment, params.is_countup)
  else if params.type == 'doing'
    @addDoing(params.workload)
  else if params.type == 'chatting'
    @addChatting(params.workload)
  else if params.type == 'finish'
    @stopUser(params.workload.user.objectId)
)

