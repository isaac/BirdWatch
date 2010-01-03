require 'hotcocoa'
framework 'Webkit'

class Status

  attr_accessor :index, :loading, :entry, :image
  
  def initialize(entry, index)
    @entry = entry
    @index = index
    @loading = false
    @image = NSImage.imageNamed "NSUser"
    @data = NSMutableData.new
  end

  def content
    entry.content.HTMLString
  end

  def author
    entry.authorsForDisplay.split(')').first.split('(').last
  end

  def button(cell = nil)
    cell.setAction "click:"
    cell.setTarget self
    cell.setImage image
    cell.setBezelStyle NSShadowlessSquareBezelStyle
    cell.setBackgroundColor NSColor.whiteColor
    cell
  end

  def text(cell = nil)
    string
  end

  def string
    string = "#{author}  ".with_attributes({ :font => NSFont.boldSystemFontOfSize(12) })
    string << "#{entry.dateForDisplay.stringForTimeIntervalSinceNow} ago\n".with_attributes({
      :font => NSFont.systemFontOfSize(11),
      :color => NSColor.grayColor
    })
    words = content.gsub(/<[^>]*b>/, '').gsub('<a href', '<ahref').split
    words.each do |word|
      attributes = { :font => NSFont.messageFontOfSize(12) }
      string << " ".with_attributes(attributes) unless word == words.first
      word.split(/<.*?>(.*?)<.*?>/).each.with_index do |s,i|
        if i == 1
          string << s.with_attributes(attributes.merge({
            :link => NSURL.URLWithString(s),
            :underline_style => NSUnderlineStyleSingle,
            :color => NSColor.blueColor,
            :cursor => NSCursor.pointingHandCursor
          }))
        else
          string << CFXMLCreateStringByUnescapingEntities(nil, s, nil).with_attributes(attributes)
        end
      end
    end
    string
  end

  def spacer(cell)
    ''
  end

  def click(sender)
    puts content
    puts content.gsub(/<[^>]*b>/, '').gsub('<a href', '<ahref').split
    puts entry.XMLRepresentation.XMLString
  end

  def href
    entry.XMLRepresentation.elementsForName('link').last.attributeForName('href').stringValue.gsub '_normal.', '_bigger.'
  end

  def get(&block)
    return if loading
    self.loading = true
    @block = block
    request = NSURLRequest.requestWithURL(NSURL.URLWithString(href))
    NSURLConnection.alloc.initWithRequest request, delegate:self
  end
  
  def connection(connection, didReceiveResponse:response)
    @data.setLength 0
  end
  
  def connection(connection, didReceiveData:data)
    @data.appendData data
  end

  def connection(connection, didFailWithError:error)
    self.loading = false
  end
  
  def connectionDidFinishLoading(connection)
    @block.call @data
    self.loading = false
  end

end