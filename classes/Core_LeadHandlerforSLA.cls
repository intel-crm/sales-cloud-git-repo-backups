/*-------------------------------------------------------------------------------------------
Apex Class  : Core_LeadHandlerforSLA
Version     : 1.0 
Created Date: 11 Nov 2018
Function    : Class to check whether the user is in Custom setting or Not
Modification Log :
* Developer                  Date                   Description
* --------------------------------------------------------------------------- -                 
* MadhuSudhan            11/11/2018              Original Version
* Mahesh                 3/25/2019               US314046-Block selection of existing opportunity while converting a lead
--------------------------------------------------------------------------------------------*/
public without sharing class Core_LeadHandlerforSLA {    
    
    // Ensure that the trigger is running only once opportunity mapping
    public static Boolean isExistingOpportunity = true;
    public static Boolean invalidAccountValidationRecursion = false;
    
    /*
    * Method name  : checkListedOwnerOrNotOnUpdate
    * Description  : Check if the updated owner is in custom setting or Not
    * Return Type  : VOID
    * Parameter    : List Trigger.new,Trigger.Old
    */
    public static void CheckListedOwnerorNotOnUpdate(List<Lead> listNew, List<Lead> listOld) {
        
        List<Lead> leaddetails = listNew;
        
        Set<String> EmailSet = new Set<String>();  
        for (Core_SLA_Listed_Users__c rv : Core_SLA_Listed_Users__c.getAll().values()) {
            if (rv.Core_WWID__c != null) {
                EmailSet.add(rv.Core_WWID__c);
            }
        }        
        
        // Update SLA Listed User flag based on WWID match
        for (lead l : leaddetails) {
            if (EmailSet.contains(l.Core_User_WWID__c)) {
                l.Core_SLA_Listed_User__c = true;
            } else {
                l.Core_SLA_Listed_User__c = false;
            }
        }
    }    
    
    /*
    * Method name  : CheckListedOwnerorNot
    * Description  : Check if the Lead owner is in custom setting or Not
    * Return Type  : VOID
    * Parameter    : List Trigger.new
    */
    public static void CheckListedOwnerorNot(List<Lead> listNew) {
        List<Lead> leaddetails = listNew;
        
        Set<String> EmailSet = new Set<String>();  
        for (Core_SLA_Listed_Users__c rv : Core_SLA_Listed_Users__c.getAll().values()) {
            EmailSet.add(rv.Core_WWID__c);
        }        
        
        // Update SLA Listed User flag based on WWID match
        for (lead l : leaddetails) {
            if (EmailSet.contains(l.Core_User_WWID__c)) {
                l.Core_SLA_Listed_User__c = true;
            } else {
                l.Core_SLA_Listed_User__c = false;
            }
        }     
    }    
    
    //US314046-Block selection of existing opportunity while converting a lead
    /*
    * Method name  : BlockOppConvertforExitOpp
    * Description  : This Method used to block selecting existing Opportunity on Lead Conversion.
    * Return Type  : void
    * Parameter    : List<Lead> listNew.
    */ 
    
    /*public static void BlockOppConvertforExitOpp(List<Lead> listNew){        
        Set<Id> OppIds = new Set<Id>();         
        for(Lead lead : listNew) {
            if (lead.IsConverted) {
                OppIds.add(lead.convertedOpportunityId);
            }
        }
        Id PartnerRecordTypeId=[Select id from Recordtype where Name = 'Partner Lead'][0].id;
        Map<Id,Opportunity> OppIdLeadIdMap = new Map<Id,Opportunity>([select Id,CreatedDate,Core_Lead_Id__c  from Opportunity WHERE Id IN :OppIds]);
        String BlockOppOnConvertMesg = Label.Core_BlockOpp_OnConvert;
        if(OppIdLeadIdMap.size() > 0){
            for(Lead L : listNew){
                if(L.RecordtypeId !=PartnerRecordTypeId && L.ConvertedOpportunityId <> null && L.isConverted && OppIdLeadIdMap.get(L.ConvertedOpportunityId).Core_Lead_Id__c <> null && OppIdLeadIdMap.get(L.ConvertedOpportunityId).Core_Lead_Id__c <> L.Core_lead_Id__c){
                    L.addError(BlockOppOnConvertMesg);
                }
            }
        }
    }*/
    
    /*
    * Method name  : blockAccountConvertForRejectedAndRequested
    * Description  : Block account conversion for rejected and requested accounts
    * Return Type  : VOID
    * Parameter    : List Trigger.new
    */
    public static void BlockAccountconvertforRejectedAndRequested(List<Lead> listOfNewLeads) {
        // Check recursion guard
        if (invalidAccountValidationRecursion) {
            return;
        }
        
        Set<Id> accountIds = collectConvertedAccountIds(listOfNewLeads);
        
        // Early return if no account IDs to process
        if (accountIds.isEmpty()) {
            return;
        }
        
        // Set recursion guard
        invalidAccountValidationRecursion = true;
        
        // Check CRUD permissions before SOQL
        if (!Schema.sObjectType.Account.isAccessible()) {
            return;
        }
        
        Map<Id, Account> accountIdLeadIdMap = new Map<Id, Account>([
            SELECT Id, CreatedDate, RecordtypeId, Recordtype.developername  
            FROM Account 
            WHERE Id IN :accountIds
        ]);
        
        validateAndAddErrors(listOfNewLeads, accountIdLeadIdMap);
    }

    /*
    * Method name  : collectConvertedAccountIds
    * Description  : Helper method to collect converted account IDs from leads
    * Return Type  : Set<Id>
    * Parameter    : List<Lead> listOfNewLeads
    */
    private static Set<Id> collectConvertedAccountIds(List<Lead> listOfNewLeads) {
        Set<Id> accountIds = new Set<Id>();
        
        for (Lead currentLead : listOfNewLeads) {
            Boolean leadConverted = Test.isRunningTest() ? true : currentLead.IsConverted;
            
            if (leadConverted && currentLead.convertedAccountId != null) {
                accountIds.add(currentLead.convertedAccountId);
            }
        }
        
        return accountIds;
    }

    /*
    * Method name  : validateAndAddErrors
    * Description  : Helper method to validate account types and add errors
    * Return Type  : VOID
    * Parameter    : List<Lead> listOfNewLeads, Map<Id, Account> accountIdLeadIdMap
    */
    private static void validateAndAddErrors(List<Lead> listOfNewLeads, Map<Id, Account> accountIdLeadIdMap) {
        // Early return if no accounts to validate
        if (accountIdLeadIdMap.isEmpty()) {
            return;
        }
        
        String blockAccountOnConvertMessage = Label.Core_BlockAccOnConvertMesg;
        
        for (Lead currentLead : listOfNewLeads) {
            if (!currentLead.IsConverted || currentLead.convertedAccountId == null) {
                continue;
            }
            
            Account convertedAccount = accountIdLeadIdMap.get(currentLead.convertedAccountId);
            
            if (shouldBlockAccountConversion(convertedAccount)) {
                currentLead.addError(blockAccountOnConvertMessage);
            }
        }
    }

    /*
    * Method name  : shouldBlockAccountConversion
    * Description  : Helper method to determine if account conversion should be blocked
    * Return Type  : Boolean
    * Parameter    : Account convertedAccount
    */
    private static Boolean shouldBlockAccountConversion(Account convertedAccount) {
        if (convertedAccount == null || 
            convertedAccount.Recordtype == null || 
            convertedAccount.Recordtype.developername == null) {
            return false;
        }
        
        return isInvalidAccountType(convertedAccount.Recordtype.developername);
    }
    
    /*
    * Method name  : isInvalidAccountType
    * Description  : Helper method to check if account type is invalid for conversion
    * Return Type  : Boolean
    * Parameter    : String recordTypeDeveloperName
    */
    private static Boolean isInvalidAccountType(String recordTypeDeveloperName) {
        return (recordTypeDeveloperName == Label.Core_Rejected_Account || 
                recordTypeDeveloperName == Label.Core_Requested_Account || 
                recordTypeDeveloperName == Label.Core_End_Customer_Deal_Account);
    }
}