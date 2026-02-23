class OrderReportingJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 5.seconds, attempts: 3 do |job, error|
    company_id, order_id = job.arguments
    Rails.logger.warn("OrderReportingJob retrying company=#{company_id} order=#{order_id}: #{error.message}")
  end

  def perform(company_id, order_id)
    company = Company.find_by(id: company_id)
    unless company
      Rails.logger.warn("OrderReportingJob: company=#{company_id} not found")
      return
    end

    endpoint = ENV["ORDER_REPORT_URL"]
    unless endpoint.present? && company.external_api_key.present?
      Rails.logger.warn("OrderReportingJob: missing endpoint or api key for company=#{company.id}")
      return
    end

    TenantSwitcher.with(tenant: company) do
      order = Order.find_by(id: order_id)
      unless order
        Rails.logger.warn("OrderReportingJob: order=#{order_id} not found for company=#{company.slug}")
        return
      end

      payload = {
        order_number: order.order_number,
        items: order.items,
        total_cents: order.total_cents,
        status: order.status,
        created_at: order.created_at&.iso8601
      }

      res = ApiService.call(external_api_key: company.external_api_key, payload: payload, endpoint: endpoint)
      unless res.is_a?(Net::HTTPSuccess)
        raise "OrderReportingJob: report failed for company=#{company.id} order=#{order.id} -> #{res.code} #{res.body}"
      end
    end
  rescue StandardError => e
    Rails.logger.error("OrderReportingJob failed for company=#{company_id} order=#{order_id}: #{e.message}")
    raise e
  end
end
