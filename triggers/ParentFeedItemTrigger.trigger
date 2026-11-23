trigger ParentFeedItemTrigger on FeedItem (after insert) {
    List<FeedItem> childFeedItems = new List<FeedItem>();

    for (FeedItem fi : Trigger.new) {
        // Ensure the feed item is related to the Parent object
        if (fi.ParentId.getSObjectType() == Schema.PCC_Deal_Change_Request__c.getSObjectType()) {
            // Query related child records
            PCC_Deal_Change_Request__c child = [
                select Id,PCC_Opportunity__c from PCC_Deal_Change_Request__c where id =:fi.ParentId limit 1];

          
                FeedItem childFeedItem = new FeedItem();
                childFeedItem.ParentId = child.PCC_Opportunity__c;
                childFeedItem.Body = fi.Body;
                childFeedItem.Title = fi.Title;
                childFeedItem.Type = fi.Type;
                childFeedItems.add(childFeedItem);
            system.debug('here'+childFeedItem);
        }
    }

    // Insert all child feed items
    if (!childFeedItems.isEmpty()) {
        insert childFeedItems;
    }
}