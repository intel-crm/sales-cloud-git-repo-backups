public class Core_IPS_FeedItem_Dispatcher {
    public static void beforeMethod(List<FeedItem> newList, 
                                    Map<Id,FeedItem> oldMap,Map<Id,FeedItem> newMap){
                                       	Boolean instancePortalUrlCheck = Core_IPS_FeedItem_Handler.checkIPSPortal();
                                        if(trigger.isInsert){
                                            Core_IPS_FeedItem_Handler.feedCommentObject(newList, instancePortalUrlCheck);
                                        }
                                     
                                    }  

}