class EntriesTableView < NSTableView

  def awakeFromNib
    window.setAcceptsMouseMovedEvents true
    addTrackingRect visibleRect, owner:self, userData:nil, assumeInside:false
    setSelectionHighlightStyle NSTableViewSelectionHighlightStyleNone
  end

  def mouseEntered(event)
    editCell event if editedRow == -1
  end

  def mouseMoved(event)
    editCell event
  end
  
  def editCell(event)
    point = convertPoint event.locationInWindow, fromView:nil
    return unless CGRectContainsPoint(visibleRect, point)
    row = rowAtPoint point
    return if row == editedRow
    return unless CGRectContainsRect(visibleRect, frameOfCellAtColumn(1, row:row))
    editColumn 1, row:row, withEvent:nil, select:false
  end
  
end
