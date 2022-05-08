# frozen_string_literal: true

require_relative 'lib/interactor'

def handler(event:, context:) # rubocop:disable Lint/UnusedMethodArgument
  Interactor.call
end

pp handler(event: {}, context: {}) if __FILE__ == $PROGRAM_NAME
