/**
 * @description       : 
 * @author            : Prem Ranjan
 * @group             : 
 * @last modified on  : 09-02-2020
 * @last modified by  : Prem Ranjan
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   07-26-2020  Prem Ranjan   Initial Version
**/

public class Core_IPS_FeedComment_Handler {
    public static Boolean checkIPSPortal(){
        String currentRequestUrl= URL.getCurrentRequestUrl().toExternalForm();
        STring salesforceBaseUrl=URL.getSalesforceBaseUrl().toExternalForm();
        String uri=currentRequestUrl.remove(salesforceBaseUrl);
        if(uri.split('/')[1] =='IPS'){
            return true;
        }
        return false;
    }
    public static void feedCommentObject(List<FeedComment> feedCommentList , Boolean instancePortalUrlCheck){
        Set<Schema.SObjectType> allSchemaObj = getAllSobjectType();
        Boolean isPartnerProfileUser = checkPartnerProfileUser();
        for(FeedComment feedCommentObj: feedCommentList){
               if(instancePortalUrlCheck && isPartnerProfileUser && allSchemaObj.contains(feedCommentObj.parentId.getSObjectType())){
                   feedCommentObj.addError('You cannot update the chatter feed.');
            }
             
        }
    }
    public static Set<Schema.SObjectType> getAllSobjectType(){
        Set<Schema.SObjectType> allSchemaObj = new  Set<Schema.SObjectType>();
        for(Core_IPS_FeedItem_CreateRestriction__c mcs : Core_IPS_FeedItem_CreateRestriction__c.getall().values()){
            allSchemaObj.add(Schema.getGlobalDescribe().get(mcs.Name));
        }
        return allSchemaObj;
    }
    
    public static Boolean checkPartnerProfileUser(){
        Boolean partnerUser = false;
        if(Userinfo.getProfileId()==(ID)Label.Core_IPS_Partner_Profile_Id){
        	partnerUser=true;
        }
        return partnerUser;
    }
    
}