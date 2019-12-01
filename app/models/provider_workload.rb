class ProviderWorkload < ApplicationRecord
  belongs_to :workload
  belongs_to :provider
  belongs_to :provider_user
end
