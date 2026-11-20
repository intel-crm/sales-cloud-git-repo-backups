/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-26-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-26-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class Core_IPS_FeedComment_Dispatcher{
    public static void beforeMethod(List<FeedComment> newList, 
                                    Map<Id,FeedComment> oldMap,Map<Id,FeedComment> newMap){
                                       	Boolean instancePortalUrlCheck = Core_IPS_FeedComment_Handler.checkIPSPortal();
                                        if(trigger.isInsert){
                                            Core_IPS_FeedComment_Handler.feedCommentObject(newList, instancePortalUrlCheck);
                                        }
                                     
                                    }  
}