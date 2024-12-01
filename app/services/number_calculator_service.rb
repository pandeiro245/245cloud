class NumberCalculatorService
  class << self
    def recalculate_numbers_for_user(user_id, start_date:, end_date:)
      update_workload_numbers(user_id, start_date, end_date)
    end

    def verify_numbers_for_user(user_id, start_date:, end_date:)
      start_time = Time.zone.parse(start_date).beginning_of_day
      end_time = Time.zone.parse(end_date).end_of_day

      workloads = fetch_workloads(user_id, start_time, end_time)
      group_workloads_by_date(workloads)
    end

    def calculate_week_start(date)
      date.in_time_zone('Tokyo').beginning_of_week
    end

    private

    def fetch_workloads(user_id, start_time, end_time)
      Workload.where(user_id: user_id)
              .where(created_at: start_time..end_time)
              .where(is_done: true)
              .order(:created_at)
    end

    def group_workloads_by_date(workloads)
      workloads.group_by { |w| w.created_at.in_time_zone('Tokyo').to_date.to_s }
               .transform_values do |daily_workloads|
        daily_workloads.map { |workload| workload_data(workload) }
      end
    end

    def workload_data(workload)
      {
        created_at: workload.created_at.in_time_zone('Tokyo'),
        number: workload.number,
        weekly_number: workload.weekly_number,
        week_start: calculate_week_start(workload.created_at).strftime('%Y-%m-%d')
      }
    end

    def update_workload_numbers(user_id, start_date, end_date)
      start_time = Time.zone.parse(start_date).beginning_of_day
      end_time = Time.zone.parse(end_date).end_of_day

      workloads = fetch_workloads(user_id, start_time, end_time)
      process_workload_numbers(workloads)
    end

    def process_workload_numbers(workloads)
      weekly_count = 0
      current_date = nil
      current_week_start = nil
      daily_count = 0

      workloads.each do |workload|
        workload_date = workload.created_at.in_time_zone('Tokyo').to_date
        workload_week_start = calculate_week_start(workload.created_at)

        if workload_date != current_date
          daily_count = 0
          current_date = workload_date
        end

        current_week_start = workload_week_start if workload_week_start != current_week_start

        daily_count += 1
        weekly_count += 1

        workload.update!(
          number: daily_count,
          weekly_number: weekly_count
        )
      end
    end
  end
end
