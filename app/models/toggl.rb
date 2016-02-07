class Toggl
  def initialize token=nil
    @toggl    = TogglV8::API.new(token)
    @user         = @toggl.me(all=true)
    @workspaces   = @toggl.my_workspaces(@user)
    @workspace_id = @workspaces.first['id']
  end

  def working
    @toggl.get_current_time_entry
  end

  def last
    @toggl.get_time_entries.last
  end

  def start
    return if working # 既に動いていたら実行しない 
    @toggl.start_time_entry({
      'description' => last['description'],
      'wid' => @workspace_id,
      'start' => Time.now,
      'created_with' => "http://245cloud.com"
    })
  end

  def stop
    @toggl.stop_time_entry(working['id'])
  end
end

