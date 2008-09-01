# Extension of String class to handle conversion from/to
# UTF-8/ISO-8869-1
class Object
  require 'iconv'

  #
  # Return an utf-8 representation of this string.
  #
  def to_utf
    begin
      Iconv.new("utf-8", "iso-8859-1").iconv(to_s)
    rescue Iconv::IllegalSequence
      STDERR << "!! Failed converting from UTF-8 -> ISO-8859-1 (#{self}). Already the right charset?"
      self
    end
  end

  #
  # Convert this string to iso-8850-1
  #
  def to_latin
    begin
      Iconv.new("iso-8859-1", "utf-8").iconv(to_s)
    rescue Iconv::IllegalSequence
      STDERR << "!! Failed converting from ISO-8859-1 -> UTF-8 (#{self}). Already the right charset?"
      self
    end
  end
end
