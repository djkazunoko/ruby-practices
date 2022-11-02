# frozen_string_literal: true

require 'etc'

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

module LS
  class Path
    attr_reader :type, :mode, :nlink, :username, :groupname, :bitesize, :mtime, :pathname, :blocks

    def initialize(path)
      path_stat = File.lstat(path)
      @type = format_type(path_stat.ftype)
      @mode = format_mode(path_stat.mode)
      @nlink = path_stat.nlink.to_s
      @username = Etc.getpwuid(path_stat.uid).name
      @groupname = Etc.getgrgid(path_stat.gid).name
      @bitesize = get_bitesize(path_stat)
      @mtime = get_mtime(path_stat)
      @pathname = get_pathname(path)
      @blocks = path_stat.blocks
    end

    private

    def format_type(type)
      {
        'fifo' => 'p',
        'characterSpecial' => 'c',
        'directory' => 'd',
        'blockSpecial' => 'b',
        'file' => '-',
        'link' => 'l',
        'socket' => 's'
      }[type]
    end

    def format_mode(mode)
      mode_octal = mode.to_s(8)
      permissions_numeric = mode_octal.slice(-3..-1).split(//)
      permissions_symbolic = permissions_numeric.map { |n| MODE_MAP[n] }
      add_special_permissions(mode_octal, permissions_symbolic).join
    end

    def add_special_permissions(mode_octal, permissions_symbolic)
      case mode_octal.slice(-4)
      when '1'
        add_sticky_bit(permissions_symbolic)
      when '2'
        add_sgid(permissions_symbolic)
      when '4'
        add_suid(permissions_symbolic)
      end
      permissions_symbolic
    end

    def add_sticky_bit(permissions_symbolic)
      permissions_symbolic[2] = if permissions_symbolic[2].slice(2) == 'x'
                                  permissions_symbolic[2].gsub(/.$/, 't')
                                else
                                  permissions_symbolic[2].gsub(/.$/, 'T')
                                end
    end

    def add_sgid(permissions_symbolic)
      permissions_symbolic[1] = if permissions_symbolic[1].slice(2) == 'x'
                                  permissions_symbolic[1].gsub(/.$/, 's')
                                else
                                  permissions_symbolic[1].gsub(/.$/, 'S')
                                end
    end

    def add_suid(permissions_symbolic)
      permissions_symbolic[0] = if permissions_symbolic[0].slice(2) == 'x'
                                  permissions_symbolic[0].gsub(/.$/, 's')
                                else
                                  permissions_symbolic[0].gsub(/.$/, 'S')
                                end
    end

    def get_bitesize(path_stat)
      if path_stat.rdev != 0
        "0x#{path_stat.rdev.to_s(16)}"
      else
        path_stat.size.to_s
      end
    end

    def get_mtime(path_stat)
      if Time.now - path_stat.mtime >= (60 * 60 * 24 * (365 / 2.0)) || (Time.now - path_stat.mtime).negative?
        path_stat.mtime.strftime('%_m %_d  %Y')
      else
        path_stat.mtime.strftime('%_m %_d %H:%M')
      end
    end

    def get_pathname(path)
      if File.symlink?(path)
        "#{path} -> #{File.readlink(path)}"
      else
        path
      end
    end
  end
end
