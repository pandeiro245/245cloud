class Bunsan
  def self.export
    Util.save('bunsan.json', {musics: self.musics, comments: comments}.to_json)
    puts 'done'
  end

  def self.musics
    musics = {}
    Workload.all.each do |w|
      w = w.decorate
      musics[w.music_key] ||= {}
      musics[w.music_key][w.facebook_id] ||= {}
      musics[w.music_key][w.facebook_id][w.created_at] = w.is_done
    end
    musics
  end

  def self.comments
    comments = {}
    Comment.roots.each do |root|
      root = root.decorate

      # FIXME
    end
  end

  def self.import
    JSON.parse(Util.get('bunsan.json'))['musics'].each do |music_key, hash|
      hash.each do |facebook_id, hash2|
        hash2.each do |created_at, is_done|
          created_at = Time.at(created_at.to_i)
          from =  created_at - 23.minutes
          to = created_at + 23.minutes
          range = from..to
          w = Workload.find_or_create_by(
            music_key: music_key,
            facebook_id: facebook_id,
            created_at: range
          )
          w.is_done = is_done
          w.save!
        end
      end
    end
  end
end
