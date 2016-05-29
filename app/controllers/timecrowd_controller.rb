class TimecrowdController < ApplicationController
  def info
    render text: TimeCrowd.new(cookies['timecrowd']).user_info['teams'].select{|t| t['is_personal'] == true}.first['id']
  end

  def recents
    begin
      t = TimeCrowd.new(cookies['timecrowd'])
      if false
        recents = t.recents
        cookies['timecrowd'] = t.refresh_keys_json
        recents['status'] = 'ok'
        recents[:entries].map do |entry|
          issue = Issue.find_or_create_by(
            key: "timecrowd:#{entry['task']['team_id']}-#{entry['task']['id']}",
            user: current_user
          )
          entry[:estimated] = issue.estimated
          entry[:worked] = issue.worked
          entry[:deadline] = issue.deadline.to_i*1000
          entry[:issue_id] = issue.id
          entry
        end
      else
        entries = Issue.actives(current_user).order('deadline IS NULL').order(:deadline).map do |issue|
          keys = issue.key.gsub(/^timecrowd:/,'').split('-')
          team_id = keys[0]
          task_id = keys[1]
          entry = {}
          begin
            task = t.team_task(team_id, task_id)
            entry[:task] = task
          rescue
          end
          entry[:estimated] = issue.estimated
          entry[:worked] = issue.worked
          entry[:deadline] = issue.deadline.to_i*1000
          entry[:issue_id] = issue.id
          entry
        end
        recents = {
          status: 'ok',
          entries: entries
        }
      end
    rescue=>e
      recents = {status: "ng: #{e}"}
    end
    render json: recents
  end

  def update
    issue = Issue.find(params[:id])
    issue.estimated = params[:estimated] if params[:estimated]
    issue.deadline = params[:deadline] if params[:deadline]
    issue.save!
    render json: issue
  end

  def create
    begin
      t = TimeCrowd.new(cookies['timecrowd'])
      team_id = params[:team_id] || t.user_info['teams'].select{|t| t['is_personal'] == true}.first['id']
      now = Time.now
      deadline = now - (now.min * 60 + now.sec) + 1.day
      estimated = 8
      t.create(
        current_user,
        team_id, 
        params[:title], 
        deadline,
        estimated
      )
      cookies['timecrowd'] = t.refresh_keys_json
      res = {status: 'ok'}
    rescue=>e
      res = {status: "ng: #{e}"}
    end
    render json: res
  end

  def stop
    begin
      t = TimeCrowd.new(cookies['timecrowd'])
      t.stop
      cookies['timecrowd'] = t.refresh_keys_json
      res = {status: 'ok'}
    rescue
      res = {status: 'ng'}
    end
    render json: res
  end

  def start
    begin
      t = TimeCrowd.new(cookies['timecrowd'])
      t.start(params[:team_id], params[:task_id])
      cookies['timecrowd'] = t.refresh_keys_json
      res = {status: 'ok'}
    rescue
      res = {status: 'ng'}
    end
    render json: res
  end
end

