class TimeCrowd
  attr_accessor :client, :access_token

  def initialize(keys_json)
    keys = JSON.parse(keys_json)

    self.client = OAuth2::Client.new(
      ENV['TIMECROWD_CLIENT_ID'],
      ENV['TIMECROWD_SECRET_KEY'],
      site: 'https://timecrowd.net',
      ssl: { verify: false }
    )
    self.access_token = OAuth2::AccessToken.new(
      client,
      keys['timecrowd_token'],
      refresh_token: keys['timecrowd_refresh_token'],
      expires_at: keys['timecrowd_expires_at']
    )
  end

  def refresh_keys_json
    #self.access_token = access_token.refresh! if self.access_token.expired?
    access_token = self.access_token.refresh!
    keys = {}
    %w(expires_at refresh_token token).each do |key|
      val = access_token.send(key)
      #File.open("tmp/timecrowd_#{key}.txt", 'w') { |file| file.write(val) }
      keys["timecrowd_#{key}"] = val
    end
    keys.to_json
  end

  def recents
    entries = access_token.get("/api/v1/user/recent_entries").parsed
    entries = [working_entry] + entries if working_entry.present?
    return {
      is_working: working_entry.present?,
      entries: entries
    }
  end

  def working_entry
    w = working_users.select{|u| u['id'] == user_info['id']}.first
    return nil unless w
    res = w['time_entry']
    res['task'] = w['task']
    return res
  end

  def stop
    access_token.put("/api/v1/time_entries/#{working_entry['id']}").parsed
  end

  def start(team_id, task_id)
    url = "/api/v1/teams/#{team_id}/tasks/#{task_id}/start"
    access_token.post(url).parsed
  end

  def teams(state = nil)
    access_token.get("/api/v1/teams?state=#{state}").parsed
  end

  def team(id)
    access_token.get("/api/v1/teams/#{id}").parsed
  end

  def team_tasks(team_id, state = nil)
    access_token.get("/api/v1/teams/#{team_id}/tasks?state=#{state}").parsed
  end

  def update_team_task(team_id, id, body)
    access_token.put("/api/v1/teams/#{team_id}/tasks/#{id}", body: body).parsed
  end

  def working_users
    access_token.get("/api/v1/user/working_users").parsed
  end

  def user_info
    access_token.get("/api/v1/user/info.json").parsed
  end

  def time_entries page = nil
    url = '/api/v1/time_entries'
    url += "?page=#{page}" unless page.nil?
    puts url
    access_token.get(url).parsed
  end

  def create_time_entry(task)
    access_token.post(
      "/api/v1/time_entries",
      body: {task: task}
    ).parsed
  end
end

