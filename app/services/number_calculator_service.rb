# app/services/number_calculator_service.rb
class NumberCalculatorService
  class << self
    def recalculate_numbers_for_user(user_id, start_date: nil, end_date: nil)
      # 対象となるWorkloadを取得
      workloads = Workload.his(user_id)

      # 期間指定がある場合は範囲を限定
      if start_date.present?
        start_time = Time.zone.parse(start_date.to_s).in_time_zone('Tokyo').beginning_of_day.in_time_zone('UTC')
        workloads = workloads.where('created_at >= ?', start_time)
      end

      if end_date.present?
        end_time = Time.zone.parse(end_date.to_s).in_time_zone('Tokyo').end_of_day.in_time_zone('UTC')
        workloads = workloads.where('created_at <= ?', end_time)
      end

      # created_atの昇順でソート
      workloads = workloads.order(created_at: :asc)

      # トランザクション内で更新を実行
      ActiveRecord::Base.transaction do
        # 日付ごとのカウンターと週ごとのカウンターをリセット
        current_date = nil
        current_week_start = nil
        daily_count = 0
        weekly_count = 0

        workloads.each do |workload|
          # 日本時間での日付を取得
          jst_date = workload.created_at.in_time_zone('Tokyo').to_date
          week_start = calculate_week_start(workload.created_at)

          # 日付が変わったらカウンターをリセット
          if current_date != jst_date
            current_date = jst_date
            daily_count = 0
          end

          # 週が変わったらweekly_numberをリセット
          if current_week_start != week_start
            current_week_start = week_start
            weekly_count = 0
          end

          # カウンターをインクリメント
          daily_count += 1
          weekly_count += 1

          # 番号を更新
          workload.update_columns(
            number: daily_count,
            weekly_number: weekly_count
          )
        end
      end
    end

    def verify_numbers_for_user(user_id, start_date: nil, end_date: nil)
      workloads = Workload.his(user_id)
                          .where(created_at: start_date..end_date)
                          .order(created_at: :asc)

      results = {}

      workloads.each do |workload|
        jst_time = workload.created_at.in_time_zone('Tokyo')
        date_key = jst_time.strftime('%Y-%m-%d')
        week_key = calculate_week_start(workload.created_at)
                   .in_time_zone('Tokyo')
                   .strftime('%Y-%m-%d')

        results[date_key] ||= []
        results[date_key] << {
          created_at: jst_time,
          number: workload.number,
          weekly_number: workload.weekly_number,
          week_start: week_key
        }
      end

      results
    end

    def calculate_week_start(date)
      # JSTでの週の開始日時を計算
      jst_time = date.in_time_zone('Tokyo')

      # 月曜日の0時を取得（JSTベース）
      monday = jst_time.beginning_of_week(:monday)
      week_start = monday.beginning_of_day

      # UTCに変換して返す
      week_start.in_time_zone('UTC')
    end
  end
end
