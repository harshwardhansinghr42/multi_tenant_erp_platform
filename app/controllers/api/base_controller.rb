module Api
  class BaseController < ApplicationController
    before_action :authenticate_token!
    around_action :switch_tenant

    private

    def authenticate_token!
      auth = request.headers["Authorization"].to_s
      token = auth.split(" ").last
      render json: { error: "Unauthorized" }, status: :unauthorized and return unless token.present?

      begin
        @jwt_payload = JwtService.decode(token)
      rescue JWT::ExpiredSignature
        render json: { error: "Token expired" }, status: :unauthorized and return
      rescue StandardError
        render json: { error: "Invalid token" }, status: :unauthorized and return
      end
    end

    def switch_tenant
      company = Company.find_by(slug: @jwt_payload["company_slug"])
      unless company
        render json: { error: "Invalid tenant" }, status: :unauthorized and return
      end

      # Keep host company available to controllers/jobs
      @current_company = company

      TenantSwitcher.with(tenant: company) do
        # Load current_user from tenant DB
        @current_user = User.find_by(id: @jwt_payload["user_id"])
        yield
      end
    end
  end
end
