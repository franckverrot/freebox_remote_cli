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

class Cursor < Struct.new(:x, :y, :pos, :verbose, :selected_pos)
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
      self.selected_pos = get_pos
      @delegate.switch_channel
    end
    self.pos = get_pos
  end

  def delegate=(obj)
    @delegate = obj
  end
end

