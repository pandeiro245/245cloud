module ApplicationHelper

  def get_offset(is_first, item_count)
    return '' unless is_first or item_count >= 5
    data = {
      1 => 5,
      2 => 4,
      3 => 3,
      4 => 2,
    }
    offset = data[item_count]
    "col-sm-offset-#{offset}"
  end

  def music_path music
    "/musics/#{music.id}"
  end

  def current_user
    User.current_user(session[:user_id])
  end

  def ruffimage id
    image_tag "https://ruffnote.com/attachments/#{id}"
  end

  def time instance
    time = instance.created_at.localtime
    type = time.to_date == Date.today ? "%H:%M" : "%m/%d"
    time.strftime(type)
  end

  def timestamp workload
    description = workload.number ? "#{workload.number}回目" : "あと#{remain(workload)}"
    "#{time(workload)}（#{description}）"
  end

  def remain instance
    sec = (instance.created_at + Workload.pomominutes - Time.now).to_i
    sec2time sec
  end

  def sec2time sec
    min = (sec/60).to_i
    sec2 = sec - min*60
    return "#{zero(min)}:#{zero(sec2)}"
  end

  def zero i
    i.to_i < 10 ? "0#{i}" : i.to_s 
  end

  def start_button workload
    base = 'https://ruffnote.com/attachments/'
    if workload.music.present?
      url = "#{base}24921"
    else 
      url = "#{base}24926"
    end
    image_tag url
  end

  def pagination(instance, dir=nil)
    id = instance.id 
    first_id = instance.class.first.id
    last_id  = instance.class.last.id
    dir = dir ? "/#{dir}/" : '/'
    res = ''
    res += link_to '<<', "#{dir}#{first_id}" if id > first_id + 1
    res += '　'
    res += link_to '<', "#{dir}#{id - 1}" if id > first_id
    res += '　'
    res += link_to 'HOME', root_path
    res += '　'
    res += link_to '>', "#{dir}#{id + 1}" if id < last_id
    res += '　'
    res += link_to '>>', "#{dir}#{last_id}" if id < last_id - 1
    return res.html_safe
  end
end
