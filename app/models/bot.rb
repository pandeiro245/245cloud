class Bot
  attr_accessor :user, :message
 def exec
    start = Time.now 
    if user.blank? && self.class == DiscordBot
      echo("#{user_name} please login https://245cloud.com/auth/discord")
    else
      @workload = user.start!

      base_uri = 'https://neat-glazing-702.firebaseio.com/'
      token = File.open('tmp/token.json').read
      firebase = Firebase::Client.new(base_uri, token)
     response = firebase.push("workloads", {
        facebook_id: user.facebook_id,
        created_at: Time.now.to_i * 1000
      })
  
      begin   
        start_post
        while(@workload.playing?) do
          process_post
          sleep sleep_sec
        end
        @workload.to_done!
        complete_post
      rescue=>e
        binding.pry
      end
    end
  end

  def start_post
    @message = echo("#{@workload.number}回目の集中開始！ ")
  end

  def process_post
    update("#{@workload.number}回目の集中完了まであと#{@workload.remain_text}#{by_user_name}")
  end

  def by_user_name
    ''
  end

  def complete_post 
    update("#{@workload.number}回集中しました。おつかれさまでした！#{by_user_name}")
  end
end
