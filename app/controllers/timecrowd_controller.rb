class TimecrowdController < ApplicationController
  def recents
    t = TimeCrowd.new
    render json: t.recents
  end

  def start
    t = TimeCrowd.new
    t.create_time_entry(
      {
        key: params[:key],
        title: params[:title],
        url: params[:url],
        team_id: params[:team_id],
      }
    )
    redirect_to params[:url]
  end

  def login
    auth_hash = request.env['omniauth.auth']

    %w(expires_at refresh_token token).each do |key|
      val = auth_hash.credentials.send(key)
      #File.open("tmp/timecrowd_#{key}.txt", 'w') { |file| file.write(val) }
      cookies[key] = val
    end
    redirect_to :root, notice: 'Signed in successfully'
  end
end

