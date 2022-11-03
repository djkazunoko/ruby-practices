require 'minitest/autorun'
require_relative '../path'

class PathTest < Minitest::Test
  def test_path_stat
    path = '../.gitkeep'
    path_stat = LS::Path.new(path)
    assert_equal '.gitkeep', path_stat.name
    assert_equal '-', path_stat.type
    assert_equal 'rw-r--r--', path_stat.mode
    assert_equal '1', path_stat.nlink
    assert_equal 'kazuki', path_stat.username
    assert_equal 'staff', path_stat.groupname
    assert_equal '0', path_stat.bitesize
    assert_equal ' 5 26 14:39', path_stat.mtime
    assert_equal '.gitkeep', path_stat.pathname
    assert_equal 0, path_stat.blocks
  end
end
