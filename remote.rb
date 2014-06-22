$:<< 'lib'
require 'yaml'
require 'cli'
require 'cursor'

def onsig(win, sig)
  win.close
  exit sig
end
((1..15).to_a - [4,8,10,11]).each do |sig_num|
  begin
    if trap(sig_num, "SIG_IGN") != 0
      trap(sig_num) {|sig| onsig(win, sig) }
    end
  rescue Exception => e
    puts "can't trap #{e.message} #{sig_num}"
  end
end

channels = YAML.load_file("channels.yml")

cli = CLI.new("Freebox Remote CLI", channels)
cli.run_forever
