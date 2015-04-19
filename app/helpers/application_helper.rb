module ApplicationHelper
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
    res += link_to '>', "#{dir}#{id + 1}" if id < last_id
    res += '　'
    res += link_to '>>', "#{dir}#{last_id}" if id < last_id - 1
    return res.html_safe
  end
end
