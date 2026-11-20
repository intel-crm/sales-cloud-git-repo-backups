/***************************************************************************************************
Class Name:  CRM_Software_And_ServicesQuote
Class Type: Utility Class 
Version     : 1.0
Created Date: 16 Aug 2024
Test class Name: CRM_Software_And_ServicesQuote_Test
Function    : Software Support type creation for Opportunity 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Areefa banu              16/08/2024              Created
****************************************************************************************************/   
public without sharing class CRM_Software_And_ServicesQuote {
    public static Id SWRecId;    
    public static Id OpptyId;
    public static boolean isApprovedOppt;
    public static String OpptyDescription;
    public static String OpptOwner;
    public static String OpptPrimaryContact;
    public static String OpptAcctOwner;
    public static String OpptProdCountGrtTnZeroWarning;
    public static String MutipleSWQuoteOnOpptyWarning;
    public static String isApprovedOpptyHardStopError;    
    public static String isAllowedToCreateOtherQuoteReqWarning;
    public static String OpptPrimaryContactNullHardError;
    public static boolean isOpptPrimaryContactHasData;
    public static boolean isOneOfTheQuoteAccepted = false;
    public static string OneOfTheOpptySwQuoteisAcceptedHardError;
    public static Id currentUserId; 
    
    @AuraEnabled
    public static boolean hasAccessToCreateSWQuote(Id recordId){
        boolean isIntelLedDealOppty = false;
        Id dealRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
        Opportunity opp = [Select id,recordtypeId,Core_Opportunity_Coverage_Nm__c from Opportunity where id =:recordId limit 1 ];
        if(opp!= null && opp.Core_Opportunity_Coverage_Nm__c=='Intel-Led Opportunity' && opp.recordtypeId == dealRecordTypeId){ 
            isIntelLedDealOppty = true;
        } 
        Boolean hasCustomPermission = FeatureManagement.checkPermission('CRM_SW_Admin_Access');
        if(hasCustomPermission && isIntelLedDealOppty){ 
            return true;              
        }
        else{
            return false;
        }
    }    
    
    @AuraEnabled
    public static List<String> getQuoteProgramName(Id recordId) {
        List<SBQQ__Quote__c> listOfquotes = [ SELECT Id, SBQQ__Opportunity2__c, Pricing_Quote_Program_Nm__c FROM SBQQ__Quote__c WHERE Pricing_Quote_Program_Nm__c IN ('Tender','PSG','Software & Services') AND SBQQ__Opportunity2__c =:recordId]; // try to read from custom Setting
        Set<String> distinctProgramNames = new Set<String>();
        for (SBQQ__Quote__c quote : listOfquotes) {
            distinctProgramNames.add(quote.Pricing_Quote_Program_Nm__c);
        }
        return new List<String>(distinctProgramNames); 
    }
    
    
    public class SWAndServQuoteSuppRequestWrapper{
        public SWAndServQuoteSuppRequestWrapper(Id SWRecId, Id OpptyId,boolean isApprovedOppt,String OpptyDescription,String OpptOwner,String OpptPrimaryContact,String OpptAcctOwner,String OpptProdCountGrtTnZeroWarning,String MutipleSWQuoteOnOpptyWarning,String isApprovedOpptyHardStopError,string OpptPrimaryContactNullHardError,boolean isOpptPrimaryContactHasData, boolean isOneOfTheQuoteAccepted,string OneOfTheOpptySwQuoteisAcceptedHardError,Id currentUserId){
            this.SWRecId = SWRecId;
            this.OpptyId = OpptyId;
            this.isApprovedOppt = isApprovedOppt;
            this.OpptyDescription = OpptyDescription;
            this.OpptOwner = OpptOwner;
            this.OpptPrimaryContact = OpptPrimaryContact;
            this.OpptAcctOwner = OpptAcctOwner;
            this.OpptProdCountGrtTnZeroWarning =OpptProdCountGrtTnZeroWarning;
            this.MutipleSWQuoteOnOpptyWarning =MutipleSWQuoteOnOpptyWarning;
            this.isApprovedOpptyHardStopError =isApprovedOpptyHardStopError;
            this.isAllowedToCreateOtherQuoteReqWarning = isAllowedToCreateOtherQuoteReqWarning;
            this.OpptPrimaryContactNullHardError = OpptPrimaryContactNullHardError;
            this.isOpptPrimaryContactHasData =isOpptPrimaryContactHasData;
            this.isOneOfTheQuoteAccepted = isOneOfTheQuoteAccepted;
            this.OneOfTheOpptySwQuoteisAcceptedHardError =OneOfTheOpptySwQuoteisAcceptedHardError;
            this.currentUserId = currentUserId;
        }
        @AuraEnabled public Id SWRecId { get;set; }
        @AuraEnabled public Id OpptyId { get;set; }
        @AuraEnabled public boolean isApprovedOppt { get;set; }
        @AuraEnabled public String OpptyDescription { get;set; }
        @AuraEnabled public String OpptOwner { get;set; } 
        @AuraEnabled public String OpptPrimaryContact { get;set; }
        @AuraEnabled public String OpptAcctOwner { get;set; }
        @AuraEnabled public String OpptProdCountGrtTnZeroWarning { get;set; }
        @AuraEnabled public String MutipleSWQuoteOnOpptyWarning { get;set; }
        @AuraEnabled public String isApprovedOpptyHardStopError { get;set; }
        @AuraEnabled public String isAllowedToCreateOtherQuoteReqWarning { get;set; }
        @AuraEnabled public String OpptPrimaryContactNullHardError { get;set; }
        @AuraEnabled Public boolean isOpptPrimaryContactHasData {get; set;}
        @AuraEnabled public boolean isOneOfTheQuoteAccepted {get; set;}
        @AuraEnabled public String OneOfTheOpptySwQuoteisAcceptedHardError {get; set;}
        @AuraEnabled public Id currentUserId;
        
    }
    
    @AuraEnabled
    public static SWAndServQuoteSuppRequestWrapper getSWAndServQuoteSuppRequestDetails(Id recordId){
        isApprovedOppt = false;
        currentUserId = UserInfo.getUserId();
        List<RecordType> recordTypes = [ SELECT Id FROM RecordType WHERE SObjectType = 'SBQQ__Quote__c' AND DeveloperName = 'Pricing_Software_Quote_Create' AND IsActive = true];
        if (!recordTypes.isEmpty()) {
            SWRecId = recordTypes[0].Id;             
            Opportunity opp = [Select id,recordtypeId,StageName,Core_Approval_Status__c,Description,OwnerId,AccountId,Core_Product_Count__c,Core_Opportunity_Coverage_Nm__c,Core_Coverage_Type_Nm__c,Core_VBS_Potential__c,Core_VBS_Status__c from Opportunity where id =:recordId limit 1 ];
            
            if(opp.Core_VBS_Potential__c==true && opp.Core_VBS_Status__c != 'SOAR1 Un-qualified' && opp.Core_VBS_Status__c != 'SOAR3 Denied' && opp.Core_VBS_Status__c != 'SOAR4 Contract Not Signed')
            {
                isApprovedOppt = true;
                isApprovedOpptyHardStopError = Core_CRM_Utility.getCRMLabel('CRM_SWOppVBSCheck'); 
            }else {
                OpptyId = opp.Id;
                OpptyDescription = opp.Description;
                OpptOwner = opp.OwnerId;
                OpptAcctOwner = opp.AccountId;
            }
            
            //Added as part of new change request
            List<SBQQ__Quote__c> swquote = [SELECT Id,SBQQ__Status__c, Pricing_Quote_Program_Nm__c,SBQQ__Opportunity2__c,SBQQ__Primary__c FROM SBQQ__Quote__c 
                                            WHERE Pricing_Quote_Program_Nm__c='Software & Services' 
                                            and SBQQ__Opportunity2__c=:recordId ]; //and SBQQ__Status__c='Accepted' limit 1
            
            if(swquote.size()>0){                
                for (SBQQ__Quote__c q : swquote) {
                    if (q.SBQQ__Primary__c==true && q.SBQQ__Status__c=='Accepted') {
                        isOneOfTheQuoteAccepted = true;
                        OneOfTheOpptySwQuoteisAcceptedHardError = Core_CRM_Utility.getCRMLabel('CRM_SW_OneOfPrimaryQuoteAccepted');
                        break; // Exit the loop as we found an accepted quote 
                    }else{
                        MutipleSWQuoteOnOpptyWarning = Core_CRM_Utility.getCRMLabel('CRM_SW_MutipleSWQuoteOnOpptyWarning');
                    }                    
                }
            }
            else{MutipleSWQuoteOnOpptyWarning=null;}
            
            if(opp.Core_Product_Count__c > 0){  OpptProdCountGrtTnZeroWarning = Core_CRM_Utility.getCRMLabel('CRM_SW_OpptProdCountGrtTnZeroWarning');}//Products associated with this Opportunity will be overwritten with the Primary Quote Products 
            
            List<OpportunityContactRole> ocr = [select id,IsPrimary,ContactId from OpportunityContactRole where opportunityid =:recordId and IsPrimary = true and Role = 'Business Decision Maker' limit 1]; //added Business Decision Maker check for TWC4767-3912 
            if (!ocr.isEmpty()) {
                isOpptPrimaryContactHasData = true;
                OpptPrimaryContact = ocr[0].ContactId;                    
            }else{
                isOpptPrimaryContactHasData =false;
                OpptPrimaryContact = null;  
                OpptPrimaryContactNullHardError = Core_CRM_Utility.getCRMLabel('CRM_SW_QuoteCntCreateWithoutPriContact'); //Software Quote cannot be create without PrimaryContact
            } 
            
            
        }else{
            system.debug('This Pricing_Software_Quote_Create recordtype is inactive');            
        } 
        
        SWAndServQuoteSuppRequestWrapper swsuppReq = new SWAndServQuoteSuppRequestWrapper(SWRecId,OpptyId,isApprovedOppt,OpptyDescription,OpptOwner,OpptPrimaryContact,OpptAcctOwner,OpptProdCountGrtTnZeroWarning,MutipleSWQuoteOnOpptyWarning,isApprovedOpptyHardStopError,OpptPrimaryContactNullHardError,isOpptPrimaryContactHasData,isOneOfTheQuoteAccepted,OneOfTheOpptySwQuoteisAcceptedHardError,currentUserId);
        
        return swsuppReq;
    }
    
    
    /*@AuraEnabled
    public static Boolean hideAndshowPSGQuoteFlag() {       
       String gethideAndshowPSGQuoteValue = Core_CRM_Utility.getCRMLabel('hideAndshowPSGQuote');   
       return 'true'.equalsIgnoreCase(gethideAndshowPSGQuoteValue);  
    }*/
}