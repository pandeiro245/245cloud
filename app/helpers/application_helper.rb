module ApplicationHelper
  def current_user
    User.find_by(id: session[:user_id])
  end

  def ruffimage id
    image_tag "https://ruffnote.com/attachments/#{id}"
  end

  def time instance
    time = instance.created_at
    type = time.to_date == Date.today ? "%H:%M" : "%m/%d"
    time.localtime.strftime(type)
  end

  def timestamp workload
    "#{time(workload)}（#{workload.number}回目）"
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
