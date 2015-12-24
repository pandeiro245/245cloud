class TimecrowdController < ApplicationController
  def recents
    begin
      t = TimeCrowd.new(cookies['timecrowd'])
      recents = t.recents
      cookies['timecrowd'] = t.refresh_keys_json
      recents['status'] = 'ok'
    rescue
      recents = {status: 'ng'}
    end
    render json: recents
  end

  def stop
    begin
      t = TimeCrowd.new(cookies['timecrowd'])
      t.stop
      cookies['timecrowd'] = t.refresh_keys_json
      res = {status: 'ok'}
    rescue
      res = {status: 'ng'}
    end
    render json: res
  end

  def start
    begin
      t = TimeCrowd.new(cookies['timecrowd'])
      t.start(params[:team_id], params[:task_id])
      cookies['timecrowd'] = t.refresh_keys_json
      res = {status: 'ok'}
    rescue
      res = {status: 'ng'}
    end
    render json: res
  end

  def login
    auth_hash = request.env['omniauth.auth']
    keys = {}
    %w(expires_at refresh_token token).each do |key|
      val = auth_hash.credentials.send(key)
      #File.open("tmp/timecrowd_#{key}.txt", 'w') { |file| file.write(val) }
      keys["timecrowd_#{key}"] = val
    end
    cookies['timecrowd'] = keys.to_json
    #raise cookies['timecrowd'].inspect
    redirect_to '/?timecrowd=1', notice: 'Signed in successfully'
  end
end

