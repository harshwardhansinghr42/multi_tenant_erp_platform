module Api
  class OrdersController < BaseController
    skip_before_action :verify_authenticity_token, only: :create

    def create
      unless @current_user
        render json: { error: "Unauthorized" }, status: :unauthorized and return
      end

      order = Order.new(order_params)
      order.user = @current_user if order.respond_to?(:user=)

      if order.save
        OrderReportingJob.perform_later(@current_company.id, order.id)
        render json: { id: order.id }, status: :created
      else
        render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def order_params
      params.require(:order).permit(:order_number, :shop_id, :total_cents, :status, items: {})
    end
  end
end
