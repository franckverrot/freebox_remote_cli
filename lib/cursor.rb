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

