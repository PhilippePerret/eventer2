module Eventer
  class Logger
    def self.bootstrap(message)
      warn("[bootstrap] #{message}")
    end
  end
end
