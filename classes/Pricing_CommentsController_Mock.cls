/**
* @description       : Mock class for Commentscontroller
* @author            : Rakshitha BR
* @group             : Gravity
* @last modified on  : 03-28-2022
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
	public class Pricing_CommentsController_Mock {
    //This method takes Pricing_Quote__c Id as parameter and returns the list of Pricing_Comments__c records assosiated with that Id
    @AuraEnabled(cacheable=true)
    public static List<Pricing_Comments__c> getTenderComments(Id recordId) {
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        
        return Pricing_Comments_Selector.newInstance().selectByIdandRecordType(recordId,commentRecordTypeId);        
    }
    
    /**
* @description Using method type from the main class
* @author Rakshitha BR | 03-25-2022 
* @param recordId 
* @return String 
**/
    @AuraEnabled
    public static String getQuoteStatus(Id recordId) {
        return Pricing_Quote_Selector.newInstance().selectByIds(new set<Id>{recordId})[0].SBQQ__Status__c;     
    }    
    
    /**
* @description  This method takes the list of Pricing_Comments__c as parameter that needs to be updated and updates them
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 03-25-2022 
* @param tenderComments 
**/
    @AuraEnabled  
    public static void updateTenderComments(List<Pricing_Comments__c> tenderComments){
        try{
            Pricing_Comments_DML.updateComments(tenderComments) ;
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        }
    }
    
    //This method checks if the current user is a Pricing manager and returns true if the current user is a Pricing Manager 
    @AuraEnabled(cacheable=true)
    public static Boolean isPricingManager() {
        return Pricing_PermissionSetAssignment_Selector.newInstance().selectByName(Userinfo.getUserId(),new set<string>{Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager,Label.Pricing_Tender_PermissionSets_PricingDivisionalTenderPricingManager,Label.Pricing_Tender_PermissionSets_TenderReadOnly}); 
    }
    
    //This method checks if the current user is part of all pricing read only user group and returns true if the current user is a PM/Legal/Finance 
    @AuraEnabled(cacheable=true)
    public static Boolean isReadOnlyUser() {
        return Pricing_User_Selector.newInstance().selectById(Userinfo.getUserId());
    }
    
    //This method takes Pricing_Quote__c record Id as parameter and returns the Pricing manager comments assosiated to that record
    @AuraEnabled(cacheable=true) 
    public static List<Pricing_Comments__c> getPricingManagerComments(Id recordId) {
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_PricingManagerComment);
        return Pricing_Comments_Selector.newInstance().selectByIdandRecordType(recordId,commentRecordTypeId);
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
            
            Pricing_Comments_DML.insertComments(new list<Pricing_Comments__c>{pc}) ;
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        }
    }
    @AuraEnabled
    public static void updateCommentThroughId(String recordId,String answer){
        Pricing_Comments__c pc = new Pricing_Comments__c(Id=recordId,Pricing_Answer__c=answer);
        Pricing_Comments_DML.updateComments(new list <Pricing_Comments__c>{pc});
    }
    
    @AuraEnabled(cacheable=true) 
    public static DocumentShare getDocumentShare(String quoteId){
        List<Pricing_Document__c> doc = Pricing_Document_Selector.newInstance().selectByquoteId(quoteId);  
        if(!doc.isEmpty()){
            Integer attachedNo = Pricing_ContentDocumentLink_Selector.newInstance().selectByRecordType(doc[0].Id);
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
}