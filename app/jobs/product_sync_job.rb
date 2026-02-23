require "csv"

class ProductSyncJob < ApplicationJob
  queue_as :default

  # Retry a couple times for transient failures
  retry_on StandardError, wait: 30.seconds, attempts: 3 do |job, error|
    Rails.logger.warn("ProductSyncJob retry: #{error.message}")
  end

  # If company_id is provided, sync only that tenant; otherwise sync all companies.
  def perform(company_id = nil)
    companies = company_id ? Company.where(id: company_id) : Company.all

    companies.find_each do |company|
      TenantSwitcher.with(tenant: company) do
        csv_path = Rails.root.join("data", "csvs", "#{company.slug}_products.csv")
        unless File.exist?(csv_path)
          Rails.logger.info("ProductSyncJob: no CSV for #{company.slug} at #{csv_path}")
          next
        end

        CSV.foreach(csv_path, headers: true) do |row|
          attrs = {
            sku: row["sku"],
            name: row["name"],
            description: row["description"],
            price_cents: (row["price_cents"] || 0).to_i
          }
          product = Product.find_or_initialize_by(sku: attrs[:sku])
          product.assign_attributes(attrs)
          product.save!
        end

        Rails.logger.info("ProductSyncJob: imported products for tenant #{company.slug} from #{csv_path}")
      end
    end
  end
end
