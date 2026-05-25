module Eventer
  module HttpHelpers
    def request_payload
      request.body.rewind
      JSON.parse(request.body.read)
    rescue JSON::ParserError
      {}
    end
  end
end
