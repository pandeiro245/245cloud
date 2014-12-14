env = {
  sc_client_id: '2b9312964a1619d99082a76ad2d6d8c6'
  et_client_id: '534872bc1c3389f658f335e241a25efd219fd144'
}

env.pomotime =  24
env.chattime =  5

if pomo = location.href.match(/pomo=[\d\.]*/)
  env.pomotime = parseFloat(pomo[0].replace('pomo=', ''))
if chat = location.href.match(/chat=[\d\.]*/)
  env.chattime = parseFloat(chat[0].replace('chat=', ''))

if localStorage['is_prod_db'] or location.href.match(/245cloud.com/)
  env.parse_app_id = 'jemiGIUHsvNeVQojqiUaXxFJZvzFDxFbUsfjPr78'
  env.parse_key = 'ZoyMZflFV5H2VoASJv505vJ2wWd9zqa2ZW5MU780'
  env.facebook_app_id = '275431199325537'
else
  env.parse_app_id = '8QzCMkUbx7TyEApZjDRlhpLQ2OUj0sQWTnkEExod'
  env.parse_key = 'gzlnFfIOoLFQzQ08bU4mxkhAHcSqEok3rox0PBOM'
  env.facebook_app_id = '322004764668180' # localhost:3001

@env = env
