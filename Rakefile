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

desc "Display license information"
task :license do
    `open http://www.gnu.org/licenses/gpl.txt`
end

desc "Default task starting the remote"
task :default do
  $stdout.puts """
  Freebox Remote CLI Copyright (C) 2014 Franck Verrot <franck@verrot.fr>
  This program comes with ABSOLUTELY NO WARRANTY; for details type `rake license'.
  This is free software, and you are welcome to redistribute it
  under certain conditions; type `rake license' for details.

  Type [Enter] to accept. Ctrl-C to reject license.
  """

  $stdin.getc
  sh "bin/remote"
end
