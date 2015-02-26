module ParseRelApi
  extend ActiveSupport::Concern

  def index
    @items = @model.order('id desc')
    limit = params[:limit] ? params[:limit].to_i : 24
    @items = @items.limit(limit)
    params[:where].each do |key ,val|
      if key.match(/is_/)
        val = val == 'true' ? true : false
      end
      @items = @items.where(key => val)
    end
    @items = @items.map do |w| 
      hash = JSON.parse(w.to_json)
      hash['user'] = {id: w.user_hash}
      hash.delete('user_hash')
      {attributes: hash}
    end
    render json: @items
  end

  included do
    before_action :set_model
  end

  private
    def set_model
      @model = controller_name.classify.constantize
    end
end

