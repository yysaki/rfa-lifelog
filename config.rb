# frozen_string_literal: true

require 'settings_cabinet'

class Settings < SettingsCabinet::Base
  using SettingsCabinet::DSL

  source 'config/settings.yml'
end
