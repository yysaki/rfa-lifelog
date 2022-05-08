# frozen_string_literal: true

require 'settings_cabinet'

class Settings < SettingsCabinet::Base
  using SettingsCabinet::DSL

  source File.expand_path('../config/settings.yml', __dir__)
end
