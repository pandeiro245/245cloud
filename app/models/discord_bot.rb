class DiscordBot < Bot
  def initialize(event, user)
    @event = event
    @user = user
  end

  def echo(text)
    @event.send_message(text)
  end


  def user_name
    @event.user.name
  end

  def sleep_sec
    0.8
  end

  def update(text)
    @message.edit(text)
  end
  
  def by_user_name
     " by #{@event.user.name}"
  end
end
