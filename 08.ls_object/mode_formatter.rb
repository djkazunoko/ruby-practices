# frozen_string_literal: true

module LS
  class ModeFormatter
    MODE_MAP = {
      '0' => '---',
      '1' => '--x',
      '2' => '-w-',
      '3' => '-wx',
      '4' => 'r--',
      '5' => 'r-x',
      '6' => 'rw-',
      '7' => 'rwx'
    }.freeze

    attr_reader :mode

    def initialize(mode)
      @mode_octal = mode.to_s(8)
      permissions_numeric = @mode_octal.slice(-3..-1).split(//)
      @permissions_symbolic = permissions_numeric.map { |n| MODE_MAP[n] }
      @mode = add_special_permissions.join
    end

    private

    def add_special_permissions
      case @mode_octal.slice(-4)
      when '1'
        add_sticky_bit
      when '2'
        add_sgid
      when '4'
        add_suid
      end
      @permissions_symbolic
    end

    def add_sticky_bit
      @permissions_symbolic[2] = if @permissions_symbolic[2].slice(2) == 'x'
                                   @permissions_symbolic[2].gsub(/.$/, 't')
                                 else
                                   @permissions_symbolic[2].gsub(/.$/, 'T')
                                 end
    end

    def add_sgid
      @permissions_symbolic[1] = if @permissions_symbolic[1].slice(2) == 'x'
                                   @permissions_symbolic[1].gsub(/.$/, 's')
                                 else
                                   @permissions_symbolic[1].gsub(/.$/, 'S')
                                 end
    end

    def add_suid
      @permissions_symbolic[0] = if @permissions_symbolic[0].slice(2) == 'x'
                                   @permissions_symbolic[0].gsub(/.$/, 's')
                                 else
                                   @permissions_symbolic[0].gsub(/.$/, 'S')
                                 end
    end
  end
end
