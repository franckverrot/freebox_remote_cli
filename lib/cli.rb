# freebox_remote_cli - Freebox Remote CLI
# Copyright (C) 2014 Franck Verrot <franck@verrot.fr>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'curses'
require 'net/http'

HEADER   = 5
PER_PAGE = 10

class CLI
  def initialize(title, channels, code, machine = "hd1", cursor = Cursor.new(0,0,0,false,0))
    @cursor = cursor
    @cursor.delegate = self
    @channels = channels
    @title = title
    @machine = machine
    @code = code

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

  def run_forever
    begin
      draw
    end while handle_key
  end

  def with_color(color, &block)
    @win.color_set(color)
    block.call
    @win.color_set(0)
  end

  private
  def draw_title
    # Title line
    with_color(1) { puts(@title, 1, Curses.cols / 2 - @title.length / 2) }
    puts('-' * (Curses.cols - 2), 2, 1)

    # Hint
    with_color(3) { puts('Hit j and k to navigate, then hit "Enter"', 3, 1) }
    puts('-' * (Curses.cols - 2), 4, 1)
  end

  def draw_channels
    @channels.each_with_index do |channel, pos|
      name, real_channel = channel
      col = pos / PER_PAGE
      formatted_channel = sprintf("%-20s", name[0..19])

      color  = pos == @cursor.pos ? 2 : 0
      prefix = pos == @cursor.selected_pos ? '* ' : '  '

      with_color(color) do
        puts("#{prefix} #{name}", HEADER + (pos % PER_PAGE), col * 24 + 1)
      end
    end
  end
end
