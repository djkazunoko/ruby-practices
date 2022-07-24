#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

params = ARGV.getopts('l')

def display_files(params)
  files = Dir.glob('*', base: './')

  if params['l']
    long_formats = []
    links = []
    owners = []
    groups = []
    file_sizes = []
    blocks = []
    files.each do |file|
      file_stat = File.lstat(file)
      long_format = {
        file_mode: get_file_mode(file_stat),
        number_of_links: file_stat.nlink.to_s,
        owner_name: Etc.getpwuid(file_stat.uid).name,
        group_name: Etc.getgrgid(file_stat.gid).name,
        file_size: get_file_size(file_stat),
        last_modified_time: get_last_modified_time(file_stat),
        pathname: get_pathname(file)
      }
      long_formats << long_format
      links << long_format[:number_of_links]
      owners << long_format[:owner_name]
      groups << long_format[:group_name]
      file_sizes << long_format[:file_size]
      blocks << file_stat.blocks
    end
    links_width = links.map(&:size).max
    owners_width = owners.map(&:size).max
    groups_width = groups.map(&:size).max
    file_sizes_width = file_sizes.map(&:size).max
    puts "total #{blocks.sum}"
    long_formats.each do |c|
      puts "#{c[:file_mode]} #{c[:number_of_links].rjust(links_width)} #{c[:owner_name].ljust(owners_width)}  #{c[:group_name].ljust(groups_width)}  #{c[:file_size].rjust(file_sizes_width)} #{c[:last_modified_time]} #{c[:pathname]}"
    end
  else
    number_of_elements = files.size
    max_number_of_words = files.map(&:size).max
    max_number_of_columns = 3
    number_of_rows = calc_number_of_rows(number_of_elements, max_number_of_columns)
    number_of_rows.times do |i|
      i.step(number_of_elements - 1, number_of_rows) do |n|
        print files[n].ljust(max_number_of_words + 2)
      end
      print "\n"
    end
  end
end

def calc_number_of_rows(number_of_elements, max_number_of_columns)
  if (number_of_elements % max_number_of_columns).zero?
    number_of_elements / max_number_of_columns
  else
    (number_of_elements / max_number_of_columns) + 1
  end
end

def get_file_mode(file_stat)
  file_mode_numeric = file_stat.mode.to_s(8).rjust(6, '0')
  file_type_symbolic = get_file_type_symbolic(file_stat.ftype)
  file_permissions_symbolic = get_file_permissions_symbolic(file_mode_numeric)
  "#{file_type_symbolic}#{file_permissions_symbolic}"
end

def get_file_type_symbolic(file_type)
  {
    'fifo' => 'p',
    'characterSpecial' => 'c',
    'directory' => 'd',
    'blockSpecial' => 'b',
    'file' => '-',
    'link' => 'l',
    'socket' => 's'
  }[file_type]
end

def get_file_permissions_symbolic(file_mode_numeric)
  file_permissions_symbolic = []
  file_mode_numeric.slice(3, 3).each_char do |file_permission_numeric|
    file_permission_symbolic = {
      '0' => '---',
      '1' => '--x',
      '2' => '-w-',
      '3' => '-wx',
      '4' => 'r--',
      '5' => 'r-x',
      '6' => 'rw-',
      '7' => 'rwx'
    }[file_permission_numeric]
    file_permissions_symbolic << file_permission_symbolic
  end

  case file_mode_numeric.slice(2)
  when '1'
    file_permissions_symbolic[2] = if file_permissions_symbolic[2].slice(2) == 'x'
                                     file_permissions_symbolic[2].gsub(/.$/, 't')
                                   else
                                     file_permissions_symbolic[2].gsub(/.$/, 'T')
                                   end
  when '2'
    file_permissions_symbolic[1] = if file_permissions_symbolic[1].slice(2) == 'x'
                                     file_permissions_symbolic[1].gsub(/.$/, 's')
                                   else
                                     file_permissions_symbolic[1].gsub(/.$/, 'S')
                                   end
  when '4'
    file_permissions_symbolic[0] = if file_permissions_symbolic[0].slice(2) == 'x'
                                     file_permissions_symbolic[0].gsub(/.$/, 's')
                                   else
                                     file_permissions_symbolic[0].gsub(/.$/, 'S')
                                   end
  end

  file_permissions_symbolic.join
end

def get_file_size(file_stat)
  if file_stat.rdev != 0
    "#{file_stat.rdev_major}, #{file_stat.rdev_minor}"
  else
    file_stat.size.to_s
  end
end

def get_last_modified_time(file_stat)
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

display_files(params)
