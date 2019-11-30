class Test
  def self.exec
    base_uri = 'https://neat-glazing-702.firebaseio.com/'
    token = File.open('tmp/token.json').read
    firebase = Firebase::Client.new(base_uri, token)
    response = firebase.push("workloads", {
      facebook_id: '10153970340413381',
      # facebook_id: '999999999999',
      created_at: Time.now.to_i * 1000
    })
  end
end
