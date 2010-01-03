class FeedsTableView < NSTableView

  def keyDown(event)
    if event.keyCode == 51
      dataSource.removeFeed selectedRow
    else
      super
    end
  end

end