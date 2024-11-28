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

      # 既存のテストケース...

      context '日本時間とUTC時間の差異による問題の再現' do
        it 'UTCでの日付変更時に日本時間での集計が正しく行われる' do
          # UTC 14:55 (JST 23:55) に1つ目のWorkload作成
          first_workload = create(:workload,
            user: user,
            created_at: Time.utc(2024, 1, 15, 14, 55)  # JST 23:55
          )
          first_workload.to_done!

          # UTC 15:05 (JST 00:05) に2つ目のWorkload作成
          second_workload = create(:workload,
            user: user,
            created_at: Time.utc(2024, 1, 15, 15, 5)   # JST 00:05
          )
          second_workload.to_done!

          puts "\n=== First Workload (UTC 14:55 / JST 23:55) ==="
          puts "UTC Time: #{first_workload.created_at}"
          puts "JST Time: #{first_workload.created_at.in_time_zone('Tokyo')}"
          puts "Number: #{first_workload.number}"
          puts "Weekly Number: #{first_workload.weekly_number}"

          puts "\n=== Second Workload (UTC 15:05 / JST 00:05) ==="
          puts "UTC Time: #{second_workload.created_at}"
          puts "JST Time: #{second_workload.created_at.in_time_zone('Tokyo')}"
          puts "Number: #{second_workload.number}"
          puts "Weekly Number: #{second_workload.weekly_number}"

          # 日本時間では異なる日付なので、numberは1からリセットされるべき
          expect(second_workload.number).to eq(1)
          
          # weekly_numberは連続すべき（同じ週なので）
          expect(second_workload.weekly_number).to eq(first_workload.weekly_number + 1)
        end

        it '週末の日本時間とUTC時間の差異による問題の再現' do
          # 日曜日 UTC 14:55 (JST 23:55) のWorkload
          sunday_workload = create(:workload,
            user: user,
            created_at: Time.utc(2024, 1, 21, 14, 55)  # JST 23:55 Sunday
          )
          sunday_workload.to_done!

          # 月曜日 UTC 15:05 (JST 00:05) のWorkload
          monday_workload = create(:workload,
            user: user,
            created_at: Time.utc(2024, 1, 21, 15, 5)   # JST 00:05 Monday
          )
          monday_workload.to_done!

          puts "\n=== Sunday Workload (UTC 14:55 / JST 23:55) ==="
          puts "UTC Time: #{sunday_workload.created_at}"
          puts "JST Time: #{sunday_workload.created_at.in_time_zone('Tokyo')}"
          puts "Number: #{sunday_workload.number}"
          puts "Weekly Number: #{sunday_workload.weekly_number}"

          puts "\n=== Monday Workload (UTC 15:05 / JST 00:05) ==="
          puts "UTC Time: #{monday_workload.created_at}"
          puts "JST Time: #{monday_workload.created_at.in_time_zone('Tokyo')}"
          puts "Number: #{monday_workload.number}"
          puts "Weekly Number: #{monday_workload.weekly_number}"

          # 日本時間では月曜日になっているので、weekly_numberは1にリセットされるべき
          expect(monday_workload.weekly_number).to eq(1)
          
          # numberも新しい日の1になるべき
          expect(monday_workload.number).to eq(1)
        end

        it '1分間隔での連続したWorkloadで正しく計算される' do
          base_time = Time.utc(2024, 1, 15, 14, 50)  # JST 23:50
          workloads = []

          # 1分間隔で20個のWorkloadを作成（日付をまたぐ）
          20.times do |i|
            workload = create(:workload,
              user: user,
              created_at: base_time + i.minutes
            )
            workload.to_done!
            workloads << workload
          end

          puts "\n=== Sequential Workloads ===="
          workloads.each do |w|
            puts "UTC: #{w.created_at}, JST: #{w.created_at.in_time_zone('Tokyo')}"
            puts "Number: #{w.number}, Weekly: #{w.weekly_number}"
          end

          # JST 00:00をまたいだ後のWorkloadは number が1からリセットされるべき
          jst_midnight = Time.zone.local(2024, 1, 16, 0, 0, 0)
          after_midnight_workloads = workloads.select { |w| w.created_at.in_time_zone('Tokyo') >= jst_midnight }
          expect(after_midnight_workloads.first.number).to eq(1)
        end
      end
    end
  end
end
