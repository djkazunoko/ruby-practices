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

  files = get_files(dotmatch: params['a'])
  display_files(files, long_format: params['l'], reverse: params['r'])
end

def display_files(files, long_format: false, reverse: false)
  files = files.reverse if reverse
  long_format ? display_long_format(files) : display_sort_by_column(files)
end

def get_files(dotmatch: false)
  dotmatch ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
end

def display_sort_by_column(files)
  element_number = files.size.to_f
  max_length = files.map(&:size).max
  row_number = (element_number / COLUMN_NUMBER).ceil
  lines = Array.new(row_number) { [] }
  files.each_with_index do |file, index|
    line_number = index % row_number
    lines[line_number].push(file.ljust(max_length + 2))
  end
  lines.each { |line| puts line.join }
end

def display_long_format(files)
  long_formats = files.map { |file| get_long_format(file) }
  max_length_map = get_max_length_map(long_formats)
  number_of_blocks = long_formats.map { |long_format| long_format[:blocks] }.sum
  puts "total #{number_of_blocks}"
  long_formats.each do |long_format|
    print "#{long_format[:type]}#{long_format[:mode]} "
    print "#{long_format[:nlink].rjust(max_length_map[:link])} "
    print "#{long_format[:username].ljust(max_length_map[:owner])}  "
    print "#{long_format[:groupname].ljust(max_length_map[:group])}  "
    print "#{long_format[:filesize].rjust(max_length_map[:filesize])} "
    print "#{long_format[:mtime]} "
    print "#{long_format[:pathname]}\n"
  end
end

def get_long_format(file)
  file_stat = File.lstat(file)
  {
    type: format_type(file_stat.ftype),
    mode: format_mode(file_stat.mode),
    nlink: file_stat.nlink.to_s,
    username: Etc.getpwuid(file_stat.uid).name,
    groupname: Etc.getgrgid(file_stat.gid).name,
    filesize: get_filesize(file_stat),
    mtime: get_mtime(file_stat),
    pathname: get_pathname(file),
    blocks: file_stat.blocks
  }
end

def get_max_length_map(long_formats)
  {
    link: long_formats.map { |long_format| long_format[:nlink].size }.max,
    owner: long_formats.map { |long_format| long_format[:username].size }.max,
    group: long_formats.map { |long_format| long_format[:groupname].size }.max,
    filesize: long_formats.map { |long_format| long_format[:filesize].size }.max
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

def get_filesize(file_stat)
  if file_stat.rdev != 0
    "#{file_stat.rdev_major}, #{file_stat.rdev_minor}"
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

def get_pathname(file)
  if File.symlink?(file)
    "#{file} -> #{File.readlink(file)}"
  else
    file
  end
end

exec
