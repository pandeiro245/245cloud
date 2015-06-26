class RoomsController < ApplicationController
  def show
    @workload = current_user.chatting_workload
    if @workload
      @remain = (@workload.created_at + Workload.pomotime.minutes + 5.minutes- Time.now).to_i
      is_redirect = true if @remain < 0
    end
    redirect_to '/' if is_redirect || !@workload
  end
end
