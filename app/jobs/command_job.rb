# frozen_string_literal: true

class CommandJob < ApplicationJob
  def execute
    command = event['command'] || 'uptime'
    sh command
  end

  def migrate
    sh 'jets db:migrate'
  end

  private

  def sh(command)
    puts "=> #{command}"
    puts `#{command}`
  end
end
