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

        # デバッグ情報の出力
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

        # 日本時間では違う日なので、numberは別々に計算される
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
