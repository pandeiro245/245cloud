# app/models/workload.rb
class Workload < ActiveRecord::Base
 POMOTIME = Rails.env.production? ? 24.minutes : 0.2.minutes
 CHATTIME = Rails.env.production? ? 5.minutes : 0.2.minutes

 belongs_to :user

 # バリデーション
 validate :music_key_presence_if_title_or_artwork_url_present

 # コールバック
 before_save :set_music_key

 # 基本スコープ
 scope :created, -> { order('workloads.created_at DESC') }
 scope :dones, -> { where(is_done: true) }
 scope :his, ->(user_id) { where(user_id: user_id, is_done: true) }

 # 音楽関連スコープ
 scope :bests, -> {
   select('music_key, COUNT(music_key) AS music_key_count')
     .where.not(music_key: '')
     .group(:music_key)
     .order('music_key_count DESC')
 }

 scope :best_listeners, ->(music_key) {
   select('user_id, COUNT(user_id) AS user_id_count')
     .where(music_key: music_key)
     .group(:user_id)
     .order('user_id_count DESC')
 }

 # 時間関連スコープ
 scope :by_range, ->(range) { where(created_at: range) }

 scope :today, ->(created_at = nil) {
   to = (created_at || Time.zone.now) - POMOTIME
   base_time = to.in_time_zone('Tokyo')
   from = base_time.beginning_of_day.in_time_zone('UTC')
   by_range(from..to)
 }

 scope :thisweek, ->(created_at = nil) {
   to = (created_at || Time.zone.now) - POMOTIME
   from = calculate_week_start(to)
   by_range(from..to)
 }

 scope :chattings, -> {
   now = Time.zone.now
   by_range((now - POMOTIME - CHATTIME)..(now - POMOTIME))
 }

 scope :playings, -> {
   now = Time.zone.now
   by_range((now - POMOTIME)..now)
 }

 # タイプ関連
 scope :of_type, ->(type) {
   raise ArgumentError, "Invalid type: #{type}" if type && !active_type?(type)
   type ? public_send(type) : dones
 }

 def self.calculate_week_start(date)
   # JSTでの週の開始日時を計算
   jst_time = date.in_time_zone('Tokyo')
   
   # 月曜日の0時を取得（JSTベース）
   monday = jst_time.beginning_of_week(:monday)
   week_start = monday.beginning_of_day
   
   # UTCに変換して返す
   week_start.in_time_zone('UTC')
 end

 # クラスメソッド
 class << self
   def active_type?(type)
     %w[dones chattings playings all].include?(type)
   end

   def find_or_start_by_user(user, params = {})
     return playings.his(user.id).first if playings.his(user.id).exists?

     create_params = build_create_params(user, params)
     create!(create_params)
   end

   def update_numbers
     created.dones.each(&:update_number!)
   end

   private

   def build_create_params(user, params)
     create_params = { 'user_id' => user.id }

     %w[title artwork_url].each do |key|
       create_params[key] = params[key] if params[key].present?
     end

     if params[:music_key].present?
       create_params[:music_key] = "#{params[:music_provider]}:#{params[:music_key]}"
     end

     create_params
   end
 end

 # インスタンスメソッド
 def hm
   time = created_at.in_time_zone('Tokyo')
   format = time.to_date == Time.zone.now.to_date ? '%H:%M' : '%m/%d %H:%M'
   time.strftime(format)
 end

 def will_reload_at
   case user.status
   when 'playing' then created_at + POMOTIME
   when 'chatting' then created_at + POMOTIME + CHATTIME
   end
 end

 def playing?
   Time.zone.now < (created_at + POMOTIME - 0.1.seconds)
 end

 def chatting?
   return false if playing?
   created_at + POMOTIME + CHATTIME > Time.zone.now
 end

 def remain
   (created_at + POMOTIME).to_i - Time.zone.now.to_i
 end

 def to_done!
   update!(
     number: next_number,
     weekly_number: next_number(:weekly),
     is_done: true
   )
   self
 end

 def update_number!
   update!(
     number: next_number,
     weekly_number: next_number(:weekly)
   )
 end

 def next_number(type = nil)
   scope = Workload.his(user_id).dones
   jst_time = created_at.in_time_zone('Tokyo')

   if type == :weekly
     week_start = self.class.calculate_week_start(created_at)
     previous_count = scope.where('created_at >= ? AND created_at < ?', week_start, created_at).count
     previous_count + 1
   else
     today_start = jst_time.beginning_of_day.in_time_zone('UTC')
     scope.where('created_at >= ? AND created_at < ?', today_start, created_at).count + 1
   end
 end

 def debug_info
   base_time = created_at.in_time_zone('Tokyo')
   week_start = self.class.calculate_week_start(created_at)
   weekly_count = Workload.his(user_id)
                         .dones
                         .where('created_at >= ? AND created_at < ?', week_start, created_at)
                         .count
   
   {
     created_at: created_at.in_time_zone('Tokyo'),
     base_time: base_time,
     week_start: week_start,
     week_end: week_start + 7.days,
     current_weekly_number: weekly_count + 1,
     previous_workloads: Workload.his(user_id)
                                .dones
                                .where('created_at >= ?', week_start)
                                .order(created_at: :asc)
                                .map { |w| {
                                  created_at: w.created_at.in_time_zone('Tokyo'),
                                  weekly_number: w.weekly_number
                                }}
   }
 end

 # 音楽関連メソッド
 def music
   @music ||= Music.new_from_key(*music_key.split(':'))
 end

 def music_path
   "/musics/#{formatted_music_key}"
 end

 def artwork_url_from_music
   music&.artwork_url
 end

 def youtube_start
   return unless music.provider == 'youtube'
   music.fetch if music.duration.blank?
   music.duration - remain
 end

 # 表示関連メソッド
 def disp
   return hm.to_s if created_at + POMOTIME + CHATTIME > Time.zone.now
   "#{hm} #{number}回目(週#{weekly_number}回)"
 end

 def finish_playing_time
   (created_at + POMOTIME).to_i * 1000
 end

 def finish_chatting_time
   (created_at + POMOTIME + CHATTIME).to_i * 1000
 end

 private

 def music_key_presence_if_title_or_artwork_url_present
   return unless title.present? || artwork_url.present?
   errors.add(:music_key, 'is required if either title or artwork_url is present') if music_key.blank?
 end

 def set_music_key
   self.music_key = URI.decode_www_form_component(music_key) if music_key.present?
 end

 def formatted_music_key
   music_key.gsub('mixcloud:/', 'mixcloud:').gsub(':', '/')
 end
