module ApplicationHelper
  def pagination(instance, dir=nil)
    dir = dir ? "/#{dir}/" : '/'
    res = ''
    res += link_to '<<', "#{dir}#{instance.class.first.id}" if instance.id > 1
    res += '　'
    res += link_to '<', "#{dir}#{instance.id - 1}" if instance.id > 2
    res += '　'
    res += link_to '>', "#{dir}#{instance.id + 1}"
    res += '　'
    res += link_to '>>', "#{dir}#{instance.class.last.id}"
    return res.html_safe
  end
end
