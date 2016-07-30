class GakkisonController < ApplicationController
  def index
    @gakkis = {
      bd: 'バスドラ',
      hh: 'ハイハット',
      sd: 'スネア'
    }
  end
end
