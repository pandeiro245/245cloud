class Ruffnote
  def self.ruffnote(token)
    client = OAuth2::Client.new(
      ENV['RUFFNOTE_KEY'],
      ENV['RUFFNOTE_SECRET'],
      site: 'http://ruffnote.com/',
      ssl: { verify: false } 
    )
    OAuth2::AccessToken.new(client, token)
  end

  def self.my_issues(token)
    Ruffnote.ruffnote(token).get(
      "/api/v1/my_issues.json"
    ).parsed
  end

  def self.note_issues(token, team, note)
    Ruffnote.ruffnote(token).get(
      "/api/v1/#{team}/#{note}/issues.json?state=all"
    ).parsed
  end

  def self.issue(token, team, note, index)
    Ruffnote.ruffnote(token).get(
      "/api/v1/#{team}/#{note}/issues/#{index}.json"
    ).parsed
  end

  def self.notes(token)
    Ruffnote.ruffnote(token).get(
      "/api/v1/notes.json"
    ).parsed
  end
  
  def self.page(token, team, note, page)
    Ruffnote.ruffnote(token).get(
      "/api/v1/#{team}/#{note}/#{page}.json"
    ).parsed
  end

  def self.done_issue(token, team, note, index)
    Ruffnote.ruffnote(token).put(
      "/api/v1/#{team}/#{note}/issues/#{index}.json", body: {
        issue: {is_done: true}
    }).parsed
  end

  def self.create_issue(token, team, note, params)
    Ruffnote.ruffnote(token).post(
      "/api/v1/#{team}/#{note}/issues.json", body: {
        issue: params 
    }).parsed
  end

  def self.update_issue(token, team, note, index, params)
    Ruffnote.ruffnote(token).put(
      "/api/v1/#{team}/#{note}/issues/#{index}.json", body: {
        issue: params 
    }).parsed
  end

  def self.add_tag_issue(token, team, note, index, tag_names)
    Ruffnote.ruffnote(token).post(
      "/api/v1/#{team}/#{note}/issues/#{index}/tags.json", body: {
        tags: tag_names
    }).parsed
  end

  def self.note(token, team, note)
    Ruffnote.ruffnote(token).get(
      "/api/v1/#{team}/#{note}.json"
    ).parsed
  end
end

