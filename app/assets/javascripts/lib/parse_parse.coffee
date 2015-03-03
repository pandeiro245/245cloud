Parse.initialize(@env.parse_app_id, @env.parse_key)

class @ParseParse
  @find: (model_name, id, callback, instance=null) ->
    Model = Parse.Object.extend(model_name)
    query = new Parse.Query(Model)
    query.get(id, {
      success: (data) ->
        if instance
          callback(instance, data)
        else
          callback(data)
      , error: (object, error) ->
        console.log error
        #alert 'error...'
    })

  @fetch: (model_name, child, callback) ->
    child.get(model_name).fetch({
      success: (parent) ->
        callback(child, parent)
    })

  @where: (model_name, cond, callback, instance=null, limit=100) ->
    url = "#{model_name.toLowerCase()}s.json?limit=#{limit}"
    for c in cond
      if c[2]
        if c[1] == '<'
          console.log '<'
          # query.lessThan(c[0], c[2])
        else if c[1] == '>'
          console.log '>'
          # query.greaterThan(c[0], c[2])
      else
        url += "&where[#{c[0]}]=#{c[1]}"

    $.get(url, (data) ->
      if instance
        callback(instance, data)
      else
        callback(data)
    )

    #Model = Parse.Object.extend(model_name)
    #query = new Parse.Query(Model)
    #query.limit(limit)
    #for c in cond
    #  if c[2]
    #    if c[1] == '<'
    #      query.lessThan(c[0], c[2])
    #    else if c[1] == '>'
    #      query.greaterThan(c[0], c[2])
    #  else
    #    query.equalTo(c[0], c[1])

    #query.descending("createdAt")
    #query.find({
    #  success: (data) ->
    #    if instance
    #      callback(instance, data)
    #    else
    #      callback(data)
    #  error: (error) ->
    #    console.log error
    #})

  @all: (model_name, callback, params={}) ->
    #Model = Parse.Object.extend(model_name)
    #query = new Parse.Query(Model)
    #query.limit(999999)
    #query.descending("createdAt")
    #query.find({
    #  success: (data) ->
    #    callback(data)
    #})
    url = "#{model_name.toLowerCase()}s.json"
    $.get(url, (data) ->
      callback(data)
    )

  @find_or_create: (model_name, key_params, params, callback) ->

  @create: (model_name, params, callback=null) ->
    Model = Parse.Object.extend(model_name)
    model = new Model()
    for key of params
      val = params[key]
      model.set(key, val)
    if Parse.User.current()
      model.set('user', Parse.User.current())
      modelACL = new Parse.ACL(Parse.User.current())
      modelACL.setPublicReadAccess(true)
      model.setACL(modelACL)
    model.save(null, {
      error: (model, error) ->
        console.log error
      ,
      success: (model) ->
        if callback
          callback(model)
      }
    )

  @addAccesslog: () ->
    console.log 'addAccesslog'
    ParseParse.create('Accesslog',
      {url: location.href}
    )
