#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'command'

LS::Command.new(ARGV).list_files
