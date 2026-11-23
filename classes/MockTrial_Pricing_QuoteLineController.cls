/*-------------------------------------------------------------------------------------------
Apex Class  : MockTrial_Pricing_QuoteLineController
Version     : 1.0 
Created Date: 28 Jun 2021
Function    : Apex class for trying ApexMock implementation on Quote Line Aura component controller.
Modification Log :
---------------------------------------------------------------------------------------------*/
public without sharing class MockTrial_Pricing_QuoteLineController {
    
   /* public static void updateACCandCon(){
        DomainLayerImpl.updateAccountAndContact(SEL_Account.newInstance().selectByAccountAndContact(),'Mock Success');
    }
    @AuraEnabled
    public static List < SBQQ__QuoteLine__c > getQuoteLines(Id recordId) {
        System.debug('Inside controller');
        //calling the desired query from the selector class by creating an instance of the selector class.
        //return QuoteLine_Selector.newInstance().selectWithQuoteAndStatusFilter(recordId);
        return SEL_QuoteLines.newInstance().selectByQuoteIdAndNegativePricingStatus(new Set<Id>{recordId},new Set<String>{Label.Pricing_Tender_QuoteLine_Status_Revised});
    }
    
    @AuraEnabled
    public static List < SBQQ__Quote__c > getQuote(Id recordId) {
        return [SELECT Id, SBQQ__Account__r.Name, Pricing_Project_Name_Nm__c, Pricing_End_Customer_Country_Nm__c, Pricing_Customer_Nm__c, Pricing_ShipmentEndDate_Dt__c, Pricing_Server_Deal_Type_Nm__c, SBQQ__SalesRep__c, Pricing_Region_Nm__c,Pricing_Program_Type_Nm__c FROM SBQQ__Quote__c WHERE Id = : recordId];
    }
    
    @AuraEnabled
    public static Boolean isCreateable() {
        return Schema.sObjectType.SBQQ__QuoteLine__c.isCreateable();
    }
    
    @AuraEnabled
    public static Boolean isOEMField() {
        integer count = [SELECT count() FROM PermissionSetAssignment
                         WHERE AssigneeId = : Userinfo.getUserId() AND PermissionSet.Name = : Label.Pricing_Tender_PermissionSets_TenderUser
                        ];
        return count > 0;
    }
    
    @AuraEnabled
    public static SBQQ__QuoteLine__c getQuoteLine(Id quoteLineId) {
        /*SBQQ__QuoteLine__c quoteLine = [SELECT Id, Pricing_Status_Nm__c, Pricing_Quote_Line_Number__c,
                                        Pricing_FSE_Recommended_Price_Nm__c, Pricing_ECAP_Price_Amt__c,
                                        Pricing_Approved_End_Date_Dt__c, Pricing_Approved_Unit_Qty__c,
                                        Pricing_Approved_Start_Date_Dt__c, Pricing_Meet_Comp_Price_Amt__c, Pricing_Deal_RFQ_Id__c
                                        From SBQQ__QuoteLine__c WHERE Id = : quoteLineId
                                       ];*/
        //return quoteLine;
        ////calling the desired query from the selector class by creating an instance of the selector class.
      /*  List<String> fields = new List<String>{'Id', 'Pricing_Status_Nm__c', 'Pricing_Quote_Line_Number__c',
                                        'Pricing_FSE_Recommended_Price_Nm__c', 'Pricing_ECAP_Price_Amt__c',
                                        'Pricing_Approved_End_Date_Dt__c', 'Pricing_Approved_Unit_Qty__c',
                                        'Pricing_Approved_Start_Date_Dt__c', 'Pricing_Meet_Comp_Price_Amt__c', 'Pricing_Deal_RFQ_Id__c'};
        return SEL_QuoteLines.newInstance().selectWithId(new Set<Id>{quoteLineId},fields)[0];
        //return SEL_QuoteLines.newInstance().selectById(new Set<Id>{quoteLineId})[0];  
    }
    
    @AuraEnabled
    public static Map<boolean, SBQQ__QuoteLine__c> hasPendingChangeRequest(Id quoteLineId) {
        Map<boolean, SBQQ__QuoteLine__c>  hasPendingCR =  new Map<boolean, SBQQ__QuoteLine__c>();        
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, Pricing_Quote_Line_Number__c  FROM SBQQ__QuoteLine__c
                                               where Pricing_Reference_Quote_Line_Nbr__c = : quoteLineId and Pricing_Status_Nm__c != 'Rejected'
                                              ];
        
        hasPendingCR.put(!quoteLines.isEmpty(), !quoteLines.isEmpty() ? quoteLines[0]: null);
        //hasPendingCR.put(quoteLines.isEmpty(), quoteLines.isEmpty() ? quoteLines[0]: null);
        return hasPendingCR;
    }
    
    @AuraEnabled
    public static List < string > getAvailableUserActions(Id quoteLineId) {
        /*SBQQ__QuoteLine__c quoteLine = [SELECT Id, Pricing_Status_Nm__c, SBQQ__Quote__r.SBQQ__Status__c, Pricing_Sales_Rep__c,Pricing_Approved_End_Date_Dt__c,
                                        CreatedById,SBQQ__ProductName__c, Pricing_Primary_Contact_Nm__c, SBQQ__Quote__r.OwnerId, SBQQ__Quote__r.CreatedById, 
                                        Pricing_Change_Request_cb__c, Pricing_Deal_RFQ_Status_Nm__c,Pricing_Integration_Status_Nm__c,Pricing_Deal_RFQ_Id__c,
                                        Pricing_Reference_Quote_Line_Nbr__c,SBQQ__Quote__r.SBQQ__Account__c From SBQQ__QuoteLine__c
                                        WHERE Id = : quoteLineId];*/
         ////calling the desired query from the selector class by creating an instance of the selector class.
      /*  SBQQ__QuoteLine__c quoteLine =  SEL_QuoteLines.newInstance().selectById(new Set<Id>{quoteLineId})[0];
        System.debug(quoteLine);      
        List<User> delegateApprovers = new List<User>();
        delegateApprovers = [SELECT DelegatedApproverId from User where id = : quoteLine.Pricing_Sales_Rep__c];
        Id delegateApprover = delegateApprovers.size() > 0 ? delegateApprovers[0].DelegatedApproverId : null;
        
        List < string > actions = new List < string > ();
        // VARIABLE USED TO GET USER ID
        Id userId = UserInfo.getUserId();
        // If user has create access he can clone always
        if(isCreateable()) {
            Set < String > allPersona = getPersonaExcludingSet(new Set < String > ());
            system.debug(allPersona);
            if(userHasValidPermissionSet(allPersona)) {
                actions.add('Clone');
            }
        }
        Set < String > allPersona = getPersonaExcludingSet(new Set < String > ());
        Set < String > isRPMPersona = new Set < String > ();
        Set<Id> multipleFSEUserIdSet = new Set<Id>();
        isRPMPersona.add(Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager);
        Map<Id, Boolean> qLIdintRejectionAllowedMap = isIntegartionRejectionAllowed(new Set<Id>{quoteLine.Id}); 

        for(ProcessInstanceWorkitem workItem : [SELECT p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId,
                                                p.ProcessInstanceId, p.OriginalActorId, p.Id FROM ProcessInstanceWorkitem p
                                                WHERE p.ProcessInstance.TargetObjectId = : quoteLineId AND ProcessInstance.Status = 'Pending']){
                                                    multipleFSEUserIdSet.add(workItem.OriginalActorId);
                                            }
                                          
        switch on quoteLine.Pricing_Status_Nm__c {
            when 'Draft' {
                Set < String > allPersonaExceptRPM = getPersonaExcludingSet(new Set < String > {
                    Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager,
                        Label.Pricing_Tender_PermissionSets_TenderAccountExecutive, Label.Pricing_Tender_Permission_Set_IT_Specialist
                        });
                system.debug(allPersona);
                if(userHasValidPermissionSet(allPersona)) {
                    actions.add(Label.Pricing_Tender_QuoteLine_Action_Edit);
                    if(quoteLine.CreatedById == userId || quoteLine.Pricing_Primary_Contact_Nm__c == userId || quoteLine.SBQQ__Quote__r.OwnerId == userId || userHasValidPermissionSet(new Set < String > {
                        Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator
                            })) {
                                actions.add(Label.Pricing_Tender_QuoteLine_Action_Delete);
                            }
                }
                system.debug(allPersonaExceptRPM);
                if(userHasValidPermissionSet(allPersonaExceptRPM) && quoteLine.SBQQ__Quote__r.SBQQ__Status__c != 'Draft') {
                    actions.add(Label.Pricing_Tender_QuoteLine_Action_Submit_For_Approval);
                }
            }
            when 'Pending Intel Field Review' {
                if(userHasValidPermissionSet(new Set < String > {
                    Label.Pricing_Tender_PermissionSets_TenderUser}))
                {
                    if(quoteLine.Pricing_Sales_Rep__c == userId || delegateApprover == userId || multipleFSEUserIdSet.contains(userId)) {
                        actions.add(Label.Pricing_Tender_QuoteLine_Action_Edit);
                        actions.add(Label.Pricing_Tender_QuoteLine_Action_Approve);
                        actions.add(Label.Pricing_Tender_QuoteLine_Action_Reject);
                        if(!quoteLine.Pricing_Change_Request_cb__c) {
                            actions.add(Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM);
                        }
                    }
                }
            }
            when 'Pending Further Intel Review' {
                if(userHasValidPermissionSet(new Set < String > {Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager})){
                    //No Actions are Available for Integration Status "Pending","InProcess" and Deal Status "Submitted"
                    if(quoteLine.Pricing_Integration_Status_Nm__c != Label.Pricing_Tender_MyDeal_Integration_Status_Pending && quoteLine.Pricing_Integration_Status_Nm__c !=  Label.Pricing_Tender_MyDeal_Integration_Status_InProcess &&
                    quoteLine.Pricing_Deal_RFQ_Status_Nm__c != Label.Pricing_Tender_MyDeal_RFQ_Status_Submitted){
                           //Avaiable for All Scenarios
                           actions.add(Label.Pricing_Tender_QuoteLine_Action_Edit);
                           //Recision Actions Available only for Non-Change Request Non Integration QuoteLines
                           if(quoteLine.Pricing_Integration_Status_Nm__c == null){
                               actions.add(Label.Pricing_Tender_QuoteLine_Action_Reject);
                               if(!quoteLine.Pricing_Change_Request_cb__c){
                                   actions.add(Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM);
                                   actions.add(Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyField);
                               }
                               if(quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product){
                                   if(quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null){
                                       actions.add(Label.Pricing_Update_Deal_MD_button_label);
                                   }else{
                                       actions.add(Label.Pricing_Send_Request_MD_Button_Label);
                                   }
                               }else{
                                   actions.add(Label.Pricing_Tender_QuoteLine_Action_Approve);
                               }
                           }
                           
                           if(quoteLine.Pricing_Integration_Status_Nm__c == Label.Pricing_Tender_MyDeal_Integration_Status_Error 
                              && ((String.isBlank(quoteLine.Pricing_Deal_RFQ_Id__c) && String.isBlank(quoteLine.Pricing_Deal_RFQ_Status_Nm__c)) 
                                  || (String.isBlank(quoteLine.Pricing_Deal_RFQ_Status_Nm__c)
                                      && quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null))){
                                          actions.add(Label.Pricing_Tender_QuoteLine_Action_Reject);
                                          if(quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product){
                                              if(quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null){
                                                  actions.add(Label.Pricing_Update_Deal_MD_button_label);
                                              }else{
                                                  actions.add(Label.Pricing_Send_Request_MD_Button_Label);
                                              }
                                          }
                                      }
                           if(quoteLine.Pricing_Deal_RFQ_Status_Nm__c == Label.Pricing_Tender_MyDeal_RFQ_Status_Requested && String.isNotBlank(quoteLine.Pricing_Deal_RFQ_Id__c)){
                               if(quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product){
                                   actions.add(Label.Pricing_Update_Deal_MD_button_label);
                               }
                           }
                        }
                        if(qLIdintRejectionAllowedMap.get(quoteLine.Id)) {
                               actions.add(Label.Pricing_Tender_QuoteLine_Action_Reject);
                        }
                }
            }
            when 'Approved' {  
                Boolean allowOnlyForRPM = allowWonLostForRPM(quoteLine);
                if(allowOnlyForRPM){
                    system.debug(isRPMPersona);
                    if(userHasValidPermissionSet(isRPMPersona)){           //Restrict Won/Loss to RPM for 16 identified Accounts
                        actions.add(Label.Pricing_Tender_QuoteLine_Action_Won);
                        actions.add(Label.Pricing_Tender_QuoteLine_Action_Lost);
                	}
                }else{
                    if(userHasValidPermissionSet(allPersona)) {
                        actions.add(Label.Pricing_Tender_QuoteLine_Action_Won);
                        actions.add(Label.Pricing_Tender_QuoteLine_Action_Lost);
                    }
                }
                Set < String > extPersona = new Set < String > {Label.Pricing_Tender_PermissionSets_TenderPartner};
                extPersona.add(Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator);
                extPersona.add(Label.Pricing_Tender_PermissionSets_TenderDrafter); 
			    //extPersona.add(Label.Pricing_Tender_PermissionSets_TenderDrafterLimited);
			    system.debug(extPersona);
                if(userHasValidPermissionSet(extPersona)) {
                    actions.add(Label.Pricing_Tender_QuoteLine_Action_Request_Change);
                }
                if(userHasValidPermissionSet(new Set < String > {
                    Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager}))  {
                        actions.add(Label.Pricing_Tender_Cancel_Action);
                        //added By ANushaM for US835690
                        if(quoteLine.Pricing_Approved_End_Date_Dt__c == null || quoteLine.Pricing_Approved_End_Date_Dt__c > (System.today() - 91)){
                            actions.add(Label.Pricing_Tender_QuoteLine_Action_Request_Change);
                        }
                    }
                
            }
            when 'Lost' {
                if(userHasValidPermissionSet(new Set < String > {
                    Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager}))  {
                        actions.add(Label.Pricing_Tender_QuoteLine_Action_Approve);
                    }
            }
            when 'Won' {
                Set < String > extPersona = new Set < String > { Label.Pricing_Tender_PermissionSets_TenderPartner };
                extPersona.add(Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator);
                extPersona.add(Label.Pricing_Tender_PermissionSets_TenderDrafter);
                //extPersona.add(Label.Pricing_Tender_PermissionSets_TenderDrafterLimited);
                
                if(userHasValidPermissionSet(extPersona)) {
                    actions.add(Label.Pricing_Tender_QuoteLine_Action_Request_Change);
                }
                if(userHasValidPermissionSet(new Set < String > {
                    Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager}))  {
                        actions.add(Label.Pricing_Tender_Cancel_Action);
                        //added By ANushaM for US835690
                        if(quoteLine.Pricing_Approved_End_Date_Dt__c == null || quoteLine.Pricing_Approved_End_Date_Dt__c > (System.today() - 91)){
                            actions.add(Label.Pricing_Tender_QuoteLine_Action_Request_Change);
                        }
                    }
                
            }
        }
        return actions;
    }
    
    @AuraEnabled
    public static void deleteRecord(Id quoteLineId) {
        if(quoteLineId != null){
            SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Id = : quoteLineId];
            List<Pricing_Quote_Line_Status_Age__c> deleteTPTList = new List<Pricing_Quote_Line_Status_Age__c>();
            deleteTPTList = [SELECT Id,Pricing_TPT_Quote_Line_Number__c from Pricing_Quote_Line_Status_Age__c where 
                             Pricing_TPT_Quote_Line_Number__c =: quoteLineId];
            if(quoteLine != null) {
                delete quoteLine;
            }
            if(!deleteTPTList.isEmpty()){
                delete deleteTPTList;
            }
        }
    }
    @AuraEnabled
    public static String cancelRecord(Id quoteLineId) {
        String retMsg = null;
        try{
            SBQQ__QuoteLine__c quoteLine = [SELECT Id,Pricing_Status_Nm__c  FROM SBQQ__QuoteLine__c WHERE Id = : quoteLineId];
            if(quoteLine != null) {
                quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Cancelled;
                update quoteLine;
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
        System.debug('inside');
        id userId = Userinfo.getUserId();
        /*integer count = [SELECT count() FROM PermissionSetAssignment
                         WHERE AssigneeId = : Userinfo.getUserId() AND PermissionSet.Name IN: permissionSets
                        ];
        return count > 0;*/
         ////calling the desired query from the selector class by creating an instance of the selector class.
       /* return SEL_PermissionSetAssignment.newInstance().selectByName(userId,permissionSets);
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
        Set < String > extPersona = new Set < String > {Label.Pricing_Tender_PermissionSets_TenderPartner};
            extPersona.add(Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator);
        	extPersona.add(Label.Pricing_Tender_PermissionSets_TenderDrafter);
        	extPersona.add(Label.Pricing_Tender_PermissionSets_TenderDrafterLimited); 
        return userHasValidPermissionSet(extPersona);
    }
    
    @AuraEnabled
    public static String recordApproval(Id quoteLineId, string comments, string status, SBQQ__QuoteLine__c lineItem){
        String retMsg = null;
        try {            
        String currentAction = status;
        Boolean isFieldReviewQL = false;
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, Name, Pricing_Status_Nm__c,Pricing_pm_approval_comments_nm__c,SBQQ__Quote__c,
                                        Pricing_Sales_Rep_Approver__c, Pricing_FSE_Recommended_Price_Nm__c, Pricing_Reference_Quote_Line_Nbr__c,
                                        Pricing_Change_Request_cb__c, Pricing_Ready_for_Review_cb__c,Customer_Revision_Count_Cnt__c,Field_Revision_Count_Cnt__c
                                        From SBQQ__QuoteLine__c WHERE Id = : quoteLineId
                                       ]; 
        Map < string, string > statusMapping = new Map < string, string > ();
        statusMapping.put(Label.Pricing_Tender_QuoteLine_Action_Approve, Label.Pricing_Tender_QuoteLine_Status_Approved);
        statusMapping.put(Label.Pricing_Tender_QuoteLine_Action_Reject, Label.Pricing_Tender_QuoteLine_Status_Rejected);
        statusMapping.put(Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyField, Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview);
        statusMapping.put(Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM, Label.Pricing_Tender_QuoteLine_Status_Draft);
        Map<Id,Set<Id>> quoteQTMMap = new Map<Id,Set<Id>>();
        if(quoteLine != null) {
            String approvalAction = null;
            List < SBQQ__QuoteLine__c > quoteLineList = new List < SBQQ__QuoteLine__c > ();
            if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview) {
                if(status != Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM){
                    quoteLine.Pricing_FSE_Recommended_Price_Nm__c = lineItem.Pricing_FSE_Recommended_Price_Nm__c;
                    quoteLine.Pricing_Sales_Rep_Approver__c = UserInfo.getUserId();
                    quoteLine.Pricing_pm_approval_comments_nm__c = comments == '' ? quoteLine.Pricing_pm_approval_comments_nm__c : comments;
                    update quoteLine;
                }
                /*ProcessInstanceWorkitem workItem = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId,
                                                    p.ProcessInstanceId, p.OriginalActorId, p.Id From ProcessInstanceWorkitem p
                                                    where p.ProcessInstance.TargetObjectId = : quoteLineId
                                                   ];
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments(comments);*/
                // Revision required by OEM Reject the Approval Process and set the Status to Draft
             /*   if(status == Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM) {
                    //req.setAction(Label.Pricing_Tender_QuoteLine_Action_Reject);
                    approvalAction = Label.Pricing_Tender_QuoteLine_Action_Reject;
                    quoteLine.Pricing_Status_Nm__c = statusMapping.get(status);
                    quoteLine.Pricing_Ready_for_Review_cb__c = true;
                    //TPT
                    quoteLine.Customer_Revision_Count_Cnt__c = (quoteLine.Customer_Revision_Count_Cnt__c == null) ? 1 :quoteLine.Customer_Revision_Count_Cnt__c + 1;
                    //TPT
                    quoteLineList.add(quoteLine);
                } else if(status == Label.Pricing_Tender_QuoteLine_Action_Reject) {
                    //If Rejected then Reject the Approval Process and set the status to Rejected
                    //req.setAction(status);
                    approvalAction = Label.Pricing_Tender_QuoteLine_Action_Reject;
                    quoteLine.Pricing_Status_Nm__c = statusMapping.get(status);
                    quoteLine.Pricing_Change_Request_cb__c = false;
                    quoteLineList.add(quoteLine); 
                } else {
                    //If Approved then Approve the Approval Process(Approval Process automatically sets the status to Approved)
                    //req.setAction(status);
                    approvalAction = status;
                }
                /*req.setNextApproverIds(new Id[] {
                    UserInfo.getUserId()
                        });
                req.setWorkitemId(workItem.Id);
                //Process the Approval Request
                */
              /*  if(!quoteLineList.isEmpty()) {
                    update quoteLineList;
                }

                //Approval.ProcessResult result = Approval.process(req);
                Pricing_Publish_Quote.setFSEActionOnQuoteLine(new Set<Id>{quoteLine.Id},approvalAction,comments,false);
            }else{
                quoteLineList.add(quoteLine);
                //Set the PM Approval Comments when RPM is performing Actions
                if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview ) {
                    quoteLine.Pricing_pm_approval_comments_nm__c = comments == '' ? quoteLine.Pricing_pm_approval_comments_nm__c : comments;
                    if(status == Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM) {
                        quoteLine.Pricing_Ready_for_Review_cb__c = true;
                        //TPT
                        quoteLine.Customer_Revision_Count_Cnt__c = (quoteLine.Customer_Revision_Count_Cnt__c == null) ? 1 : quoteLine.Customer_Revision_Count_Cnt__c + 1;
                        //TPT
                    }
                    //TPT
                    if(status == Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyField){
                        //Validate Quote Team's FSEs on field revision
                        quoteQTMMap = Pricing_Publish_Quote.validateQtmFse(new Set<Id>{quoteLine.SBQQ__Quote__c});
                        if(quoteQTMMap.size() > 0){
                            isFieldReviewQL = true;
                             quoteLine.Field_Revision_Count_Cnt__c = (quoteLine.Field_Revision_Count_Cnt__c == null) ? 1: quoteLine.Field_Revision_Count_Cnt__c + 1;
                        }else{
                            isFieldReviewQL = false;
                            quoteLineList.remove(quoteLineList.indexOf(quoteLine));
                            retMsg = Label.Pricing_Tender_Quote_Sales_Rep_Error_Message;
                        }
                        
                    }
                    //TPT
                }
                if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Action_Lost && status == Label.Pricing_Tender_QuoteLine_Action_Approve){
                    quoteLine.Pricing_pm_approval_comments_nm__c = comments;
                }
                if(status == Label.Pricing_Tender_QuoteLine_Action_Won || status == Label.Pricing_Tender_QuoteLine_Action_Lost) {
                    // update comments to win lost field
                    quoteLine.Pricing_Won_Lost_Comments_Txt__c = comments;
                }
                
                Boolean statusOverrideForWonCR = false;
                system.debug('1----->'+quoteLine.Pricing_Change_Request_cb__c);
                system.debug('2----->'+quoteLine.Pricing_Reference_Quote_Line_Nbr__c);
                system.debug('3----->'+status);
                if(quoteLine.Pricing_Change_Request_cb__c && quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null && (status == Label.Pricing_Tender_QuoteLine_Action_Lost || status == Label.Pricing_Tender_QuoteLine_Action_Reject || status == Label.Pricing_Tender_QuoteLine_Action_Approve || status == Label.Pricing_Tender_QuoteLine_Action_Won)) {
                    //Check if Change Request Quote Line is getting Approved then make the Parent as Revised
                    if(status == Label.Pricing_Tender_QuoteLine_Action_Approve) {
                        SBQQ__QuoteLine__c parentQuoteLine = [SELECT ID, Pricing_Status_Nm__c,Pricing_Won_Lost_Comments_Txt__c from SBQQ__QuoteLine__c where id = : quoteLine.Pricing_Reference_Quote_Line_Nbr__c];
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
                }
                if(!quoteLineList.isEmpty()) {
                    update quoteLineList;
                }

                //Create Approval records for only valid FSE on field revision
                if(isFieldReviewQL){
                    Pricing_Publish_Quote.publishQuoteLinesToMultipleFSE(new Set<Id>{quoteLine.Id});
                }
            }
        }
             system.debug('retMsg==>'+retMsg);
        }
        catch(Exception e){
            retMsg = Pricing_Tender_Utility.getExceptionMessage(e);
            system.debug('retMsg==>'+retMsg);          
            Pricing_Tender_Utility.logError(e);        
        }
        return retMsg;
    }
    
    // Get the document Id from the name
    @AuraEnabled
    public static Id getDocumentId(string name) {
        List < Document > document = [SELECT Id, Name FROM Document where Name = : name LIMIT 1];
        return document.isEmpty() ? null : document[0].Id;
    }
    
    //Method used in Pricing_CPQ_RunReport to get the user type of the current user
    @AuraEnabled
    public static String reportingURLValue(id quoteIdPara) {
        String fullRecordURL;
        try{
            List < PermissionSetAssignment > lstcurrentUserPerSet = [SELECT Id, PermissionSet.Name, AssigneeId
                                                                     FROM PermissionSetAssignment
                                                                     WHERE AssigneeId = : Userinfo.getUserId()
                                                                    ];
            //String fullRecordURL;
            Id quoteId = (Id) String.escapeSingleQuotes(String.valueOf(quoteIdPara)); 
            SBQQ__Quote__c quote = [select id, Name from SBQQ__Quote__c where id = : quoteId];
            Report generateReportRecord = new Report();
            String reportName;
            Set < String > internalPSWithoutRPM = new Set < String > ();
            Set < String > internalPSWithRPM = new Set < String > ();
            if(Label.Pricing_Tender_PermissionSets_AllInternal != null) {
                internalPSWithoutRPM.addAll(new List < String > ((Label.Pricing_Tender_PermissionSets_AllInternal).split(':')));
                internalPSWithoutRPM.remove(Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager);
                internalPSWithRPM = new Set < String > {
                    Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager
                        };
                            }
            Set < String > externalPS = new Set < String > ();
            if(Label.Pricing_Tender_PermissionSets_AllExternal != null) {
                externalPS.addAll(new List < String > ((Label.Pricing_Tender_PermissionSets_AllExternal).split(':')));
            }
            ReportFilters filter = new ReportFilters('equals', quote.Name, 'SBQQ__Quote__c.Name');
            List < reportFilters > reportFilters = new List < ReportFilters > {
                filter
                    };
                        String filterString = JSON.serialize(reportFilters);
            Boolean isInternalUserWithoutRPM = false;
            Boolean isRPMUser = false;
            Boolean isExternalUser = false;
            if(userHasValidPermissionSet(internalPSWithRPM)) {
                isRPMUser = true;
            } else if(userHasValidPermissionSet(internalPSWithoutRPM)) {
                isInternalUserWithoutRPM = true;
            } else if(userHasValidPermissionSet(externalPS)) {
                isExternalUser = true;
            }
            if(isRPMUser || isInternalUserWithoutRPM) {
                fullRecordURL = URL.getSalesforceBaseURL().toExternalForm().split('\\.')[0];
                reportName = Label.Pricing_Tender_Report_GenerateInternalReport;
                fullRecordURL = fullRecordURL.toLowerCase() + '.lightning.force.com/lightning/r/Report/';
            } else if(isExternalUser) {
                fullRecordURL = URL.getSalesforceBaseURL().toExternalForm();
                reportName = Label.Pricing_Tender_Report_GenerateExternalReport;
            }
            if(!Test.isRunningTest()) {
                generateReportRecord = [SELECT Id, Name FROM Report where DeveloperName = : reportName Limit 1];
            }
            if(isRPMUser) {
                fullRecordURL = fullRecordURL + generateReportRecord.Id + '/view?fv0=' + quote.Name + '&fv1=' + Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
            } else if(isInternalUserWithoutRPM) {
                fullRecordURL = fullRecordURL + generateReportRecord.Id + '/view?fv0=' + quote.Name + '&fv1=' + Label.Pricing_Tender_PicklistValue_AllQLStatus;
            } else if(isExternalUser && Network.getNetworkId() != null) {
                fullRecordURL = Network.getLoginUrl(Network.getNetworkId());
                fullRecordURL = fullRecordURL.removeEnd('login') + 'report/' + generateReportRecord.Id + '?reportFilters=' + filterString;
            }
        }
        catch(Exception e){
            //retMsg = Pricing_Tender_Utility.getExceptionMessage(e);
            //system.debug('retMsg==>'+retMsg);          
            Pricing_Tender_Utility.logError(e);        
        }
        return fullRecordURL;
        
    }
    public Class ReportFilters {
        public String operator;
        public String value;
        public String column;
        public ReportFilters(String str1, String str2, String str3) {
            this.operator = str1;
            this.value = str2;
            this.column = str3;
        }
    }
    @AuraEnabled
    public Static String insertOutbound(Id parentId,String action) 
    {
        Map<Id,String> quoteLineIdToActionMap = new Map<Id,String>();
        Map<Id,String> quoteLineIdToErrorMap = new Map<Id,String>();
        Map<Id,SBQQ__QuoteLine__c> quoteLineMap;
        quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, 
                                                       SBQQ__Quote__r.Name, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,
                                                       Pricing_Reference_Quote_Line_Nbr__c,SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,
                                                       SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,
                                                       SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,
                                                       Pricing_Manager__r.Core_WWID__c,SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_CIM_ID__c,
                                                       Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,
                                                       Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,
                                                       Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                                       Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_Deal_RFQ_Status_Nm__c, 
                                                       Pricing_Quote_Line_Number__c,//Pricing_Market_Segment_values_Nm__c,
                                                       Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c,
                                                       Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c,
                                                       SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,
                                                       Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,Pricing_Competetor_Product__r.Name,
                                                       SBQQ__Quote__r.Pricing_End_Customer__r.Name,SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c,
                                                       SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c,
                                                       (SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,
                                                        Pricing_Performance_Metric_Nm__c FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) FROM SBQQ__QuoteLine__c WHERE 
                                                       Id IN : (new Set<Id>{parentId})]); 
        Pricing_IntegrationSFDCToPricingSystems integrationSystem =  new Pricing_IntegrationSFDCToPricingSystems(); 
        quoteLineIdToErrorMap.putAll(integrationSystem.validationMethod(quoteLineMap.values()));
        
        if(quoteLineIdToErrorMap.containsKey(parentId) && quoteLineIdToErrorMap.get(parentId) == 'Success'){
            quoteLineIdToActionMap.put(parentId,action);
            User loggedInUser = [SELECT Id,Name,Core_WWID__c from User where Id =: userInfo.getUserId()];
            quoteLineIdToErrorMap = Pricing_IntegrationSFDCToPricingSystems.insertQuoteOutBoundMessage(quoteLineIdToActionMap,quoteLineMap,loggedInUser.Core_WWID__c,true);
        }
        
        
        return quoteLineIdToErrorMap.get(parentId);
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
       // [SELECT SBQQ__ProductName__c,Pricing_Integration_Status_Nm__c,Pricing_Reference_Quote_Line_Nbr__c,Pricing_Status_Nm__c FROM SBQQ__QuoteLine__c WHERE Id IN: quoteLineIdSet]
        for(SBQQ__QuoteLine__c quoteLine: SEL_QuoteLines.newInstance().selectById(quoteLineIdSet)) {
            if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) {
                if(quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product 
                && quoteLine.Pricing_Integration_Status_Nm__c == Label.Pricing_Tender_MyDeal_Integration_Status_Complete 
                && quoteLine.Pricing_Reference_Quote_Line_Nbr__c == null) {
                    validQlIdToIsIntegrationRejectMap.put(quoteLine.Id , true);
                } else {
                    validQlIdToIsIntegrationRejectMap.put(quoteLine.Id , false);
                }
            }                                 
        }
        return validQlIdToIsIntegrationRejectMap;
    }
        
    
    @AuraEnabled
    public static Boolean isNotUnifiedQuoteLine(Id quoteLineId) {
        Boolean isUnifiedQuoteLine;
        Set<Id> quoteLineIdSet = isNotUnifiedQuoteLineBulk(new Set<Id>{quoteLineId});
        if(quoteLineIdSet.size() > 0){
            isUnifiedQuoteLine = true;
        }
        else{
            isUnifiedQuoteLine = false;
        }
        return isUnifiedQuoteLine;
    }

    public static set<Id> isNotUnifiedQuoteLineBulk(Set<Id> quoteLineIdSet) {
        Set<Id>  isNotUnifiedQLSet =  new Set<Id>();        
        List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id FROM SBQQ__QuoteLine__c where Id IN: quoteLineIdSet
                                                 AND SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c = false 
                                                 AND SBQQ__Product__r.Name !=: Label.Pricing_Write_In_Product];

        if(quoteLineList.size() > 0) {
            for(SBQQ__QuoteLine__c ql : quoteLineList){
                isNotUnifiedQLSet.add(ql.Id);
            }
        }
        return isNotUnifiedQLSet;
    }

    @AuraEnabled
    public static Id getRecordTypeId(String programTypeName){
        system.debug(programTypeName);
        Id recordTypeId;
        if(programTypeName == Label.Pricing_Tender_Standard_Quote){
          recordTypeId =  Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c',Label.Pricing_Tender_Quote_Line_Create);
        }
        else if(programTypeName == Label.Pricing_Tender_Small_Volume_Quote){
            recordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c',Label.Pricing_SVD_Quote_Line_Create);
          }
          system.debug(recordTypeId);
          return recordTypeId;
    }
*/    
}