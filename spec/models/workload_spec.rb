# spec/models/workload_spec.rb
RSpec.describe Workload, type: :model do
  describe 'タイムゾーンに関連するテスト' do
    let(:user) { create(:user) }

    around do |example|
      Time.use_zone('Tokyo') do
        example.run
      end
    end

    describe 'when calculating number and weekly_number' do
      let(:base_time) { Time.zone.local(2024, 1, 1, 0, 0, 0) }

      it 'increments weekly number across days within same week' do
        monday_workload = create(:workload,
                                 user: user,
                                 created_at: Time.zone.local(2023, 12, 31, 23, 50, 0),
                                 is_done: true)
        monday_workload.to_done!

        tuesday_workload = create(:workload,
                                  user: user,
                                  created_at: Time.zone.local(2024, 1, 1, 0, 10, 0))
        tuesday_workload.to_done!

        expect(tuesday_workload.weekly_number).to eq(monday_workload.weekly_number + 1)
      end

      describe 'when handling UTC and JST time differences' do
        it 'correctly numbers workloads across midnight JST' do
          before_midnight = create(:workload,
                                   user: user,
                                   created_at: Time.utc(2023, 12, 31, 14, 59))
          before_midnight.to_done!

          after_midnight = create(:workload,
                                  user: user,
                                  created_at: Time.utc(2023, 12, 31, 15, 1))
          after_midnight.to_done!

          expect(after_midnight.number).to eq(1)
        end

        it 'resets weekly number at start of week JST' do
          sunday_workload = create(:workload,
                                   user: user,
                                   created_at: Time.zone.local(2024, 1, 7, 23, 59, 59))
          sunday_workload.to_done!

          monday_workload = create(:workload,
                                   user: user,
                                   created_at: Time.zone.local(2024, 1, 8, 0, 0, 1))
          monday_workload.to_done!

          expect(monday_workload.weekly_number).to eq(1)
        end

        it 'correctly handles sequential workloads' do
          base_time = Time.utc(2024, 1, 15, 14, 50)
          first_workload = create(:workload,
                                  user: user,
                                  created_at: base_time)
          first_workload.to_done!

          second_workload = create(:workload,
                                   user: user,
                                   created_at: base_time + 10.minutes)
          second_workload.to_done!

          expect(second_workload.number).to eq(2)
        end
      end
    end
  end
end
