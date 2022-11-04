# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../file_stat'

class FileStatTest < Minitest::Test
  def test_file_stat
    file = '../.gitkeep'
    file_stat = LS::FileStat.new(file)
    assert_equal '.gitkeep', file_stat.basename
    assert_equal '-', file_stat.type
    assert_equal 'rw-r--r--', file_stat.mode
    assert_equal '1', file_stat.nlink
    assert_equal 'kazuki', file_stat.username
    assert_equal 'staff', file_stat.groupname
    assert_equal '0', file_stat.bitesize
    assert_equal ' 5 26 14:39', file_stat.mtime
    assert_equal '.gitkeep', file_stat.pathname
    assert_equal 0, file_stat.blocks
  end
end
