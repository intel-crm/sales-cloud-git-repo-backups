public with sharing class caseCommentListController {
    @AuraEnabled(cacheable = true)
    public static List<Core_IPS_Case_Comments__c> getCaseComments(String caseId, String searchText){
        string searchKey = '%' + searchText + '%';
        list<Core_IPS_Case_Comments__c> commentResult = new list<Core_IPS_Case_Comments__c>();
        
        commentResult=  [SELECT id,name,CreatedBy.contactid,CreatedBy.Accountid,CreatedBy.Name,Core_IPS_Comment__c,CreatedBy.Account.Name,Core_IPS_Rich_Comment__c,CreatedBy.Contact.Account.name,CreatedBy.Profile.Name,CreatedBy.Firstname,CreatedBy.Profileid, CreatedDate, Core_IPS_Case_Comment_Type__c,Core_IPS_Comment_Authored_By_Email__c,Core_IPS_Comment_Authored_By_Name__c FROM Core_IPS_Case_Comments__c WHERE Core_IPS_Case__c =: caseId];
        list<Core_IPS_Case_Comments__c> searchResult = new list<Core_IPS_Case_Comments__c>();
        if(commentResult!=null && !String.isEmpty(searchText))
            {
                for(Core_IPS_Case_Comments__c objCmt : commentResult)
                {
                    if(objCmt.Core_IPS_Comment__c.containsIgnoreCase(searchText)){searchResult.add(objCmt);}
                }
                return searchResult;
            } else{
                return commentResult;
            }
    }
    
}