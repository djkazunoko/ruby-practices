#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'game'

shots = ARGV[0].split(',')

game = Game.new(shots)
puts game.score
