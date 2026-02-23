class JwtService
  ALGORITHM = "HS256".freeze

  def self.encode(payload, exp = 24.hours.from_now)
    payload = payload.dup
    payload["exp"] = exp.to_i
    JWT.encode(payload, secret, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret, true, { algorithm: ALGORITHM })
    decoded[0]
  rescue JWT::DecodeError => e
    raise e
  end

  def self.secret
    # Prefer explicit credential; fall back to secret_key_base
    Rails.application.credentials.dig(:jwt_secret) || Rails.application.secret_key_base
  end
end
