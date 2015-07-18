class City < ActiveRecord::Base
  belongs_to :pref
  has_many :postals
  store :info, accessors: [:population2005, :population2010, :size]

  def pop(type=2010)
    if type.to_i == 2005
      population2005
    else
      population2010
    end
  end
end
