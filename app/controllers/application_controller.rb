class ApplicationController < ActionController::API
  def authenticate_jwt
    auth_header = request.headers['Authorization']
    if auth_header.present? && auth_header =~ /^Bearer /
      payload = auth_header.split(' ').last
      begin
        retrieve_secrets
        res = JSON.parse(JWT.decode(payload, @secret, true, { :algorithm => @encryption }).first)
        p "res, #{res}"
        data = res["data"]
        data ||= res
        @current_user = User.find_by(phone_no: data["phone_no"])
        p @current_user.firstname
        render json: {data: 'unauthorized', status: false}, status: :unauthorized unless @current_user
      rescue JWT::DecodeError
        render json: { data: 'invalid token', status: false }, status: :unauthorized
      end
    else
      render json: { data: 'Unauthorized', status: false }, status: :unauthorized
    end
  end

  def retrieve_secrets
    @secret = ENV["OTP_JWT_SECRET"]      
    @encryption = ENV["JWT_ENCRYPTION"]
  end

end
