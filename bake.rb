#!/usr/bin env ruby
# encoding: utf-8

#  bake - builds and concatenates static websites from a list of templates
#
#  Copyright (C) 2014. George Craig. CSR Development, Co.
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'json'

class Bake

  VERSION = 0.1
  VERSION_DATE = '01/24/2014'

  @@config = nil
  @@values = nil
  @@build_file = 'bakefile.json'

  #
  # Construct a Bake object to craft our webby goodness
  #
  def initialize()
    display_usage
    check_bakefile
    check_gems
    read_bakefile
    generate_files
  end

  #
  # Read bakefile.json
  #
  def read_bakefile
    #
    # read in configuration file,
    # file list supports globs *.*, *.html
    #
    begin
      @@config = IO.read(@@build_file)
      @@values = JSON.parse(@@config)
    rescue
      $stderr.puts($!)
    end
  end

  #
  # Check to ensure all required gems, not installed by default,
  # are present. if not, attempt to install them automatically
  # and then continue to 'bake'.
  #
  # Raises:
  #   Error if ()trollop) gems are not installed.
  #
  def check_gems
    begin
      gem 'trollop'
      # example with requirements: gem "trollop", ">=2.0"
    rescue Gem::LoadError
      # not installed
      puts "bake: trollop gem is not installed!"
      puts "Attempting to install trollop:"
      # attempt to install the gem
      cmd = "gem install trollop"
      res = %x(#{cmd})
      puts res
      if res.include? "1 gem installed"
        Gem::clear_paths
        puts "Continuing the bake ..."
        return true
      else
        raise "Error installing ruby gem trollop"
      end
      return false
    end
  end

  #
  # Generate the web page from specified templates, header, footer,
  # and process pre-, post- executable hooks.
  #
  def generate_files
    #
    # slurp up and bake the yummy
    # goodness, concatenate the files.
    #
    # if file extension:
    #   .md = run markdown
    #
    Dir::mkdir(values["output_dir"]) unless File.exists?(values["output_dir"])
    Dir::mkdir(values["output_dir"] + "/" + values["static_dir"]) unless File.exists?(values["static_dir"])

    values["pages"].each do |page|
      if File.exists?(page)
        File.open(values["output_dir"] + "/" + page, "w") do |f|
          f.puts IO.read(values["header"])
          f.puts IO.read(page)
          f.puts IO.read(values["footer"])
        end
      end
    end
  end

  #
  # Monitor files for any changes and re-run on differences;
  #
  def monitor
    #
    # even though most editors can
    # watch files, running bake as a
    # service will auto-build and
    # publish ala eclipse, etc.
    #
  end

  #
  # Publish the output files to the appropriate deploy destination
  #
  def publish
    #
    # publish to the destination (via rsync lib? direct cp),
    # backup existing copy
    #
    # if archive_existing = true
    #
  end

  #
  # Check if a standard bakefile (bakefile.json) exists,
  # if not, then notify the user and exit.
  #
  def check_bakefile
    if !File.exists?("bakefile.json")
      puts "bake: bakefile.json does not exist!"
      puts "bake -h, --help  displays usage options for 'bake'"
      puts "bake aborted.\n"
      exit 3
    end
    return true
  end

  #
  # Display bake's command line usage
  #
  def display_usage
    $stderr.puts "Usage: #{File.basename($0)}: [-l <file] [-v] ..."
    $stderr.puts 'bake builds and concatenates static websites from a list of templates'
    $stderr.puts 'Copyright 2014. CSR Development, Co. Distributed under the GNU General Public License.'
    $stderr.puts 'This program comes with ABSOLUTELY NO WARRANTY; this is free software, and you are welcome to '
    $stderr.puts 'redistribute it under certain conditions.'
    $stderr.puts 'Options:'
    $stderr.puts '  -e, --version     outputs version and exit'
    $stderr.puts '  -f, --file        bakefile (if specifying build file other than bakefile.json)'
    $stderr.puts '  -h, --help        displays this help and exit'
    $stderr.puts '  -p, --push        pushes website out to destination (-d required if bakefile.json not present)'
    $stderr.puts '  -d, --dest        destination [protocol:server:uid:pwd]'
    $stderr.puts '  -v, --verbose     outputs debugging information'
    $stderr.puts '  -l, --log <file>  captures all output to file'
    exit(2)
  end

  #
  # Displays current bake version
  #
  def display_version
    $stderr.puts "#{File.basename($0)} #{VERSION} #{VERSION_DATE}"
    exit(1)
  end

end

Bake.new()
