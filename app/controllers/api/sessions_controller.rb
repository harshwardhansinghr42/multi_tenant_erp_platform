module Api
  class SessionsController < ApplicationController
    # Login does not require an existing token
    skip_before_action :verify_authenticity_token, only: :create

    def create
      company = Company.find_by(slug: params[:company_slug])
      return render json: { error: "Invalid company" }, status: :unauthorized unless company

      TenantSwitcher.with(tenant: company) do
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          token = JwtService.encode({ "user_id" => user.id, "company_slug" => company.slug })
          return render json: { token: token, expires_in: 24.hours.to_i }
        else
          return render json: { error: "Invalid credentials" }, status: :unauthorized
        end
      end
    end
  end
end
