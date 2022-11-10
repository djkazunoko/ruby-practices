# frozen_string_literal: true

require 'etc'
require_relative 'mode_formatter'

module LS
  class FileStat
    TYPE_MAP = {
      'fifo' => 'p',
      'characterSpecial' => 'c',
      'directory' => 'd',
      'blockSpecial' => 'b',
      'file' => '-',
      'link' => 'l',
      'socket' => 's'
    }.freeze

    attr_reader :basename, :type, :mode, :nlink, :username, :groupname, :bitesize, :mtime, :pathname, :blocks

    def initialize(path)
      file_stat = File.lstat(path)
      @basename = File.basename(path)
      @type = TYPE_MAP[file_stat.ftype]
      @mode = ModeFormatter.new(file_stat.mode).mode
      @nlink = file_stat.nlink.to_s
      @username = Etc.getpwuid(file_stat.uid).name
      @groupname = Etc.getgrgid(file_stat.gid).name
      @bitesize = get_bitesize(file_stat)
      @mtime = get_mtime(file_stat)
      @pathname = get_pathname(path)
      @blocks = file_stat.blocks
    end

    private

    def get_bitesize(file_stat)
      if file_stat.rdev != 0
        "0x#{file_stat.rdev.to_s(16)}"
      else
        file_stat.size.to_s
      end
    end

    def get_mtime(file_stat)
      if Time.now - file_stat.mtime >= (60 * 60 * 24 * (365 / 2.0)) || (Time.now - file_stat.mtime).negative?
        file_stat.mtime.strftime('%_m %_d  %Y')
      else
        file_stat.mtime.strftime('%_m %_d %H:%M')
      end
    end

    def get_pathname(path)
      if File.symlink?(path)
        "#{File.basename(path)} -> #{File.readlink(path)}"
      else
        File.basename(path)
      end
    end
  end
end
