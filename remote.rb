require 'curses'
require 'net/http'
require 'yaml'

HEADER = 5

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

class Window
  def initialize(title, channels, cursor = Cursor.new(0,0,0))
    @cursor = cursor
    @cursor.delegate = self
    @channels = channels
    @title = title
    @machine = "hd1"
    @code = "72230083"

    Curses.init_screen
    Curses.start_color
    Curses.init_pair(1, Curses::COLOR_GREEN, Curses::COLOR_BLUE)
    Curses.init_pair(2, Curses::COLOR_BLUE, Curses::COLOR_GREEN)
    Curses.init_pair(3, Curses::COLOR_BLUE, Curses::COLOR_RED)
    Curses.curs_set(0)
    Curses.noecho
    @win = Curses::Window.new(0, 0, 35, 0)
    #(Curses.lines - 8) / 2, (Curses.cols - (my_str.length + 10)) / 2 
    @win.box("|", "-")
  end

  def draw
    draw_title
    draw_channels
    draw_debug_info if @cursor.verbose
  end

  def draw_debug_info
    puts("[Verbose mode] Cursor [#{@cursor.inspect}]", 18, 1)
  end

  def puts(s, x, y)
    @win.setpos(x,y)
    @win.addstr(s)
  end

  def handle_key
    @cursor.handle_key(@win.getch)
  end

  def close
    @win.close
  end

  def send_command(key, long_press = false)
    uri = URI("http://#{@machine}.freebox.fr/pub/remote_control?code=#{@code}&key=#{key}#{long_press ? '&long=true' : ''}")
    Net::HTTP.get(uri)
  end

  def switch_channel
    channel_index = @cursor.pos
    channel = @channels.values[channel_index].to_s

    if channel.length == 1
      send_command(channel)
    else
      channel[0..-2].each_char do |char|
        send_command(char, true)
      end
      send_command(channel[-1])
    end
  end

  private
  def draw_title
    @win.setpos(0,0)
    @win.color_set(1)
    @win.setpos(1, Curses.cols / 2 - @title.length / 2)
    @win.addstr(@title)
    @win.color_set(0)

    @win.setpos(2, 1)
    @win.addstr('-' * (Curses.cols - 2))

    @win.color_set(3)
    @win.setpos(3, 1)
    @win.addstr('Hit j and k to navigate, then hit "Enter"')

    @win.color_set(0)
    @win.setpos(4, 1)
    @win.addstr('-' * (Curses.cols - 2))
  end

  def draw_channels
    @channels.each_with_index do |channel, pos|
      name, real_channel = channel
      col = pos / 10
      formatted_channel = sprintf("%-20s", name[0..19])
      @win.setpos(HEADER + (pos % 10), col * 24 + 1)
      @win.color_set(pos == @cursor.pos ? 2 : 0)
      @win.addstr("#{pos == @cursor.pos ? '* ' : '  '} #{formatted_channel}")
      @win.color_set(0)
    end
  end


end


class Cursor < Struct.new(:x, :y, :pos, :verbose)
  def get_pos
    x * 10 + y
  end

  def handle_key(key)
    case key
    when 'q'
      @delegate.close
      exit 0
    when 'j'
      self.y += 1
    when 'k'
      self.y -= 1
    when 'v'
      self.verbose ^= true
    when 10
      @delegate.switch_channel
    end
    self.pos = get_pos
  end

  def delegate=(obj)
    @delegate = obj
  end
end

channels = YAML.load_file("channels.yml")

win = Window.new("Freebox Remote CLI", channels)
win.draw

begin
  win.draw
end while win.handle_key
