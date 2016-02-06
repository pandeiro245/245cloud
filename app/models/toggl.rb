class Toggl
  def initialize token=nil
    @toggl    = TogglV8::API.new(token)
    @user         = @toggl.me(all=true)
    @workspaces   = @toggl.my_workspaces(@user)
    @workspace_id = @workspaces.first['id']
  end

  def recent
    @toggl.get_current_time_entry
  end

  def start
    @toggl.create_time_entry({
      'description' => recent['description'],
      'wid' => @workspace_id,
      'duration' => 1200,
      'start' => Time.now,
      'created_with' => "http://245cloud.com"
    })
  end

  def stop
    @toggl.stop_time_entry(recent['id'])
  end
end

