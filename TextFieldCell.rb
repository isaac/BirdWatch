class TextFieldCell < NSTextFieldCell

  def trackMouse(event, inRect:rect, ofView:view, untilMouseUp:untilMouseUp)
    #frame = view.frameOfCellAtColumn(1, row:view.selectedRow)
    #view.editColumn 1, row:view.selectedRow, withEvent:nil, select:false
    #NSApplication.sharedApplication.sendEvent event
    true
  end

  def setUpFieldEditorAttributes(text)
    super
    text.delegate = self
    text.setSelectable false
    text.instance_eval do
      def shouldDrawInsertionPoint
        false
      end
      def clickedOnLink(link, atIndex:index)
        string = link.absoluteString
        return super if string[0..3] == "http"
        query = string.gsub '@', 'from:'
        window.delegate.addFeed query
      end
    end
    text
  end

  def textView(text, shouldChangeTextInRange:range, replacementString:replacement)
    false
  end

  def drawingRect(rect)
    rect.size.width -= 20
    rect.origin.x += 10
    textSize = cellSizeForBounds rect
    heightDelta = rect.size.height - textSize.height
    if heightDelta > 0
      rect.size.height -= heightDelta
      rect.origin.y += heightDelta / 2
    end
    rect
  end

  def drawingRectForBounds(bounds)
    rect = super
    drawingRect(rect)
  end

  def selectWithFrame(frame, inView:view, editor:editor, delegate:delegate, start:start, length:length)
    rect = drawingRectForBounds frame
    super rect, view, editor, delegate, start, length
  end
  
  def editWithFrame(frame, inView:view, editor:editor, delegate:delegate, event:event)
    rect = drawingRectForBounds frame
    rect.origin.y -= 1
    super rect, view, editor, delegate, event
  end 

end