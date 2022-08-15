#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

COLUMN_NUMBER = 3

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

def exec
  params = ARGV.getopts('alr')

  paths = get_paths(dotmatch: params['a'])
  list_paths(paths, long_format: params['l'], reverse: params['r'])
end

def get_paths(dotmatch: false)
  dotmatch ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
end

def list_paths(paths, long_format: false, reverse: false)
  paths = paths.reverse if reverse
  long_format ? list_long(paths) : list_short(paths)
end

def list_long(paths)
  long_formats = paths.map { |path| get_long_format(path) }
  max_length_map = get_max_length_map(long_formats)
  block_total = long_formats.map { |long_format| long_format[:blocks] }.sum

  puts "total #{block_total}"
  long_formats.each { |long_format| print_long_format(long_format, max_length_map) }
end

def get_long_format(path)
  path_stat = File.lstat(path)
  {
    type: format_type(path_stat.ftype),
    mode: format_mode(path_stat.mode),
    nlink: path_stat.nlink.to_s,
    username: Etc.getpwuid(path_stat.uid).name,
    groupname: Etc.getgrgid(path_stat.gid).name,
    bitesize: get_bitesize(path_stat),
    mtime: get_mtime(path_stat),
    pathname: get_pathname(path),
    blocks: path_stat.blocks
  }
end

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
    permissions_symbolic[2] = if permissions_symbolic[2].slice(2) == 'x'
                                permissions_symbolic[2].gsub(/.$/, 't')
                              else
                                permissions_symbolic[2].gsub(/.$/, 'T')
                              end
  when '2'
    permissions_symbolic[1] = if permissions_symbolic[1].slice(2) == 'x'
                                permissions_symbolic[1].gsub(/.$/, 's')
                              else
                                permissions_symbolic[1].gsub(/.$/, 'S')
                              end
  when '4'
    permissions_symbolic[0] = if permissions_symbolic[0].slice(2) == 'x'
                                permissions_symbolic[0].gsub(/.$/, 's')
                              else
                                permissions_symbolic[0].gsub(/.$/, 'S')
                              end
  end
  permissions_symbolic
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

def get_max_length_map(long_formats)
  {
    nlink: long_formats.map { |long_format| long_format[:nlink].size }.max,
    username: long_formats.map { |long_format| long_format[:username].size }.max,
    groupname: long_formats.map { |long_format| long_format[:groupname].size }.max,
    bitesize: long_formats.map { |long_format| long_format[:bitesize].size }.max
  }
end

def print_long_format(long_format, max_length_map)
  print [
    "#{long_format[:type]}#{long_format[:mode]} ",
    "#{long_format[:nlink].rjust(max_length_map[:nlink])} ",
    "#{long_format[:username].ljust(max_length_map[:username])}  ",
    "#{long_format[:groupname].ljust(max_length_map[:groupname])}  ",
    "#{long_format[:bitesize].rjust(max_length_map[:bitesize])} ",
    "#{long_format[:mtime]} ",
    "#{long_format[:pathname]}\n"
  ].join
end

def list_short(paths)
  element_number = paths.size.to_f
  max_length = paths.map(&:size).max
  row_number = (element_number / COLUMN_NUMBER).ceil
  lines = Array.new(row_number) { [] }
  paths.each_with_index do |path, index|
    line_number = index % row_number
    lines[line_number].push(path.ljust(max_length + 2))
  end
  lines.each { |line| puts line.join }
end

exec
