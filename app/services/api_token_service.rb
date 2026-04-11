class ApiTokenService
  def self.generate!(user, expires_in: nil)
    token = SecureRandom.hex(24)
    expires_at = expires_in&.from_now
    user.update(api_token: token, api_token_expires_at: expires_at)
    token
  end

  def self.revoke!(user)
    user.update(api_token: nil, api_token_expires_at: nil)
  end
end
