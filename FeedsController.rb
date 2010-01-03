framework 'PubSub'

class FeedsController
  attr_writer :feedsTableView
  attr_writer :entriesTableView

  def awakeFromNib
    @client = PSClient.applicationClient
    @feeds = @client.feeds
    selectFeed 0
    @feeds.each { |feed| feed.refresh nil }
  end

  def addSearch(sender)
    search = sender.stringValue
    addFeed(search) if search.size > 0
  end

  def addFeed(query)
    url = "http://search.twitter.com/search.atom?rpp=100&q=#{query.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)}"
    feed = @client.addFeedWithURL NSURL.URLWithString(url)
    NSNotificationCenter.defaultCenter.addObserver self, selector:"refresh:", name:PSFeedRefreshingNotification, object:feed
    feed.refresh nil
    @feeds = @client.feeds
    @feedsTableView.reloadData
  end

  def refresh(notification)
    feed = notification.object
    @feedsTableView.reloadData unless feed.isRefreshing
  end

  def numberOfRowsInTableView(view)
    @feeds.size
  end

  def tableView(view, objectValueForTableColumn:column, row:index)
    query = @feeds[index].URL.query.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    "     #{ query.split('q=').last.split('+').last.gsub('from:', '@') }".with_attributes({
      :baseline_offset => 2,
      :font => NSFont.systemFontOfSize(12)
    })
  end

  def selectFeed(index)
    if @feeds.size > 0
      @feedsTableView.selectRowIndexes NSIndexSet.indexSetWithIndex(index), byExtendingSelection:false
      tableView @feedsTableView, shouldSelectRow:index
    end
  end

  def removeFeed(index)
    @client.removeFeed @feeds.slice!(index)
    @feedsTableView.reloadData
    selectFeed index - 1
  end

  def tableView(tableView, shouldSelectRow:index)
    @entriesTableView.dataSource.displayEntries @feeds[index].entries.reverse
    @entriesTableView.setIntercellSpacing [ 0, 1 ]
    @entriesTableView.reloadData
    true
  end

  def windowDidBecomeMain(notification)
    notification.object.setBackgroundColor @feedsTableView.backgroundColor
  end

end