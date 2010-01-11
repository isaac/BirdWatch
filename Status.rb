require 'attributed_string'

class Status

  attr_accessor :index, :entry, :image
  
  def initialize(entry, index)
    @entry = entry
    @index = index
    @loading = false
    @image = NSImage.imageNamed "NSUser"
    @data = NSMutableData.new
    @url = url entry
  end

  def url(entry)
    links = entry.XMLRepresentation.nodesForXPath '//link[@type="image/png"]', error:nil
    href = links.first.attributeForName("href").stringValue.gsub '_normal.', '_bigger.'
    NSURL.URLWithString href
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

  def download(&block)
    return if @loading
    @loading = true
    @block = block
    request = NSURLRequest.requestWithURL @url
    NSURLConnection.alloc.initWithRequest request, delegate:self
  end
  
  def connection(connection, didReceiveResponse:response)
    @data.setLength 0
  end
  
  def connection(connection, didReceiveData:data)
    @data.appendData data
  end

  def connection(connection, didFailWithError:error)
    @loading = false
  end
  
  def connectionDidFinishLoading(connection)
    @block.call @data
    @loading = false
  end

end