class EntriesController

  def awakeFromNib
    @entries ||= []
  end
  
  def numberOfRowsInTableView(view)
    @entries.size
  end

  def tableView(view, objectValueForTableColumn:column, row:index)
    @entries[index].send column.identifier, column.dataCellForRow(index)
  end

  def displayEntries(entries)
    @entries = entries.map.with_index { |entry, index| Status.new entry, index }
  end

  def tableView(tableView, heightOfRow:row)
    73
  end

  def tableView(view, willDisplayCell:cell, forTableColumn:column, row:index)
    case column.identifier
    when "button"
      if column.dataCellForRow(index).image.name == "NSUser"
        status = @entries[index]
        status.get do |data|
          status.image = NSImage.alloc.initWithData data
          view.reloadDataForRowIndexes NSIndexSet.indexSetWithIndex(status.index), columnIndexes:NSIndexSet.indexSetWithIndex(0)
        end
      end
    when "text"
      cell.setFocusRingType NSFocusRingTypeNone
      cell.setAllowsEditingTextAttributes true
      cell.setSelectable true
    end
  end
  
  def tableView(view, shouldTrackCell:cell, forTableColumn:column, row:index)
    true
  end

end