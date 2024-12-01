class NumberCalculatorService
  class << self
    def recalculate_numbers_for_user(user_id, start_date: nil, end_date: nil)
      target_workloads = fetch_workloads_for_recalculation(user_id, start_date, end_date)
      update_workload_numbers(target_workloads)
    end

    def verify_numbers_for_user(user_id, start_date: nil, end_date: nil)
      workloads = Workload.where(user_id: user_id)
        .where(is_done: true)
        .where(created_at: start_date..end_date)
        .order(created_at: :asc)
      
      results = {}
      
      workloads.each do |workload|
        jst_time = workload.created_at.in_time_zone('Tokyo')
        date_key = jst_time.strftime('%Y-%m-%d')
        week_start = calculate_week_start(workload.created_at)
                    .in_time_zone('Tokyo')
                    .strftime('%Y-%m-%d')

        results[date_key] ||= []
        results[date_key] << {
          created_at: jst_time,
          number: workload.number,
          weekly_number: workload.weekly_number,
          week_start: week_start
        }
      end

      results
    end

    def calculate_week_start(date)
      jst_time = date.in_time_zone('Tokyo')
      monday = jst_time.beginning_of_week(:monday)
      monday.beginning_of_day.in_time_zone('UTC')
    end

    private

    def fetch_workloads_for_recalculation(user_id, start_date, end_date)
      return [] unless start_date.present?

      start_time = Time.zone.parse(start_date.to_s).in_time_zone('Tokyo').beginning_of_day
      end_time = end_date.present? ? Time.zone.parse(end_date.to_s).in_time_zone('Tokyo').end_of_day : start_time
      
      start_time_utc = start_time.in_time_zone('UTC')
      end_time_utc = end_time.in_time_zone('UTC')

      Workload.where(user_id: user_id, is_done: true)
        .where('created_at >= ? AND created_at <= ?', start_time_utc, end_time_utc)
        .order(created_at: :asc)
    end

    def update_workload_numbers(workloads)
      return if workloads.empty?

      ActiveRecord::Base.transaction do
        current_date = nil
        weekly_count = 0

        workloads.each do |workload|
          jst_time = workload.created_at.in_time_zone('Tokyo')
          jst_date = jst_time.to_date

          if current_date != jst_date
            current_date = jst_date
            daily_count = 1
          else
            daily_count += 1
          end

          weekly_count += 1

          workload.update!(
            number: daily_count,
            weekly_number: weekly_count
          )
        end
      end
    end
  end
end
