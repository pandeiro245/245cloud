class @ParseMithril
  @all: (model_name) ->
    console.log model_name
    m.request
      method: 'GET'
      url: "/#{model_name}.json"