end

# spec/models/workload_spec.rb
require 'rails_helper'

RSpec.describe Workload, type: :model do
 describe 'タイムゾーンに関連するテスト' do
   let(:user) { create(:user) }
   
   around do |example|
     Time.use_zone('Tokyo') do
       example.run
     end
   end

   context 'numberとweekly_numberの計算' do
     let(:base_time) { Time.zone.local(2024, 1, 1, 0, 0, 0) }

     it '日本時間での週をまたぐ集計が正しく計算される' do
       # 12/31(月) 23:50のWorkload
       monday_workload = create(:workload, 
         user: user, 
         created_at: Time.zone.local(2023, 12, 31, 23, 50, 0),
         is_done: true
       )
       monday_workload.to_done!

       puts "\n=== Monday Workload Debug ==="
       puts monday_workload.debug_info

       # 1/1(火) 00:10のWorkload
       tuesday_workload = create(:workload,
         user: user,
         created_at: Time.zone.local(2024, 1, 1, 0, 10, 0)
       )
       tuesday_workload.to_done!

       puts "\n=== Tuesday Workload Debug ==="
       puts tuesday_workload.debug_info

       # 同じ週なので、weekly_numberは連続する
       expect(tuesday_workload.weekly_number).to eq(monday_workload.weekly_number + 1)
     end

     it 'UTCとJSTの日付変更線をまたぐ場合でも正しく計算される' do
       # UTCで12/31 14:59 (JST 23:59)のWorkload
       before_midnight = create(:workload,
         user: user,
         created_at: Time.utc(2023, 12, 31, 14, 59)
       )
       before_midnight.to_done!

       puts "\n=== Before Midnight Workload Debug ==="
       puts before_midnight.debug_info

       # UTCで12/31 15:01 (JST 1/1 00:01)のWorkload
       after_midnight = create(:workload,
         user: user,
         created_at: Time.utc(2023, 12, 31, 15, 1)
       )
       after_midnight.to_done!

       puts "\n=== After Midnight Workload Debug ==="
       puts after_midnight.debug_info

       # 日本時間では違う日なので、numberは1から始まる
       expect(after_midnight.number).to eq(1)
       expect(before_midnight.number).not_to eq(after_midnight.number)
     end

     it '週の変わり目で正しく計算される (月曜0時前後)' do
       # 日曜深夜のWorkload (JST月曜 0:00直前)
       sunday_workload = create(:workload,
         user: user,
         created_at: Time.zone.local(2024, 1, 7, 23, 59, 59)
       )
       sunday_workload.to_done!

       puts "\n=== Sunday Workload Debug ==="
       puts sunday_workload.debug_info

       # 月曜早朝のWorkload (JST月曜 0:00直後)
       monday_workload = create(:workload,
         user: user,
         created_at: Time.zone.local(2024, 1, 8, 0, 0, 1)
       )
       monday_workload.to_done!

       puts "\n=== Monday Workload Debug ==="
       puts monday_workload.debug_info

       # 週が変わるので、weekly_numberは1からリセット
       expect(monday_workload.weekly_number).to eq(1)
       expect(monday_workload.weekly_number).not_to eq(sunday_workload.weekly_number + 1)
     end

     context '複数のWorkloadが混在する場合' do
       it '同じ週内の複数のWorkloadで正しく連番が振られる' do
         workloads = []
         
         # 月曜から金曜まで、毎日3件ずつWorkloadを作成
         (0..4).each do |day_offset|
           3.times do |i|
             workload = create(:workload,
               user: user,
               created_at: Time.zone.local(2024, 1, 8, 10, 0, 0) + day_offset.days + i.hours
             )
             workload.to_done!
             workloads << workload
           end
         end

         puts "\n=== Weekly Workloads Debug ==="
         workloads.each do |w|
           puts "Time: #{w.created_at.in_time_zone('Tokyo')}, Weekly: #{w.weekly_number}"
         end

         # weekly_numberが1から15まで連番になっていることを確認
         expect(workloads.map(&:weekly_number)).to eq((1..15).to_a)
       end

       it '日付をまたぐWorkloadでも正しくnumberが計算される' do
         # 23:00, 23:30, 0:30のWorkloadを作成
         workloads = [
           create(:workload, user: user, created_at: Time.zone.local(2024, 1, 8, 23, 0)),
           create(:workload, user: user, created_at: Time.zone.local(2024, 1, 8, 23, 30)),
           create(:workload, user: user, created_at: Time.zone.local(2024, 1, 9, 0, 30))
         ]

         workloads.each(&:to_done!)

         puts "\n=== Cross-day Workloads Debug ==="
         workloads.each do |w|
           puts "Time: #{w.created_at.in_time_zone('Tokyo')}, Number: #{w.number}"
         end

         # 最初の2つは同じ日の1,2、最後は次の日の1になる
         expect(workloads[0].number).to eq(1)
         expect(workloads[1].number).to eq(2)
         expect(workloads[2].number).to eq(1)
       end
     end
   end
 end
end

# 既存のFactoryBot定義はそのまま
