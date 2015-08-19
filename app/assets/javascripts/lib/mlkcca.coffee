mlkcca = new MilkCocoa("#{@env.milkcocoa}.mlkcca.com")
@socket = mlkcca.dataStore('workload')

@socket.on( 'push', (params) ->
  console.log 'mlkcca', params
  params = params.value
  $('table.comments').prepend("""
  <tr><td><img class="icon" src="https://graph.facebook.com/10152403406713381/picture?type=square"></td> <td></td> <td>#{Util.parseHttp(params.comment.body)}</td> <td>#{Util.hourMin(new Date())}</td> </tr>
  """)
)

