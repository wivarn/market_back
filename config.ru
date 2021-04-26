# frozen_string_literal: true

require 'jets'
require './config/auth'

use Auth
Jets.boot
run Jets.application
