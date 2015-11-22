mlkcca = new MilkCocoa("#{@env.milkcocoa}.mlkcca.com")
@socket = mlkcca.dataStore('workload')

@socket.on( 'push', (params) ->
  console.log 'mlkcca', params
  params = params.value
  if params.type == 'comment'
    # 自分の投稿だけはMilkcocoaを経由させない 
    unless params.comment.user.objectId == Parse.User.current().id
      @addComment(params.room_id, params.comment)
  else if params.type == 'doing'
    @addDoing(params.workload)
  else if params.type == 'chatting'
    @addChatting(params.workload)
  else if params.type == 'finish'
    @stopUser(params.workload.user.objectId)
)

