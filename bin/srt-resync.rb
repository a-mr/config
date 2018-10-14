#!/usr/bin/ruby -w

require "optparse"

ProgVersion = "1.1.0"
#Error codes
INVALID_IFILE = 1
O_AND_I_EXCL = 2
ZERO_DELAY = 3
NO_IFILE_WITH_INPLACE = 4

class ProgOptions 
  def initialize
    @delay=0.0
    @input_file=nil
    @backup_file=nil
    @output_file=nil
    @inplace=false
  end
  attr_reader :delay, :input_file, :inplace, :extension, :output_file, :backup_file
  attr_writer :delay, :input_file, :inplace, :extension, :output_file, :backup_file
end

class SubRipField
  T_delimiter = [ " --> ", "\r\n" ]
  def initialize(start_t, stop_t, speech="")
    @start_t=start_t
    @stop_t=stop_t
    @speech=speech
  end
  attr_reader :start_t, :stop_t, :speech
  attr_writer :start_t, :stop_t, :speech
  def time_ary
    [@start_t, @stop_t]
  end
  def t_interval_f		# formatted time interval
    str_result = ''
    2.times do |i|
      str_result += self.time_ary[i].strftime( "%H:%M:%S," ) + (self.time_ary[i].tv_usec/1000).to_s.rjust(3,'0') + T_delimiter[i]
    end
    str_result
  end
end

def error_msg(err_no)
  case err_no
    when INVALID_IFILE then $stderr.puts "Specified input file does not exist!"
    when O_AND_I_EXCL then $stderr.puts "Argument error : option -o and -i cannot be given at the same time!"
    when ZERO_DELAY then $stderr.puts "Argument error : you specified a zero delay or no delay option!"
    when NO_IFILE_WITH_INPLACE then $stderr.puts "Argument error : -i option cannot be used without specifying any input file!"
    else $stderr.puts "Unexpected error!"
  end
  exit 1
end
def check_options(options)
  error_msg( INVALID_IFILE ) unless ! ( options.input_file != nil && ! File.exist?(options.input_file) )
  error_msg( O_AND_I_EXCL ) unless ! ( options.inplace && options.output_file != nil )
  error_msg( ZERO_DELAY ) unless options.delay != 0
  error_msg( NO_IFILE_WITH_INPLACE ) unless ! ( options.input_file == nil && options.inplace )
end

options = ProgOptions.new

opts = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0[2..-1]} -d DELAY [OPTIONS] FILE"
  opts.separator ""
  opts.separator "Synchronizes subtitles in SubRip (.srt) format by adding/substracting a specified delay."
  opts.separator ""
  opts.on("-f", "--input-file IFILE", "Specifies the input file IFILE.") do |file|
    options.input_file = file
  end
  opts.on("-d", "--delay DELAY", Integer, "DELAY is the delay to add/substract (in milliseconds).",\
	  "It must be a positive integer if the subtitle comes before the speech, negative otherwise.") do |delay|
    options.delay = delay
  end
  opts.on("-i", "--inplace [EXTENSION]",
	  "Edit file in place.",
	  "  (make backup if EXTENSION supplied)") do |ext|
    options.inplace = true
    options.extension = ext || ''
    options.extension.sub!(/\A\.?(?=.)/, ".")  # Ensure extension begins with dot.
  end
  opts.on("-o", "--output-file OFILE", "Specifies the output file OFILE") do |file|
    options.output_file = file
  end
  opts.on_tail("-h", "--help", "Display this message.") do
    puts opts
    exit(0)
  end
  opts.on_tail("-V", "--version", "Print the program version.") do
    puts "SrtResync version #{ProgVersion}"
    puts "Copyright (C) 2008."
    puts "This is free software.  You may redistribute copies of it under the terms of"
    puts "the GNU General Public License - version 2 <http://www.gnu.org/licenses/gpl-2.0.html>."
    puts "There is NO WARRANTY, to the extent permitted by law."
    puts ""
    puts "Written by Giovanni Rapagnani."
    exit(0)
  end
end

args = opts.parse(ARGV)

if options.input_file == nil && args.length > 0
  options.input_file = args[0]
end

check_options(options)

# WARNING : check_options must be called before setting options.backup_file and options.output_file. 
# We must check that an input file has been supplied for the determination of options.backup_file.
# We must check that -o and -i options weren't given at the same time.
if options.inplace 
  options.output_file = options.input_file 
end

options.backup_file =
  if options.inplace && options.extension != ""
    # edit file in place and make backup with supplied extension
    if options.input_file =~ /.*\..*/ 
      ( options.input_file.split(".")[0..-2].join('.') + options.extension )
    else 
      ( options.input_file + options.extension )
    end
  end

subriplist = []
subrip = ""
n_speech = 0

fd = options.input_file != nil ? File.open(options.input_file) : $stdin
oldline = fd.gets
while newline = fd.gets do
  if ( newline =~ /(\d\d):(\d\d):(\d\d),(\d\d\d) --> (\d\d):(\d\d):(\d\d),(\d\d\d)/ ) 
    # When we get here, 'oldline' is the speech index. Thus, we won't record 'oldline' anywhere
    subriplist.push( subrip ) unless n_speech == 0
    n_speech += 1
    md = $~
    subrip = SubRipField.new( Time.utc( 2000, 1, 1, md[1], md[2], md[3], md[4].to_i * 1000 ),\
			      Time.utc( 2000, 1, 1, md[5], md[6], md[7], md[8].to_i * 1000 ) )
    newline = false
  else
    # When we get here, 'oldline' is a speech or has been set false previously when processing a time interval
    # We will only use 'oldline' when it is a speech.
    subrip.speech += oldline unless oldline == false || n_speech == 0
  end
  oldline = newline
end
if n_speech != 0
  subrip.speech += oldline unless oldline == false
  subriplist.push( subrip )
end

if options.backup_file != nil
  fd.pos = 0
  File.open( options.backup_file, File::CREAT | File::RDWR | File::TRUNC, 0644 ) do |fd_bck|
    while line=fd.gets do
      fd_bck.print line
    end
  end
end

fd.close unless fd == $stdin
print "#{n_speech} dialogues processed\n" 

# Add the specified delay to the subtitles
subriplist.each do |subrip|
  subrip.start_t += options.delay / 1000.0
  subrip.stop_t += options.delay / 1000.0
end

if options.output_file == nil
  fd_o = $stdout
else 
  fd_o = File.open( options.output_file, File::CREAT | File::RDWR | File::TRUNC, 0644 )
end
subriplist.each_with_index do |subrip,index|
  fd_o.print "#{index+1}\r\n"
  fd_o.print subrip.t_interval_f
  fd_o.print subrip.speech
end
fd_o.close unless fd_o == $stdout

exit 0
