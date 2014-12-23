env = {
  sc_client_id: '2b9312964a1619d99082a76ad2d6d8c6'
  et_client_id: '534872bc1c3389f658f335e241a25efd219fd144'
}
env.pomotime =  if localStorage['dev_pomo'] then parseFloat(localStorage['dev_pomo']) else 24
env.chattime =  if localStorage['dev_chat'] then parseFloat(localStorage['dev_chat']) else 5

if location.href.match(/245cloud.com/)
  env.parse_app_id = 'jemiGIUHsvNeVQojqiUaXxFJZvzFDxFbUsfjPr78'
  env.parse_key = 'ZoyMZflFV5H2VoASJv505vJ2wWd9zqa2ZW5MU780'
  env.facebook_app_id = '275431199325537'
else
  env.parse_app_id = '8QzCMkUbx7TyEApZjDRlhpLQ2OUj0sQWTnkEExod'
  env.parse_key = 'gzlnFfIOoLFQzQ08bU4mxkhAHcSqEok3rox0PBOM'
  env.facebook_app_id = '322004764668180' # localhost:3001

@env = env
