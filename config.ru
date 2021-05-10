# frozen_string_literal: true

require 'jets'
require './app/racks/auth'

use Auth
Jets.boot
run Jets.application
