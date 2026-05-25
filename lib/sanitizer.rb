module Eventer
  class Sanitizer
    ID_PATTERN = /\A[a-zA-Z0-9_-]+\z/

    def self.id(value, label = 'Identifiant invalide')
      cleaned = value.to_s.strip
      raise ArgumentError, label unless cleaned.match?(ID_PATTERN)

      cleaned
    end

    def self.path(value)
      raw = value.to_s.strip
      return [] if raw.empty?

      raw.split('/').map { |part| id(part, 'Chemin invalide') }
    end
  end
end
