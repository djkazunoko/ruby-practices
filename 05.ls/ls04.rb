#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

params = ARGV.getopts('l')

def display_files(params)
  files = Dir.glob('*', base: './')

  if params['l']
    files.each do |file|
      fs = File.lstat(file)
      file_mode = get_file_mode(fs)
      number_of_links = fs.nlink
      owner_name = Etc.getpwuid(fs.uid).name
      group_name = Etc.getgrgid(fs.gid).name
      file_size = get_file_size(fs)
      last_modified_time = get_last_modified_time(fs)
      pathname = file
      print "#{file_mode}  #{number_of_links} #{owner_name}  #{group_name}  #{file_size}  #{last_modified_time} #{pathname}\n"
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

def get_file_mode(fs)
  file_mode_numeric = fs.mode.to_s(8).rjust(6, "0")
  file_type_symbolic = get_file_type_symbolic(fs.ftype)
  file_permissions_symbolic = get_file_permissions_symbolic(file_mode_numeric)
  file_mode_symbolic = "#{file_type_symbolic}#{file_permissions_symbolic}"
end

def get_file_type_symbolic(name)
  {
    "fifo" => "p",
    "characterSpecial" => "c",
    "directory" => "d",
    "blockSpecial" => "b",
    "file" => "-",
    "link" => "l",
    "socket" => "s"
  }[name]
end

def get_file_permissions_symbolic(file_mode_numeric)
  file_permissions_symbolic = []
  file_mode_numeric.slice(3, 3).each_char do |file_permission_numeric|
    file_permission_symbolic = {
      "0" => "---",
      "1" => "--x",
      "2" => "-w-",
      "3" => "-wx",
      "4" => "r--",
      "5" => "r-x",
      "6" => "rw-",
      "7" => "rwx",
    }[file_permission_numeric]
    file_permissions_symbolic << file_permission_symbolic
  end

  if file_mode_numeric.slice(2) == "1"
    if file_permissions_symbolic[2].slice(2) == "x"
      file_permissions_symbolic[2] = file_permissions_symbolic[2].gsub(/.$/, "t")
    else
      file_permissions_symbolic[2] = file_permissions_symbolic[2].gsub(/.$/, "T")
    end
  elsif file_mode_numeric.slice(2) == "2"
    if file_permissions_symbolic[1].slice(2) == "x"
      file_permissions_symbolic[1] = file_permissions_symbolic[1].gsub(/.$/, "s")
    else
      file_permissions_symbolic[1] = file_permissions_symbolic[1].gsub(/.$/, "S")
    end
  elsif file_mode_numeric.slice(2) == "4"
    if file_permissions_symbolic[0].slice(2) == "x"
      file_permissions_symbolic[0] = file_permissions_symbolic[0].gsub(/.$/, "s")
    else
      file_permissions_symbolic[0] = file_permissions_symbolic[0].gsub(/.$/, "S")
    end
  end

  file_permissions_symbolic.join
end

def get_file_size(fs)
  if fs.rdev != 0
    "#{fs.rdev_major}, #{fs.rdev_minor}"
  else
    fs.size
  end
end

def get_last_modified_time(fs)
  if Time.now - fs.mtime >= (60 * 60 * 24 * (365 / 2.0)) || Time.now - fs.mtime < 0
    fs.mtime.strftime("%_m %_d %Y")
  else
    fs.mtime.strftime("%_m %_d %H:%M")
  end
end

display_files(params)
