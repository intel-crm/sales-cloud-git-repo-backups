/*-------------------------------------------------------------------------------------------
Apex Class  : Pricing_QuoteLineController
Version     : 1.0 
Created Date: 11 JAN 2020
Function    : Apex class for Quote Line Aura component 
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Biradar          1 JAN 2020              Original Version
-------------------------------------------------------------------------------------------*/
public without sharing class Pricing_QuoteLineController extends TriggerHandler{
    public static Integer retryCounter = 0;
    public static SBQQ__QuoteLine__c parentQuoteLine;
    private static User currentUser = [select id, Core_User_Profile_Name__c, (select PermissionSet.Name from PermissionSetAssignments) from User where id =: UserInfo.getUserId()];
    public static Boolean isRPMUser = userHasValidPermissionSet(new Set < String > {
        Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager}) ? true : false;
    
    @AuraEnabled
    public static List < SBQQ__QuoteLine__c > getQuoteLines(Id recordId) {  
        String getQuoteLinesQuery;
        String statusToExclude = Label.Pricing_Tender_QuoteLine_Status_Revised;
        getQuoteLinesQuery='SELECT Id, Name, SBQQ__ProductName__c, Pricing_Other_Product_Nm__c, Pricing_Quote_Line_Number__c,Pricing_Application_Agent_Status__c,Pricing_Status_Nm__c,Pricing_Integration_Status_Nm__c, Pricing_Error_Messages__c,Pricing_Program_Type_Nm__c,Pricing_Quote_Program_Nm__c,Pricing_Approved_End_Date_Dt__c,Pricing_ECAP_Price_Amt__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_SIPP_Cb__c, Pricing_Market_Segment_values_Nm__c,Pricing_Change_Request_cb__c,Pricing_Form_Factor_Nm__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = : recordId and Pricing_Status_Nm__c != :statusToExclude ORDER BY Pricing_Quote_Line_Number__c ASC';
        return Database.query(getQuoteLinesQuery);
    }
    
    @AuraEnabled
    public static List < SBQQ__Quote__c > getQuote(Id recordId) {
        return [SELECT Id, SBQQ__Account__r.Name, Pricing_Project_Name_Nm__c, Pricing_End_Customer_Country_Nm__c, Pricing_Customer_Nm__c, Pricing_ShipmentEndDate_Dt__c, Pricing_Server_Deal_Type_Nm__c, SBQQ__SalesRep__c, Pricing_Region_Nm__c,Pricing_Program_Type_Nm__c,SBQQ__Status__c,Pricing_On_Hold_Cb__c FROM SBQQ__Quote__c WHERE Id = : recordId];
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean isCreateable() {
        return Schema.sObjectType.SBQQ__QuoteLine__c.isCreateable();
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean isOEMField() {
        return FeatureManagement.checkPermission(Label.Pricing_Tender_PermissionSets_TenderUser);
    }
    
    @AuraEnabled
    public static SBQQ__QuoteLine__c getQuoteLine(Id quoteLineId) {
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, Pricing_Product_Nm__r.Name,Pricing_Other_Product_Nm__c,Pricing_Status_Nm__c, Pricing_Quote_Line_Number__c,SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.SBQQ__Account__c,SBQQ__Quote__r.Pricing_Region_Nm__c,
                                        Pricing_FSE_Recommended_Price_Nm__c, Pricing_ECAP_Price_Amt__c,Pricing_Change_Request_cb__c,Pricing_Form_Factor_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,Pricing_Integration_Status_Nm__c,Pricing_Error_Messages__c,
                                        Pricing_Approved_End_Date_Dt__c, Pricing_Approved_Unit_Qty__c,Pricing_Payable_Quantity__c,SBQQ__ProductName__c, Pricing_Other_Competitor_Product_Nm__c, Pricing_Competetor_Product__c,Pricing_EndCustomer_Nm__c,Pricing_FI_Net_RPU_Amt__c,
                                        Pricing_Approved_Start_Date_Dt__c, Pricing_Meet_Comp_Price_Amt__c, Pricing_Deal_RFQ_Id__c, Pricing_Program_Type_Nm__c,Pricing_Req_Discounted_Unit_Price__c,Pricing_Unit_Qty__c,Pricing_SDM_Fast_Track__c,
                                        Pricing_Server_Deal_Type_Nm__c,Pricing_Workload_Nm__c,Pricing_New_Change_Request_cb__c,Pricing_SIPP_Cb__c, Pricing_Market_Segment_values_Nm__c FROM SBQQ__QuoteLine__c WHERE Id = : quoteLineId
                                       ];
        return quoteLine;
    }
    
    @AuraEnabled
    public static String getProductName(Id quoteLineId) {
        String productName;
        SBQQ__QuoteLine__c qlRec = Pricing_QuoteLineController.getQuoteLine(quoteLineId);
        if(qlRec.Pricing_Product_Nm__r.Name != 'Write In Product'){
            productName = qlRec.Pricing_Product_Nm__r.Name;
        }
        else
        {
            productName = qlRec.Pricing_Other_Product_Nm__c;
        }
        return productName;
    }
    
    @AuraEnabled
    public static List < string > getAvailableUserActions(Id quoteLineId) {
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, Pricing_New_Change_Request_cb__c, Pricing_Status_Nm__c, SBQQ__Quote__r.SBQQ__Status__c, SBQQ__Quote__r.Pricing_On_Hold_Cb__c, Pricing_Sales_Rep__c,Pricing_Sales_Rep__r.DelegatedApproverId,Pricing_Approved_End_Date_Dt__c,
                                        CreatedById,SBQQ__ProductName__c, Pricing_Primary_Contact_Nm__c, SBQQ__Quote__r.OwnerId, SBQQ__Quote__r.CreatedById,Pricing_Other_Product_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.SBQQ__ProductName__c,
                                        Pricing_Change_Request_cb__c, Pricing_Deal_RFQ_Status_Nm__c,Pricing_Integration_Status_Nm__c,Pricing_Deal_RFQ_Id__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Deal_RFQ_Id__c,SBQQ__Quote__c,
                                        Pricing_Reference_Quote_Line_Nbr__c,SBQQ__Quote__r.SBQQ__Account__c,Pricing_Program_Type_Nm__c,Pricing_Error_Messages__c,Pricing_Quote_Program_Nm__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Approval_Status__c,Pricing_SIPP_Cb__c,Pricing_Market_Segment_values_Nm__c,Pricing_Form_Factor_Nm__c  From SBQQ__QuoteLine__c
                                        WHERE Id = : quoteLineId];        
        Id delegateApprover = quoteLine.Pricing_Sales_Rep__r.DelegatedApproverId;
        
        List < string > actions = new List < string > ();
        // VARIABLE USED TO GET USER ID
        Id userId = UserInfo.getUserId();
        // If user has create access he can clone always
        if(isCreateable()) {
            Set < String > allPersona = getPersonaExcludingSet(new Set < String >{});
            if((userHasValidPermissionSet(allPersona) && (quoteLine.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_FinancialIncentive_Quote)) && ((!quoteLine.SBQQ__Quote__r.Pricing_On_Hold_Cb__c) || isPartnerUser())) {
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Clone);
            }
        }
        Set < String > allPersona = getPersonaExcludingSet(new Set < String > ());
        Set < String > isRPMPersona = new Set < String > ();
        
        isRPMPersona.add(Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager);
        Map<Id, Boolean> qLIdintRejectionAllowedMap = isIntegartionRejectionAllowed(new Set<Id>{quoteLine.Id}); 
        
        if((!quoteLine.SBQQ__Quote__r.Pricing_On_Hold_Cb__c) || (currentUser.Core_User_Profile_Name__c == Label.Pricing_Tender_Profiles_Partner)){
            switch on quoteLine.Pricing_Status_Nm__c {
                when 'Draft' {
                    getAvailableUserActionsDraft(actions, quoteLine, userId, allPersona);
                }
                when 'Pending Intel Field Review' {
                    getAvailableUserActionsPIFR(actions, quoteLine, userId, delegateApprover);
                }
                when 'Pending Further Intel Review' {
                    getAvailableUserActionsPFIR(actions, quoteLine, qLIdintRejectionAllowedMap);
                }
                when 'Approved' {  
                    getAvailableUserActionsApproved(actions, quoteLine, isRPMPersona, allPersona);
                }
                when 'Lost' {
                    getAvailableUserActionsLost(actions, quoteLine);
                }
                when 'Won' {
                    getAvailableUserActionsWon(actions, quoteLine);
                }
            }
        }
        return actions;
    }
    
    public static void getAvailableUserActionsDraft(List < string > actions, SBQQ__QuoteLine__c quoteLine, Id userId, Set < String > allPersona){
        Set < String > allPersonaExceptRPMAEITS = getPersonaExcludingSet(new Set < String > {
            Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager,
                Label.Pricing_Tender_PermissionSets_TenderAccountExecutive, Label.Pricing_Tender_Permission_Set_IT_Specialist
                });
        Boolean isReadOnlyUsers = userHasValidPermissionSet(new Set < String > {
            Label.Pricing_Tender_PermissionSets_PricingDivisionalTenderPricingManager,Label.Pricing_Tender_PermissionSets_TenderReadOnly,
                Label.Pricing_Tender_PermissionSets_TenderRebateAnalyst}) ? true : false;   
        if(isRPMUser && quoteLine.SBQQ__Quote__r.SBQQ__Status__c == 'Draft')
        {
            actions.remove(actions.indexOf(Label.Pricing_Tender_QuoteLine_Action_Clone)); 
        }
        if(userHasValidPermissionSet(allPersona)) {
            if(quoteLine.CreatedById == userId || quoteLine.Pricing_Primary_Contact_Nm__c == userId || quoteLine.SBQQ__Quote__r.OwnerId == userId || userHasValidPermissionSet(new Set < String > {
                Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator
                    })) {
                        actions.add(Label.Pricing_Tender_QuoteLine_Action_Delete);
                    }
        }
        if(userHasValidPermissionSet(allPersonaExceptRPMAEITS) && quoteLine.SBQQ__Quote__r.SBQQ__Status__c != 'Draft' && checkSVDActiveStatus(quoteLine.Pricing_Program_Type_Nm__c)) {
            actions.add(Label.Pricing_Tender_QuoteLine_Action_Submit_For_Approval);
        }
        if(!isRPMUser && !isReadOnlyUsers) {
            actions.add(Label.Pricing_Tender_QuoteLine_Action_Edit);
            actions.add(Label.Pricing_Edit_Consumption_Parameters);
        }
    }
    
    public static void getAvailableUserActionsPIFR(List < string > actions, SBQQ__QuoteLine__c quoteLine,Id userId,Id delegateApprover){
        Set<Id> multipleFSEUserIdSet = new Set<Id>();
        Set<Id> qtmIds = new Set<Id>();
        Boolean fseUserPs = userHasValidPermissionSet(new Set < String > {Label.Pricing_Tender_PermissionSets_TenderUser});
        for(ProcessInstanceWorkitem workItem : [SELECT p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId,
                                                p.ProcessInstanceId, p.OriginalActorId, p.Id FROM ProcessInstanceWorkitem p
                                                WHERE p.ProcessInstance.TargetObjectId = : quoteLine.Id AND ProcessInstance.Status = 'Pending']){
                                                    multipleFSEUserIdSet.add(workItem.OriginalActorId);
                                                }
        if(multipleFSEUserIdSet.size() == 0){
            for(Pricing_Quote_Team__c qtm : [SELECT  Pricing_Quote_Team_Member_Id__c FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Id__c =: quoteLine.SBQQ__Quote__C  
                                            AND Pricing_Role_Nm__c =: Label.Pricing_Quote_Team_Role_FSE]){
                qtmIds.add(qtm.Pricing_Quote_Team_Member_Id__c);
            }
        }
        if(fseUserPs){
            if(quoteLine.Pricing_Sales_Rep__c == userId || delegateApprover == userId || multipleFSEUserIdSet.contains(userId) || qtmIds.contains(userId) ) {
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Edit);
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Approve);
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Reject);
                actions.add(Label.Pricing_Edit_Consumption_Parameters);
                if(!quoteLine.Pricing_Change_Request_cb__c && checkSVDActiveStatus(quoteLine.Pricing_Program_Type_Nm__c)){
                    //actions.add(Label.Pricing_Edit_Consumption_Parameters);
                    actions.add(Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM);
                }
            }
        }
        
        if(userHasValidPermissionSet(new Set<String>{Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator,Label.Pricing_Tender_PermissionSets_TenderPartner}) && !quoteLine.Pricing_Change_Request_cb__c && checkSVDActiveStatus(quoteLine.Pricing_Program_Type_Nm__c)){
            actions.add(Label.Pricing_Tender_QuoteLine_Action_Rollback);
        }
        
        if(Label.Pricing_Tender_PriceComp_QuoteLineType.split(',').contains(quoteLine.Pricing_Program_Type_Nm__c) && fseUserPs && quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product){
            actions.add(Label.Pricing_Tender_QuoteLine_Action_Pricecomp);
        }
    }
    
    public static void getAvailableUserActionsPFIR(List < string > actions, SBQQ__QuoteLine__c quoteLine,Map<Id, Boolean> qLIdintRejectionAllowedMap) {
        Set<String> processorQuoteLineTypeSet = new Set<String>(Label.Pricing_Tender_Processors_Quote_Line_Type.split(','));
        Boolean isCPUQuoteLine = false;
        Boolean isRPMandReadOnlyUsers = userHasValidPermissionSet(new Set < String > {
            Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager,Label.Pricing_Tender_PermissionSets_PricingDivisionalTenderPricingManager,
                Label.Pricing_Tender_PermissionSets_TenderReadOnly,Label.Pricing_Tender_PermissionSets_TenderRebateAnalyst}) ? true : false; 
        if(processorQuoteLineTypeSet.contains(quoteLine.Pricing_Program_Type_Nm__c)) {
            isCPUQuoteLine = true;
        }
        if(userHasValidPermissionSet(new Set < String > {Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager})) {
            //No Actions are Available for Integration Status "Pending","InProcess" and Deal Status "Submitted"
            if(quoteLine.Pricing_Integration_Status_Nm__c != Label.Pricing_Tender_MyDeal_Integration_Status_Pending && quoteLine.Pricing_Integration_Status_Nm__c !=  Label.Pricing_Tender_MyDeal_Integration_Status_InProcess &&
               quoteLine.Pricing_Deal_RFQ_Status_Nm__c != Label.Pricing_Tender_MyDeal_RFQ_Status_Submitted) {
                   //Avaiable for All Scenarios
                   actions.add(Label.Pricing_Tender_QuoteLine_Action_Edit);
                   actions.add(Label.Pricing_Edit_Consumption_Parameters);
                   //Recision Actions Available only for Non-Change Request Non Integration QuoteLines
                   if(quoteLine.Pricing_Integration_Status_Nm__c == null) {
                       actions.add(Label.Pricing_Tender_QuoteLine_Action_Reject);
                       // Non Change Request and Non SVD
                       
                       if(!quoteLine.Pricing_Change_Request_cb__c && checkSVDActiveStatus(quoteLine.Pricing_Program_Type_Nm__c) ) {
                           actions.add(Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM);
                           actions.add(Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyField);
                       }
                       
                       if(quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null && String.isNotBlank(quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Deal_RFQ_Id__c)) {
                           actions.add(Label.Pricing_Update_Deal_MD_button_label);
                       }
                       else if( quoteLine.Pricing_Reference_Quote_Line_Nbr__c == null || (quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null && quoteLine.Pricing_Reference_Quote_Line_Nbr__r.SBQQ__ProductName__c != quoteLine.SBQQ__ProductName__c ) ) {
                           actions.add(Label.Pricing_Send_Request_MD_Button_Label);
                       }
                       
                       if(quoteLine.SBQQ__ProductName__c == Label.Pricing_Tender_Write_In_Product && (quoteLine.Pricing_Reference_Quote_Line_Nbr__c == null || (quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null && String.isBlank(quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Deal_RFQ_Id__c)))) {
                           actions.add(Label.Pricing_Tender_QuoteLine_Action_Approve);
                       }
                       
                       if(TriggerHandler.isActive('Pricing_AI') && isCPUQuoteLine && !(String.isNotBlank(quoteLine.Pricing_Deal_RFQ_Id__c)) && quoteLine.Pricing_Reference_Quote_Line_Nbr__c == null) {
                           actions.add(Label.Pricing_GetAI_Button_Label);
                       }
                   }
                   
                   if(quoteLine.Pricing_Integration_Status_Nm__c == Label.Pricing_Tender_MyDeal_Integration_Status_Error 
                      && ((String.isBlank(quoteLine.Pricing_Deal_RFQ_Id__c) && String.isBlank(quoteLine.Pricing_Deal_RFQ_Status_Nm__c)) 
                          || (String.isBlank(quoteLine.Pricing_Deal_RFQ_Status_Nm__c)
                              && quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null))) {
                                  actions.add(Label.Pricing_Tender_QuoteLine_Action_Reject);
                                  
                                  if(quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null && quoteLine.Pricing_Reference_Quote_Line_Nbr__r.SBQQ__ProductName__c == quoteLine.SBQQ__ProductName__c ) {
                                      actions.add(Label.Pricing_Update_Deal_MD_button_label);
                                  }
                                  else {
                                      actions.add(Label.Pricing_Send_Request_MD_Button_Label);
                                      if(quoteLine.SBQQ__ProductName__c == Label.Pricing_Tender_Write_In_Product) {
                                          actions.add(Label.Pricing_Tender_QuoteLine_Action_Approve);
                                      }
                                  }
                                  
                                  if(TriggerHandler.isActive('Pricing_AI') && isCPUQuoteLine && quoteLine.Pricing_Reference_Quote_Line_Nbr__c == null) {
                                      actions.add(Label.Pricing_GetAI_Button_Label);
                                  }
                              }
                   if(quoteLine.Pricing_Deal_RFQ_Status_Nm__c == Label.Pricing_Tender_MyDeal_RFQ_Status_Requested && String.isNotBlank(quoteLine.Pricing_Deal_RFQ_Id__c)) {
                       
                       actions.add(Label.Pricing_Update_Deal_MD_button_label);
                       
                       if(TriggerHandler.isActive('Pricing_AI') && isCPUQuoteLine && quoteLine.Pricing_Reference_Quote_Line_Nbr__c == null) {
                           actions.add(Label.Pricing_GetAI_Button_Label);
                       }
                   }
               }
            if(qLIdintRejectionAllowedMap.get(quoteLine.Id)) {
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Reject);
            }
            if(TriggerHandler.isActive('Pricing_Rollback_Action_Switch') && quoteLine.Pricing_New_Change_Request_cb__c && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && quoteLine.Pricing_Integration_Status_Nm__c ==  Label.Pricing_Tender_MyDeal_Integration_Status_Complete && (quoteLine.Pricing_Deal_RFQ_Status_Nm__c == Label.Pricing_Tender_MyDeal_RFQ_Status_Submitted || quoteLine.Pricing_Deal_RFQ_Status_Nm__c == Label.Pricing_Tender_MyDeal_RFQ_Status_Requested))
            {
                actions.add(Label.Pricing_Tender_QuoteLine_RollBack);
            } 
        }
        if(Label.Pricing_Tender_PriceComp_QuoteLineType.split(',').contains(quoteLine.Pricing_Program_Type_Nm__c)  && isRPMandReadOnlyUsers && quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product) {
            actions.add(Label.Pricing_Tender_QuoteLine_Action_Pricecomp);
        }
        
        if(quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote && userHasValidPermissionSet(new Set < String > {Label.Pricing_Tender_PermissionSets_FinancialIncentivePricingManager})) {
            actions.clear();
            actions.add(Label.Pricing_Tender_QuoteLine_Action_Edit);
            actions.add(Label.Pricing_Tender_QuoteLine_Action_Approve);
            actions.add(Label.Pricing_Tender_QuoteLine_Action_Reject);
        }
        //Added by VB
        Boolean notEligibleForPricing =  eligibleForPricingSupportCheck(quoteLine);
        if(Pricing_CommentsController.isPricingManagerAlpha() && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && quoteLine.Pricing_New_Change_Request_cb__c == false && !notEligibleForPricing) {
            actions.add(Label.Pricing_Get_Price_Button);
        }
    }
    
    public static void getAvailableUserActionsApproved(List < string > actions, SBQQ__QuoteLine__c quoteLine,Set < String > isRPMPersona,Set < String > allPersona){
        Boolean allowOnlyForRPM = allowWonLostForRPM(quoteLine);
        Boolean isRPMandReadOnlyUsers = userHasValidPermissionSet(new Set < String > {
            Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager,Label.Pricing_Tender_PermissionSets_PricingDivisionalTenderPricingManager,
                Label.Pricing_Tender_PermissionSets_TenderReadOnly,Label.Pricing_Tender_PermissionSets_TenderRebateAnalyst}) ? true : false;
        Boolean isFSE_SDMUser = userHasValidPermissionSet(new Set < String > {Label.Pricing_Tender_PermissionSets_TenderUser }) ? true : false;
        if(allowOnlyForRPM){
            if(userHasValidPermissionSet(isRPMPersona)){           //Restrict Won/Loss to RPM for 16 identified Accounts
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Won);
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Lost);
            }
        }else if((userHasValidPermissionSet(allPersona) || userHasValidPermissionSet(new set<String>{Label.Pricing_Tender_PermissionSets_TenderRebateAnalyst})) && quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_Quote_Program){
            actions.add(Label.Pricing_Tender_QuoteLine_Action_Won);
            actions.add(Label.Pricing_Tender_QuoteLine_Action_Lost);
        }
        Set < String > extPersona = new Set < String > {Label.Pricing_Tender_PermissionSets_TenderPartner};
        extPersona.add(Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator);
        extPersona.add(Label.Pricing_Tender_PermissionSets_TenderDrafter);
        if(userHasValidPermissionSet(extPersona)) {
            actions.add(Label.Pricing_Tender_QuoteLine_Action_Request_Change); // OEM 
        }
        if(userHasValidPermissionSet(new Set < String > {
            Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager})) {
                actions.add(Label.Pricing_Tender_Cancel_Action);
                //added By ANushaM for US835690
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Request_Change);
        }

        if(Label.Pricing_Tender_PriceComp_QuoteLineType.split(',').contains(quoteLine.Pricing_Program_Type_Nm__c) && (isRPMandReadOnlyUsers || isFSE_SDMUser)  && quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product){
            actions.add(Label.Pricing_Tender_QuoteLine_Action_Pricecomp);
        }
        
        if(userHasValidPermissionSet(new Set<String> { Label.Pricing_Tender_PermissionSets_FinancialIncentivePricingManager}) && quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote){
            actions.clear();
            actions.add(Label.Pricing_Tender_Cancel_Action);
            if(!(Label.Pricing_Opp_CoreApprovalStatus_ApprovedSubmitted.split(':').contains(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Approval_Status__c))){
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Request_Change);
            }
        }
    }
    
    public static void getAvailableUserActionsLost(List < string > actions,SBQQ__QuoteLine__c quoteLine){
        if(userHasValidPermissionSet(new Set < String > {
            Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager})){
                actions.add(Label.Pricing_Tender_QuoteLine_Action_Approve);                
            }
        if(userHasValidPermissionSet(new Set<String> { Label.Pricing_Tender_PermissionSets_FinancialIncentivePricingManager}) && quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote){
            actions.clear();
        }
    }
    
    public static void getAvailableUserActionsWon(List < string > actions, SBQQ__QuoteLine__c quoteLine){
        Set < String > extPersona = new Set < String > { Label.Pricing_Tender_PermissionSets_TenderPartner };
            Boolean allowOnlyForRPM = allowWonLostForRPM(quoteLine);
        extPersona.add(Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator);
        extPersona.add(Label.Pricing_Tender_PermissionSets_TenderDrafter);
        
        if(userHasValidPermissionSet(extPersona)) { 
            actions.add(Label.Pricing_Tender_QuoteLine_Action_Request_Change);
        }
        
        if(userHasValidPermissionSet(new Set < String > {Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager}))  {
            actions.add(Label.Pricing_Tender_Cancel_Action);
            //added By ANushaM for US835690
            actions.add(Label.Pricing_Tender_QuoteLine_Action_Request_Change);
        }
        
        if(allowOnlyForRPM){
            if(userHasValidPermissionSet(new Set < String > {
                Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager}) && quoteLine.Pricing_Integration_Status_Nm__c == 'Error' && quoteLine.Pricing_Error_Messages__c.contains(Label.Pricing_Tender_MyDeal_Overlap_Error)){
                    actions.add(Label.Pricing_Tender_Sync_Status);
                }
        }else if((userHasValidPermissionSet(new Set < String > {
            Label.Pricing_Tender_PermissionSets_TenderBusinessUserAdmin}) || userHasValidPermissionSet(new Set < String > {
                Label.Pricing_Tender_PermissionSets_TenderRebateAnalyst}) || userHasValidPermissionSet(new Set < String > {
                    Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager}))&&quoteLine.Pricing_Integration_Status_Nm__c == 'Error' && quoteLine.Pricing_Error_Messages__c.contains(Label.Pricing_Tender_MyDeal_Overlap_Error)){
                        actions.add(Label.Pricing_Tender_Sync_Status);
                    }
        //Only Cancel action should be available for FI RPM for Won QuoteLine
        if(userHasValidPermissionSet(new Set<String> { Label.Pricing_Tender_PermissionSets_FinancialIncentivePricingManager}) && quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote){
            actions.clear();
            actions.add(Label.Pricing_Tender_Cancel_Action);
        }
    }
    
    @AuraEnabled
    public static void deleteRecord(Id quoteLineId) {
        if(quoteLineId != null){
            SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Id = : quoteLineId];
            List<Pricing_Quote_Line_Status_Age__c> deleteTPTList = new List<Pricing_Quote_Line_Status_Age__c>();
            deleteTPTList = [SELECT Id,Pricing_TPT_Quote_Line_Number__c from Pricing_Quote_Line_Status_Age__c where 
                             Pricing_TPT_Quote_Line_Number__c =: quoteLineId];
            // Bulkify deletes into a single DML where possible
            List<SObject> toDelete = new List<SObject>();
            if(quoteLine != null) {
                toDelete.add(quoteLine);
            }
            if(!deleteTPTList.isEmpty()){
                toDelete.addAll(deleteTPTList);
            }
            if(!toDelete.isEmpty()){
                delete toDelete;
            }
        }
    }
    
    @AuraEnabled
    public static String cancelRecord(Id quoteLineId, string comments) {
        String retMsg = null;
        String isValidApproval = '';
        Set<Id> qliIds = new Set<Id>();
        try{
            SBQQ__QuoteLine__c quoteLine = [SELECT Id, SBQQ__Quote__c, SBQQ__Quote__r.Name, Pricing_Quote_Program_Nm__c, Pricing_Quote_Line_Number__c, Pricing_Status_Nm__c, Pricing_Rejection_Comments_nm__c,Pricing_Program_Type_Nm__c, Pricing_Approved_End_Date_Dt__c , Pricing_Approved_Start_Date_Dt__c,Pricing_Billing_End_Date_Dt__c,Pricing_Billing_Start_Date_Dt__c  FROM SBQQ__QuoteLine__c WHERE Id = : quoteLineId];
            qliIds.add(quoteLine.Id);
            if(quoteLine != null) {
                isValidApproval = isValidRecordApproval(Label.Pricing_Tender_Cancel_Action, quoteLine);
                system.debug('Entered CancelRecord method isvalidrecordapproval: '+isValidApproval);
                if(isValidApproval != ''){
                    return isValidApproval;
                }else{
                    Boolean cancelationLogic = [Select Active__c from Trigger_Execution__mdt where MasterLabel ='Pricing_Cancelation_Date_Logic_Check' Limit 1].Active__c;
                    system.debug('Entered CancelRecord method else statement: '+cancelationLogic);
                    
                    if(quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote || (cancelationLogic && quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_Quote_Program)){
                        if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved){ // QLI Status = Approved
                            quoteLine.Pricing_Approved_End_Date_Dt__c = quoteLine.Pricing_Approved_End_Date_Dup_Dt__c = quoteLine.Pricing_Approved_Start_Date_Dt__c; // 
                            if(quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_Quote_Program){
                                quoteLine.Pricing_Billing_End_Date_Dt__c  = quoteLine.Pricing_Billing_Start_Date_Dt__c;
                            } 
                        }else if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won  // QLI Status = WON
                                 && quoteLine.Pricing_Approved_End_Date_Dt__c > System.today()){               // Approved End Date in Future
                                     
                                     if(quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_Quote_Program){
                                         if(quoteLine.Pricing_Approved_Start_Date_Dt__c < System.today()){
                                             //If AppStartdate is in Past then AppEndDate = Cancelation date else Nochange for future deals.
                                             quoteLine.Pricing_Approved_End_Date_Dt__c = quoteLine.Pricing_Approved_End_Date_Dup_Dt__c =  System.today();
                                         }
                                         //quoteLine.Pricing_Billing_End_Date_Dt__c = quoteLine.Pricing_Approved_Start_Date_Dt__c < System.today() ? quoteLine.Pricing_Billing_End_Date_Dt__c > System.today()  ?  System.today() : quoteLine.Pricing_Billing_End_Date_Dt__c : quoteLine.Pricing_Billing_Start_Date_Dt__c;
                                         quoteLine.Pricing_Billing_End_Date_Dt__c = quoteLine.Pricing_Approved_Start_Date_Dt__c < System.today() && quoteLine.Pricing_Billing_End_Date_Dt__c > System.today()  ?  System.today() : quoteLine.Pricing_Billing_End_Date_Dt__c;
                                     }
                                     else if(quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote && quoteLine.Pricing_Approved_Start_Date_Dt__c < System.today()){
                                         //If AppStartdate is in Past then AppEndDate = Cancellation date else Nochange for future deals.
                                         quoteLine.Pricing_Approved_End_Date_Dt__c = quoteLine.Pricing_Approved_End_Date_Dup_Dt__c = System.today();
                                     }   
                                 }
                    }
                    
                    quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Cancelled;
                    if (String.isBlank(quoteLine.Pricing_Rejection_Comments_nm__c)) {
                        quoteLine.Pricing_Rejection_Comments_nm__c = comments;
                        quoteLine.Pricing_Cancellation_Date_Dt__c = DateTime.now();
                    }
                    SBQQ.TriggerControl.disable();
                    update quoteLine;
                    SBQQ.TriggerControl.enable();
                    if(quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_Quote_Program){
                        Pricing_EmailUtility.sendEmail(qliIds, 'Pricing_QuoteLineCancelEmailNotification');
                    } 
                    /*else if(quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote){
                        Pricing_EmailUtility.sendEmail(qliIds, 'Pricing_FI_QL_Cancel_Notification');
                    }*/
                }
            }
        }
        catch(Exception e){
            retMsg = Pricing_Tender_Utility.getExceptionMessage(e);
            Pricing_Tender_Utility.logError(e);        
        }
        return retMsg;
    }
    
    private static Set < String > getPersonaExcludingSet(Set < String > excludePermission) {
        Set < String > ps = new Set < String > ();
        ps.add(Label.Pricing_Tender_PermissionSets_TenderUser);
        ps.add(Label.Pricing_Tender_PermissionSets_TenderPartner);
        ps.add(Label.Pricing_Tender_PermissionSets_TenderDrafter);
        ps.add(Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager);
        ps.add(Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator);
        ps.add(Label.Pricing_Tender_PermissionSets_TenderAccountExecutive);
        ps.add(Label.Pricing_Tender_Permission_Set_IT_Specialist);
        ps.add(Label.Pricing_Tender_PermissionSets_TenderDrafterLimited);
        ps.removeAll(excludePermission);
        return ps;
    }
    
    private static Boolean userHasValidPermissionSet(Set < string > permissionSets) {
        for(PermissionSetAssignment psa: currentUser.PermissionSetAssignments){
            if(permissionSets.contains(psa.PermissionSet.Name)){
                return true;
            }
        }
        return false;
    }
    
    //Method to check if Won/Loss has to be aloowed only for RPM
    public static Boolean allowWonLostForRPM(SBQQ__QuoteLine__c quoteLine){
        Boolean allowOnlyFoRPM = false;
        integer count = [SELECT count() FROM Pricing_QuoteLine_WonLoss_Restriction__mdt
                         WHERE Pricing_Account_Id__c = :quoteLine.SBQQ__Quote__r.SBQQ__Account__c AND Pricing_IsActive_Ind__c=true];
        if(count > 0){
            allowOnlyFoRPM = true;
        }else{
            allowOnlyFoRPM = false;
        }       
        return allowOnlyFoRPM;
    }
    
    @AuraEnabled
    public static boolean isPartnerUser() {
        Set < String > extPersona = new Set < String > {Label.Pricing_Tender_PermissionSets_TenderPartner,Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator,Label.Pricing_Tender_PermissionSets_TenderDrafter,Label.Pricing_Tender_PermissionSets_TenderDrafterLimited}; 
        return userHasValidPermissionSet(extPersona);
    }
    
    @AuraEnabled
    public static String recordApproval(Id quoteLineId, string comments, string status, SBQQ__QuoteLine__c lineItem, String revisionComment, Boolean showRevisionFields,String rejectionReason, String lostReason){
        String retMsg = null;
        try {
            String currentAction = status;
            Boolean isFieldReviewQL = false;
            Boolean isOEMField = isOEMField();
            String isValidApproval = '';
            List<Id> quoteLineIds = new List<Id>();
            SBQQ__QuoteLine__c quoteLine = [SELECT Id, Name, Pricing_Status_Nm__c,Pricing_pm_approval_comments_nm__c, Pricing_Rejection_Comments_nm__c,SBQQ__Quote__c,Pricing_Quote_Line_Number__c,Pricing_Integration_Status_Nm__c,Pricing_Error_Messages__c,Pricing_Payable_Quantity__c,Pricing_Approved_Unit_Qty__c,
                                            Pricing_Sales_Rep_Approver__c, Pricing_FSE_Recommended_Price_Nm__c, Pricing_Reference_Quote_Line_Nbr__c,Pricing_Last_Submitted_By_Id__c, Pricing_Rejection_Reason__c, Pricing_Lost_Reason_Nm__c,Pricing_EndCustomer_Nm__c,SBQQ__Quote__r.SBQQ__Account__c,Pricing_New_Change_Request_cb__c,
                                            Pricing_Change_Request_cb__c, Pricing_Ready_for_Review_cb__c,Customer_Revision_Count_Cnt__c,Pricing_Billing_Start_Date_Dt__c,Field_Revision_Count_Cnt__c, SBQQ__Quote__r.SBQQ__PrimaryContact__r.Id,Pricing_Sales_Rep_Approver__r.Id,SBQQ__Quote__r.Id,SBQQ__Quote__r.Name,Pricing_Won_Lost_Comments_Txt__c,pricing_TDP__c ,Pricing_Additional_Comments_Txt__c,Pricing_Quote_Line_Won_Lost_Status__c,
                                            Pricing_Program_Type_Nm__c,Pricing_Server_Deal_Type_Nm__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c From SBQQ__QuoteLine__c WHERE Id = : quoteLineId
                                           ]; 
            Map < string, string > statusMapping = new Map < string, string > ();
            statusMapping.put(Label.Pricing_Tender_QuoteLine_Action_Approve, Label.Pricing_Tender_QuoteLine_Status_Approved);
            statusMapping.put(Label.Pricing_Tender_QuoteLine_Action_Reject, Label.Pricing_Tender_QuoteLine_Status_Rejected);
            statusMapping.put(Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyField, Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview);
            statusMapping.put(Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM, Label.Pricing_Tender_QuoteLine_Status_Draft);
            statusMapping.put(Label.Pricing_Tender_QuoteLine_Action_Rollback, Label.Pricing_Tender_QuoteLine_Status_Draft);
            Map<Id,Set<Id>> quoteQTMMap = new Map<Id,Set<Id>>();
            if(quoteLine != null) {
                String approvalAction = null;
                List < SBQQ__QuoteLine__c > quoteLineList = new List < SBQQ__QuoteLine__c > ();
                isValidApproval = isValidRecordApproval(currentAction, quoteLine);
                if(isValidApproval != ''){
                    return isValidApproval;
                }
                else if((isOEMField || status == Label.Pricing_Tender_QuoteLine_Action_Rollback) && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview) {
                    recordApprovalPIFR(quoteLine, approvalAction, showRevisionFields, quoteLineList, status, lineItem, comments, statusMapping,revisionComment,rejectionReason, lostReason ); 
                }
                else{
                    quoteLineList.add(quoteLine);
                    //Set the PM Approval Comments when RPM is performing Actions
                    isFieldReviewQL = recordApprovalStatusCheckAgainstPIFR(quoteLine, showRevisionFields, quoteLineList, status, comments,revisionComment,quoteQTMMap,retMsg,rejectionReason, lostReason);
                    recordApprovalChangeReq(quoteLine, quoteLineList, status, statusMapping);
                }
                if(!quoteLineList.isEmpty()) {
                    SBQQ.TriggerControl.disable();
                    update quoteLineList;
                    SBQQ.TriggerControl.enable();
                }
                if(quoteLine.Pricing_Program_Type_Nm__c == 'Financial Incentive' && (status == 'Approve' || status == 'Reject')){
                    quoteLineIds.add(quoteLine.Id);
                    //Pricing_FinancialIncentive_BusinessLogic.populateQLNumberOnOppLineItem(quoteLine.id,null,status);
                    Pricing_FinancialIncentive_BusinessLogic.populateQLNumberOnOppLineItemBulk(quoteLineIds,status); 
                }
                //Create Approval records for only valid FSE on field revision
                if(isFieldReviewQL){
                    Pricing_Publish_Quote.publishQuoteLinesToMultipleFSE(new Set<Id>{quoteLine.Id});
                }
            }
        }
        catch(Exception e){
            retryCounter++;
            if(retryCounter<=Integer.valueOf(Label.Pricing_Retry_Record_Approval_Counter_Label)){
                retMsg = recordApprovalRetry(quoteLineId,comments,status, lineItem,  revisionComment,  showRevisionFields, rejectionReason, lostReason);
            }else {
                retMsg = Pricing_Tender_Utility.getExceptionMessage(e);
                Pricing_Tender_Utility.logError(e); 
            }   
        }
        finally {
            SBQQ.TriggerControl.enable();
        }
        return retMsg;
    }
    
    public static String recordApprovalRetry(Id quoteLineId, string comments, string status, SBQQ__QuoteLine__c lineItem, String revisionComment, Boolean showRevisionFields, String rejectionReason, String lostReason){
        return recordApproval(quoteLineId,comments,status, lineItem,  revisionComment,  showRevisionFields, rejectionReason, lostReason);
    }
    
    public static void recordApprovalPIFR(SBQQ__QuoteLine__c quoteLine, String approvalAction,Boolean showRevisionFields,List < SBQQ__QuoteLine__c > quoteLineList, String status,SBQQ__QuoteLine__c lineItem,string comments,Map < string, string > statusMapping,String revisionComment, String rejectionReason, String lostReason){
        if(status != Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM && status != Label.Pricing_Tender_QuoteLine_Action_Rollback){
            quoteLine.Pricing_FSE_Recommended_Price_Nm__c = lineItem.Pricing_FSE_Recommended_Price_Nm__c;
            quoteLine.Pricing_Sales_Rep_Approver__c = UserInfo.getUserId();
            quoteLine.Pricing_SDM_Fast_Track__c = lineItem.Pricing_SDM_Fast_Track__c;
            
            if(String.isBlank(rejectionReason)){
                quoteLine.Pricing_pm_approval_comments_nm__c  = comments == '' ? quoteLine.Pricing_pm_approval_comments_nm__c : comments;
            }else{
                quoteLine.Pricing_Rejection_Comments_nm__c = comments == '' ? quoteLine.Pricing_Rejection_Comments_nm__c : comments;
                quoteLine.Pricing_pm_approval_comments_nm__c ='';
            }
            
            SBQQ.TriggerControl.disable();
            update quoteLine;
            SBQQ.TriggerControl.enable();
        }
        // Revision required by OEM Reject the Approval Process and set the Status to Draft
        if(status == Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM) {
            approvalAction = Label.Pricing_Tender_QuoteLine_Action_Reject;
            quoteLine.Pricing_Status_Nm__c = statusMapping.get(status);
            quoteLine.Pricing_Ready_for_Review_cb__c = true;
            //TPT
            quoteLine.Customer_Revision_Count_Cnt__c = (quoteLine.Customer_Revision_Count_Cnt__c == null) ? 1 :quoteLine.Customer_Revision_Count_Cnt__c + 1;
            //TPT
            quoteLineList.add(quoteLine);
            chatterPostCreation(revisionComment, quoteLine, false, showRevisionFields,false);
        } else if(status == Label.Pricing_Tender_QuoteLine_Action_Reject) {
            //If Rejected then Reject the Approval Process and set the status to Rejected
            approvalAction = Label.Pricing_Tender_QuoteLine_Action_Reject;
            quoteLine.Pricing_Status_Nm__c = statusMapping.get(status);
            quoteLine.Pricing_Change_Request_cb__c = false;
            quoteLine.Pricing_Rejection_Reason__c = rejectionReason;
            quoteLineList.add(quoteLine); 
        } else if(status == Label.Pricing_Tender_QuoteLine_Action_Rollback) {
            QuoteLineBusinessLogic.isOEMRecall = true;
            approvalAction = Label.Pricing_Tender_QuoteLine_Action_Reject;
            quoteLine.Pricing_Status_Nm__c = statusMapping.get(status);
            quoteLine.Pricing_Ready_for_Review_cb__c = true;
            quoteLine.Customer_Revision_Count_Cnt__c = (quoteLine.Customer_Revision_Count_Cnt__c == null) ? 1 :quoteLine.Customer_Revision_Count_Cnt__c + 1;
            quoteLineList.add(quoteLine);
        } else {
            //If Approved then Approve the Approval Process(Approval Process automatically sets the status to Approved)
            approvalAction = status;
            Pricing_Publish_Quote.isApproveWithoutApprovalRec = true;
        }
        if(!quoteLineList.isEmpty()) {
            update quoteLineList;
        }
        
        //Approval.ProcessResult result = Approval.process(req);
        Pricing_Publish_Quote.setFSEActionOnQuoteLine(new Set<Id>{quoteLine.Id},approvalAction,comments,false);
    }
    
    public static Boolean recordApprovalStatusCheckAgainstPIFR(SBQQ__QuoteLine__c quoteLine,Boolean showRevisionFields,List < SBQQ__QuoteLine__c > quoteLineList, String status,string comments,string revisionComment,Map<Id,Set<Id>> quoteQTMMap,string retMsg, String rejectionReason, String lostReason){
        Boolean isFieldReview = false;
        if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview ) {
            
            if(status == Label.Pricing_Tender_QuoteLine_Action_Reject) {
                quoteLine.Pricing_Rejection_Comments_nm__c = comments == '' ? quoteLine.Pricing_Rejection_Comments_nm__c : comments;
                quoteLine.Pricing_pm_approval_comments_nm__c  ='';
            }else{
                quoteLine.Pricing_pm_approval_comments_nm__c  = comments;
            }
            
            if(status == Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM) {
                quoteLine.Pricing_Ready_for_Review_cb__c = true;
                //TPT
                quoteLine.Pricing_Meet_Comp_Price_Amt__c = isRPMUser && QuoteLineBusinessLogic.checkforAuotoPopLogic(quoteLine, quoteLine.Pricing_Server_Deal_Type_Nm__c, quoteLine.Pricing_EndCustomer_Nm__c) ? null 
                    : quoteLine.Pricing_Meet_Comp_Price_Amt__c;
                
                
                //Blank out Billing Start date if QLI comes under AI Category
                quoteLine.Pricing_Billing_Start_Date_Dt__c = isRPMUser && QuoteLineBusinessLogic.checkforAuotoPopLogic(quoteLine, quoteLine.Pricing_Server_Deal_Type_Nm__c, quoteLine.Pricing_EndCustomer_Nm__c) ? null 
                    : quoteLine.Pricing_Billing_Start_Date_Dt__c;
                quoteLine.Customer_Revision_Count_Cnt__c = (quoteLine.Customer_Revision_Count_Cnt__c == null) ? 1 : quoteLine.Customer_Revision_Count_Cnt__c + 1;
                //TPT
                chatterPostCreation(revisionComment, quoteLine, false, showRevisionFields, false);
            }
            //TPT
            if(status == Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyField){
                //Validate Quote Team's FSEs on field revision
                quoteQTMMap = Pricing_Publish_Quote.validateQtmFse(new Set<Id>{quoteLine.SBQQ__Quote__c});
                if(quoteQTMMap.size() > 0){
                    isFieldReview = true;
                    quoteLine.Pricing_Meet_Comp_Price_Amt__c = isRPMUser && QuoteLineBusinessLogic.checkforAuotoPopLogic(quoteLine, quoteLine.Pricing_Server_Deal_Type_Nm__c, quoteLine.Pricing_EndCustomer_Nm__c) ? null 
                        : quoteLine.Pricing_Meet_Comp_Price_Amt__c;
                    
                    
                    //Blank out Billing Start date if QLI comes under AI Category
                    quoteLine.Pricing_Billing_Start_Date_Dt__c = isRPMUser && QuoteLineBusinessLogic.checkforAuotoPopLogic(quoteLine, quoteLine.Pricing_Server_Deal_Type_Nm__c, quoteLine.Pricing_EndCustomer_Nm__c) ? null 
                        : quoteLine.Pricing_Billing_Start_Date_Dt__c;
                    
                    quoteLine.Field_Revision_Count_Cnt__c = (quoteLine.Field_Revision_Count_Cnt__c == null) ? 1: quoteLine.Field_Revision_Count_Cnt__c + 1;
                }else{
                    isFieldReview = false;
                    quoteLineList.remove(quoteLineList.indexOf(quoteLine));
                    retMsg = Label.Pricing_Tender_Quote_Sales_Rep_Error_Message;
                }
                chatterPostCreation(revisionComment, quoteLine, true, showRevisionFields, false);
            }
            //TPT
        }
        
        quoteLine.Pricing_pm_approval_comments_nm__c  = quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Action_Lost && status == Label.Pricing_Tender_QuoteLine_Action_Approve ? comments : quoteLine.Pricing_pm_approval_comments_nm__c 	;
        quoteLine.Pricing_Won_Lost_Comments_Txt__c = status == Label.Pricing_Tender_QuoteLine_Action_Won || status == Label.Pricing_Tender_QuoteLine_Action_Lost ? comments : status == Label.Pricing_Tender_QuoteLine_Action_Approve ? '' : quoteLine.Pricing_Won_Lost_Comments_Txt__c;
        quoteLine.Pricing_Rejection_Reason__c  = status == Label.Pricing_Tender_QuoteLine_Action_Reject ? rejectionReason : '' ;
        quoteLine.Pricing_Lost_Reason_Nm__c  = status == Label.Pricing_Tender_QuoteLine_Action_Lost ? lostReason : '' ;
        quoteLine.Pricing_Quote_Line_Won_Lost_Status__c = status == Label.Pricing_Tender_QuoteLine_Action_Won || status == Label.Pricing_Tender_QuoteLine_Action_Lost ? quoteLine.Pricing_Quote_Line_Won_Lost_Status__c : '' ;
        quoteLine.Pricing_Error_Messages__c = status == Label.Pricing_Tender_QuoteLine_Action_Approve && quoteLine.Pricing_Integration_Status_Nm__c == Label.Pricing_Tender_MyDeal_Integration_Status_Error ? null : quoteLine.Pricing_Error_Messages__c;
        quoteLine.Pricing_Integration_Status_Nm__c = status == Label.Pricing_Tender_QuoteLine_Action_Approve && quoteLine.Pricing_Integration_Status_Nm__c == Label.Pricing_Tender_MyDeal_Integration_Status_Error ? null : quoteLine.Pricing_Integration_Status_Nm__c;
        return isFieldReview;
    }
    
    public static void recordApprovalChangeReq(SBQQ__QuoteLine__c quoteLine,List < SBQQ__QuoteLine__c > quoteLineList, String status, Map < string, string > statusMapping){
        Boolean statusOverrideForWonCR = false;
        List<String> statusList = new List<String>();
        statusList.add(Label.Pricing_Tender_QuoteLine_Action_Lost);
        statusList.add(Label.Pricing_Tender_QuoteLine_Action_Reject);
        statusList.add(Label.Pricing_Tender_QuoteLine_Action_Approve);
        statusList.add(Label.Pricing_Tender_QuoteLine_Action_Won);
        if(quoteLine.Pricing_Change_Request_cb__c && quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null && statusList.contains(status)) {
            if(status == Label.Pricing_Tender_QuoteLine_Action_Approve || status == Label.Pricing_Tender_QuoteLine_Action_Reject){
                parentQuoteLine = [SELECT ID, Pricing_Status_Nm__c,Pricing_Won_Lost_Comments_Txt__c,Pricing_Approved_Unit_Qty__c from SBQQ__QuoteLine__c where id = : quoteLine.Pricing_Reference_Quote_Line_Nbr__c];
            }
            //Check if Change Request Quote Line is getting Approved then make the Parent as Revised
            if(status == Label.Pricing_Tender_QuoteLine_Action_Approve) {
                if(parentQuoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Action_Won) {
                    quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Action_Won;
                    quoteLine.Pricing_Won_Lost_Comments_Txt__c = parentQuoteLine.Pricing_Won_Lost_Comments_Txt__c;
                    statusOverrideForWonCR = true;
                }
                parentQuoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Revised;
                quoteLineList.add(parentQuoteLine);
            }
            quoteLine.Pricing_Change_Request_cb__c = false;
        }
        if(!statusOverrideForWonCR) {
            //Map the Actions with Appropriate QuoteLine Status Value.
            quoteLine.Pricing_Status_Nm__c = statusMapping.containsKey(status) ? statusMapping.get(status) : status;
            if(status == Label.Pricing_Tender_QuoteLine_Action_Won && !Pricing_QuoteLineCloneController.restrictedAccountMethod(quoteLine.SBQQ__Quote__r.SBQQ__Account__c,'') && quoteLine.Pricing_New_Change_Request_cb__c == false){
                quoteLine.Pricing_Payable_Quantity__c = quoteLine.Pricing_Approved_Unit_Qty__c;
            }
        }
    }
    
    public static void chatterPostCreation(String revisionComment, SBQQ__QuoteLine__c quoteline, Boolean isFieldRevision, Boolean showRevisionFields ,Boolean isDPMRevision) {
        Set<Id> submitterIds = new Set<Id>();
        if(showRevisionFields){
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            //mention primary contact
            ConnectApi.MentionSegmentInput mentionSegmentInput;
            if(!isDPMRevision){
                List<User> primaryContact = [Select Id, ContactId from User where ContactId = :quoteline.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Id];
                if(!isFieldRevision){
                    if(primaryContact.size() > 0){
                        submitterIds.add(primaryContact[0].Id);
                    }     
                    submitterIds.add(quoteline.Pricing_Last_Submitted_By_Id__c);  
                    if(submitterIds.size() > 0){
                        for(Id submitterId: submitterIds){
                            mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                            mentionSegmentInput.id = submitterId;
                            messageBodyInput.messageSegments.add(mentionSegmentInput);
                            
                            textSegmentInput = new ConnectApi.TextSegmentInput(); 
                            textSegmentInput.text = '  ';
                            messageBodyInput.messageSegments.add(textSegmentInput);
                        }
                    }        
                    
                    //visible for all users with access
                    feedItemInput.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;
                }else{
                    //mention sales rep approver
                    if(quoteline.Pricing_Sales_Rep_Approver__r.Id != null){
                        
                        mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                        mentionSegmentInput.id = quoteline.Pricing_Sales_Rep_Approver__r.Id;
                        messageBodyInput.messageSegments.add(mentionSegmentInput);
                        
                        textSegmentInput = new ConnectApi.TextSegmentInput(); 
                        textSegmentInput.text = '  ';
                        messageBodyInput.messageSegments.add(textSegmentInput);
                    }
                }
            }
            
            ConnectApi.EntityLinkSegmentInput entityLinkSegmentInputOpportunity = new ConnectApi.EntityLinkSegmentInput();
            entityLinkSegmentInputOpportunity.entityId = quoteline.SBQQ__Quote__r.Id;  
            messageBodyInput.messageSegments.add(entityLinkSegmentInputOpportunity);
            
            textSegmentInput = new ConnectApi.TextSegmentInput(); 
            textSegmentInput.text = '\nQuote Line Number: '+quoteline.Pricing_Quote_Line_Number__c;
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            // post body
            textSegmentInput = new ConnectApi.TextSegmentInput();
            String postBody = isDPMRevision ? 'DPM Revision Comments : '+revisionComment : revisionComment;
            textSegmentInput.text = '\n'+postBody.stripHtmlTags();
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            feedItemInput.body = messageBodyInput;
            
            
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = quoteline.SBQQ__Quote__r.Id;
            //post the chatter
            if(!Test.isRunningTest()){
                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
            }            
        }
    }
    
    // Get the document Id from the name
    @AuraEnabled
    public static Id getDocumentId(string name) {
        List < Document > document = [SELECT Id FROM Document where Name = : name LIMIT 1];
        return document.isEmpty() ? null : document[0].Id;
    }
    
    @AuraEnabled
    public Static String insertOutbound(Id parentId,String action) 
    {
        Map<Id,String> quoteLineIdToActionMap = new Map<Id,String>();
        Map<Id,String> quoteLineIdToErrorMap = new Map<Id,String>();
        Map<Id,SBQQ__QuoteLine__c> quoteLineMap;
        Map<Id,String> qlIdToRuleIdRuleNameMap = new Map<Id,String>();
        String overLapDealQLErrMsg;
        String qlStatusMsg;
        quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,
                                                       SBQQ__Quote__r.Name, Pricing_EndCustomer_Nm__c, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,
                                                       Pricing_Reference_Quote_Line_Nbr__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,
                                                       SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,
                                                       Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Program_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,
                                                       Pricing_Manager__r.Core_WWID__c,SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_Business_Party_Id__c,SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c,
                                                       Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,SBQQ__Product__r.Core_Item_Id__c,
                                                       Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,Pricing_Workload_Nm__c,Pricing_New_Change_Request_cb__c,
                                                       Pricing_Meet_Comp_Price_Amt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                                       Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Project_Nm__c,Pricing_Approved_Unit_Qty__c,Pricing_Payable_Quantity__c,Pricing_Deal_RFQ_Status_Nm__c,Pricing_Consumption_Segment__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Consumption_Segment__c,
                                                       Pricing_Quote_Line_Number__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c,Pricing_Market_Segment_values_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_ECAP_Price_Amt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Unit_Qty__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c,
                                                       Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Billing_Start_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Billing_End_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Consumption_Platform__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Consumption_Platform__c,Pricing_Consumption_Sale_Geo__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Country__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Consumption_Country__c,Pricing_Consumption_Region__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Consumption_Region__c,
                                                       SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,SBQQ__Product__r.Core_Family_Nm__c,SBQQ__Product__r.Core_Forecast_Product_Name__c,SBQQ__Product__r.Core_Processor_Number_Nm__c,Pricing_Product_Nm__r.Name,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,
                                                       Pricing_Additional_T_C_s_Txt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Deal_Description__c,Pricing_Additional_RPM_Notify_Recipients__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Additional_RPM_Notify_Recipients__c,Pricing_Competetor_Product__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Name,
                                                       SBQQ__Quote__r.Pricing_End_Customer__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__c,SBQQ__Quote__r.Pricing_End_Customer__c,SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c,
                                                       SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c,SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c,SBQQ__Quote__r.Pricing_End_Customer_Name__c,Pricing_Program_Type_Nm__c,
                                                       SBQQ__Quote__r.Pricing_Is_Sanctioned__c,Pricing_Account_Division_Nm__c,Pricing_Comp_Product_Txt__c,Pricing_Performance_Metric_Nm__c,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,Pricing_SDM_Fast_Track__c,(SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,
                                                                                                                                                                                                                                                                                               Pricing_Performance_Metric_Nm__c FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) FROM SBQQ__QuoteLine__c WHERE 
                                                       Id IN : (new Set<Id>{parentId})]); 
        Pricing_IntegrationSFDCToPricingSystems integrationSystem =  new Pricing_IntegrationSFDCToPricingSystems();
        quoteLineIdToErrorMap.putAll(integrationSystem.validationMethod(quoteLineMap.values()));
        
        if(quoteLineIdToErrorMap.containsKey(parentId) && quoteLineIdToErrorMap.get(parentId) == 'Success'){
            if (TriggerHandler.isActive('Pricing_OverLap_Deal_QL_Switch') && String.isBlank(quoteLineMap.get(parentId).Pricing_Other_Product_Nm__c)){
                overLapDealQLErrMsg = isOverLapDealQL(quoteLineMap,parentId);
            }
            if(String.isNotBlank(overLapDealQLErrMsg)){
                qlStatusMsg = overLapDealQLErrMsg;
            }
            else {
                quoteLineIdToActionMap.put(parentId,action);
                User loggedInUser = [SELECT Id,Name,Core_WWID__c from User where Id =: userInfo.getUserId()];
                quoteLineIdToErrorMap = Pricing_IntegrationSFDCToPricingSystems.insertQuoteOutBoundMessage(quoteLineIdToActionMap,quoteLineMap,loggedInUser.Core_WWID__c,true,qlIdToRuleIdRuleNameMap);
                qlStatusMsg = quoteLineIdToErrorMap.get(parentId);
            }
            return qlStatusMsg;
        } else{
            return quoteLineIdToErrorMap.get(parentId);
        }
    }
    
    /*Method written to prevent RPM from creating/updating a Deal for a Quote Line which belongs to the 
same Account, End Customer, Product, Project and has a partial overlap or exact match as the Approved Start 
and Approved End Date of the existing Quote Lines of a Quote*/
    public static String isOverLapDealQL(Map<Id,SBQQ__QuoteLine__c> quoteLineMap,Id parentId){
        String overLapDealMsg;
        List<String> overLapQLNums = new List<String>();
        /*Query which retrieves the overlapping quote lines belonging to the same Account, Product, Project and has a 
partial overlap or exact match as the Approved Start and Approved End Date of the existing Quote Lines of a Quote*/
        List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id, Pricing_Quote_Line_Number__c, SBQQ__Quote__r.Pricing_Customer_Nm__c, SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name, SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__c, SBQQ__Quote__r.Pricing_End_Customer__r.Name,
                                                  Pricing_Consumption_Platform__c,Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Country__c,Pricing_Consumption_Region__c,Pricing_Consumption_Segment__c FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__r.SBQQ__Account__c =: quoteLineMap.get(parentId).SBQQ__Quote__r.SBQQ__Account__c 
                                                  AND Id !=: quoteLineMap.get(parentId).Id  
                                                  AND Pricing_Project_Nm__c =: (quoteLineMap.get(parentId).Pricing_Project_Nm__c).trim() 
                                                  AND Pricing_Product_Nm__r.Name =: (quoteLineMap.get(parentId).Pricing_Product_Nm__r.Name).trim() 
                                                  AND ((Pricing_Approved_Start_Date_Dt__c <= :quoteLineMap.get(parentId).Pricing_Approved_Start_Date_Dt__c AND Pricing_Approved_End_Date_Dt__c >= :quoteLineMap.get(parentId).Pricing_Approved_Start_Date_Dt__c) OR
                                                       (Pricing_Approved_Start_Date_Dt__c <= :quoteLineMap.get(parentId).Pricing_Approved_End_Date_Dt__c AND Pricing_Approved_End_Date_Dt__c >= :quoteLineMap.get(parentId).Pricing_Approved_End_Date_Dt__c) OR 
                                                       (Pricing_Approved_Start_Date_Dt__c >= :quoteLineMap.get(parentId).Pricing_Approved_Start_Date_Dt__c AND Pricing_Approved_End_Date_Dt__c <= :quoteLineMap.get(parentId).Pricing_Approved_End_Date_Dt__c)) 
                                                  AND Pricing_Quote_Line_Number__c !=: quoteLineMap.get(parentId).Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c 
                                                  AND (Pricing_Deal_RFQ_Id__c != null OR Pricing_Integration_Status_Nm__c =: Label.Pricing_Tender_MyDeal_Integration_Status_Pending) 
                                                  AND Pricing_Status_Nm__c IN : Label.Pricing_QL_Overlap_Deal_Statuses_Label.split(',')];
        
        for(SBQQ__QuoteLine__c oQL: quoteLineList){
            /*Condition to check the Unified End Customer/End Customer/Write in End Customer against the Unified Global End 
Customer lookup field or the End Customer lookup field or the Write In End Customer text field. 
If a match is found, the overlapping QL numbers are added to the list and then concatenated with the error message 
to be shown on the UI*/
            Boolean isEndCustomerOverlap = false;
            if((quoteLineMap.get(parentId).SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c == true && (oQL.SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name == quoteLineMap.get(parentId).SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name || 
                                                                                                   oQL.SBQQ__Quote__r.Pricing_End_Customer__r.Name == quoteLineMap.get(parentId).SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name || 
                                                                                                   oQL.SBQQ__Quote__r.Pricing_Customer_Nm__c == quoteLineMap.get(parentId).SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name)) || 
               (quoteLineMap.get(parentId).SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c == false && (oQL.SBQQ__Quote__r.Pricing_End_Customer__r.Name == quoteLineMap.get(parentId).SBQQ__Quote__r.Pricing_End_Customer_Name__c || 
                                                                                                    oQL.SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name == quoteLineMap.get(parentId).SBQQ__Quote__r.Pricing_End_Customer_Name__c || 
                                                                                                    oQL.SBQQ__Quote__r.Pricing_Customer_Nm__c == quoteLineMap.get(parentId).SBQQ__Quote__r.Pricing_End_Customer_Name__c))){
                                                                                                        isEndCustomerOverlap = true;
                                                                                                        //overLapQLNums.add(oQL.Pricing_Quote_Line_Number__c);
                                                                                                    }
            
            if(isEndCustomerOverlap) {
                
                Boolean isConsumptionOverlap = Pricing_QuoteLine_BulkDealController.consumptionOverlap(oQL, quoteLineMap.get(parentId));
                
                if(isConsumptionOverlap) {
                    overLapQLNums.add(oQL.Pricing_Quote_Line_Number__c);
                }
            }
        }
        if(overLapQLNums.size() > 0){
            overLapDealMsg = Label.Pricing_OverlapDeal_Error_Message + ' ' + overLapQLNums;
        }
        return overLapDealMsg;
    }
    
    //Method to delete the related records(Document share, TPT, Comments) when is quote is delete
    @AuraEnabled
    public static Boolean deleteIQRQuote(Id quoteId){
        Id currentUserid = userinfo.getUserId();
        Boolean deletable = false;
        List<Pricing_Comments__c> comList = new List<Pricing_Comments__c>();
        List<Pricing_Document__c> documentShareList = new List<Pricing_Document__c>();
        List<Pricing_Quote_Line_Status_Age__c> pricingTPTList = new List<Pricing_Quote_Line_Status_Age__c>();
        List<Pricing_Quote_Team__c> quoteTeamList = new List<Pricing_Quote_Team__c>();
        SBQQ__Quote__c quote = [SELECT id,CreatedbyId,SBQQ__PrimaryContact__c,OwnerId from SBQQ__Quote__c where Id =:quoteId];
        integer count = [SELECT count() FROM PermissionSetAssignment
                         WHERE AssigneeId = : Userinfo.getUserId() AND PermissionSet.Name =:Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator];
        if(quoteId != null){
            if(quote.CreatedbyId == currentUserid || quote.OwnerId == currentUserid || count > 0){
                deletable = true;
                comList = [SELECT id,Pricing_Quote__c FROM Pricing_Comments__c where Pricing_Quote__c =: quoteId];
                documentShareList = [SELECT id, Pricing_Quote_Id__c FROM Pricing_Document__c where Pricing_Quote_Id__c =: quoteId];
                pricingTPTList = [SELECT id FROM Pricing_Quote_Line_Status_Age__c where Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__c =: quoteId];
                quoteTeamList = [SELECT id, Pricing_Quote_Id__c FROM Pricing_Quote_Team__c where Pricing_Quote_Id__c =:quoteId];
                if(!comList.isEmpty()){
                    delete comList;
                }
                if(!documentShareList.isEmpty()){
                    delete documentShareList;
                }
                if(!pricingTPTList.isEmpty()){
                    delete pricingTPTList;
                }
                if(!quoteTeamList.isEmpty()){
                    delete quoteTeamList;
                }
                delete quote;    
            } else{
                deletable = false;
            }
        }
        return deletable;  
    }
    
    //Method to check if rejection is allowed after integration
    public static Map<Id, Boolean> isIntegartionRejectionAllowed(set<Id> quoteLineIdSet) {
        Map<Id, Boolean> validQlIdToIsIntegrationRejectMap = new Map<Id, Boolean>();
        for(SBQQ__QuoteLine__c quoteLine: [SELECT SBQQ__ProductName__c,Pricing_Integration_Status_Nm__c,Pricing_Reference_Quote_Line_Nbr__c,
                                           Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c FROM SBQQ__QuoteLine__c WHERE Id IN: quoteLineIdSet]) {
                                               if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) {
                                                   if(quoteLine.Pricing_Integration_Status_Nm__c == Label.Pricing_Tender_MyDeal_Integration_Status_Complete 
                                                      && quoteLine.Pricing_Reference_Quote_Line_Nbr__c == null) {
                                                          validQlIdToIsIntegrationRejectMap.put(quoteLine.Id , true);
                                                      } 
                                                   else {
                                                       validQlIdToIsIntegrationRejectMap.put(quoteLine.Id , false);
                                                   }
                                               }                                 
                                           }
        return validQlIdToIsIntegrationRejectMap;
    }
    
    //Method to restrict won through bulk list view if QL is not unified and country is in REVIEWWIP or country is blocked
    public static Map<Id,String> isNotUnifiedQuoteLineBulk(Set<Id> quoteLineIdSet) {
        Map<Id, String> quoteLineIdMsgMap = new Map<Id, String>();
        List<SBQQ__QuoteLine__c> nonWriteInQLList = [SELECT Id, SBQQ__Product__r.Name, SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c, SBQQ__Quote__r.Pricing_Is_Sanctioned__c, 
                                                     SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c, Pricing_Quote_Line_Number__c, Pricing_Deal_RFQ_Id__c FROM SBQQ__QuoteLine__c 
                                                     WHERE Pricing_Deal_RFQ_Id__c != null AND Id IN: quoteLineIdSet];
        
        
        try {
            if(nonWriteInQLList.size() > 0) {
                for(SBQQ__QuoteLine__c quoteLine : nonWriteInQLList) {
                    if(!quoteLineIdMsgMap.containsKey(quoteLine.Id)) {
                        if(quoteLine.SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c == false) {
                            quoteLineIdMsgMap.put(quoteLine.Id, Label.Pricing_Tender_Not_Unified_Error);
                        } else if(TriggerHandler.isActive('Pricing_UCD_Switch') && quoteLine.SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c == true) {
                            List<String> complianceWatchList = new List<String>();
                            String cwlValue = quoteLine.SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c;
                            if(cwlValue != null) {
                                complianceWatchList.addAll(cwlValue.split(';'));
                            }
                            if(quoteLine.SBQQ__Quote__r.Pricing_Is_Sanctioned__c == true) {
                                if(complianceWatchList.contains('EC') || complianceWatchList.contains('EMBUN')) {
                                    quoteLineIdMsgMap.put(quoteLine.Id, Label.Pricing_UCD_Auto_Rejection_Comments_For_EC);
                                } else {
                                    quoteLineIdMsgMap.put(quoteLine.Id, Label.Pricing_UCD_Auto_Rejection_Comments);
                                }
                            } else if (quoteLine.SBQQ__Quote__r.Pricing_Is_Sanctioned__c == false && (complianceWatchList.contains('REVIEWWIP') || complianceWatchList.contains('WIP') || complianceWatchList.isEmpty())) {
                                quoteLineIdMsgMap.put(quoteLine.Id, Label.Pricing_UCD_Auto_Rejection_Comments_for_REVIEWWIP_and_blank);
                            }
                        }
                    }
                } 
            } 
        } catch(exception ex) {
            Pricing_Tender_Utility.logError(ex);
        }
        return quoteLineIdMsgMap;
    }
    
    //Method to restrict won through dropdown if QL is not unified and country is in REVIEWWIP or country is blocked 
    @AuraEnabled
    public static String isNotUnifiedQuoteLine(Id quoteLineId,Date qliApprovedEndDate,String action) {
        String msg;
        Map<Id, String> qlIdMsgMap = new Map<Id, String>();
        List<SBQQ__QuoteLine__c> pendingCRList =  [SELECT Id, Pricing_Quote_Line_Number__c FROM SBQQ__QuoteLine__c
                                                   WHERE Pricing_Reference_Quote_Line_Nbr__c = : quoteLineId AND Pricing_Status_Nm__c IN: Label.Pricing_QuotelineStatus_AllPicklistValues_Except_Rejected.split(',')];
        
        if((pendingCRList.Size() > 0) && (action == Label.Pricing_Tender_QuoteLine_Action_Request_Change || action == Label.Pricing_Tender_Cancel_Action || action == Label.Pricing_Tender_QuoteLine_Action_Won || action == Label.Pricing_Tender_QuoteLine_Action_Lost)) {
            msg =  'PendingCRExist;' + Label.Pricing_Active_CR_Warning_Header + ';' + pendingCRList[0].Pricing_Quote_Line_Number__c;
        }
        else if(qliApprovedEndDate != null && qliApprovedEndDate <= (System.today() - 91) && action == Label.Pricing_Tender_QuoteLine_Action_Request_Change){
            msg =  'expiredCR;' + Label.Pricing_Tender_ExpiredCR_Header + ';' + Label.Pricing_Tender_ExpiredCR_ErrorMessage;
        }
        else {
            qlIdMsgMap = isNotUnifiedQuoteLineBulk(new Set<Id>{quoteLineId});
            String errorMsg = qlIdMsgMap.isEmpty() ? 'Success' : (qlIdMsgMap.containsKey(quoteLineId)) ? qlIdMsgMap.get(quoteLineId) : 'Error';
            msg = 'customerBlocked;' + Label.Pricing_Won_Not_Allowed_Warning_Header +';' + errorMsg;
        }                                         
        return msg;
    }
    
    //Method to return Quoteline RecordTypeId using Quote Line Type 
    @AuraEnabled(cacheable = true)
    public static String getRecordTypeId(String quoteLineType){
        Id recordTypeId;
        String recordTypeDeveloperName = '';
        recordTypeDeveloperName = (quoteLineType == Label.Pricing_Tender_Standard_QuoteLine) ? Label.Pricing_Tender_Quote_Line_Create
            :(quoteLineType == Label.Pricing_Tender_Small_Volume_Quote) ? Label.Pricing_SVD_Quote_Line_Create
                :(quoteLineType == Label.Pricing_Tender_SSD_Quote) ? Label.Pricing_SSD_Quote_Line_Create
                    :(quoteLineType == Label.Pricing_Tender_PMem_Quote) ? Label.Pricing_PMem_Quote_Line_Create
                        :(quoteLineType == Label.Pricing_Tender_NIC_Quote) ? Label.Pricing_NIC_Quote_Line_Create
                            :(quoteLineType == Label.Pricing_Tender_CCG_Quote) ? Label.Pricing_CCG_Quote_Line_Create
                                :(quoteLineType == Label.Pricing_Tender_DataCenter_GPU) ? Label.Pricing_GPU_DataCenter_QuoteLine_Create
                                    : Label.Pricing_CCG_Quote_Line_Create;
        
        if(recordTypeDeveloperName!= null){
            recordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c',recordTypeDeveloperName);
        }        
        return recordTypeId;
    }
    
    //Method to search Products and return Product list to show in DataTable
    @AuraEnabled
    public static List<Product2> searchProductsSOQL(String searchString, String quoteLineType) {
        if(quoteLineType!=null) {
            Pricing_Dynamic_Data_Table__mdt dynamicDataTableMetadata = [SELECT Id,Pricing_Field_Label__c,Pricing_Field_Value__c, Pricing_Query__c, Label, Pricing_Where_Clause__c,Pricing_Record_Type_Pkl__c,Pricing_SearchColumn_Field__c FROM Pricing_Dynamic_Data_Table__mdt WHERE Pricing_Record_Type_Pkl__c =:quoteLineType];
            List<Product2> productList = new List<Product2>();
            if(dynamicDataTableMetadata != null) {
                String queryString =dynamicDataTableMetadata.Pricing_Query__c;
                if(searchString!=null && searchString!='') {
                    searchString = '%'+string.escapeSingleQuotes(searchString.trim())+'%';
                    String whereClause = '';
                    if(quoteLineType == 'Data Center XeonÂ® CPU' || quoteLineType == 'Small Volume Quotes - Data Center XeonÂ® CPU' || quoteLineType == 'Financial Incentive') {
                        List<String> lobValuesList = Label.Pricing_LOB_Values.split(',');
                        String additionalCondition = ' AND (Core_Line_of_Business__c IN (\'' + String.join(lobValuesList, '\',\'') + '\') OR Name Like \'%' + String.escapeSingleQuotes('IntelÂ® XeonÂ®') + '%\')) OR Name = \'' + String.escapeSingleQuotes('Write In Product') + '\'';
                        system.debug('additionalCondition:'+additionalCondition);
                        whereClause =  dynamicDataTableMetadata.Pricing_Where_Clause__c + additionalCondition + ') '+ dynamicDataTableMetadata.Pricing_SearchColumn_Field__c.replace('{{searchString}}',searchString);
                    }else{
                        whereClause = dynamicDataTableMetadata.Pricing_Where_Clause__c + dynamicDataTableMetadata.Pricing_SearchColumn_Field__c.replace('{{searchString}}',searchString);
                    }
                    system.debug('whereClause: '+whereClause);
                    queryString = queryString+ ' ' + whereClause;
                    queryString = queryString + ' Limit 100';
                    productList = database.query(queryString);
                    system.debug('productList: '+productList.size());
                    return productList;
                } else {
                    return null;
                }
            } else {
                return null;
            }
        } else {
            return null;
        } 
    }
    
    //Method to get Data Table columns with the use of Metadata record for particular Quote Type
    @AuraEnabled
    public static Map<String,List<DataTableColumns>>  getDataTableColumns() {
        Map<String,List<DataTableColumns>> qlTypeToDataTblColMap = new Map<String,List<DataTableColumns>>();
        List<Pricing_Dynamic_Data_Table__mdt> dynamicDataTableMetadata = [SELECT Id,Pricing_Field_Label__c,Pricing_Field_Value__c, Label, Pricing_Record_Type_Pkl__c FROM Pricing_Dynamic_Data_Table__mdt WHERE Label NOT IN ('Quote', 'Quote Group', 'Unified L1 and L2 Account Details')];
        for(Pricing_Dynamic_Data_Table__mdt pd: dynamicDataTableMetadata){
            List<string> columnList = new List<string>();
            List<string> fieldAPINameList = new List<string>();
            List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
            if(pd.Pricing_Field_Label__c != null) {
                columnList = pd.Pricing_Field_Label__c.split(',');
            }
            if(pd.Pricing_Field_Value__c != null) {
                fieldAPINameList = pd.Pricing_Field_Value__c.split(',');
            }
            if(columnList.size() > 0) {
                for(integer i = 0; i < columnList.size(); i++) {
                    DataTableColumns datacolumn = new DataTableColumns(columnList[i].substringBefore(':').trim(), 
                                                                       fieldAPINameList[i].substringBefore(':').trim(), 
                                                                       fieldAPINameList[i].substringAfter(':').trim(),
                                                                       true);
                    lstDataColumns.add(datacolumn);
                }
                if(qlTypeToDataTblColMap.get(pd.Pricing_Record_Type_Pkl__c) == null){
                    qlTypeToDataTblColMap.put(pd.Pricing_Record_Type_Pkl__c,lstDataColumns);
                }
            }
        }
        system.debug('qlTypeToDataTblColMap:'+qlTypeToDataTblColMap);
        if(!(qlTypeToDataTblColMap.isEmpty())){
            return qlTypeToDataTblColMap;
        }
        else{
            return null;
        }
    }
    
    //Wrapper class to return Dynamic DataTable columns based on Quote Type
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Boolean sortable {get;set;}
        
        public DataTableColumns(String label, String fieldName, String type, Boolean sortable)
        {
            this.label     = label;
            this.fieldName = fieldName;
            this.type      = type;  
            this.sortable = sortable;        
        }
    }
    
    //method to get wrapper of listViews.
    @AuraEnabled
    public static list<listViewWrapper> listValues(string objectInfo){
        
        list<listViewWrapper> oListViewWrapper = new list<listViewWrapper>();
        
        for(ListView lv : [SELECT id, Name, DeveloperName FROM ListView
                           WHERE sObjectType = : objectInfo AND DeveloperName = :Label.Pricing_Tender_QuoteLine_ListViews.split(',') ORDER By Name ASC]){ 
                               listViewWrapper oWrapper = new listViewWrapper();
                               oWrapper.label = lv.Name;
                               oWrapper.developerName = lv.DeveloperName;
                               oListViewWrapper.add(oWrapper);
                           }
        return oListViewWrapper; 
    }  
    
    //wrapper class to store listView details
    public class listViewWrapper{
        @AuraEnabled public string label{get;set;} 
        @AuraEnabled public string developerName{get;set;} 
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean isPricingManager() {
        Boolean isRPMUser = Pricing_CommentsController.isPricingManager();
        return isRPMUser;
    }
    
    /**
* @description Method to check action performed against correct quoteline status
* @author Accenture | 06-23-2022 
* @param status 
* @param quoteLine 
* @return errorMsg 
**/
    public static String isValidRecordApproval(String status, SBQQ__QuoteLine__c quoteLine){
        Boolean isRPMUser = isPricingManager();
        Boolean isOEMField = isOEMField();
        String errorMsg = '';
        if((status == Label.Pricing_Tender_QuoteLine_Action_Won || status == Label.Pricing_Tender_QuoteLine_Action_Lost) && quoteLine.Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_Approved){
            errorMsg = Label.Pricing_Tender_QuoteLine_ApprovalFlow_Message.replace('<quoteline status>', quoteLine.Pricing_Status_Nm__c);
        }
        
        if(isRPMUser){
            if((status == Label.Pricing_Tender_QuoteLine_Action_Approve && (quoteLine.Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && quoteLine.Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_Lost)) ||
               ((status == Label.Pricing_Tender_QuoteLine_Action_Reject || status == Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyField || status == Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM) && quoteLine.Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) ||
               (status == Label.Pricing_Tender_Cancel_Action && (quoteLine.Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_Approved && quoteLine.Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_Won))){
                   errorMsg = Label.Pricing_Tender_QuoteLine_ApprovalFlow_Message.replace('<quoteline status>', quoteLine.Pricing_Status_Nm__c);
               }
        }
        
        if(isOEMField && quoteLine.Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview && quoteLine.Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_Approved){
            if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview){
                errorMsg = Label.Pricing_Tender_QuoteLine_ApprovalFlow_Message.replace('<quoteline status>', 'Approved');
            }
            else{
                errorMsg = Label.Pricing_Tender_QuoteLine_ApprovalFlow_Message.replace('<quoteline status>', quoteLine.Pricing_Status_Nm__c);
            }
        }
        return errorMsg;
    }
    
    /**
* @description method checks if the current user is a FSE or SDM and returns true if the current user is a FSE or SDM 
* @author Accenture | 11-05-2022  
* @return count 
**/
    @AuraEnabled(cacheable=true)
    public static Boolean isFSEorSDM() {
        return FeatureManagement.checkPermission(Label.Pricing_Tender_PermissionSets_TenderUser);
    }
    
    /**
* @description method checks if Enable or disable SDM bulk action for bulk approve/reject
* @author Accenture | 11-17-2022  
* @return count 
**/
    @AuraEnabled(cacheable=true)
    public static Boolean isBulkApproveRejectAction() {
        
        integer count = [Select COUNT() from Trigger_Execution__mdt where DeveloperName = 'Pricing_Sales_Rep_Action' AND Active__c = true limit 1];        
        return count > 0;
    }
    
    /**
* @description method checks if Enable or disable RPM bulk action for bulk deal creations 
* @author Accenture | 11-17-2022  
* @return count 
**/	
    @AuraEnabled(cacheable=true)
    public static Boolean isBulkDealCreations() {
        
        integer count = [Select COUNT() from Trigger_Execution__mdt where DeveloperName = 'Pricing_Bulk_Deal_Creations' AND Active__c = true limit 1];        
        return count > 0;
    }
    
   /* @description method checks if Enable or disable RPM bulk action for bulk Update Deal processing
    * @author Accenture | 11-17-2022  
    * @return count 
    **/
    @AuraEnabled(cacheable=true)
    public static Boolean isBulkUpdateDealProcess() {
        
        integer count = [Select COUNT() from Trigger_Execution__mdt where DeveloperName = 'Pricing_Bulk_Update_Deal_Processing' AND Active__c = true limit 1];        
        return count > 0;
    }
    
    /**
    * @description method checks if User has RPM Permission Sets assigned or not 
    * @author Accenture  
    * @return count 
    **/	
   @AuraEnabled(cacheable=true)
    public static Boolean hasPricingManagerAccess() {
        return FeatureManagement.checkPermission('Pricing_Tender_Regional_Pricing_Manager');
    }
    
    /**
    * @description method checks if User has FinancialIncentivePricingManager Permission Sets assigned or not 
    * @author Accenture  
    * @return Boolean true if has access , false is not.
    **/	
    @AuraEnabled(cacheable=true)
    public static Boolean hasFinancialIncentivePricingManagerPS() {
        return FeatureManagement.checkPermission('Pricing_Financial_Incentive_Regional_Pricing_Manager');
    }
    /**
    * @description method returns picklist options available for Rejection Reasons
    * @author Accenture | 02-02-2023
    * @return options
    **/	
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getRejectionReasonsValue(Id recId){

        Map<String, String> options = new Map<String, String>();
        try{
        String quoteProgram = [SELECT Id,Pricing_Quote_Program_Nm__c FROM SBQQ__Quote__c WHERE Id =: recId].Pricing_Quote_Program_Nm__c;               
        Map<String, List<String>> quoteProgramRejectionReasonsMap = Pricing_RestAPI_QuotesUtilityV2.getFieldDependencies('SBQQ__QuoteLine__c', 'Pricing_Quote_Program_Nm__c', 'Pricing_Rejection_Reason__c');
        if(quoteProgramRejectionReasonsMap.size() > 0 && quoteProgramRejectionReasonsMap.containsKey(quoteProgram)){
            for(String rejectionReason : quoteProgramRejectionReasonsMap.get(quoteProgram)){
                options.put(rejectionReason, rejectionReason);
            }
        }
        }
        catch(exception ex) {
            Pricing_Tender_Utility.logError(ex);
        }
        return options;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<string, string> getLostReasonValue(){
        Map<string, string> values = new Map<string, string>();
        Schema.DescribeFieldResult fResult = SBQQ__QuoteLine__c.Pricing_Lost_Reason_Nm__c.getDescribe();
        // Retrive the list of picklist values for the field
        List<Schema.PicklistEntry> pickValues = fResult.getPicklistValues();
        for (Schema.PicklistEntry p: pickValues) {            
            values.put(p.getValue(), p.getLabel());
        }
        // Return the map containing the Lost Reason values
        return values;
    }
    
    /**
* @description method will call publishIQR and publish IQR event  
* @author Accenture | 08-08-2023
* @param quoteLineId 
**/	
    @AuraEnabled
    public static void handleSyncStatus(Id quoteLineId){
        try {
            Map<String, Set<Id>> quoteLineActionMap = new Map<String, Set<Id>>();
            quoteLineActionMap.put(Label.Pricing_IQR_Event_Action_Won_Lost_Integration, new Set<id>{quoteLineId});
            QuoteLineBusinessLogic.publishIQR(quoteLineActionMap);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // This method checks if the user has access to create Pricing_Performance_Metric__c record
    // Returns Boolean True if user has access else it returns false
    public static Boolean isCreateablePf(){
        return Schema.sObjectType.Pricing_Performance_Metric__c.isCreateable();
    }
    
    // This method checks if the user has access to update Pricing_Performance_Metric__c record
    // Returns Boolean True if user has access else it returns false
    public static Boolean isUpdateablePf(){
        return Schema.sObjectType.Pricing_Performance_Metric__c.isUpdateable();
    }
    // This method checks if the user has access to delete Pricing_Performance_Metric__c record
    // Returns Boolean True if user has access else it returns false
    public static Boolean isDeletablePf(){
        return Schema.sObjectType.Pricing_Performance_Metric__c.isDeletable();
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,Boolean> performetricsObjectAccess(){
        Map<String,Boolean> pfObjectAccess = new Map<String,Boolean>();
        pfObjectAccess.put('isCreateablePf',isCreateablePf());
        pfObjectAccess.put('isUpdateablePf',isUpdateablePf());
        pfObjectAccess.put('isDeletablePf',isDeletablePf());
        return pfObjectAccess;
    }
    //This method is used in Pricing_PerformanceMetrics
    //It takes object name and field name as parameters and returns the list of lables of values in that field 
    @AuraEnabled(cacheable=true)     
    public static List<String> getPickListValues(String objectType, String selectedField) {
        List<String> pkListValues = new List<String>();
        Schema.SObjectType obj = ((SObject)Type.forName(objectType).newInstance()).getSObjectType();
        Schema.DescribeSObjectResult res = obj.getDescribe();
        Schema.DescribeFieldResult result = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> pkle = result.getPicklistValues();
        for( Schema.PicklistEntry pklVal : pkle){
            pkListValues.add(pklVal.getLabel());
        }     
        return pkListValues;
    }
    //Method for Paired CPU Text field Updation
    @InvocableMethod(label = 'updatePairedCPU' description = 'updatePairedCPU')
    public static void updatePairedCPU(List <List<SBQQ__QuoteLine__c>> lstquoteLines){
        try{
            Set<Id> qlIdSet = new Set<Id>();
            List<SBQQ__Quoteline__c> quotelineList = new List<SBQQ__Quoteline__c>();
            Map<Id,SBQQ__QuoteLine__c> qliMap = new Map<Id,SBQQ__QuoteLine__c>();
            for(List<SBQQ__Quoteline__c> quoteLines: lstquoteLines){
                for(SBQQ__QuoteLine__c quoteLine: quoteLines){       
                    if(quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_DataCenter_GPU || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine){
                        qlIdSet.add(quoteLine.Id);  
                    }  
                }
            }
            if(qlIdSet.size()>0){
                qliMap= new Map<Id,SBQQ__QuoteLine__c>([SELECT Id,Pricing_Program_Type_Nm__c,Pricing_Paired_CPU_Nm__r.Name, Pricing_Write_In_Paired_CPU_Nm__c, Pricing_Product_Nm__r.Core_Product_Series__c
                                                    FROM SBQQ__QuoteLine__c WHERE Id IN :qlIdSet]);                             
            }
            for(SBQQ__QuoteLine__c qli: qliMap.values()){
                if(qli.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_DataCenter_GPU){
                    qli.Pricing_CPU_Txt__c = (qli.Pricing_Paired_CPU_Nm__r.Name == Label.Pricing_Tender_Write_In_Product)?Label.Pricing_Tender_Write_In_Product:qli.Pricing_Paired_CPU_Nm__r.Name;
                    quotelineList.add(qli); 
                }
                else if(qli.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine){
                    qli.Pricing_Product_Series_Name__c = qliMap.get(qli.Id).Pricing_Product_Nm__r.Core_Product_Series__c;
                    quotelineList.add(qli); 
                }    
            }
            if(quotelineList.size()>0){
                SBQQ.TriggerControl.disable();
                update quotelineList;
                SBQQ.TriggerControl.enable();
            }        
        }
        catch(Exception ex){
            Pricing_Tender_Utility.logError(ex);
        }
    }

    /**
    * @description :  Return boolean for SVD QuoteLine is active or not
    * @author Vrushabh Uprikar | 01-06-2025 
    * @return boolean 
    **/
    @AuraEnabled(cacheable=true)
    public static boolean getSVDQuoteLineActiveStatus(){
        integer count = [Select COUNT() From Trigger_Execution__mdt Where DeveloperName = 'Pricing_SVD_QuoteLine_Disabled' AND Active__c = false limit 1];
        return count > 0 ? true : false;
    }

    /**
    * @description :  Return boolean for SVD Quote is , If True = Add Error else No Error
    * @author Vrushabh Uprikar | 01-06-2025 
    * @return boolean 
    **/ 
    @AuraEnabled(cacheable=true)
    public static boolean getSVDQuoteActiveStatus(){
        integer count = [Select COUNT() From Trigger_Execution__mdt Where DeveloperName = 'Pricing_SVD_Quote_Disabled' AND Active__c = false limit 1];
        return count > 0 ? true : false;
    }

    /**
    * @description 
    * @author Vrushabh Uprikar | 01-28-2025 
    * @param quoteLineType 
    * @return Boolean 
    **/
    public static Boolean checkSVDActiveStatus(String quoteLineType){
        if(getSVDQuoteLineActiveStatus() == false){
            return true;
        }else{
            return ((!getSVDQuoteLineActiveStatus() && quoteLineType == Label.Pricing_Tender_Small_Volume_Quote ) || quoteLineType != Label.Pricing_Tender_Small_Volume_Quote);
        }        
    }

    //Description : Returns all the permission sets assigned to the user.
    @AuraEnabled(cacheable=true)
    public static List<PermissionSetAssignment> getUserPemissionSets(String userId){
        List<PermissionSetAssignment> userPermissionSets = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE Assigneeid = : userId];
        return userPermissionSets;
    }
    /**
* @description method checks if product is Non-SIPP, Market Segment is Corp,Form factor Notebook
* @author Accenture | 07-03-2026
* @return Boolean 
**/	
    @AuraEnabled(cacheable=true)
    public static Boolean eligibleForPricingSupportCheck(SBQQ__QuoteLine__c quoteLine) {//PAA V2
        Boolean notEligibleForPricing = false;
        if(quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote && quoteLine.Pricing_SIPP_Cb__c == false && quoteLine.Pricing_Market_Segment_values_Nm__c == 'Corp' && quoteLine.Pricing_Form_Factor_Nm__c == 'Notebook'){
            notEligibleForPricing = true;
        }
        return notEligibleForPricing;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean getRecommendedPrice(Id quoteLineId) {
        Boolean isError = false;
        try {
            Pricing_Application_Agent_AI_Integration.populateJSON(new List<Id>{quoteLineId}, new Map<String,Integer>()); 
        }
        catch(Exception ex){
            isError = true;
            Pricing_Tender_Utility.logError(ex);
        }
        return isError;
    }
}