class DiscordBot
  def self.run
    self.new.run
  end

  def initialize
    @pomo_sec = 24 * 60
  end

  def run
    bot = Discordrb::Commands::CommandBot.new(
      token: ENV['DISCORD_TOKEN'],
      client_id: ENV['DISCORD_CLIENT_ID'],
      prefix: '/',
    )
    bot.command :pomo do |event|
      start = Time.now 
      sec = 0
      workload = nil
      user = User.find_by(discord_id: event.user.id)

      if user.blank?
        event.send_message("#{event.user.name} please login https://245cloud.com/auth/discord")
      else
        res = event.send_message("loading...")

        workload = user.start!

        base_uri = 'https://neat-glazing-702.firebaseio.com/'
        token = File.open('tmp/token.json').read
        firebase = Firebase::Client.new(base_uri, token)
        response = firebase.push("workloads", {
          facebook_id: user.facebook_id,
          created_at: Time.now.to_i * 1000
        })
        
        while(@pomo_sec > sec) do
          sec = (Time.now - start).to_i
          res.edit("#{remain_text(sec)} by #{event.user.name} id: #{res.id}")
          sleep 0.8
        end
        workload.to_done!
        res.edit("done! by #{event.user.mention}")
      end
    end
    bot.run
  end

  def remain_text(_sec)
    remain = (@pomo_sec - _sec).to_i
    min = (remain / 60).to_i
    sec = remain - min * 60
    format("%02d:%02d", min, sec)
  end
end
