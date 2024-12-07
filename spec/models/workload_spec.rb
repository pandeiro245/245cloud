require 'rails_helper'

RSpec.describe Workload do
  describe '.recalculate_numbers_for_user' do
    let(:user) { create(:user) }
    let(:base_time) { Time.zone.local(2024, 1, 1, 12, 0, 0) }

    context '同じ日のWorkloadの場合' do
      before do
        # 同じ日に3つのWorkloadを作成
        create(:workload, user: user, created_at: base_time, is_done: true)
        create(:workload, user: user, created_at: base_time + 1.hour, is_done: true)
        create(:workload, user: user, created_at: base_time + 2.hours, is_done: true)
      end

      it 'numberが連番で設定される' do
        described_class.recalculate_numbers_for_user(
          user.id,
          start_date: base_time.to_date.to_s,
          end_date: base_time.to_date.to_s
        )

        workloads = user.workloads.where(created_at: base_time.all_day)
                        .order(:created_at)
        expect(workloads.map(&:number)).to eq [1, 2, 3]
      end

      it 'weekly_numberが連番で設定される' do
        described_class.recalculate_numbers_for_user(
          user.id,
          start_date: base_time.to_date.to_s,
          end_date: base_time.to_date.to_s
        )

        workloads = user.workloads.where(created_at: base_time.all_day)
                        .order(:created_at)
        expect(workloads.map(&:weekly_number)).to eq [1, 2, 3]
      end
    end

    context '異なる日のWorkloadの場合' do
      before do
        # 1日目に2つ、2日目に2つのWorkloadを作成
        create(:workload, user: user, created_at: base_time, is_done: true)
        create(:workload, user: user, created_at: base_time + 1.hour, is_done: true)
        create(:workload, user: user, created_at: base_time + 1.day, is_done: true)
        create(:workload, user: user, created_at: base_time + 1.day + 1.hour, is_done: true)
      end

      it '日ごとにnumberがリセットされる' do
        described_class.recalculate_numbers_for_user(
          user.id,
          start_date: base_time.to_date.to_s,
          end_date: (base_time + 1.day).to_date.to_s
        )

        workloads = user.workloads.where(
          created_at: base_time.beginning_of_day..(base_time + 1.day).end_of_day
        ).order(:created_at)
        expect(workloads.map(&:number)).to eq [1, 2, 1, 2]
      end

      it 'weekly_numberは継続して増加する' do
        described_class.recalculate_numbers_for_user(
          user.id,
          start_date: base_time.to_date.to_s,
          end_date: (base_time + 1.day).to_date.to_s
        )

        workloads = user.workloads.where(
          created_at: base_time.beginning_of_day..(base_time + 1.day).end_of_day
        ).order(:created_at)
        expect(workloads.map(&:weekly_number)).to eq [1, 2, 3, 4]
      end
    end

    context '異なる週のWorkloadの場合' do
      before do
        # 第1週に2つ、第2週に2つのWorkloadを作成
        create(:workload, user: user, created_at: base_time, is_done: true)
        create(:workload, user: user, created_at: base_time + 1.hour, is_done: true)
        create(:workload, user: user, created_at: base_time + 1.week, is_done: true)
        create(:workload, user: user, created_at: base_time + 1.week + 1.hour, is_done: true)
      end

      it '週が変わってもnumberは日ごとにリセットされる' do
        described_class.recalculate_numbers_for_user(
          user.id,
          start_date: base_time.to_date.to_s,
          end_date: (base_time + 1.week).to_date.to_s
        )

        workloads = user.workloads.where(
          created_at: base_time.beginning_of_day..(base_time + 1.week).end_of_day
        ).order(:created_at)
        expect(workloads.map(&:number)).to eq [1, 2, 1, 2]
      end

      it 'weekly_numberは週ごとにリセットされる' do
        described_class.recalculate_numbers_for_user(
          user.id,
          start_date: base_time.to_date.to_s,
          end_date: (base_time + 1.week).to_date.to_s
        )

        workloads = user.workloads.where(
          created_at: base_time.beginning_of_day..(base_time + 1.week).end_of_day
        ).order(:created_at)
        expect(workloads.map(&:weekly_number)).to eq [1, 2, 1, 2]
      end
    end
  end
end
