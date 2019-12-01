class DiscordBotWatcher
  def self.run
    self.new.run
  end
  def run
    bot = Discordrb::Commands::CommandBot.new(
      token: ENV['DISCORD_TOKEN'],
      client_id: ENV['DISCORD_CLIENT_ID'],
      prefix: '/',
    )
    bot.command :pomo do |event|
      user = User.find_by(
        discord_id: event.user.id
      )
      DiscordBot.new(event, user).exec
    end
    bot.run
  end
end
