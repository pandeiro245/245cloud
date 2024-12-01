# spec/models/workload_spec.rb
require 'rails_helper'

RSpec.describe NumberCalculatorService do
  describe '.recalculate_numbers_for_user' do
    let(:user) { create(:user) }
    
    context '指定した日付範囲内のworkloadが存在する場合' do
      let!(:workload1) { create(:workload, user: user, is_done: true, created_at: '2024-01-01 10:00:00') }
      let!(:workload2) { create(:workload, user: user, is_done: true, created_at: '2024-01-01 11:00:00') }
      let!(:workload3) { create(:workload, user: user, is_done: true, created_at: '2024-01-02 10:00:00') }

      it '日次番号が正しく計算される' do
        described_class.recalculate_numbers_for_user(user.id, start_date: '2024-01-01', end_date: '2024-01-02')
        
        expect(workload1.reload.number).to eq(1)
        expect(workload2.reload.number).to eq(2)
        expect(workload3.reload.number).to eq(1)
      end

      it '週次番号が正しく計算される' do
        described_class.recalculate_numbers_for_user(user.id, start_date: '2024-01-01', end_date: '2024-01-02')
        
        expect(workload1.reload.weekly_number).to eq(1)
        expect(workload2.reload.weekly_number).to eq(2)
        expect(workload3.reload.weekly_number).to eq(3)
      end
    end

    context '指定した日付範囲内のworkloadが存在しない場合' do
      it '何も更新されない' do
        expect {
          described_class.recalculate_numbers_for_user(user.id, start_date: '2024-01-01', end_date: '2024-01-02')
        }.not_to change { Workload.count }
      end
    end
  end

  describe '.verify_numbers_for_user' do
    let(:user) { create(:user) }
    let!(:workload) { create(:workload, user: user, is_done: true, number: 1, weekly_number: 1, created_at: '2024-01-01 10:00:00') }

    it '正しい形式でデータを返す' do
      result = described_class.verify_numbers_for_user(user.id, start_date: '2024-01-01', end_date: '2024-01-01')
      
      expect(result['2024-01-01']).to be_present
      expect(result['2024-01-01'].first).to include(
        created_at: workload.created_at.in_time_zone('Tokyo'),
        number: 1,
        weekly_number: 1,
        week_start: '2024-01-01'
      )
    end
  end

  describe '.calculate_week_start' do
    it '日本時間での週初め（月曜日）を返す' do
      date = Time.zone.parse('2024-01-03 10:00:00') # 水曜日
      result = described_class.calculate_week_start(date)
      
      expect(result.in_time_zone('Tokyo').strftime('%Y-%m-%d')).to eq('2024-01-01')
    end
  end
end
