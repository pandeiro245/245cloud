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
      # 日本時間の2024/1/1 00:00を基準にテストデータを作成
      let(:base_time) { Time.zone.local(2024, 1, 1, 0, 0, 0) }

      before do
        # テスト用の完了済みWorkloadを作成
        create(:workload, user: user, created_at: base_time - 1.day, is_done: true, number: 1, weekly_number: 1)
        create(:workload, user: user, created_at: base_time - 12.hours, is_done: true, number: 2, weekly_number: 2)
      end

      it '日本時間での日次カウントが正しく計算される' do
        # 日本時間1/1 00:30に新しいWorkloadを作成
        new_workload = create(:workload, user: user, created_at: base_time + 30.minutes)
        new_workload.to_done!
        
        # 前日のWorkloadは含まれず、当日の分だけでカウント
        expect(new_workload.number).to eq(1)
      end

      it '日本時間での週次カウントが正しく計算される' do
        # 2024/1/1は火曜日。週の開始は月曜日
        new_workload = create(:workload, user: user, created_at: base_time + 1.hour)
        new_workload.to_done!
        
        expect(new_workload.weekly_number).to eq(1)
      end

      it '日本時間での週をまたぐ集計が正しく計算される' do
        # 12/31(月) 23:50のWorkload
        monday_workload = create(:workload, 
          user: user, 
          created_at: Time.zone.local(2023, 12, 31, 23, 50, 0),
          is_done: true
        )
        monday_workload.to_done!

        # 1/1(火) 00:10のWorkload
        tuesday_workload = create(:workload,
          user: user,
          created_at: Time.zone.local(2024, 1, 1, 0, 10, 0)
        )
        tuesday_workload.to_done!

        # 同じ週なので、weekly_numberは連続する
        expect(tuesday_workload.weekly_number).to eq(monday_workload.weekly_number + 1)
      end

      it '異なる時間帯でも日本時間に基づいて集計される' do
        # UTCで12/31 15:00 (日本時間1/1 00:00)のWorkload
        Time.use_zone('UTC') do
          workload = create(:workload,
            user: user,
            created_at: Time.zone.local(2023, 12, 31, 15, 0, 0)
          )
          workload.to_done!
          
          # 日本時間では1/1なので、numberは1から始まる
          expect(workload.number).to eq(1)
        end
      end
    end

    context 'today/thisweekスコープ' do
      let(:base_time) { Time.zone.local(2024, 1, 1, 9, 0, 0) } # 日本時間9:00

      it 'todayスコープが日本時間の日付で正しく動作する' do
        # 前日23:50のWorkload
        create(:workload, user: user, created_at: base_time - 9.hours - 10.minutes, is_done: true)
        # 当日0:10のWorkload
        today_workload = create(:workload, user: user, created_at: base_time - 8.hours + 10.minutes, is_done: true)
        
        # POMOTIMEを考慮した集計時点で、当日分のみが含まれる
        expect(Workload.today(base_time)).to contain_exactly(today_workload)
      end

      it 'thisweekスコープが日本時間の週で正しく動作する' do
        # 先週金曜のWorkload
        create(:workload, user: user, created_at: base_time - 4.days, is_done: true)
        # 今週月曜のWorkload
        this_week_workload = create(:workload, user: user, created_at: base_time - 1.day, is_done: true)
        
        # 週初めから現在までのWorkloadが含まれる
        expect(Workload.thisweek(base_time)).to contain_exactly(this_week_workload)
      end
    end
  end
end
