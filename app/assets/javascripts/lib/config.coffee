href = location.href

env = {
  sc_client_id: '2b9312964a1619d99082a76ad2d6d8c6'
  et_client_id: '534872bc1c3389f658f335e241a25efd219fd144'
}

if min = href.match(/pomotime=(.[0-9.]*)/)
  localStorage['pomotime'] = min[1]

env.pomotime = if localStorage['pomotime'] then parseFloat(localStorage['pomotime']) else 24
env.chattime = if localStorage['chattime'] then parseFloat(localStorage['chattime']) else 5


if href.match(/production_mode=/) || href.match(/245cloud.com/)
  env.parse_app_id = 'jemiGIUHsvNeVQojqiUaXxFJZvzFDxFbUsfjPr78'
  env.parse_key = 'ZoyMZflFV5H2VoASJv505vJ2wWd9zqa2ZW5MU780'

  if href.match(/245cloud.dev/) # http://pow.cx/
    env.facebook_app_id = '275431199325537'
  else if href.match(/245cloud.com/)
    env.facebook_app_id = '363848477150475'
  else
    alert 'please set facebook_app_id in app/assets/javascripts/lib/config.coffee'
  env.milkcocoa = 'iceiabmz2nv'
  env.yt_client_id = 'AIzaSyAvb5RW4gNEcQlaHODHZ1h0jjYxD8mKvIM'
else
  env.parse_app_id = 'xDQHbCXqlrdCoOAnTbunjJjoxxBhSbQll1vKIcSQ' #245cloudDev2
  env.parse_key = 'jcwkk9MstoMebuv9ovsFB26aR9IDNg5vc6Ec0GwN'
  env.milkcocoa = 'hotiabmydrw'
  env.yt_client_id = 'AIzaSyD1A25NZMbp4VA4uikV8e-naG7oVa-B1pY'
  
  if location.href.match(/localhost:3001/)
    env.facebook_app_id = '322004764668180'
  else if location.href.match(/245cloud.dev/)
    env.facebook_app_id = '363848477150475'
  else if location.href.match(/nishikocloud-staging.herokuapp.com/)
    env.facebook_app_id = '366798926855430'

env.is_kakuhen = false
env.is_doing = false
env.is_done = false
@nomusic_url = 'https://ruffnote.com/attachments/24985'

@env = env
window.env = env
