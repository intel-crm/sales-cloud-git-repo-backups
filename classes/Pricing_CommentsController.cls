/**
 * @description       : 
 * @author            : Subhanku
 * @group             : Accenture
 * @last modified on  : 09-18-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_CommentsController {
    //This method takes Pricing_Quote__c Id as parameter and returns the list of Pricing_Comments__c records assosiated with that Id
    @AuraEnabled(cacheable=true)
    public static List<Pricing_Comments__c> getTenderComments(Id recordId) {
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        return [SELECT Id, Name, Pricing_Question__c,CreatedBy.Name, CreatedDate,Pricing_Quote__r.Pricing_Program_Type_Nm__c,Pricing_Answer__c, Pricing_Quote__c, Pricing_Required_Ind__c
                FROM Pricing_Comments__c WHERE Pricing_Quote__c = :recordId and recordtypeid =:commentRecordTypeId];        
    }
    
    @AuraEnabled
    public static String getQuoteStatus(Id recordId) {
        try{
        List<SBQQ__Quote__c> quotes = [SELECT Id, SBQQ__Status__c FROM SBQQ__Quote__c WHERE id = :recordId];
        return quotes.size() > 0 ? quotes[0].SBQQ__Status__c : null;
        }
        catch(exception ex) {
            Pricing_Tender_Utility.logError(ex);
            return null;
        }    
    }
    
    // This method takes the list of Pricing_Comments__c as parameter that needs to be updated and updates them
    @AuraEnabled  
    public static void updateTenderComments(List<Pricing_Comments__c> tenderComments){
        try{
            update tenderComments;
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        }
    }
    
    //This method checks if the current user is a Pricing manager and returns true if the current user is a Pricing Manager 
    @AuraEnabled(cacheable=true)
    public static Boolean isPricingManager() {
        List <String> permissionSetNames = new List<String>();
        permissionSetNames = Label.Pricing_Tender_RPM_Read_Only_Users_PS.split(',');
        integer count = [SELECT count() FROM PermissionSetAssignment 
                         WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name IN: permissionSetNames];
        return count > 0;
    }

    //This method checks if the current user is a Financial Incentive Pricing manager and returns true if the current user is a Financial Incentive Pricing Manager 
    @AuraEnabled(cacheable=true)
    public static Boolean isFinancialIncentivePricingManager() {
        integer count = [SELECT count() FROM PermissionSetAssignment 
                          WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name IN: (Label.Pricing_Tender_PermissionSets_FinancialIncentivePricingManager).split(',')];
        return count > 0;
    }
    
    //This method checks if the current user is part of all pricing read only user group and returns true if the current user is a PM/Legal/Finance 
    @AuraEnabled(cacheable=true)
    public static Boolean isReadOnlyUser() {
        integer count = [select count() from user 
                         where id = :Userinfo.getUserId()
                         AND id in (select userorgroupid from groupmember where group.DeveloperName =:Label.Pricing_Tender_PublicGroup_AllPricingReadOnlyUsersGroup)];
        return count > 0;
    }
    
    //This method takes Pricing_Quote__c record Id as parameter and returns the Pricing manager comments assosiated to that record
    @AuraEnabled(cacheable=true) 
    public static List<Pricing_Comments__c> getPricingManagerComments(Id recordId) {
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_PricingManagerComment);
        return [SELECT Id, Name, Pricing_Question__c,CreatedBy.Name, CreatedDate,	Pricing_Answer__c, Pricing_Quote__c, Pricing_Required_Ind__c
                FROM Pricing_Comments__c WHERE Pricing_Quote__c = :recordId and recordtypeid =:commentRecordTypeId order by CreatedDate desc];    
    }
    
    //This method takes the Pricing Manager Comment as string and the Id of the related Quote as parameters
    //and creates a new Pricing_Comments__c record
    @AuraEnabled  
    public static void createTenderComments(String pmComments, Id quoteId){
        try{
            Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_PricingManagerComment);
            Pricing_Comments__c pc = new Pricing_Comments__c();
            pc.recordtypeid = commentRecordTypeId;
            pc.Pricing_Question__c = 'Pricing Manager Comment';
            pc.Pricing_Answer__c = pmComments;
            pc.Pricing_Quote__c = quoteId;
            insert pc;
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        }
    }
    @AuraEnabled
    public static void updateCommentThroughId(String recordId,String answer){
        Pricing_Comments__c pc = new Pricing_Comments__c(Id=recordId,Pricing_Answer__c=answer);
        update pc;
    }

    @AuraEnabled(cacheable=true) 
    public static DocumentShare getDocumentShare(String quoteId){
        List<Pricing_Document__c> doc = [Select Id, Name from Pricing_Document__c where Pricing_Quote_Id__c=:quoteId];
        if(!doc.isEmpty()){
            Id documentId = doc[0].Id; 
            Integer attachedNo =  Database.countQuery('SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :documentId');
            DocumentShare docShare = new DocumentShare();
            docShare.name = doc[0].Name;
            docShare.noOfAttachment = attachedNo;
            docShare.recordId = doc[0].Id;
            return docShare;
        }else{
            return null;
        }  
    }

    public class DocumentShare {
        @AuraEnabled public String name {set;get;}
        @AuraEnabled public String recordId {set;get;}
        @AuraEnabled public Integer noOfAttachment {set;get;}     
    } 

    /**
     * @description       : This Method will return comments for specific account stored in Pricing_AccountId_Comments_Mapping__c custom setting.
     * @author            : Vrushabh
     * @param             : accountId Account Id from Quote.
     * @last modified on  : 09-18-2026
    **/
    @AuraEnabled(cacheable=true)
    public static Pricing_AccountId_Comments_Mapping__c getAccountIdCommentsMapping(String accountId) {
        List<Pricing_AccountId_Comments_Mapping__c> accCommentMapping = new List<Pricing_AccountId_Comments_Mapping__c>();
        if(String.isNotBlank(accountId)){
            accCommentMapping = [Select Id, Name, AccountId__c, Comments_Part_1__c, Comments_Part_2__c from Pricing_AccountId_Comments_Mapping__c Where AccountId__c =:accountId Limit 1];
        }else{
            accCommentMapping = null;
        }
        return (accCommentMapping.size() > 0) ? accCommentMapping[0] : null;
    }
    //This method checks if the current user is a Pricing Manager Alpha User  
    @AuraEnabled(cacheable=true)
    public static Boolean isPricingManagerAlpha() {
        integer count = [SELECT count() FROM PermissionSetAssignment 
                         WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Pricing_Tender_Regional_Pricing_Manager_Alpha'];
        return count > 0;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean isPAAEligible(SBQQ__QuoteLine__c quoteLine){
        return Pricing_QuoteLineController.eligibleForPricingSupportCheck(quoteLine);
    }
}