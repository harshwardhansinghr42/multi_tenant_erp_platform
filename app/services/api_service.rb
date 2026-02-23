require "net/http"
require "uri"

# Service responsible for external API calls.
class ApiService
  def self.call(external_api_key:, payload:, endpoint: nil)
    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")

    req = Net::HTTP::Post.new(uri.request_uri, "Content-Type" => "application/json")
    req["Authorization"] = "Bearer #{external_api_key}"
    req.body = payload.to_json

    http.request(req)
  end
end
