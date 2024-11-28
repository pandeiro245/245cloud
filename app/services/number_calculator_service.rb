# app/services/number_calculator_service.rb
class NumberCalculatorService
  class << self
    def recalculate_numbers_for_user(user_id, start_date: nil, end_date: nil)
      workloads = fetch_target_workloads(user_id, start_date, end_date)
      update_workload_numbers(workloads)
    end

    def verify_numbers_for_user(user_id, start_date: nil, end_date: nil)
      workloads = Workload.his(user_id)
                          .where(created_at: start_date..end_date)
                          .order(created_at: :asc)

      collect_verification_results(workloads)
    end

    def calculate_week_start(date)
      jst_time = date.in_time_zone('Tokyo')
      monday = jst_time.beginning_of_week(:monday)
      week_start = monday.beginning_of_day
      week_start.in_time_zone('UTC')
    end

    private

    def fetch_target_workloads(user_id, start_date, end_date)
      workloads = Workload.his(user_id)

      if start_date.present?
        start_time = Time.zone.parse(start_date.to_s).in_time_zone('Tokyo').beginning_of_day.in_time_zone('UTC')
        workloads = workloads.where(created_at: start_time..)
      end

      if end_date.present?
        end_time = Time.zone.parse(end_date.to_s).in_time_zone('Tokyo').end_of_day.in_time_zone('UTC')
        workloads = workloads.where(created_at: ..end_time)
      end

      workloads.order(created_at: :asc)
    end

    def update_workload_numbers(workloads)
      ActiveRecord::Base.transaction do
        current_date = nil
        current_week_start = nil
        daily_count = 0
        weekly_count = 0

        workloads.each do |workload|
          counts = calculate_counts(workload, current_date, current_week_start, daily_count, weekly_count)
          update_workload(workload, counts)

          current_date = workload.created_at.in_time_zone('Tokyo').to_date
          current_week_start = calculate_week_start(workload.created_at)
          daily_count = counts[:daily]
          weekly_count = counts[:weekly]
        end
      end
    end

    def calculate_counts(workload, current_date, current_week_start, daily_count, weekly_count)
      jst_date = workload.created_at.in_time_zone('Tokyo').to_date
      week_start = calculate_week_start(workload.created_at)

      daily_count = 0 if current_date != jst_date
      weekly_count = 0 if current_week_start != week_start

      {
        daily: daily_count + 1,
        weekly: weekly_count + 1
      }
    end

    def update_workload(workload, counts)
      workload.update!(
        number: counts[:daily],
        weekly_number: counts[:weekly]
      )
    end

    def collect_verification_results(workloads)
      results = {}

      workloads.each do |workload|
        jst_time = workload.created_at.in_time_zone('Tokyo')
        date_key = jst_time.strftime('%Y-%m-%d')
        week_key = calculate_week_start(workload.created_at)
                   .in_time_zone('Tokyo')
                   .strftime('%Y-%m-%d')

        results[date_key] ||= []
        results[date_key] << build_verification_result(workload, jst_time, week_key)
      end

      results
    end

    def build_verification_result(workload, jst_time, week_key)
      {
        created_at: jst_time,
        number: workload.number,
        weekly_number: workload.weekly_number,
        week_start: week_key
      }
    end
  end
end
