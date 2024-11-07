class Fb
  def exec
    # require 'net/http'
    # require 'json'

    # Firebase プロジェクトの認証情報
    project_id = ENV['FIREBASE_PROJECT_ID']
    api_key = ENV['FIREBASE_API_KEY']

    # データベースにデータを追加する
    uri = URI("https://firestore.googleapis.com/v1/projects/#{project_id}/databases/(default)/documents/users/alice")
    req = Net::HTTP::Post.new(uri)
    req['Authorization'] = "Bearer #{api_key}"
    req.body = JSON.generate({
      "name" => "Alice Smith",
      "age" => 30
    })
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    # レスポンスを確認する
    puts res.body
  end
end
