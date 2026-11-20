public without sharing class Pricing_SW_QuoteBusinessLogic {
    /************************************************************************************************************
*Method Name : updateRecordtypebyStatusandApprovalStatus
*Created Date: 12/08/2024 
*Author: Deepthi Kambam
*Description : Update Status based on Approval Status Field, Update record type based on Status Field.
************************************************************************************************************/
        
    public static void updateRecordtypebyStatusandApprovalStatus(
        List<SBQQ__Quote__c> quoteList,
        Map<Id, SBQQ__Quote__c> oldMap,
        Boolean isInsert
    ) {            
        Boolean isUpdate = !isInsert;
        
        Id EditRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_SW_QuoteEditRecordTypeId);
        Id readOnlyRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_SW_QuoteReadonlyRecordTypeId);
        Id SubmitRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_SW_QuoteSubmitRecordTypeId);           
        
        Set<Id> opportunityIds = getOpportunityIds(quoteList);
        Map<Id, Opportunity> opportunityMap = fetchOpportunities(opportunityIds);

        if (isInsert) {   
            for (SBQQ__Quote__c quote : quoteList) {
                assignRecordType(quote, EditRecordTypeId);
                assignTemplate(quote);
                assignOwner(quote);
                validateQuote(quote, oldMap, opportunityMap, isInsert);
                cloneQuotes(quote, opportunityIds);
                validateOpportunityProductLost(quote, null, opportunityIds, true);
            }
        }
        if (isUpdate) {
            // Process the quotes and apply the necessary validation rules
            for (SBQQ__Quote__c quote : quoteList)
            {
                SBQQ__Quote__c oldQuote = oldMap.get(quote.Id);             
                updateSubmittedDate(quote, oldQuote);           
               
                if ((oldMap.get(quote.Id).ApprovalStatus__c != quote.ApprovalStatus__c && oldMap.get(quote.Id).ApprovalStatus__c == Label.Pricing_SW_QuoteApprovalStatusPending && quote.ApprovalStatus__c == Label.Pricing_SW_QuoteApprovalStatusApproved)||(oldMap.get(quote.Id).ApprovalStatus__c != quote.ApprovalStatus__c && oldMap.get(quote.Id).ApprovalStatus__c == Label.Pricing_SW_QuoteApprovalStatusPending && quote.ApprovalStatus__c == Label.Pricing_SW_QuoteApprovalStatusRejected)||(oldMap.get(quote.Id).ApprovalStatus__c != quote.ApprovalStatus__c && oldMap.get(quote.Id).ApprovalStatus__c == null && quote.ApprovalStatus__c == Label.Pricing_SW_QuoteApprovalStatusApproved)) {
                    quote.Pricing_SW_Approved_Rejected_Date__c = system.today();
                }
            
                //Update Status for Quote based on Approval Status
                updateQuoteStatus(quote, oldQuote);
                updateRecordType(quote, oldQuote);                
                
                if(quote.SBQQ__SalesRep__c!=null){
                    quote.OwnerId=quote.SBQQ__SalesRep__c;
                }
                
                if(quote.OwnerId!=null && oldMap.get(quote.Id).OwnerId != quote.OwnerId){
                    quote.Pricing_sw_Quote_Owner__c=quote.OwnerId;
                }
                validateQuote(quote, oldMap, opportunityMap, isInsert);
                validateOpportunityProductLost(quote, oldMap, opportunityIds, false);
            }
        }
    }

    /** START: IsInsert Methods */
    private static void assignRecordType(SBQQ__Quote__c quote, Id EditRecordTypeId) {
        if (quote.SBQQ__Status__c == Label.Pricing_SW_QuoteStatusDraft) {
            quote.RecordTypeId = EditRecordTypeId;
        }
    }

    private static void assignTemplate(SBQQ__Quote__c quote) {
        Id templateId = [SELECT Id FROM SBQQ__QuoteTemplate__c WHERE Name = :Label.Pricing_SW_IQR_Software_Quote_Template LIMIT 1].Id;

        quote.SBQQ__QuoteTemplateId__c = templateId;
        quote.SBQQ__DefaultTemplate__c = templateId;
    }

    private static void assignOwner(SBQQ__Quote__c quote) {
        if (quote.SBQQ__SalesRep__c != null) {
            quote.OwnerId = quote.SBQQ__SalesRep__c;
        }

        if (quote.OwnerId != null && quote.Pricing_sw_Quote_Owner__c == null) {
            quote.Pricing_sw_Quote_Owner__c = quote.OwnerId;
        }
    }

    private static Set<Id> getOpportunityIds(List<SBQQ__Quote__c> quoteList) {
        Set<Id> opportunityIds = new Set<Id>();
        for (SBQQ__Quote__c quote : quoteList) {
            if (quote.SBQQ__Opportunity2__c != null) {
                opportunityIds.add(quote.SBQQ__Opportunity2__c);
            }
        }
        return opportunityIds;
    }

    private static Map<Id, Opportunity> fetchOpportunities(Set<Id> opportunityIds) {      
        if (opportunityIds.isEmpty()) {
            return new Map<Id, Opportunity>();
        }

        return new Map<Id, Opportunity>(
                [SELECT Id, Description, Core_Approval_Status__c, SBQQ__PrimaryQuote__c, 
                    SBQQ__PrimaryQuote__r.SBQQ__Status__c, SBQQ__PrimaryQuote__r.SBQQ__Primary__c, 
                    SBQQ__PrimaryQuote__r.Pricing_Quote_Program_Nm__c 
                FROM Opportunity 
                WHERE Id IN :opportunityIds 
                AND (Core_Approval_Status__c IN :new List<String>{Label.Pricing_SW_OpportunityStatusSubmitted, Label.Pricing_SW_OpportunityStatusApproved} 
                    OR SBQQ__PrimaryQuote__c != null)
            ]
        );
    }
    
    
    private static Map<Id, Opportunity> fetchOpportunitiesNotSubmitted(Set<Id> opportunityIds) {
    return new Map<Id, Opportunity>(
        [SELECT Id, Description, Core_Approval_Status__c, SBQQ__PrimaryQuote__c, 
                SBQQ__PrimaryQuote__r.SBQQ__Status__c, SBQQ__PrimaryQuote__r.SBQQ__Primary__c, 
                SBQQ__PrimaryQuote__r.Pricing_Quote_Program_Nm__c 
            FROM Opportunity 
            WHERE Id IN :opportunityIds 
            AND Core_Approval_Status__c NOT IN: new List<String>{Label.Pricing_SW_OpportunityStatusSubmitted, Label.Pricing_SW_OpportunityStatusApproved}
        ]
    );
}
    
    public static void cloneQuotes(SBQQ__Quote__c quote, Set<Id> opportunityIds) {
        Integer expiryDays = Integer.valueOf(Label.Pricing_SW_AddExpiryDays);

        Map<Id, Opportunity> opportunitiesNotSubmittedMap = fetchOpportunitiesNotSubmitted(opportunityIds);
        if (quote.isClone()) {
            Id currentUserId = UserInfo.getUserId();
            quote.SBQQ__SalesRep__c = currentUserId;
            quote.OwnerId = currentUserId;
            quote.Pricing_sw_Quote_Owner__c = currentUserId;
            quote.SBQQ__CustomerDiscount__c = 0;
            quote.Pricing_SW_Approval_Comments__c = null;
            quote.Pricing_SW_Submitted_Date__c = null;
            quote.SBQQ__TargetCustomerAmount__c= null;
            quote.Pricing_SW_Approved_Rejected_Date__c = null;
            quote.ApprovalStatus__c = null;
        quote.SBQQ__StartDate__c = (quote.SBQQ__StartDate__c < System.today()) 
            ? System.today()
            : quote.SBQQ__StartDate__c;
            quote.Pricing_SW_Expiry_Date__c = (quote.Pricing_SW_Expiry_Date__c < System.today().addDays(expiryDays)) 
                ? System.today().addDays(expiryDays) 
                : quote.Pricing_SW_Expiry_Date__c;

            // Populate description from related Opportunity
            if (quote.SBQQ__Opportunity2__c != null && opportunitiesNotSubmittedMap.containsKey(quote.SBQQ__Opportunity2__c)) {
                quote.Pricing_SW_Description__c = opportunitiesNotSubmittedMap.get(quote.SBQQ__Opportunity2__c).Description;
            }
        }
    }   

    public static void validateQuote(
        SBQQ__Quote__c quote,
        Map<Id, SBQQ__Quote__c> oldQuoteMap,
        Map<Id, Opportunity> opportunityMap,
        Boolean isInsert
    ) {

        Map<String, String> quoteStatusToErrorMap = new Map<String, String>{
            Label.Pricing_SW_QuoteStatusAccepted => Label.Pricing_SW_OpportunityAndQuoteStatusCheck,
            Label.Pricing_SW_QuoteStatusApproved => Label.Pricing_SW_OpportunityAndQuoteStatusCheck,
            Label.Pricing_SW_QuoteStatusDenied => Label.Pricing_SW_OpportunityAndQuoteStatusCheck,
            Label.Pricing_SW_QuoteStatusRejected => Label.Pricing_SW_OpportunityAndQuoteStatusCheck
        };

        List<String> opportunityStatuses = new List<String>{
            Label.Pricing_SW_OpportunityStatusSubmitted,
            Label.Pricing_SW_OpportunityStatusApproved
        };
        
        String getPrimaryField = 'SBQQ__Primary__c';
        String getStatusValue = 'SBQQ__Status__c';
        String strCreateLabel = 'create';
        String strUpdateLabel = 'update';

        Opportunity opp = opportunityMap.get(quote.SBQQ__Opportunity2__c);
        SBQQ__Quote__c oldQuote = oldQuoteMap.get(quote.Id);
        Set<String> validApprovalStatuses = new Set<String>{Label.Pricing_SW_OpportunityStatusSubmitted, Label.Pricing_SW_OpportunityStatusApproved};

        if (opp != null && opp.SBQQ__PrimaryQuote__r != null) {
            //Logic For Submitted Opportunites
            //Boolean isPrimaryChange = isInsert ? quote.SBQQ__Primary__c == true : ;
            for (String oppStatus : opportunityStatuses) {

                if (opp.Core_Approval_Status__c == oppStatus && quoteStatusToErrorMap.containsKey(opp.SBQQ__PrimaryQuote__r.SBQQ__Status__c)) {
                    // Get the appropriate error message for the quote status
                    String errorMessage = Label.Pricing_SW_AlreadyApprovedOpportunity;//quoteStatusToErrorMap.get(opp.SBQQ__PrimaryQuote__r.SBQQ__Status__c);
            
                    if (isInsert) {
                        errorMessage = getFormattedErrorMessage(errorMessage, strCreateLabel, opp.Core_Approval_Status__c); 
                        quote.addError(errorMessage);                        
                    } else  {
                        String primaryQuoteStatus = opp.SBQQ__PrimaryQuote__r.SBQQ__Status__c;

                        Set<String> validQuoteStatuses = new Set<String>{Label.Pricing_SW_QuoteStatusAccepted, Label.Pricing_SW_QuoteStatusApproved, Label.Pricing_SW_QuoteStatusDenied, Label.Pricing_SW_QuoteStatusRejected};
                        Object newPrimaryCheckboxValue = quote.get(getPrimaryField);
                        Object oldPrimaryCheckboxValue = oldQuote.get(getPrimaryField);
                        Object oldStatusValue = oldQuote.get(getStatusValue);

                        if (validQuoteStatuses.contains(primaryQuoteStatus)) {
                            if (opp.SBQQ__PrimaryQuote__r.SBQQ__Primary__c == true && oldQuote.SBQQ__Primary__c) {
                                errorMessage = getFormattedErrorMessage(errorMessage, strUpdateLabel, opp.Core_Approval_Status__c); 
                                quote.addError(errorMessage);
                            }
                        }
                        if(!(opp.SBQQ__PrimaryQuote__r.SBQQ__Primary__c) && newPrimaryCheckboxValue != oldPrimaryCheckboxValue){//Allow users to update non-primary quotes 
                            errorMessage = getFormattedErrorMessage(errorMessage, strUpdateLabel, opp.Core_Approval_Status__c); 
                            quote.addError(errorMessage);
                        }
                    }
                } else if(!validApprovalStatuses.contains(opp.Core_Approval_Status__c)){
                    //Logic for not submitted opportunities
                    Set<String> validQuoteStatuses = new Set<String>{Label.Pricing_SW_QuoteStatusAccepted};
                    String errorMessage = quoteStatusToErrorMap.get(opp.SBQQ__PrimaryQuote__r.SBQQ__Status__c);

                    if (validQuoteStatuses.contains(opp.SBQQ__PrimaryQuote__r.SBQQ__Status__c)){
                        if(isInsert){
                            errorMessage = getFormattedErrorMessage(errorMessage, strCreateLabel, opp.SBQQ__PrimaryQuote__r.SBQQ__Status__c); 
                            quote.addError(errorMessage);                                
                        } else {
                            Object newPrimaryCheckboxValue = quote.get(getPrimaryField);
                            Object oldPrimaryCheckboxValue = oldQuote.get(getPrimaryField);
                            Object oldStatusValue = oldQuote.get(getStatusValue);
                            if(newPrimaryCheckboxValue != oldPrimaryCheckboxValue){
                                errorMessage = getFormattedErrorMessage(errorMessage, strUpdateLabel, opp.SBQQ__PrimaryQuote__r.SBQQ__Status__c); 
                                quote.addError(errorMessage);
                            }
                        }
                    }                   
                }
            }
        }
    }

    public static String getFormattedErrorMessage(String errorMessage, String dynamicValue, String quoteStatus) {
        // Replace placeholders in the error message
        errorMessage = errorMessage.replace('{0}', dynamicValue); // Add the dynamic opportunity status to the error message
        errorMessage = errorMessage.replace('{1}', quoteStatus); // Add the dynamic opportunity status to the error message 
        
        return errorMessage;
    }

    /** END: IsInsert Methods */

    /** START: IsUpdate Methods */
    private static void updateQuoteStatus(SBQQ__Quote__c quote, SBQQ__Quote__c oldQuote) {
        if (oldQuote.ApprovalStatus__c != quote.ApprovalStatus__c) {
            Map<String, String> statusMap = new Map<String, String>{
                Label.Pricing_SW_QuoteApprovalStatusPending => Label.Pricing_SW_QuoteStatusInReview,
                Label.Pricing_SW_QuoteApprovalStatusApproved => Label.Pricing_SW_QuoteStatusApproved,
                Label.Pricing_SW_QuoteApprovalStatusRejected => Label.Pricing_SW_QuoteStatusRejected,
                Label.Pricing_SW_QuoteApprovalStatusRecalled => Label.Pricing_SW_QuoteStatusDraft
            };

            if (statusMap.containsKey(quote.ApprovalStatus__c)) {
                quote.SBQQ__Status__c = statusMap.get(quote.ApprovalStatus__c);
            }
        }
    }

    private static void updateSubmittedDate(SBQQ__Quote__c quote, SBQQ__Quote__c oldQuote) {
        if (isApprovalStatusPendingTransition(oldQuote, quote)) {
            quote.Pricing_SW_Submitted_Date__c = System.today();
        } else if (quote.ApprovalStatus__c == Label.Pricing_SW_QuoteApprovalStatusRecalled) {
            quote.Pricing_SW_Submitted_Date__c = null;
        }
    }

    private static Boolean isApprovalStatusPendingTransition(SBQQ__Quote__c oldQuote, SBQQ__Quote__c newQuote) {
        return (oldQuote.ApprovalStatus__c == null && 
                (newQuote.ApprovalStatus__c == Label.Pricing_SW_QuoteApprovalStatusPending ||
                 newQuote.ApprovalStatus__c == Label.Pricing_SW_QuoteApprovalStatusApproved));
    }

    private static void updateRecordType(SBQQ__Quote__c quote, SBQQ__Quote__c oldQuote) {
        Id EditRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_SW_QuoteEditRecordTypeId);
        Id readOnlyRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_SW_QuoteReadonlyRecordTypeId);
        Id SubmitRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_SW_QuoteSubmitRecordTypeId);

        if (oldQuote.SBQQ__Status__c != quote.SBQQ__Status__c) {
            Map<String, Id> recordTypeMap = new Map<String, Id>{
                Label.Pricing_SW_QuoteStatusInReview => SubmitRecordTypeId,
                Label.Pricing_SW_QuoteStatusApproved => readOnlyRecordTypeId,
                Label.Pricing_SW_QuoteStatusRejected => readOnlyRecordTypeId,
                Label.Pricing_SW_QuoteStatusDraft => EditRecordTypeId
            };

            if (recordTypeMap.containsKey(quote.SBQQ__Status__c)) {
                quote.RecordTypeId = recordTypeMap.get(quote.SBQQ__Status__c);
            }
        }
    }
   
    public static Boolean isPrimaryQuoteSubmitted(SBQQ__Quote__c quote, Map<Id, Opportunity> opportunityMap) {
        if (opportunityMap.containsKey(quote.SBQQ__Opportunity2__c)) {
            Opportunity opp = opportunityMap.get(quote.SBQQ__Opportunity2__c);
            
            if (opp.SBQQ__PrimaryQuote__r != null && opp.SBQQ__PrimaryQuote__r.SBQQ__Status__c == 'Submitted') {
                return true;  
            }
        }
        return false; 
    }
    /** END: IsUpdate Methods */
    
    /** START: Common Methods */
    /************************************************************************************************************
    *Method Name : getOpportunityLostStatusMap
    *Created Date: 03/10/2024
    *Author: Prasad Kulkarni
    *Description : Get Opportunity Product with Lost status
    ************************************************************************************************************/ 
    public static Map<Id, Boolean> getOpportunityLostStatusMap(Set<Id> opportunityIds) {
        Map<Id, Boolean> opportunityLostStatusMap = new Map<Id, Boolean>();
        
        for (OpportunityLineItem oppLineItem : [SELECT OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN :opportunityIds AND Core_Status__c = 'Lost']) {
            opportunityLostStatusMap.put(oppLineItem.OpportunityId, true);
        }
        
        return opportunityLostStatusMap;
    }
        
    /************************************************************************************************************
    *Method Name : validateOpportunityProductLost
    *Created Date: 03/10/2024
    *Author: Prasad Kulkarni
    *Description : Restrict any update on Quote if Opportunity Product with Lost status
    ************************************************************************************************************/ 
    public static void validateOpportunityProductLost(
    SBQQ__Quote__c quote,
    Map<Id, SBQQ__Quote__c> oldQuoteMap,
    Set<Id> opportunityIds,
    Boolean isInsert
    ) {
        Map<Id, Boolean> opportunityLostStatusMap = getOpportunityLostStatusMap(opportunityIds);

        // Check if the related Opportunity has any OpportunityLineItems with Core_Status__c = 'Lost'
        if (opportunityLostStatusMap.containsKey(quote.SBQQ__Opportunity2__c)) {

            if (isInsert) {
                quote.addError(Label.Pricing_SW_OppLostInsertErrorCheck);
            }
            else {
                SBQQ__Quote__c oldQuote = oldQuoteMap.get(quote.Id);
                String fieldsToCheckLabel = Label.Pricing_SW_FieldsToCheck;
                // Prevent any updates to fields if the quote is Primary
                if (oldQuote != null && oldQuote.SBQQ__Primary__c == true) {
                    // List of fields to check for changes
                    List<String> fieldsToCheck = fieldsToCheckLabel.split(',');

                    // Check each field to see if it has changed
                    for (String fieldName : fieldsToCheck) {
                        Object newValue = quote.get(fieldName);
                        Object oldValue = oldQuote.get(fieldName);
                        if (newValue != oldValue) {
                            quote.addError(Label.Pricing_SW_OppLostUpdateErrorCheck);
                            break; // Exit the loop after adding the error
                        }
                    }
                } else {
                    String getPrimaryField = 'SBQQ__Primary__c';
    
                    Object newPrimaryCheckboxValue = quote.get(getPrimaryField);
                    Object oldPrimaryCheckboxValue = oldQuoteMap.get(quote.Id).get(getPrimaryField);
                    if(newPrimaryCheckboxValue != oldPrimaryCheckboxValue){
                        quote.addError(Label.Pricing_SW_OppLostUpdatePrimaryCheck);//Label.Pricing_SW_OppLostPrimaryCheckboxErrorCheck
                    }
                }                                     
            }
        }
    }
    /** END: Common Methods */


    
    /** START: Standalone Methods */
    public static void updateCRMSWOnOpportunity(List<SBQQ__Quote__c> swTriggerList) {    
        Set<Id> oppIds = new Set<Id>();
        
        for (SBQQ__Quote__c quote : swTriggerList) {
            if (quote.SBQQ__Opportunity2__c != null) {
                oppIds.add(quote.SBQQ__Opportunity2__c);
                
            }
        }  
        if (!oppIds.isEmpty()) {
            List<Opportunity> oppsToUpdate = [SELECT Id, CRM_SW_Flag_Ind__c FROM Opportunity WHERE Id IN :oppIds];  
            
            for (Opportunity opp : oppsToUpdate) {
                opp.CRM_SW_Flag_Ind__c = true;
            }  
            if (!oppsToUpdate.isEmpty()) {
                update oppsToUpdate;     
            }
            //Sharing quotes for team member for new quotes created
            createQuoteSharesForSW((List<Id>)JSON.deserialize(JSON.serialize(oppIds), List<Id>.class));
        } 
    } 

    /************************************************************************************************************
    *Method Name : createQuoteSharesForSW
    *Created Date: 29/08/2024
    *Author: Mahesh Biradar
    *Description : Create Quote Share for Opportunity Team members
    ************************************************************************************************************/    
    public static void createQuoteSharesForSW(List<Id> opportunityIds){
        // Map to hold related Quotes for each Opportunity
        Map<Id, List<SBQQ__Quote__c>> opportunityToQuotesMap = new Map<Id, List<SBQQ__Quote__c>>();  
        // Query for all related Quotes for the collected Opportunity IDs
        for (SBQQ__Quote__c relatedQuote : [SELECT Id, SBQQ__Opportunity2__c,Owner.id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN :opportunityIds]) {
            if (!opportunityToQuotesMap.containsKey(relatedQuote.SBQQ__Opportunity2__c)) {
                opportunityToQuotesMap.put(relatedQuote.SBQQ__Opportunity2__c, new List<SBQQ__Quote__c>());
            }
            opportunityToQuotesMap.get(relatedQuote.SBQQ__Opportunity2__c).add(relatedQuote);
        }
        // Get current manually shared quote share records
        List<SBQQ__Quote__Share> quoteSharesListToDelete= [SELECT Id FROM SBQQ__Quote__Share 
                                                           WHERE Parent.SBQQ__Opportunity2__c IN :opportunityIds and RowCause = 'Pricing_SW_Opportunity_Sharing__c'];
        
        // Prepare a list to hold the new QuoteTeamMembers to be inserted
        List<SBQQ__Quote__Share> quoteSharesList = new List<SBQQ__Quote__Share>();
        
        // Loop through each inserted OpportunityTeamMember
        for (OpportunityTeamMember newTeamMember : [SELECT Id,OpportunityId,UserId FROM OpportunityTeamMember WHERE OpportunityId IN: opportunityIds]) {
            // Get the related Quotes from the map
                List<SBQQ__Quote__c> relatedQuotes = opportunityToQuotesMap.get(newTeamMember.OpportunityId);
            // Check if there are related Quotes
                if (relatedQuotes != null) {
                // Loop through each related Quote and prepare a new QuoteTeamMember
                    for (SBQQ__Quote__c relatedQuote : relatedQuotes) {  
                      if (newTeamMember.UserId != relatedQuote.Owner.id) {
                            SBQQ__Quote__Share quoteShr = new SBQQ__Quote__Share();
                            quoteShr.ParentId = relatedQuote.Id;
                            quoteShr.UserOrGroupId = newTeamMember.UserId;
                            quoteShr.AccessLevel = 'Read';
                            quoteShr.RowCause = Schema.SBQQ__Quote__Share.RowCause.Pricing_SW_Opportunity_Sharing__c;
                            // Add to the list for bulk insertion
                            quoteSharesList.add(quoteShr);
                }
            }
          }
        } 
        
        // Delete the previous quote shares
        if(!quoteSharesListToDelete.isEmpty()){
            try {
                delete quoteSharesListToDelete;
            } catch(exception ex) {
                Pricing_Tender_Utility.logErrorPricingSW(ex);
            }
        }
        // Check if there are any QuoteTeamMembers to add
        if (!quoteSharesList.isEmpty()) {
            // Insert the new QuoteTeamMembers in bulk
            try {
                insert quoteSharesList;
            }catch(exception ex) {
                Pricing_Tender_Utility.logErrorPricingSW(ex);
            }
        }
    }
    /** END: Standalone Methods */

}