require 'rails_helper'

RSpec.describe Workload do
  describe '.process_workload_numbers' do
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
        workloads = Workload.fetch_workloads(
          user.id,
          base_time.beginning_of_day,
          base_time.end_of_day
        )
        Workload.process_workload_numbers(workloads)

        numbers = workloads.reload.map(&:number)
        expect(numbers).to eq [1, 2, 3]
      end

      it 'weekly_numberが連番で設定される' do
        workloads = Workload.fetch_workloads(
          user.id,
          base_time.beginning_of_day,
          base_time.end_of_day
        )
        Workload.process_workload_numbers(workloads)

        weekly_numbers = workloads.reload.map(&:weekly_number)
        expect(weekly_numbers).to eq [1, 2, 3]
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
        workloads = Workload.fetch_workloads(
          user.id,
          base_time.beginning_of_day,
          (base_time + 1.day).end_of_day
        )
        Workload.process_workload_numbers(workloads)

        numbers = workloads.reload.map(&:number)
        expect(numbers).to eq [1, 2, 1, 2]
      end

      it 'weekly_numberは継続して増加する' do
        workloads = Workload.fetch_workloads(
          user.id,
          base_time.beginning_of_day,
          (base_time + 1.day).end_of_day
        )
        Workload.process_workload_numbers(workloads)

        weekly_numbers = workloads.reload.map(&:weekly_number)
        expect(weekly_numbers).to eq [1, 2, 3, 4]
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
        workloads = Workload.fetch_workloads(
          user.id,
          base_time.beginning_of_day,
          (base_time + 1.week).end_of_day
        )
        Workload.process_workload_numbers(workloads)

        numbers = workloads.reload.map(&:number)
        expect(numbers).to eq [1, 2, 1, 2]
      end

      it 'weekly_numberは週ごとにリセットされる' do
        workloads = Workload.fetch_workloads(
          user.id,
          base_time.beginning_of_day,
          (base_time + 1.week).end_of_day
        )
        Workload.process_workload_numbers(workloads)

        weekly_numbers = workloads.reload.map(&:weekly_number)
        expect(weekly_numbers).to eq [1, 2, 1, 2]
      end
    end
  end
end
