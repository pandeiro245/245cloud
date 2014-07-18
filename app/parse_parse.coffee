class @ParseParse
  @find: (model_name, id, callback) ->

  @all: (model_name, callback) ->
    Model = Parse.Object.extend(model_name)
    query = new Parse.Query(Model)
    query.find({
      success: (data) ->
        callback(data)
    })

  @find_or_create: (model_name, key_params, params, callback) ->


  @create: (model_name, params, callback=null) ->
    Model = Parse.Object.extend(model_name)
    model = new Model()
    for key of params
      val = params[key]
      val = parseInt(val) if key.match(/_id$/)
      model.set(key, val)
    model.save(null, {
      error: (model, error) ->
        console.log error
      ,
      success: (model) ->
        if callback
          callback(model)
      }
    )
