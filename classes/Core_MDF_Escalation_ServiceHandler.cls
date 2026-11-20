/****************************************************************************************************************************************
* Class Name  : Core_MDF_Escalation_ServiceHandler 
* Created Date: 15-05-2019
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shridhar             15-05-2019         Service Class for updating Channel Program on Escalations for Sharing the records
* Ayush                13-01-2025         Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Escalation_ServiceHandler {
    public static Boolean iserrorOccured = false;
    public static Boolean isBusinessErrorOccured = false;
    public static String errorMessage = ''; 
    private static string ESC_APPROVED_STATUS = Core_MDF_CCP_ConstantClass.ESC_APPROVED_STATUS;
    private static string TYPE_CLAIM = Core_MDF_CCP_ConstantClass.TYPE_CLAIM; 
    private static string LATECLAIM_TYPE = Core_MDF_CCP_ConstantClass.LATECLAIM_TYPE;  
    public static List <string> byPassValidationBasedOnStatus = Core_MDF_CCP_ConstantClass.ESC_CANCELLED_EXPIRED_STATUS.split(';');
    
    /*************************************************************************************************** 
    Method Name:        initializeEscalationFields
    @return  :          void
    @parameters:        List<Core_MDF_Escalation__c> List of updated escalations
    Description:        This method is used to intialize the escalation fields
    Added By:           Accenture - SK - 19/5/2019
    Modified By:        Date:       Changes: 
    Manasa              24-6-2019   Modified code to include Activity Lookup changes
    Ayush               13-01-2025  Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
    *******************************************************************************************************/
    public static void initializeEscalationFields(List<Core_MDF_Escalation__c> escalationList, Map<Id,Core_MDF_Escalation__c> escalationOldMap,Boolean isInsert){
        try{
            Id escBudgetRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Budget').getRecordTypeId();
            Id escCaseRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId(); 
            Id escActivityRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();   
            string IPA_PROG = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;
            List<string> ELIGIBLE_PAYMENT_TYPE = (System.Label.Core_MDF_IPA_PaymentTypes_to_hideBank != null) ? System.Label.Core_MDF_IPA_PaymentTypes_to_hideBank.split(',') : new List<String>();
            List<Core_MDF_Escalation__c> escalationToBoProcessed  = new List<Core_MDF_Escalation__c>();
            
            Set<Id> budgetIdSet = new Set<Id>();
            Set<Id> caseIdSet = new Set<Id>();
            Set<Id> activityIdSet = new Set<Id>();
            Set<Id> caseIdSetforCS = new Set<Id>();
            Set<Id> claimSubIdSet = new Set<Id>();
            Map<Id,Id> budgetIdWithProgramId = new Map<Id,Id>();
            Map<Id,Id> caseIdWithProgramId = new Map<Id,Id>();
            Map<Id,Id> caseIdWithAccId = new Map<Id,Id>();
            Map<Id,Id> activityIdWithProgramId = new Map<Id,Id>();
            Map<Id,Id> activityIdWithAccId = new Map<Id,Id>();
            Map<Id,String> activityIdWithAccountId = new Map<Id,String>();
            Set<Id> actIdAccIdSet = new Set<Id>();
            Set<Id> clmIdAccIdSet = new Set<Id>();
            Set<Id> clmIdBankIdSet = new Set<Id>();
            Map<Id,String> caseIdWithAccIdBankIdMap = new Map<Id,String>();
            //1. US1033391
            Map<Id,String> caseIdToAccIdMap = new Map<Id,String>();
            Map<String, Boolean> abmActiveMap = new Map<String, Boolean>();
            Map<Id, Boolean> accIdWithActiveInd = new Map<Id, Boolean>();
            //Added by ganapati
            Map<Id,String> caseIdWithCaseReviewFindings = new Map<Id,String>();
            List<Core_MDF_Escalation__c> escToUpdateCaseDetailsList = new List<Core_MDF_Escalation__c>();
            set<Id> caseIds = new set<Id>();
            //US625712 : Late Claim - Escalation Creation SLA
            Map<String,Date> dueDateMap = new Map<String,Date>();
            Map<String,Date> submissionWindowMap = new Map<String,Date>();
            Map<String,Date> closureWindowMap = new Map<String,Date>(); 
            Map<id,string> pfrIdToKeyMap = new Map<id,string>();
            
           // Map<Id,String> escIdWithCountryMap = new Map<Id,String>();
                                  
            String loggedInUser = userInfo.getUserId();
            String loggedInUserType = userInfo.getUserType();
            
            for(Core_MDF_Escalation__c esc: escalationList){
                
                Boolean isCaseEsc = false;
                Boolean isLateClaimEsc = false;
                               
                //Set Status to Pending Review for all escalation
                if(isInsert){
                    esc.Core_MDF_Approved_Amount_amt__c = esc.Core_MDF_Total_Dollar_Impact_amt__c;
                    esc.Core_MDF_Claim_Review_Closure_Note_txt__c = null;
                    esc.Core_MDF_Escalation_Status_nm__c = 'Pending Review';
		    //Added by Akash- to fix the population of claim field during the clone
                    if(escalationOldMap == null && esc.Core_MDF_Claim_Number_id__c != null){
                    	esc.Core_MDF_Claim_Number_id__c = null;
                	}
                }
                if(esc.recordTypeId == escBudgetRecTypeId && esc.Core_MDF_Budget_ID_Number_id__c != null &&
                   (isInsert || esc.Core_MDF_Budget_ID_Number_id__c != escalationOldMap.get(esc.Id).Core_MDF_Budget_ID_Number_id__c)){
                    escalationToBoProcessed.add(esc);
                    budgetIdSet.add(esc.Core_MDF_Budget_ID_Number_id__c);                
                }
                if(esc.recordTypeId == escCaseRecTypeId && esc.Core_MDF_Case_ID_Number_id__c != null){
                    Boolean escalationToUpdate = FALSE;
                    isCaseEsc = TRUE;
                    if(isInsert){
                        esc.Core_MDF_Total_Dollar_Impact_amt__c = null;
                        esc.Core_MDF_Approved_Amount_amt__c = null;
                    }
                    if(isInsert || (esc.Core_MDF_Case_ID_Number_id__c != escalationOldMap.get(esc.Id).Core_MDF_Case_ID_Number_id__c)){
                        escalationToUpdate = TRUE;
                        caseIdSet.add(esc.Core_MDF_Case_ID_Number_id__c);
                        escToUpdateCaseDetailsList.add(esc);
                        caseIds.add(esc.Core_MDF_Case_ID_Number_id__c);
                    }
                    //2. US1033391: prepare caseIdSet to validate AutoClaimCreate
                    if(!isInsert && esc.Core_MDF_Do_not_Auto_Create_Claim_Ind__c != escalationOldMap.get(esc.Id).Core_MDF_Do_not_Auto_Create_Claim_Ind__c && 
                       escalationOldMap.get(esc.Id).Core_MDF_Do_not_Auto_Create_Claim_Ind__c && !esc.Core_MDF_Do_not_Auto_Create_Claim_Ind__c){
                        escalationToUpdate = TRUE;                           caseIdSet.add(esc.Core_MDF_Case_ID_Number_id__c);
                    }
                    //US1092465: 1. commented isClaimSubmitter changed check, to trigger validation while Case Escalation approval as well
                    if(!isInsert && esc.Core_MDF_Claim_Submitter_Id__c != NULL/*&& esc.Core_MDF_Claim_Submitter_Id__c != escalationOldMap.get(esc.Id).Core_MDF_Claim_Submitter_Id__c*/){
                        escalationToUpdate = TRUE; caseIdSetforCS.add(esc.Core_MDF_Case_ID_Number_id__c);
                    }
                     
                    if(escalationToUpdate){
                        escalationToBoProcessed.add(esc);
                    }                   
                }
                
                /*if(esc.recordTypeId == escCaseRecTypeId && esc.Core_MDF_Case_ID_Number_id__c != null &&
                   (isInsert || (esc.Core_MDF_Case_ID_Number_id__c != escalationOldMap.get(esc.Id).Core_MDF_Case_ID_Number_id__c || esc.Core_MDF_Claim_Submitter_Id__c != escalationOldMap.get(esc.Id).Core_MDF_Claim_Submitter_Id__c))){
                    escalationToBoProcessed.add(esc);
                    caseIdSet.add(esc.Core_MDF_Case_ID_Number_id__c);
                    isCaseEsc = true;
                }*/                                      
                
                //checking if Core_MDF_Co_Marketing_Activity_id__c is not null and adding it to activityIdSet based upon following conditions
                //US1092465: 2. commented isClaimSubmitter changed check & added isUpdate check to trigger validation while Late Escalation approval as well
                if(esc.recordTypeId == escActivityRecTypeId && esc.Core_MDF_Co_Marketing_Activity_id__c != null){
                    if(isInsert || (esc.Core_MDF_Co_Marketing_Activity_id__c != escalationOldMap.get(esc.Id).Core_MDF_Co_Marketing_Activity_id__c || (!isInsert && esc.Core_MDF_Claim_Submitter_Id__c != NULL)/* || esc.Core_MDF_Claim_Submitter_Id__c != escalationOldMap.get(esc.Id).Core_MDF_Claim_Submitter_Id__c*/)){
                       escalationToBoProcessed.add(esc);
                       activityIdSet.add(esc.Core_MDF_Co_Marketing_Activity_id__c); 
                       isLateClaimEsc = true;
                    }                    
                }
                //1. Based on US843424: added check for Case Type of Ecsalation 
                if(isCaseEsc || isLateClaimEsc){
                    
                    //while insert/ update
                    //US1092465: 3. added isUpdate check
                    if(isInsert || esc.Core_MDF_Claim_Submitter_Id__c != escalationOldMap.get(esc.Id).Core_MDF_Claim_Submitter_Id__c || (!isInsert && esc.Core_MDF_Claim_Submitter_Id__c != NULL)){
                      
                       claimSubIdSet.add(esc.Core_MDF_Claim_Submitter_Id__c);
                    } 
                    if(esc.Core_MDF_Claim_Number_id__c != null && esc.Core_MDF_Claim_Submitter_Id__c == null && loggedInUserType.equals('PowerPartner')){ 
                        esc.Core_MDF_Claim_Submitter_Id__c = loggedInUser; // for External Retail Claim Submitter
                    }                    
                }              
            }
           
            if(!escToUpdateCaseDetailsList.isEmpty() && !caseIds.isEmpty() && !Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_Case_Details_On_Esc')){
                populateCaseDetails(escToUpdateCaseDetailsList,caseIds);
            }

            if(caseIdSetforCS != NULL && !caseIdSetforCS.isEmpty()){                
                for(Case cs : [SELECT Id, AccountId FROM Case WHERE ID IN: caseIdSetforCS]){
                    caseIdWithAccId.put(cs.ID,cs.AccountID);
                }
            }
            
            if(budgetIdSet.size() > 0 ){
                for(PartnerMarketingBudget pmb: [SELECT Id, Core_MDF_Program__c FROM PartnerMarketingBudget WHERE Id IN: budgetIdSet]){
                    budgetIdWithProgramId.put(pmb.Id,pmb.Core_MDF_Program__c);
                }           
            }
            
            if(caseIdSet.size() > 0){
                // US949836 : New Budget Type field changes replaced txt field with new global picklist field
                for(PartnerFundclaim pfc: [SELECT Id, ChannelPartnerId,RequestId, Request.Core_MDF_Budget_Type_nm__c, Core_MDF_Bank__c,Core_MDF_Claim_Review_Case__c, 
                                           Core_MDF_Claim_Review_Case__r.AccountId, Core_MDF_Claim_Review_Case__r.Account.Core_MDF_Channel_Program__c,
                                           ChannelPartner.Core_MDF_Active_Ind__c, RecordType.DeveloperName,Core_MDF_Audit_Adjustment_Amount__c,ChannelPartner.Core_MDF_Payment_Type_nm__c,
                                           Core_MDF_Claim_Review_Case__r.Core_MDF_Adjustment_Amount_USD_Amt__c,Core_MDF_Region_Cd__c,Core_MDF_Country_Location_nm__c,ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c,
                                           Core_MDF_Claim_Review_Case__r.Core_MDF_Non_Compliance_Reason_txt__c,Core_MDF_Paid_By_Payment_Type_nm__c,Core_MDF_Program__c
                                           FROM PartnerFundclaim
                                           WHERE Core_MDF_Claim_Review_Case__c IN: caseIdSet]){
                    caseIdWithProgramId.put(pfc.Core_MDF_Claim_Review_Case__c, pfc.Core_MDF_Claim_Review_Case__r.Account.Core_MDF_Channel_Program__c);
                    //Added by ganapati
                    caseIdWithCaseReviewFindings.put(pfc.Core_MDF_Claim_Review_Case__c, pfc.Core_MDF_Claim_Review_Case__r.Core_MDF_Non_Compliance_Reason_txt__c);
                    clmIdAccIdSet.add(pfc.ChannelPartnerId);

                    //3. Based on US843424: populating case's Account based on caseId                         
                    caseIdWithAccId.put(pfc.Core_MDF_Claim_Review_Case__c,pfc.Core_MDF_Claim_Review_Case__r.AccountId); 
                    
                    clmIdBankIdSet.add(pfc.Core_MDF_Bank__c);
                                                
                    //escIdWithCountryMap.put(pfc.Core_MDF_Claim_Review_Case__c,pfc.Core_MDF_Country_Location_nm__c);      
                                               
                    //Prepare Map to fetch Account+Bank from Claim  
                    //if(pfc.RecordType.DeveloperName != Label.Core_MDF_RMF_MD_Record_Type_Developer_Name){ 
                    // US949836 : New Budget Type field changes replaced txt field with new global picklist field 
		    string paymentType = string.isNotBlank(pfc.ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c) ? pfc.ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c : pfc.ChannelPartner.Core_MDF_Payment_Type_nm__c;
                                               if(pfc.Request.Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_RSAMD_UnTranslated') 
                                                  && pfc.Request.Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDF') 
                                                  && pfc.Request.Core_MDF_Budget_Type_nm__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_MDFPlus')
                                                 && (pfc.Core_MDF_Program__c == IPA_PROG && !ELIGIBLE_PAYMENT_TYPE.contains(paymentType))){ 
                                                   caseIdWithAccIdBankIdMap.put(pfc.Core_MDF_Claim_Review_Case__c, (String)pfc.ChannelPartnerId+pfc.Core_MDF_Bank__c);
                                                   //3. US1033391: Populate map: CaseToAccount to validate ABM for Case Esc
                                                   caseIdToAccIdMap.put(pfc.Core_MDF_Claim_Review_Case__c, (String)pfc.ChannelPartnerId);
                                               }
                                               accIdWithActiveInd.put(pfc.ChannelPartnerId, pfc.ChannelPartner.Core_MDF_Active_Ind__c);                     
                                               //caseIdAdjustmentAmountMap.put(pfc.Core_MDF_Claim_Review_Case__c,pfc.Core_MDF_Claim_Review_Case__r.Core_MDF_Adjustment_Amount_USD_Amt__c);
                                               
                                               /*caseIdAdjustmentAmountMap.put(pfc.Core_MDF_Claim_Review_Case__c,
pfc.Core_MDF_Claim_Review_Case__r.Core_MDF_Adjustment_Amount_USD_Amt__c != NULL ? (pfc.Core_MDF_Claim_Review_Case__r.Core_MDF_Adjustment_Amount_USD_Amt__c.setScale(2,System.RoundingMode.HALF_UP)) : pfc.Core_MDF_Claim_Review_Case__r.Core_MDF_Adjustment_Amount_USD_Amt__c);*/
                                           }               
                
                
            } 
            
            
            
            //Query Channel Program from Activity and add channel program Id to activityIdWithProgramId Map
            //Query Account from Activity and add to activityIdWithAccId Map
            // US949836 : New Budget Type field changes replaced txt field with new global picklist field
            if(activityIdSet.size() > 0){
                String japanCntry, ultimateAcctCtryGeo;
                for(PartnerFundRequest pfr: [SELECT Id, ChannelPartner.Core_MDF_Channel_Program__c, ChannelPartner.Core_MDF_Active_Ind__c, 
                                             ChannelPartnerId, Core_MDF_Program__c, Core_MDF_Budget_Type_nm__c,Core_MDF_Region_nm__c,Core_MDF_Sub_Region_nm__c,Core_MDF_Country_nm__c, Core_MDF_End_Date__c,
                                             Tolabel(ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode),ChannelPartner.Core_MDF_Payment_Type_nm__c,ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c, 
                                             ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Geo__c
                                             FROM PartnerFundRequest 
                                             WHERE Id IN: activityIdSet]){
                    activityIdWithProgramId.put(pfr.Id,pfr.ChannelPartner.Core_MDF_Channel_Program__c);
                    activityIdWithAccId.put(pfr.Id,pfr.ChannelPartnerId);                           
                    //escIdWithCountryMap.put(pfr.Id,pfr.Core_MDF_Country_nm__c);
                                                 
                    //As per US846978, getting Ulti Account Country, Geo                             
                    japanCntry = pfr.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode; 
                    ultimateAcctCtryGeo = pfr.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Geo__c;
                    if(String.isNotBlank(japanCntry)) {
                       japanCntry = japanCntry.toUpperCase();
                    }                              
                    //Prepare Map to fetch Activity's Account
                    // US949836 : New Budget Type field changes replaced txt field with new global picklist field
	           string paymentType = string.isNotBlank(pfr.ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c) ? pfr.ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c : pfr.ChannelPartner.Core_MDF_Payment_Type_nm__c;
                                                 if(pfr.Core_MDF_Budget_Type_nm__c != 'RSA MD' && pfr.Core_MDF_Budget_Type_nm__c != 'MDF' 
                                                    && pfr.Core_MDF_Budget_Type_nm__c != 'MDF+' 
                                                    && (pfr.Core_MDF_Program__c == IPA_PROG && !ELIGIBLE_PAYMENT_TYPE.contains(paymentType))) {
                         activityIdWithAccountId.put(pfr.Id,(String)pfr.ChannelPartnerId);
                         actIdAccIdSet.add(pfr.ChannelPartnerId);                           
                    }
                    accIdWithActiveInd.put(pfr.ChannelPartnerId, pfr.ChannelPartner.Core_MDF_Active_Ind__c);
                    string key, country, geo, subgeo;                                              
                                                 
                    if(pfr.Core_MDF_Program__c == 'Retail Marketing Funds'){
                        country =  'null';//pfr.Core_MDF_Country_nm__c; 
			//US1098882
                        //geo = pfr.Core_MDF_Region_cd__c; 
                        geo = pfr.Core_MDF_Region_nm__c; 
                        subgeo = 'null';
                        //As per US846978, forming key for JAPAN cycle
                        // US949836 : New Budget Type field changes replaced txt field with new global picklist field
                        //Mohit - Align japan cycle with 4 quarter(3 months a quarter)
                        /*if(System.Label.Core_MDF_Retail_RSA_MD_Budget_Type.equals(pfr.Core_MDF_Budget_Type_nm__c) &&  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Country_JAPAN').equals(japanCntry)){  
                            country = japanCntry;    
                            geo = ultimateAcctCtryGeo;   
                            subgeo =  'null';                              
                        }*/        
                        key = pfr.Core_MDF_Program__c+':'+pfr.Core_MDF_Budget_Type_nm__c+
                              ':'+geo+':'+subgeo+
                              ':'+country+':'+pfr.Core_MDF_End_Date__c.format();                                   
                        
                        key = key.deleteWhitespace();
                        dueDateMap.put(key,null);
                        pfrIdToKeyMap.put(pfr.id,key); 
                    }
                                   
                }
                 
             }
            
            Set<ID> validClaimSubmitters = new Set<ID>();
            Set<ID> cscClaimSubmitters = new Set<ID>();
            Set<ID> validExtrnlClaimSubmitrs = new Set<ID>();
            Set<ID> validIntrnlClaimSubmitrs = new Set<ID>();
            Map<Id,Set<Id>> userIDwithAccIdMap = new Map<Id,Set<Id>>();
            //US867533 : [RMF] - PRC Mystery Shopper to submit Late Claim
            if(claimSubIdSet.size() > 0){                
                List<String> claimSubmitterPSList = Label.Core_MDF_Claim_Submitter.split(';'); 
                //for(Id claimSubId : claimSubIdSet){
                    //Querying the permission set assigned to the user
                    //US1092465: 4. Added userActive check
                    for(PermissionSetAssignment usrPer : [SELECT Id, AssigneeId,PermissionSet.Name
                                                          FROM PermissionSetAssignment
                                                          WHERE AssigneeId IN :claimSubIdSet
                                                          AND PermissionSet.Name = :claimSubmitterPSList
                                                          AND (Assignee.IsActive = TRUE OR Assignee.Partner_License_Reclaimed__c = true)]){ //Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
                        validClaimSubmitters.add(usrPer.AssigneeId); //If US is not assigned with ext clm sub PS
                        String permissionSet = usrPer.PermissionSet.Name;                                  
                        
                        for(String lst : Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_Claim_Submitter').split(';')){
                            if(permissionSet.contains(lst)){
                                validExtrnlClaimSubmitrs.add(usrPer.AssigneeId);
                            }  
                        }
                        
                        if(permissionSet.contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_PRC_ClaimSubmitter'))){ validIntrnlClaimSubmitrs.add(usrPer.AssigneeId);}
			  if(permissionSet.contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_CSC_Claim_Submitter'))){
                                                             cscClaimSubmitters.add(usrPer.AssigneeId);
                                                          }
                    }
                
                //Querying the pnum of the user and adding it to map
                //2. Based on US843424: added filter for Account: caseIdWithAccId.values()
                //if(externalClaimSubmitterFlag){
                if(validExtrnlClaimSubmitrs.size() > 0){
                    //US1092465: 4. Added userActive check
                    for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id,Core_MDF_Account__c, Core_MDF_User__c 
                                                                      FROM Core_MDF_Partner_Node_User_Mapping__c
                                                                      WHERE (Core_MDF_User__r.IsActive = TRUE OR Core_MDF_User__r.Partner_License_Reclaimed__c = TRUE) AND //Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
                                                                            (Core_MDF_Account__c IN: activityIdWithAccId.values() OR 
                                                                            Core_MDF_Account__c IN: caseIdWithAccId.values()) AND
                                                                            Core_MDF_User__c IN: claimSubIdSet and Core_MDF_Active_Ind__c = true ]){
                                                                                if(userIDwithAccIdMap.containsKey(pnum.Core_MDF_Account__c)){ 
                                                                                    userIDwithAccIdMap.get(pnum.Core_MDF_Account__c).add(pnum.Core_MDF_User__c);    
                                                                                }else{
                                                                                    userIDwithAccIdMap.put(pnum.Core_MDF_Account__c,new Set<Id>{pnum.Core_MDF_User__c});  
                                                                                }  
                                                                                validClaimSubmitters.add(pnum.Core_MDF_User__c);
                                                                            }  
                    
                }
                if(validIntrnlClaimSubmitrs.size() > 0){
                    //Querying the IUPGM of the user and adding it to map -Mystery Shopper
                    for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Id,Core_MDF_Account_id__c,Core_MDF_User_id__c,Core_MDF_Active_Ind__c
                                                                        FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                        WHERE (Core_MDF_Account_id__c IN: activityIdWithAccId.values() OR 
                                                                        Core_MDF_Account_id__c IN: caseIdWithAccId.values()) AND
                                                                        Core_MDF_User_id__c IN: claimSubIdSet AND Core_MDF_is_User_Active_ind__c = TRUE
                                                                        AND Core_MDF_Active_Ind__c = TRUE AND Core_MDF_Role_nm__c = :Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_PRC_ClaimSubmitter')]){
                                                                            if(userIDwithAccIdMap.containsKey(iupgm.Core_MDF_Account_id__c)){
                                                                                userIDwithAccIdMap.get(iupgm.Core_MDF_Account_id__c).add(iupgm.Core_MDF_User_id__c);
                                                                            }else{
                                                                                userIDwithAccIdMap.put(iupgm.Core_MDF_Account_id__c,new Set<Id>{iupgm.Core_MDF_User_id__c});
                                                                            }
                                                                            validClaimSubmitters.add(iupgm.Core_MDF_User_id__c);
                                                                        }
                }
                
            }
            if(pfrIdToKeyMap != null && !pfrIdToKeyMap.isEmpty()){
                submissionWindowMap = Core_MDF_ProcessClaimSubmissionClosure.getSubmissionDueDate(dueDateMap);                
                closureWindowMap = Core_MDF_ProcessClaimSubmissionClosure.getEscSubDate(dueDateMap);
            }
            //US1033391: 4. Added clmIdAccIdSet as filter for Account
            for(Core_MDF_Account_Bank_Mapping__c abm: [Select Id, Core_MDF_Account__c, Core_MDF_Bank__c, Core_MDF_Active_ind__c, Core_MDF_AccountIdBankIdMapping__c 
                                                       from Core_MDF_Account_Bank_Mapping__c 
                                                       where ((Core_MDF_Account__c IN: actIdAccIdSet) OR 
                                                       (Core_MDF_Account__c IN: clmIdAccIdSet) OR 
                                                       (Core_MDF_Account__c IN: clmIdAccIdSet AND Core_MDF_Bank__c IN: clmIdBankIdSet))]){
                //Check ABM, for Late Claim Escalation or for Case Escalation                                   
                if(!abmActiveMap.containskey(abm.Core_MDF_Account__c)){
                    abmActiveMap.put(abm.Core_MDF_Account__c, abm.Core_MDF_Active_ind__c);                
                }else if(abmActiveMap.containskey(abm.Core_MDF_Account__c) && !abmActiveMap.get(abm.Core_MDF_Account__c) && abm.Core_MDF_Active_ind__c){ 
                    abmActiveMap.put(abm.Core_MDF_Account__c, abm.Core_MDF_Active_ind__c);
                }     
                
                //US1033391: 5. use below code that checks for Account & Bank combination to create AutoClaim
                                                          
                //Check ABM, for Case Escalation
                if(!abmActiveMap.containskey((String)abm.Core_MDF_Account__c+abm.Core_MDF_Bank__c)){
                    abmActiveMap.put((String)abm.Core_MDF_Account__c+abm.Core_MDF_Bank__c, abm.Core_MDF_Active_ind__c);                
                }else if(abmActiveMap.containskey((String)abm.Core_MDF_Account__c+abm.Core_MDF_Bank__c) && !abmActiveMap.get((String)abm.Core_MDF_Account__c+abm.Core_MDF_Bank__c) && abm.Core_MDF_Active_ind__c){
                    abmActiveMap.put((String)abm.Core_MDF_Account__c+abm.Core_MDF_Bank__c, abm.Core_MDF_Active_ind__c);
                }                                            
            }
            
            //Set Program for esclation
            for(Core_MDF_Escalation__c esc: escalationToBoProcessed){
                
                //4. Based on US843424: added checks for case escalation: (a)caseIdSet contains caseId on Esc (b)caseIdWithAccId not null
                //Avoid Deeply Nested IF Statements
                    Boolean displayError = false;
                    set<ID> submitterSet = new set<ID>();
                    //checks for Late Claim Escalations
                    if(esc.Core_MDF_Claim_Submitter_Id__c != null && esc.Core_MDF_Co_Marketing_Activity_id__c != null && activityIdSet.contains(esc.Core_MDF_Co_Marketing_Activity_id__c) 
                    && activityIdWithAccId != null && !activityIdWithAccId.isEmpty()){
                        Id activityAccountId = activityIdWithAccId.get(esc.Core_MDF_Co_Marketing_Activity_id__c);
                        if(activityAccountId != NULL && userIDwithAccIdMap.get(activityAccountId) != NULL){
                            submitterSet = userIDwithAccIdMap.get(activityAccountId);
                        }
                    }
                    //checks for Case Escalations
                    else if(esc.Core_MDF_Claim_Submitter_Id__c != null && esc.Core_MDF_Case_ID_Number_id__c != null && (caseIdSet.contains(esc.Core_MDF_Case_ID_Number_id__c) || caseIdSetforCS.contains(esc.Core_MDF_Case_ID_Number_id__c)) 
                            && caseIdWithAccId != NULL && !caseIdWithAccId.isEmpty()){            
                                Id caseAccId = caseIdWithAccId.get(esc.Core_MDF_Case_ID_Number_id__c);
                                if(caseAccId != NULL && userIDwithAccIdMap.get(caseAccId) != NULL){               
                                    submitterSet = userIDwithAccIdMap.get(caseAccId);// get pnum user for that Account on Case
                                }             
                    }
                    
                    //If user is not assigned with ext clm sub PS || not associated with activity's/ case's Account
                    if(esc.Core_MDF_Claim_Submitter_Id__c != null && (submitterSet == null || (submitterSet != null && (submitterSet.isEmpty() || !submitterSet.contains(esc.Core_MDF_Claim_Submitter_Id__c)))) && (cscClaimSubmitters==null ||(cscClaimSubmitters!=null && !cscClaimSubmitters.contains(esc.Core_MDF_Claim_Submitter_Id__c)))){ 
                        displayError = TRUE; //if Clm Sub is not Account User
                    }

                    Boolean isClaimSubmitterUpdated = (isInsert || (!isInsert && esc.Core_MDF_Claim_Submitter_Id__c != escalationOldMap.get(esc.Id).Core_MDF_Claim_Submitter_Id__c));
                    if(esc.Core_MDF_Claim_Submitter_Id__c != null && ((!validClaimSubmitters.contains(esc.Core_MDF_Claim_Submitter_Id__c) || displayError ) &&(cscClaimSubmitters==null ||(cscClaimSubmitters!=null && !cscClaimSubmitters.contains(esc.Core_MDF_Claim_Submitter_Id__c))))
                      && !byPassValidationBasedOnStatus.contains(esc.Core_MDF_Escalation_Status_nm__c) && isClaimSubmitterUpdated){
                        
                        esc.addError(Label.Core_MDF_Claim_Submitter_User_Check); 
                        
                        
                    }
                
                if(esc.recordTypeId == escBudgetRecTypeId && budgetIdSet.size() > 0 && budgetIdWithProgramId.containsKey(esc.Core_MDF_Budget_ID_Number_id__c)){
                    esc.Core_MDF_Program_txt__c = budgetIdWithProgramId.get(esc.Core_MDF_Budget_ID_Number_id__c);
                    esc.Core_MDF_Channel_Program_id__c = budgetIdWithProgramId.get(esc.Core_MDF_Budget_ID_Number_id__c); 
                  }
                
                if(esc.recordTypeId == escCaseRecTypeId && caseIdSet.size() > 0 && caseIdWithProgramId.containsKey(esc.Core_MDF_Case_ID_Number_id__c)){
                    
                    if(caseIdWithAccIdBankIdMap.containsKey(esc.Core_MDF_Case_ID_Number_id__c) && caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c) != NULL){
                        String accountId = caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c).left(18);
                    
                        //US1033391: 6. Validation for AutoCLaimCreate
                        if(((abmActiveMap.containsKey(caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c)) &&
                             !abmActiveMap.get(caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c))) ||
                            (!abmActiveMap.containsKey(caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c)))) && accIdWithActiveInd.get(accountId)){
                                if((isInsert && !esc.Core_MDF_Do_not_Auto_Create_Claim_Ind__c) || 
                                   (!isInsert && esc.Core_MDF_Do_not_Auto_Create_Claim_Ind__c != escalationOldMap.get(esc.Id).Core_MDF_Do_not_Auto_Create_Claim_Ind__c && 
                                    escalationOldMap.get(esc.Id).Core_MDF_Do_not_Auto_Create_Claim_Ind__c && !esc.Core_MDF_Do_not_Auto_Create_Claim_Ind__c && esc.Core_MDF_Escalation_Status_nm__c == 'Pending Review')){
                                        esc.addError(Label.Core_MDF_CannotAutoCreateClaim); //Escalation cannot be created for an inactive Account Bank Mapping.                                    
                                    }
                            }
                    }
                    
                    //US1033391: 7. If caseToAcc Map has caseId(Key) and has AccId(Value)
                    if(caseIdToAccIdMap.containsKey(esc.Core_MDF_Case_ID_Number_id__c) && caseIdToAccIdMap.get(esc.Core_MDF_Case_ID_Number_id__c) != NULL){
                        String accountId = caseIdToAccIdMap.get(esc.Core_MDF_Case_ID_Number_id__c);
                        
                        //Check if active abm is present for that Account
                        //Check if case's account is active
                        if(accIdWithActiveInd.get(accountId)){
                            //US1033391: 3. If no/zero abm exists on case's account
                            if(!abmActiveMap.containskey(accountId)){
                                esc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Escltion_Err_when_no_ABM_exists')); //Escalation cannot be created as no active Account Bank Mapping exists.  
                            }
                            //US1033391: 4. If abm exists,if abmMap has accId(Key),but abm active indicator(Value) is false or abm Map does not have accId
                            if(((abmActiveMap.containsKey(caseIdToAccIdMap.get(esc.Core_MDF_Case_ID_Number_id__c)) &&
                                 !abmActiveMap.get(caseIdToAccIdMap.get(esc.Core_MDF_Case_ID_Number_id__c))) ||
                                (!abmActiveMap.containsKey(caseIdToAccIdMap.get(esc.Core_MDF_Case_ID_Number_id__c)))) /*&& accIdWithActiveInd.get(accountId)*/){     
                                    esc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Escalation_Err_for_Inactive_ABM')); //Escalation cannot be created for an inactive Account Bank Mapping.    
                                }        
                        } 
                        /*if(((abmActiveMap.containsKey(caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c)) &&
                        !abmActiveMap.get(caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c))) ||
                        (!abmActiveMap.containsKey(caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c)))) && accIdWithActiveInd.get(accountId)){     
                            esc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Escalation_Err_for_Inactive_ABM')); //Escalation cannot be created for an inactive Account Bank Mapping.    
                        }*/
                    }
                    
                    
                    esc.Core_MDF_Program_txt__c = caseIdWithProgramId.get(esc.Core_MDF_Case_ID_Number_id__c);
                    esc.Core_MDF_Channel_Program_id__c = caseIdWithProgramId.get(esc.Core_MDF_Case_ID_Number_id__c);  
                    //Added by ganapati
                    esc.Core_MDF_Case_Review_Findings_txt__c = caseIdWithCaseReviewFindings.get(esc.Core_MDF_Case_ID_Number_id__c);
                    
                   /* if(escIdWithCountryMap != null && escIdWithCountryMap.containsKey(esc.Core_MDF_Case_ID_Number_id__c)){
                        esc.Core_MDF_Country_txt__c = escIdWithCountryMap.get(esc.Core_MDF_Case_ID_Number_id__c);
                    }*/
                    
                }
            
                // setting Channel Program Name and Program Id based on Activity
                if(esc.recordTypeId == escActivityRecTypeId && activityIdSet.size() > 0 && activityIdWithProgramId.containsKey(esc.Core_MDF_Co_Marketing_Activity_id__c)){
                    if(activityIdWithAccountId.containsKey(esc.Core_MDF_Co_Marketing_Activity_id__c) && activityIdWithAccountId.get(esc.Core_MDF_Co_Marketing_Activity_id__c) != NULL){
                        String accId = activityIdWithAccountId.get(esc.Core_MDF_Co_Marketing_Activity_id__c);                        
                        //Check if activity's account is active
                        if(accIdWithActiveInd.get(accId)){
                            //Check if abm is present for that account 
                            if(!abmActiveMap.containskey(accId)){    
                                esc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Escltion_Err_when_no_ABM_exists'));
                            }
                            //Check if active abm is present for that Account
                            else if(abmActiveMap.containsKey(accId) && !abmActiveMap.get(accId)){                                
                                esc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Escalation_Err_for_Inactive_ABM')); //Escalation cannot be created for an inactive Account Bank Mapping.    
                            }
                        }
                    }
                    esc.Core_MDF_Program_txt__c = activityIdWithProgramId.get(esc.Core_MDF_Co_Marketing_Activity_id__c);
                    esc.Core_MDF_Channel_Program_id__c = activityIdWithProgramId.get(esc.Core_MDF_Co_Marketing_Activity_id__c);
                    
                   /* if(escIdWithCountryMap != null && escIdWithCountryMap.containsKey(esc.Core_MDF_Co_Marketing_Activity_id__c)){
                        
                        esc.Core_MDF_Country_txt__c = escIdWithCountryMap.get(esc.Core_MDF_Co_Marketing_Activity_id__c);
                    }*/
                    
                    //need to validate claimsubmissionwindow to create escalation
                    if(pfrIdToKeyMap != null && pfrIdToKeyMap.containsKey(esc.Core_MDF_Co_Marketing_Activity_id__c)){
                        string key = pfrIdToKeyMap.get(esc.Core_MDF_Co_Marketing_Activity_id__c);
                        Date dtToday = System.today();
                        
                        if(submissionWindowMap != null && submissionWindowMap.containsKey(key) && closureWindowMap != null && closureWindowMap.containsKey(key) ){
                            Date submissionDueDate = submissionWindowMap.get(key);
                            Date closureDueDate = closureWindowMap.get(key);
                            esc.Core_MDF_Esc_Submission_End_Date_dtm__c = closureDueDate;
                            
                            if(submissionDueDate != null && closureDueDate != null){
                                if(((closureDueDate != NULL) && !(dtToday > submissionDueDate && dtToday <= closureDueDate))
                                   && !byPassValidationBasedOnStatus.contains(esc.Core_MDF_Escalation_Status_nm__c)){ 
                                    esc.addError(Label.Core_MDF_Late_Claim_Escalation_Creation_Error); //Late Claim Escalation creation window closed
                                }
                            }
                        }
                        
                    }                                                
                } 
               } 
                   
        }        catch(Exception e){String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,Label.Core_MDF_Set_Program_for_Escalation);
        } 
    }
    
    /*************************************************************************************************** 
    Method Name:        shareEscalation
    @return  :          void
    @parameters:        List<Core_MDF_Escalation__c> List of updated escalations
    Description:        This method is used to provide sharing
    Added By:           Accenture - SK - 19/5/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static void shareEscalation(Map<Id,Core_MDF_Escalation__c> escalationMap, Map<Id,Core_MDF_Escalation__c> escalationOldMap,Boolean isInsert){
        try{
            Id escBudgetRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Budget').getRecordTypeId();
            Id escCaseRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId(); 
            Id escActivityRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();           
            string RMF_PROG = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Channel_Program_Name');
            List<Id> escalationIdList  = new List<Id>();
            Set<Id> budgetIdSet = new Set<Id>();
            Set<Id> caseIdSet = new Set<Id>();
            Set<Id> activityIdSet = new Set<Id>();            
            Set<Id> intelAccSet = new Set<Id>();
            Set<Id> channelProgramIdSet = new Set<Id>();   
            
            List<string> ELIGIBLE_PROG = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Escalation_Eligible_Program') != null ? 
                				   Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Escalation_Eligible_Program').split(';') : new List<string>();
            
            
            
            Map<Id,String> budgetEscIdToUltimateAccIdCpIdMap = new Map<Id,String>();
            List<Id> budgetEscUltimateAccIdList = new List<Id>();
            List<Id> budgetEscProgramIdList = new List<Id>();
            
            for(Core_MDF_Escalation__c esc : escalationMap.values()){
                if(isInsert || esc.OwnerId != escalationOldMap.get(esc.Id).OwnerId){
                    escalationIdList.add(esc.Id);
                }
            }            
            // US949836 : New Budget Type field changes replaced txt field with new global picklist field
            // US949927, NK : Budget type consolidation for case
            //US1053743: [IPA Proposal] - Allow Country Selection Across Geo - included Multiselect Region, Sub Region in Query
            List<Core_MDF_Escalation__c> escalationList = [SELECT Id, recordTypeId, OwnerId, Core_MDF_Budget_Type_txt__c, Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Budget_Type_nm__c,
                                                           Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c, 
                                                           Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program_id__c,
                                                           Core_MDF_Case_ID_Number_id__r.Core_Account_Geo__c,Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Host_Region_txt__c,Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,
                                                           Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_nm__c,Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_nm__c,
                                                           Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_Geo__c,Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c,
                                                           Core_MDF_Case_ID_Number_id__r.Core_IPS_Account_Sub_Geo__c,Core_MDF_Case_ID_Number_id__r.Core_MDF_Budget_Type_nm__c,Core_MDF_Channel_Program_id__r.Name,
                                                           Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Id,Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_Group_Id__c,
                                                           Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_Group_Id__c,Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_Group_Id__c,
                                                           Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Case_ID_Number_id__r.Account.Core_Geo__c,Core_MDF_Claim_Submitter_Id__c,
                                                           Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Campaign_Ultimate_Account_Id__c,Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Program__c,
                                                           Core_MDF_Case_ID_Number_id__r.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Campaign_Ultimate_Account_Id__c
                                                           FROM Core_MDF_Escalation__c 
                                                           WHERE ID IN: escalationIdList];
            
            List<Core_MDF_RecordGeoShare> recordGeoShareList = new List<Core_MDF_RecordGeoShare>();
            
            List<String> nonCcpProgramList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Channel_Program_Name').split(';');
           
            for(Core_MDF_Escalation__c esc : escalationList){
                channelProgramIdSet.add(esc.Core_MDF_Channel_Program_id__c);
                Boolean isNodeBasedSharingReqd = Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(esc.Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c);
                //For Budget Escalation
                if(esc.recordTypeId == escBudgetRecTypeId && esc.Core_MDF_Budget_ID_Number_id__c != null){
                    
                    /*if(esc.Core_MDF_Channel_Program_id__r.Name != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Channel_Program_Name')){
                        budgetIdSet.add(esc.Core_MDF_Budget_ID_Number_id__c);
                        intelAccSet.add(esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c);
                    }*/
                    
                    if(!isNodeBasedSharingReqd){
                        budgetIdSet.add(esc.Core_MDF_Budget_ID_Number_id__c);
                        intelAccSet.add(esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c);
                    }else{
                        //To share with Retail Account Manager
                        String accIdCpId = String.valueOf(esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c) + String.valueOf(esc.Core_MDF_Channel_Program_id__c);
                        budgetEscIdToUltimateAccIdCpIdMap.put(esc.Id,accIdCpId); budgetEscProgramIdList.add(esc.Core_MDF_Channel_Program_id__c); budgetEscUltimateAccIdList.add(esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c);
                    }
                    
                    if(esc.Core_MDF_Channel_Program_id__r.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Channel_Program_Name')){
                        //For Finance Manager Sharing
                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(esc.Id,esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_Geo__c,esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c,
                                                                           esc.Core_MDF_Channel_Program_id__r.Name));
                    }
                }
                
                //For Case Escalation
                if(esc.recordTypeId == escCaseRecTypeId && esc.Core_MDF_Case_ID_Number_id__c != null){
                    
                    caseIdSet.add(esc.Core_MDF_Case_ID_Number_id__c);
                    /*if(esc.Core_MDF_Channel_Program_id__r.Name != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Channel_Program_Name')){
                        intelAccSet.add(esc.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c);
                    }*/
                    //only for retail
                    if(!isNodeBasedSharingReqd){
                        intelAccSet.add(esc.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c);
                        //primary account
                        //Set<Id> newSet = new Set<Id>();
                    }
                    //Avoid Deeply Nested IF Statements
                    if(!isNodeBasedSharingReqd && esc.Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c == 'Ecosystem Extension Fund'){
                            intelAccSet.add(esc.Core_MDF_Case_ID_Number_id__r.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Campaign_Ultimate_Account_Id__c);
                    }
                    //US949927, NK : Budget type consolidation for case
                    //ipa******                    
                    String escRegion = (esc.Core_MDF_Channel_Program_id__r.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name')) ? esc.Core_MDF_Case_ID_Number_id__r.Account.Core_Geo__c : esc.Core_MDF_Case_ID_Number_id__r.Core_Account_Geo__c.trim(); 
                    if(esc.Core_MDF_Channel_Program_id__r.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name') && esc.Core_MDF_Case_ID_Number_id__r.Core_MDF_Budget_Type_nm__c != NULL){
                            recordGeoShareList.add(new Core_MDF_RecordGeoShare(esc.Id,escRegion, NULL, esc.Core_MDF_Channel_Program_id__r.Name, esc.Core_MDF_Case_ID_Number_id__r.Core_MDF_Budget_Type_nm__c));
                    }//else{
                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(esc.Id,escRegion,esc.Core_MDF_Case_ID_Number_id__r.Core_IPS_Account_Sub_Geo__c.trim(), esc.Core_MDF_Channel_Program_id__r.Name));                           
                    //}
                    //******ipa                                                  
                }
                
                //For Late Claim Escalaytion (Activity)
                if(esc.recordTypeId == escActivityRecTypeId && esc.Core_MDF_Co_Marketing_Activity_id__c != null){
                    
                    activityIdSet.add(esc.Core_MDF_Co_Marketing_Activity_id__c);
                    
                    /*if(esc.Core_MDF_Channel_Program_id__r.Name != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Channel_Program_Name')){
                        intelAccSet.add(esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c);
                    }*/
                   
                    if(!isNodeBasedSharingReqd){                        
                        
                        intelAccSet.add(esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c);//Activating acc
                        
                        //priamry account
                    }
                    //priamry account
                    //Avoid Deeply Nested IF Statements
                    if(!isNodeBasedSharingReqd && esc.Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c == 'Ecosystem Extension Fund'){
                            intelAccSet.add(esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Campaign_Ultimate_Account_Id__c);
                    }
                    //ipa***********  
                    // US949836 : New Budget Type field changes replaced txt field with new global picklist field
                    /*if(esc.Core_MDF_Channel_Program_id__r.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name') && esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Budget_Type_nm__c != NULL){
                        if(esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_cd__c != NULL){                            recordGeoShareList.add(new Core_MDF_RecordGeoShare(esc.Id,esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_cd__c, esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_cd__c,
                                                                               esc.Core_MDF_Channel_Program_id__r.Name, esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Budget_Type_nm__c));
                        }else{
                            recordGeoShareList.add(new Core_MDF_RecordGeoShare(esc.Id,esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_cd__c, NULL, esc.Core_MDF_Channel_Program_id__r.Name,  esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Budget_Type_nm__c));
                        }
                    }*///else{
                    //US1098882 replace Core_MDF_Region_cd__c with Core_MDF_Region_nm__c && Core_MDF_Sub_Region_cd__c with Core_MDF_Sub_Region_nm__c
                    if(esc.Core_MDF_Channel_Program_id__r.Name != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name') && esc.Core_MDF_Channel_Program_id__r.Name != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Co_GTM_program_name')) { 
                          recordGeoShareList.add(new Core_MDF_RecordGeoShare(esc.Id,esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_nm__c, esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_nm__c,
                                                                       esc.Core_MDF_Channel_Program_id__r.Name));
                    }
                    //}
                    //***********ipa
                    
                    if(ELIGIBLE_PROG.contains(esc.Core_MDF_Channel_Program_id__r.Name)){
                       // activityAccountIdSet.add(esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Id);                                                                                                                         
                    }
                }                
            }
            
            /*if(activityAccountIdSet != NULL && activityAccountIdSet.Size() > 0){
                for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id, Core_MDF_Account__c, Core_MDF_User__c
                                                                  FROM Core_MDF_Partner_Node_User_Mapping__c
                                                                  WHERE Core_MDF_Account__c IN: activityAccountIdSet AND Core_MDF_User__r.IsActive = TRUE and Core_MDF_Active_Ind__c = true]){
                                                                      userIdSet.add(pnum.Core_MDF_User__c);
                                                                      if(accIdUserIdSetMap.containsKey(pnum.Core_MDF_Account__c)){  accIdUserIdSetMap.get(pnum.Core_MDF_Account__c).add(pnum.Core_MDF_User__c); }else{ accIdUserIdSetMap.put(pnum.Core_MDF_Account__c,new Set<Id>{pnum.Core_MDF_User__c}); }
                                                                  }
            }*/
          //  List<String> permissionSetNameList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_Claim_Submitter').split(';');	
                //Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Claim_Sbmter_Prmisn_Set').split(';');
           /* if(userIdSet != NULL && userIdSet.Size() > 0){
                for(PermissionSetAssignment psa : [SELECT Id, PermissionSet.Name,AssigneeId FROM PermissionSetAssignment
                                                   WHERE AssigneeId IN: userIdSet AND PermissionSet.Name IN: permissionSetNameList]){  userWithRequiredPermissionSet.add(psa.AssigneeId); }}
            */
            //Fetching PGM records and storing them in map with Account
            Map<String,List<Id>> intelAccIdWithGroup = new Map<String,List<Id>>();
            Map<String,Id> pgmForSubGeoMap = new Map<String,Id>();
            Map<String,Id> pgmForSubGeoBudgetTypeMap = new Map<String,Id>();
            Map<String,Id> pgmForGeoMap = new Map<String,Id>();
            Map<String,Id> pgmForGeoBudgetTypeMap = new Map<String,Id>();
            Map<String,Id> pgmForWWMap = new Map<String,Id>();
            Map<String,Id> pgmForWWBudgetTypeMap = new Map<String,Id>();
            
            if(intelAccSet != NULL && intelAccSet.Size() > 0){
                for(Core_MDF_Partner_Group_Mapping__c pgm:[SELECT Id, Core_MDF_Group_Id__c, Core_MDF_Account__c,Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c,
                                                           Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Name ,Core_MDF_BudgetType_nm__c
                                                           FROM Core_MDF_Partner_Group_Mapping__c 
                                                           WHERE Core_MDF_Type_of_Access__c='Internal' AND 
                                                           Core_MDF_Account__c IN :intelAccSet AND
                                                          Core_MDF_Channel_Program__c IN :channelProgramIdSet AND Core_MDF_Inactive_Ind__c = false]){
                    String accIdCpId = (String)pgm.Core_MDF_Account__c+pgm.Core_MDF_Channel_Program__c;
                                                               
                    //To share budget escalation of CCP programs with all PGM
                    if(!nonCcpProgramList.contains(pgm.Core_MDF_Channel_Program__r.Name)){    
                        if(intelAccIdWithGroup.containsKey(accIdCpId)){
                            intelAccIdWithGroup.get(accIdCpId).add(pgm.Core_MDF_Group_Id__c);
                        }else{
                            List<Id> tempPGM = new List<Id>();
                            tempPGM.add(pgm.Core_MDF_Group_Id__c);
                            intelAccIdWithGroup.put(accIdCpId,tempPGM);
                        }
                    }
                    
                    String accIdCpIdGeoSubGeo, accIdCpIdGeo;
                    String accountIdProgramIdSubGeoBudgetType = '';
                    String accountIdProgramIdGeoBudgetType = '';                                          
                    String accountIdProgramIdBudgetType = '';                                          
                                                               
                   if(pgm.Core_MDF_BudgetType_nm__c == null){
                    //Sub Region != Null i.e. for Retail and ASMO - LAR & NAR specific                                          
                    if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                        accIdCpIdGeoSubGeo = (String)pgm.Core_MDF_Account__c+pgm.Core_MDF_Channel_Program__c+pgm.Core_MDF_Region_cd__c+pgm.Core_MDF_Sub_Region_cd__c;
                        pgmForSubGeoMap.put(accIdCpIdGeoSubGeo, pgm.Core_MDF_Group_Id__c);
                        
                    }
                    //For all CCP Programs including Retail(APJ,EMEA,PRC)
                    else {
                        accIdCpIdGeo = (String)pgm.Core_MDF_Account__c+pgm.Core_MDF_Channel_Program__c+pgm.Core_MDF_Region_cd__c;
                        pgmForGeoMap.put(accIdCpIdGeo, pgm.Core_MDF_Group_Id__c);
                    }    
                  }
                  else{
                      if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                          accountIdProgramIdSubGeoBudgetType = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c + pgm.Core_MDF_BudgetType_nm__c;
                          pgmForSubGeoBudgetTypeMap.put(accountIdProgramIdSubGeoBudgetType,pgm.Core_MDF_Group_Id__c);
                      }
                      else{
                          accountIdProgramIdGeoBudgetType = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_BudgetType_nm__c;
                          pgmForGeoBudgetTypeMap.put(accountIdProgramIdGeoBudgetType,pgm.Core_MDF_Group_Id__c);
                      }                                           
                  }                                        
                    
                    //For CCP Programs and PGM of type WW
                    //accIdCpId = accIdCpId.left(36);                                         
                    if(pgm.Core_MDF_Region_cd__c == 'WW'){
                        if(pgm.Core_MDF_BudgetType_nm__c == null){
                            accIdCpId = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c;
                        pgmForWWMap.put(accIdCpId,pgm.Core_MDF_Group_Id__c);                                        
                    }
                        else{
                            accountIdProgramIdBudgetType = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_BudgetType_nm__c; 
                            pgmForWWBudgetTypeMap.put(accountIdProgramIdBudgetType,pgm.Core_MDF_Group_Id__c);
                        }
                    }
                }
            }
            
            //Create escalation share records 
            Map<Id,List<Id>> esclationWithGroupId = new Map<Id,List<Id>>();
            //List<Core_MDF_Escalation__c> listEscToBeUpdated = new List<Core_MDF_Escalation__c>();       
            for(Core_MDF_Escalation__c esc: escalationList){
                //only for retail
                Boolean isNodeBasedSharingReqd = Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(esc.Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c);
                
                List<Id> groupIdList = new List<Id>();
                List<Id> internalGroupId = new List<Id>();
                String accIdCpId, accIdCpIdGeo, accIdCpIdGeoSubGeo;
                //EEF
                String accPrimaryIdCpId, accPrimaryIdCpIdGeo, accPrimaryIdCpIdGeoSubGeo;
                String accPrimaryIdProgramIdSubGeoBudgetType, accPrimaryIdProgramIdGeoBudgetType, accPrimaryIdProgramIdBudgetType;
                String accountIdProgramIdSubGeoBudgetType = '';
                String accountIdProgramIdGeoBudgetType = '';
                String accountIdProgramIdBudgetType = '';
                
                //Budget Escalation
                if(esc.recordTypeId == escBudgetRecTypeId && budgetIdSet.contains(esc.Core_MDF_Budget_ID_Number_id__c)){
                    
                    /*if(esc.Core_MDF_Channel_Program_id__r.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Channel_Program_Name') && 
                       esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_Group_Id__c != NULL){
                        groupIdList.add(esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_Group_Id__c);
                    }else{*/

                    accIdCpIdGeoSubGeo = (String)esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c +esc.Core_MDF_Channel_Program_id__c + esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_Geo__c + esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c;
                    accIdCpIdGeo = (String)esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c + esc.Core_MDF_Channel_Program_id__c + esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_Geo__c;
                    accIdCpId = (String)esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c + esc.Core_MDF_Channel_Program_id__c;
                    
                    if(intelAccIdWithGroup.containsKey(accIdCpId) && intelAccIdWithGroup.get(accIdCpId) != NULL){ groupIdList.addAll(intelAccIdWithGroup.get(accIdCpId));
                    }
                    else if(pgmForSubGeoMap.containsKey(accIdCpIdGeoSubGeo) && pgmForSubGeoMap.get(accIdCpIdGeoSubGeo) != NULL){ groupIdList.add(pgmForSubGeoMap.get(accIdCpIdGeoSubGeo));
                    }
                    else if(pgmForGeoMap.containsKey(accIdCpIdGeo) && pgmForGeoMap.get(accIdCpIdGeo) != NULL){groupIdList.add(pgmForGeoMap.get(accIdCpIdGeo));
                    }
                    if(groupIdList != NULL && groupIdList.Size() > 0){internalGroupId.addAll(groupIdList);
                    }
                }
                //Case Escalation
                if(esc.recordTypeId == escCaseRecTypeId && caseIdSet.contains(esc.Core_MDF_Case_ID_Number_id__c )){
                    
                    if(isNodeBasedSharingReqd && esc.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_Group_Id__c != NULL){ groupIdList.add(esc.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_Group_Id__c);
                    }else{
                        String region = (esc.Core_MDF_Channel_Program_id__r.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name')) ? esc.Core_MDF_Case_ID_Number_id__r.Account.Core_Geo__c : esc.Core_MDF_Case_ID_Number_id__r.Core_Account_Geo__c.trim();
                        accIdCpIdGeoSubGeo = (String)esc.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c + esc.Core_MDF_Channel_Program_id__c+ region +esc.Core_MDF_Case_ID_Number_id__r.Core_IPS_Account_Sub_Geo__c.trim();
                        accIdCpIdGeo = (String)esc.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c +esc.Core_MDF_Channel_Program_id__c+ region;
                        accIdCpId = (String)esc.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c +esc.Core_MDF_Channel_Program_id__c;
                        accountIdProgramIdSubGeoBudgetType = (String)esc.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c + esc.Core_MDF_Channel_Program_id__c+ region +esc.Core_MDF_Case_ID_Number_id__r.Core_IPS_Account_Sub_Geo__c.trim() + esc.Core_MDF_Budget_Type_txt__c;
                        accountIdProgramIdGeoBudgetType = (String)esc.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c +esc.Core_MDF_Channel_Program_id__c+ region + esc.Core_MDF_Budget_Type_txt__c;
                        accountIdProgramIdBudgetType = (String)esc.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c +esc.Core_MDF_Channel_Program_id__c + esc.Core_MDF_Budget_Type_txt__c;
                            
                        if(pgmForSubGeoMap.containsKey(accIdCpIdGeoSubGeo) && pgmForSubGeoMap.get(accIdCpIdGeoSubGeo) != NULL){ groupIdList.add(pgmForSubGeoMap.get(accIdCpIdGeoSubGeo));
                        }
                        else if(pgmForGeoMap.containsKey(accIdCpIdGeo) && pgmForGeoMap.get(accIdCpIdGeo) != NULL){groupIdList.add(pgmForGeoMap.get(accIdCpIdGeo));}
                        
                        if(pgmForSubGeoBudgetTypeMap.containsKey(accountIdProgramIdSubGeoBudgetType) && pgmForSubGeoBudgetTypeMap.get(accountIdProgramIdSubGeoBudgetType) != null){groupIdList.add(pgmForSubGeoBudgetTypeMap.get(accountIdProgramIdSubGeoBudgetType));
                        }else if(pgmForGeoBudgetTypeMap.containsKey(accountIdProgramIdGeoBudgetType) && pgmForGeoBudgetTypeMap.get(accountIdProgramIdGeoBudgetType) != null){groupIdList.add(pgmForGeoBudgetTypeMap.get(accountIdProgramIdGeoBudgetType));
                        }
                        
                        if(pgmForWWMap.containsKey(accIdCpId) && pgmForWWMap.get(accIdCpId) != NULL){groupIdList.add(pgmForWWMap.get(accIdCpId));}
                        
                        if(pgmForWWBudgetTypeMap.containsKey(accountIdProgramIdBudgetType) && pgmForWWBudgetTypeMap.get(accountIdProgramIdBudgetType) != null){groupIdList.add(pgmForWWBudgetTypeMap.get(accountIdProgramIdBudgetType));
                        }
                        
                        if(esc.Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c == 'Ecosystem Extension Fund'){
                            
                            accPrimaryIdCpIdGeoSubGeo = (String)esc.Core_MDF_Case_ID_Number_id__r.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Campaign_Ultimate_Account_Id__c+ esc.Core_MDF_Channel_Program_id__c+ region +esc.Core_MDF_Case_ID_Number_id__r.Core_IPS_Account_Sub_Geo__c.trim();
                            accPrimaryIdCpIdGeo = (String)esc.Core_MDF_Case_ID_Number_id__r.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Campaign_Ultimate_Account_Id__c+esc.Core_MDF_Channel_Program_id__c+ region;
                            accPrimaryIdCpId = (String)esc.Core_MDF_Case_ID_Number_id__r.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Campaign_Ultimate_Account_Id__c+esc.Core_MDF_Channel_Program_id__c;
                            
                            accPrimaryIdProgramIdSubGeoBudgetType = (String)esc.Core_MDF_Case_ID_Number_id__r.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Campaign_Ultimate_Account_Id__c + esc.Core_MDF_Channel_Program_id__c+ region +esc.Core_MDF_Case_ID_Number_id__r.Core_IPS_Account_Sub_Geo__c.trim() + esc.Core_MDF_Budget_Type_txt__c;
                            accPrimaryIdProgramIdGeoBudgetType = (String)esc.Core_MDF_Case_ID_Number_id__r.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Campaign_Ultimate_Account_Id__c +esc.Core_MDF_Channel_Program_id__c+ region + esc.Core_MDF_Budget_Type_txt__c;
                            accPrimaryIdProgramIdBudgetType = (String)esc.Core_MDF_Case_ID_Number_id__r.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Campaign_Ultimate_Account_Id__c +esc.Core_MDF_Channel_Program_id__c + esc.Core_MDF_Budget_Type_txt__c;
                                
                                if(pgmForSubGeoMap.containsKey(accPrimaryIdCpIdGeoSubGeo) && pgmForSubGeoMap.get(accPrimaryIdCpIdGeoSubGeo) != NULL){groupIdList.add(pgmForSubGeoMap.get(accPrimaryIdCpIdGeoSubGeo));
                                }else if(pgmForGeoMap.containsKey(accPrimaryIdCpIdGeo) && pgmForGeoMap.get(accPrimaryIdCpIdGeo) != NULL){groupIdList.add(pgmForGeoMap.get(accPrimaryIdCpIdGeo));
                                }
                                
                                if(pgmForSubGeoBudgetTypeMap.containsKey(accPrimaryIdProgramIdSubGeoBudgetType) && pgmForSubGeoBudgetTypeMap.get(accPrimaryIdProgramIdSubGeoBudgetType) != null){groupIdList.add(pgmForSubGeoBudgetTypeMap.get(accPrimaryIdProgramIdSubGeoBudgetType));
                                }else if(pgmForGeoBudgetTypeMap.containsKey(accPrimaryIdProgramIdGeoBudgetType) && pgmForGeoBudgetTypeMap.get(accPrimaryIdProgramIdGeoBudgetType) != null){groupIdList.add(pgmForGeoBudgetTypeMap.get(accPrimaryIdProgramIdGeoBudgetType));
                                }
                                if(pgmForWWMap.containsKey(accPrimaryIdCpId) && pgmForWWMap.containsKey(accPrimaryIdCpId) != NULL){groupIdList.add(pgmForWWMap.get(accPrimaryIdCpId));
                                }
                                if(pgmForWWBudgetTypeMap.containsKey(accPrimaryIdProgramIdBudgetType) && pgmForWWBudgetTypeMap.get(accPrimaryIdProgramIdBudgetType) != null){groupIdList.add(pgmForWWBudgetTypeMap.get(accPrimaryIdProgramIdBudgetType));
                                }
                            
                        }
                    }
	
                if(groupIdList != NULL && groupIdList.Size() > 0){  internalGroupId.addAll(groupIdList);}
                }
                
                //Activity Escalation
                String geo = '';
                
                geo = (String.isNotBlank(esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Host_Region_txt__c)) ? esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Host_Region_txt__c : esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_nm__c;
                if(esc.recordTypeId == escActivityRecTypeId && activityIdSet.contains(esc.Core_MDF_Co_Marketing_Activity_id__c )){
                    
                    if(isNodeBasedSharingReqd && esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_Group_Id__c != NULL){  
						groupIdList.add(esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_Group_Id__c); 
                    }else if(esc.Core_MDF_Channel_Program_id__r.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name')){
                            accIdCpIdGeoSubGeo = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+ esc.Core_MDF_Channel_Program_id__c + geo + esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_nm__c;
                            accIdCpIdGeo = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+esc.Core_MDF_Channel_Program_id__c+ geo;
                            accIdCpId = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+esc.Core_MDF_Channel_Program_id__c;
                            accountIdProgramIdSubGeoBudgetType = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+ esc.Core_MDF_Channel_Program_id__c + geo + esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_nm__c + esc.Core_MDF_Budget_Type_txt__c;
                            accountIdProgramIdGeoBudgetType = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+esc.Core_MDF_Channel_Program_id__c+ geo + esc.Core_MDF_Budget_Type_txt__c;
                            accountIdProgramIdBudgetType = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+esc.Core_MDF_Channel_Program_id__c + esc.Core_MDF_Budget_Type_txt__c;
                            
                            if(pgmForSubGeoMap.containsKey(accIdCpIdGeoSubGeo) && pgmForSubGeoMap.get(accIdCpIdGeoSubGeo) != NULL){groupIdList.add(pgmForSubGeoMap.get(accIdCpIdGeoSubGeo));
                            }else if(pgmForGeoMap.containsKey(accIdCpIdGeo) && pgmForGeoMap.get(accIdCpIdGeo) != NULL){groupIdList.add(pgmForGeoMap.get(accIdCpIdGeo));
                            }
                        
                            if(pgmForSubGeoBudgetTypeMap.containsKey(accountIdProgramIdSubGeoBudgetType) && pgmForSubGeoBudgetTypeMap.get(accountIdProgramIdSubGeoBudgetType) != null){groupIdList.add(pgmForSubGeoBudgetTypeMap.get(accountIdProgramIdSubGeoBudgetType));
                            }else if(pgmForGeoBudgetTypeMap.containsKey(accountIdProgramIdGeoBudgetType) && pgmForGeoBudgetTypeMap.get(accountIdProgramIdGeoBudgetType) != null){groupIdList.add(pgmForGeoBudgetTypeMap.get(accountIdProgramIdGeoBudgetType));
                            }
                        
                            if(pgmForWWBudgetTypeMap.containsKey(accountIdProgramIdBudgetType) && pgmForWWBudgetTypeMap.get(accountIdProgramIdBudgetType) != null){groupIdList.add(pgmForWWBudgetTypeMap.get(accountIdProgramIdBudgetType));
                            }
                            if(pgmForWWMap.containsKey(accIdCpId) && pgmForWWMap.containsKey(accIdCpId) != NULL){groupIdList.add(pgmForWWMap.get(accIdCpId));
                            }
                        
                            /*if(pgmForWWMap.containsKey(accIdCpId) && pgmForWWMap.containsKey(accIdCpId) != NULL){
                                groupIdList.add(pgmForWWMap.get(accIdCpId));
                            }*/                           
                            if(esc.Core_MDF_Channel_Program_id__r.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name') && esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Budget_Type_nm__c != NULL){
                                    recordGeoShareList.add(new Core_MDF_RecordGeoShare(esc.Id,geo, NULL, esc.Core_MDF_Channel_Program_id__r.Name, esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Budget_Type_nm__c));
                                                            }
                       // }//end of for}
					   
                        
                        /*accIdCpIdGeoSubGeo = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+ esc.Core_MDF_Channel_Program_id__c+esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_cd__c+esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_cd__c;
                        accIdCpIdGeo = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+esc.Core_MDF_Channel_Program_id__c+esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_cd__c;
                        accIdCpId = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+esc.Core_MDF_Channel_Program_id__c;
                        
                        if(pgmForSubGeoMap.containsKey(accIdCpIdGeoSubGeo) && pgmForSubGeoMap.get(accIdCpIdGeoSubGeo) != NULL){
                            groupIdList.add(pgmForSubGeoMap.get(accIdCpIdGeoSubGeo));
                        }else if(pgmForGeoMap.containsKey(accIdCpIdGeo) && pgmForGeoMap.get(accIdCpIdGeo) != NULL){
                            groupIdList.add(pgmForGeoMap.get(accIdCpIdGeo));
                        }                        
                        if(pgmForWWMap.containsKey(accIdCpId) && pgmForWWMap.containsKey(accIdCpId) != NULL){
                            groupIdList.add(pgmForWWMap.get(accIdCpId));
                        } */                   
					}//End of else
					else if(esc.Core_MDF_Channel_Program_id__r.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Co_GTM_program_name')){
                        accIdCpId = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+esc.Core_MDF_Channel_Program_id__c;
                        accountIdProgramIdBudgetType = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+esc.Core_MDF_Channel_Program_id__c + esc.Core_MDF_Budget_Type_txt__c;
                            if(pgmForWWBudgetTypeMap.containsKey(accountIdProgramIdBudgetType) && pgmForWWBudgetTypeMap.get(accountIdProgramIdBudgetType) != null){groupIdList.add(pgmForWWBudgetTypeMap.get(accountIdProgramIdBudgetType));
                        }
                        if(pgmForWWMap.containsKey(accIdCpId) && pgmForWWMap.containsKey(accIdCpId) != NULL){groupIdList.add(pgmForWWMap.get(accIdCpId));
                        }
                        //concatenating 'WW' along with other regions
                        geo = String.isNotBlank(geo) ? (geo + ';WW') : (geo + 'WW');
                        List<String> geoList= geo.split(';');
                        for (String region : geoList) {
                            accIdCpIdGeoSubGeo = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+ esc.Core_MDF_Channel_Program_id__c + region + esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_nm__c;
                            accIdCpIdGeo = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+esc.Core_MDF_Channel_Program_id__c+ region;
                            accountIdProgramIdSubGeoBudgetType = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+ esc.Core_MDF_Channel_Program_id__c + region + esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_nm__c + esc.Core_MDF_Budget_Type_txt__c;
                            accountIdProgramIdGeoBudgetType = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+esc.Core_MDF_Channel_Program_id__c+ region + esc.Core_MDF_Budget_Type_txt__c;
                            
                            if(pgmForSubGeoMap.containsKey(accIdCpIdGeoSubGeo) && pgmForSubGeoMap.get(accIdCpIdGeoSubGeo) != NULL){groupIdList.add(pgmForSubGeoMap.get(accIdCpIdGeoSubGeo));
                            }else if(pgmForGeoMap.containsKey(accIdCpIdGeo) && pgmForGeoMap.get(accIdCpIdGeo) != NULL){groupIdList.add(pgmForGeoMap.get(accIdCpIdGeo));
                            }
                        
                            if(pgmForSubGeoBudgetTypeMap.containsKey(accountIdProgramIdSubGeoBudgetType) && pgmForSubGeoBudgetTypeMap.get(accountIdProgramIdSubGeoBudgetType) != null){groupIdList.add(pgmForSubGeoBudgetTypeMap.get(accountIdProgramIdSubGeoBudgetType));
                            }else if(pgmForGeoBudgetTypeMap.containsKey(accountIdProgramIdGeoBudgetType) && pgmForGeoBudgetTypeMap.get(accountIdProgramIdGeoBudgetType) != null){groupIdList.add(pgmForGeoBudgetTypeMap.get(accountIdProgramIdGeoBudgetType));
                            }
                        
                                        
                            if(esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Budget_Type_nm__c != NULL){recordGeoShareList.add(new Core_MDF_RecordGeoShare(esc.Id,region, NULL, esc.Core_MDF_Channel_Program_id__r.Name, esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Budget_Type_nm__c));
                            }
                        }
                            
                        
                    }else{
                        // CCP sharing: Replaced SingleSelect Region, SubRegion with MultiSelect Region, SubRegion
						accIdCpIdGeoSubGeo = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+ esc.Core_MDF_Channel_Program_id__c+ geo +esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_nm__c;
						accIdCpIdGeo = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+esc.Core_MDF_Channel_Program_id__c+ geo;
						accIdCpId = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+esc.Core_MDF_Channel_Program_id__c;
						
                        if(esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Program__c=='Ecosystem Extension Fund'){
                            accPrimaryIdCpIdGeoSubGeo = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Campaign_Ultimate_Account_Id__c+ esc.Core_MDF_Channel_Program_id__c+ geo +esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_nm__c;
                            accPrimaryIdCpIdGeo = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Campaign_Ultimate_Account_Id__c+esc.Core_MDF_Channel_Program_id__c+ geo;
                            accPrimaryIdCpId = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Campaign_Ultimate_Account_Id__c+esc.Core_MDF_Channel_Program_id__c;
                             	if(pgmForSubGeoMap.containsKey(accPrimaryIdCpIdGeoSubGeo) && pgmForSubGeoMap.get(accPrimaryIdCpIdGeoSubGeo) != NULL){
                                    groupIdList.add(pgmForSubGeoMap.get(accPrimaryIdCpIdGeoSubGeo));
                                }else if(pgmForGeoMap.containsKey(accPrimaryIdCpIdGeo) && pgmForGeoMap.get(accPrimaryIdCpIdGeo) != NULL){
                                    groupIdList.add(pgmForGeoMap.get(accPrimaryIdCpIdGeo));
                                }
                                if(pgmForWWMap.containsKey(accPrimaryIdCpId) && pgmForWWMap.containsKey(accPrimaryIdCpId) != NULL){
                                    groupIdList.add(pgmForWWMap.get(accPrimaryIdCpId));
                                }
                            
                        }
                           
						if(pgmForSubGeoMap.containsKey(accIdCpIdGeoSubGeo) && pgmForSubGeoMap.get(accIdCpIdGeoSubGeo) != NULL){groupIdList.add(pgmForSubGeoMap.get(accIdCpIdGeoSubGeo));
						}else if(pgmForGeoMap.containsKey(accIdCpIdGeo) && pgmForGeoMap.get(accIdCpIdGeo) != NULL){groupIdList.add(pgmForGeoMap.get(accIdCpIdGeo));
						}
					if(pgmForWWMap.containsKey(accIdCpId) && pgmForWWMap.containsKey(accIdCpId) != NULL){
						groupIdList.add(pgmForWWMap.get(accIdCpId));
					}
					}//End of IPA chk	
					
                    
                    if(groupIdList != NULL && groupIdList.Size() > 0){                        
                        internalGroupId.addAll(groupIdList);
                    }
                    
                    /*if(accIdUserIdSetMap.containsKey(esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Id) && accIdUserIdSetMap.get(esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Id) != NULL){
                        for(Id userId : accIdUserIdSetMap.get(esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Id)){
                            if(userWithRequiredPermissionSet.contains(userId)){ 
                                groupIdList.add(userId);
                            }                        
                        }
                    }*/
                }
                
                if(groupIdList.Size() > 0){                    
                    esclationWithGroupId.put(esc.Id,groupIdList);
                    
                    //To update PGM of Internal type group Id 
                    
                    /*if(esc.Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c == RMF_PROG){ //Moved this logic to flow
                        Core_MDF_Escalation__c escalation = new Core_MDF_Escalation__c();
                        escalation.Id = esc.Id;
                        if(internalGroupId != NULL && internalGroupId.Size() > 0){
                            escalation.Core_MDF_PGM_Internal_Group_Id_txt__c = String.join(internalGroupId, ';');
                            listEscToBeUpdated.add(escalation);
                        }
                    }*/
                    
                }  
            }//end of escList for loop
           
            //Calling Core_MDF_shareRecordToAccountGroup to share budget escalation with all account node groups
            if(budgetEscIdToUltimateAccIdCpIdMap != NULL && budgetEscIdToUltimateAccIdCpIdMap.Size() > 0 && 
               budgetEscUltimateAccIdList != NULL && budgetEscUltimateAccIdList.Size() > 0){
                Core_MDF_shareRecordToAccountGroup.shareRecordToAllAcctGroupInHierarchy(budgetEscIdToUltimateAccIdCpIdMap,'Core_MDF_Escalation__c',budgetEscUltimateAccIdList,budgetEscProgramIdList);
            }
            
            //Call Generic Approval Process class to create escalation Share records        
            if(esclationWithGroupId.size()>0){
                //Core_MDF_GenericShareRecordActionClass.createShareRecordList('Core_MDF_Escalation__c', esclationWithGroupId); 
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Escalation__c',esclationWithGroupId, 'Edit');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            }
            
            if(recordGeoShareList != NULL && recordGeoShareList.size() >0){                        
                Core_MDF_ShareRecordToGeoGroup.shareRecordToGeoGroup('Core_MDF_Escalation__c',recordGeoShareList);
            }              
            }
        catch(Exception e){ String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,Label.Core_MDF_Escalation_Sharing );
        } 
    } 
    
    public static void  shareEscalationWithAccNodeGroup(List<Core_MDF_Escalation__c> escalationList, Map<Id,Core_MDF_Escalation__c> escalationOldMap, Boolean isInsert){
        Id escLateClaimRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();   
        Map<string,string> escIdToPfrIdMap = new Map<string,string>();
        Map<string,string> pfrIdToExtGrpIdMap = new Map<string,string>();
        set<string> groupIdToRemoveShare = new set<string>();
        set<string> oldPfrIdSet = new set<string>();
        List<Core_MDF_Escalation__Share> escShareToDeleteList = new List<Core_MDF_Escalation__Share>();
        Map<string,Core_MDF_Escalation__c> escShareToDeleteMap = new Map<string,Core_MDF_Escalation__c>();
        
        try{
            for(Core_MDF_Escalation__c esc: escalationList){
                if(esc.recordTypeId == escLateClaimRecTypeId && esc.Core_MDF_Co_Marketing_Activity_id__c != null){
                    if(isInsert){
                        escIdToPfrIdMap.put(esc.Id,esc.Core_MDF_Co_Marketing_Activity_id__c);
                    }
                    if((escalationOldMap != null && (esc.OwnerId != escalationOldMap.get(esc.Id).OwnerId || esc.Core_MDF_Co_Marketing_Activity_id__c != escalationOldMap.get(esc.Id).Core_MDF_Co_Marketing_Activity_id__c))){
                        escShareToDeleteMap.put(esc.Id,escalationOldMap.get(esc.Id)); oldPfrIdSet.add(escalationOldMap.get(esc.Id).Core_MDF_Co_Marketing_Activity_id__c); escIdToPfrIdMap.put(esc.Id,esc.Core_MDF_Co_Marketing_Activity_id__c);
                    } 
                }
            }
            
            Map<String, String> pfrIdToCampaignIdMap = new Map<String, String>();
            Set<String> eefActivitySet = new Set<String>();
            if(!escIdToPfrIdMap.isEmpty()){
                for(PartnerFundRequest pfr : [SELECT Id,Core_MDF_Program__c,ChannelPartnerId,ChannelPartner.Core_MDF_External_Group_Id__c, CampaignId, Campaign.Core_MDF_Account__r.Core_MDF_External_Group_Id__c
                                              FROM PartnerFundRequest
                                              WHERE Id IN: escIdToPfrIdMap.values() OR Id IN: oldPfrIdSet]){
                                                  pfrIdToExtGrpIdMap.put(pfr.Id, pfr.ChannelPartner.Core_MDF_External_Group_Id__c);
                                                  if(pfr.Core_MDF_Program__c == 'Ecosystem Extension Fund' && String.isNotBlank(pfr.Campaign.Core_MDF_Account__r.Core_MDF_External_Group_Id__c)){
                                                    pfrIdToCampaignIdMap.put(pfr.Id, pfr.CampaignId); eefActivitySet.add(pfr.Id); pfrIdToExtGrpIdMap.put(pfr.CampaignId, pfr.Campaign.Core_MDF_Account__r.Core_MDF_External_Group_Id__c);
                                                      //add the campaign's external group id.
                                                  }
                                              }
            }
            
            if(!escShareToDeleteMap.isEmpty() && !pfrIdToExtGrpIdMap.isEmpty()){
                for(Core_MDF_Escalation__c esc : escShareToDeleteMap.values()){
                    if(pfrIdToExtGrpIdMap.containsKey(esc.Core_MDF_Co_Marketing_Activity_id__c)){
                        groupIdToRemoveShare.add(pfrIdToExtGrpIdMap.get(esc.Core_MDF_Co_Marketing_Activity_id__c));  

                        if(eefActivitySet.contains(esc.Core_MDF_Co_Marketing_Activity_id__c) && pfrIdToExtGrpIdMap.containsKey(pfrIdToCampaignIdMap.get(esc.Core_MDF_Co_Marketing_Activity_id__c))){
                            groupIdToRemoveShare.add(pfrIdToExtGrpIdMap.get(pfrIdToCampaignIdMap.get(esc.Core_MDF_Co_Marketing_Activity_id__c)));  
                        }
                    }
                }
                
                if(!groupIdToRemoveShare.isEmpty()){
                    for(Core_MDF_Escalation__Share escShare: [SELECT Id
                                                              FROM Core_MDF_Escalation__Share 
                                                              WHERE ParentId IN : escShareToDeleteMap.KeySet() 
                                                              AND UserOrGroupId IN: groupIdToRemoveShare]){
                                                                  escShareToDeleteList.add(escShare);
                                                              }
                    
                    if(!escShareToDeleteList.isEmpty()){
                        delete escShareToDeleteList;
                    }
                }            
            }
            
            List<Core_MDF_Escalation__Share> escShareToInsert = new List<Core_MDF_Escalation__Share>();
            for(Core_MDF_Escalation__c esc: escalationList){
                if(pfrIdToExtGrpIdMap.containsKey(esc.Core_MDF_Co_Marketing_Activity_id__c)){
                    string userOrGroupId = pfrIdToExtGrpIdMap.get(esc.Core_MDF_Co_Marketing_Activity_id__c);
                    escShareToInsert.add(createEscalationShare(esc.Id,userOrGroupId));

                    if(eefActivitySet.contains(esc.Core_MDF_Co_Marketing_Activity_id__c) && pfrIdToExtGrpIdMap.containsKey(pfrIdToCampaignIdMap.get(esc.Core_MDF_Co_Marketing_Activity_id__c))){
                        string userOrGroupIdFromCampaign = pfrIdToExtGrpIdMap.get(pfrIdToCampaignIdMap.get(esc.Core_MDF_Co_Marketing_Activity_id__c));
                        escShareToInsert.add(createEscalationShare(esc.Id,userOrGroupIdFromCampaign));
                    }
                }
            }
            
            if(!escShareToInsert.isEmpty()){
                insert escShareToInsert;
            }
        }
        catch(Exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
    
    public static Core_MDF_Escalation__Share createEscalationShare(String escId, String userOrGroupId){
        Core_MDF_Escalation__Share escShare = new Core_MDF_Escalation__Share();
        escShare.ParentId = escId;
        escShare.RowCause = 'Manual';
        escShare.AccessLevel = 'Edit';
        escShare.UserOrGroupId = userOrGroupId;
        return escShare;
    }
    
    
    /*************************************************************************************************** 
    Method Name:        approvalAction
    @return  :          void
    @parameters:        List<Core_MDF_Escalation__c> escalationList, Map<Id,Core_MDF_Escalation__c> escalationOldMap
    Description:        This method will perform the approval action for claim review result 
    Added By:           Accenture - SK - 20/06/2019. Aswin (24/09/2024)- Commented this method(not in use)
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/    
    /*public static void approvalAction(List<Core_MDF_Escalation__c> escalationList, Map<Id,Core_MDF_Escalation__c> escalationOldMap){
        
        try{
            Map<Id, Core_MDF_Escalation__c> escToBeProcessedMap = new Map<Id, Core_MDF_Escalation__c>();
            
            Id escCaseRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId(); 
                                 
            Set<Id> caseIdSet = new Set<Id>();
            List<Core_MDF_Escalation__c> listEscToBeUpdated = new List<Core_MDF_Escalation__c>();
            
            
            for(Core_MDF_Escalation__c esc: escalationList){
                
                if(esc.recordTypeId == escCaseRecTypeId && esc.Core_MDF_Case_ID_Number_id__c != null &&  
                   ((!esc.Core_MDF_Do_not_Auto_Create_Claim_Ind__c &&
                     esc.Core_MDF_Escalation_Status_nm__c != escalationOldMap.get(esc.Id).Core_MDF_Escalation_Status_nm__c &&
                     esc.Core_MDF_Escalation_Status_nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Approved')) || 
                    (esc.Core_MDF_Do_not_Auto_Create_Claim_Ind__c && esc.Core_MDF_Claim_Number_id__c != escalationOldMap.get(esc.Id).Core_MDF_Claim_Number_id__c))){
                         
                         escToBeProcessedMap.put(esc.Core_MDF_Case_ID_Number_id__c, esc);
                     }
               
            }
           
            
            List<Case> toBeUpdatedCases = new List<Case>();
            List<PartnerFundClaim>  toBeUpdatedClaims = new List<PartnerFundClaim>();
            List<Core_MDF_Adjustment_Request__c> toBeInsertedAdjustmentRec = new List<Core_MDF_Adjustment_Request__c>();
            
            for(PartnerFundClaim pfc: [SELECT Id, Core_MDF_Claim_Review_Case__c, Core_MDF_Status__c, Core_MDF_Audit_Adjustment_Amount__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Review_Case_Status__c
                                       ,Core_MDF_Claim_Review_Case__r.Core_MDF_Claim_Conversion_Exchange_Rate__c FROM PartnerFundClaim WHERE Core_MDF_Claim_Review_Case__c IN : escToBeProcessedMap.keySet()]){
                                           
                                           String claimStatus = pfc.Core_MDF_Status__c;
                                           List<String> nonPaidclmStsLst = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Pre_Payment_Claim_Statuses').split(';');
                                           List<String> paidclmStsLst = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Post_Payment_Claim_Statuses').split(';');
                                           
                                           //If claim is in Pending Available Fund, Payment Due, Hold OR If claim is in Pending Payment, Paid, Cancelled, Denied                       
                                           if(nonPaidclmStsLst.contains(claimStatus) || paidclmStsLst.contains(claimStatus)){                        
                                               
                                               if(!escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Do_not_Auto_Create_Claim_Ind__c ||
                                                  (escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Do_not_Auto_Create_Claim_Ind__c &&
                                                   escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Claim_Number_id__c != NULL)){
                                                       // if claims are denied                
                                                       if(pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Status_Denied')){
                                                           pfc.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Adjusted;
                                                           Case cs = new Case();
                                                           cs.Id = pfc.Core_MDF_Claim_Review_Case__c;
                                                           cs.Core_MDF_Review_Case_Status__c = 'Review Completed';
                                                           cs.Core_MDF_Status__c = 'Review Completed';   
                                                           toBeUpdatedCases.add(cs);                   
                                                       }
                                                   }
                                                                                            
                                                                                        
                                               //If Core_MDF_Do_not_Auto_Create_Claim__c is unchecked, auto create claim
                                               if(!escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Do_not_Auto_Create_Claim_Ind__c){
                                                   
                                                   Core_MDF_Adjustment_Request__c adjRec = new Core_MDF_Adjustment_Request__c();
                                                   adjRec.Core_MDF_Amount_Amt__c = escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Approved_Amount_amt__c;
                                                   adjRec.Core_MDF_Reference_Claim_Nbr__c = pfc.Id;
                                                   adjRec.Core_MDF_Reason_Cd__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Review_Results_Positive');
                                                   adjRec.Core_MDF_Escalation_Id__c = escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Id;
                                                   toBeInsertedAdjustmentRec.add(adjRec); 
                                               }
                                               //If Core_MDF_Do_not_Auto_Create_Claim__c is checked, create Claim manually and change the Old Denied Claim and Case Statuses
                                               if(escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Do_not_Auto_Create_Claim_Ind__c &&
                                                  escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Claim_Number_id__c != NULL){
                                                      
                                                      Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
                                                      adjReq.Core_MDF_Amount_Amt__c = escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Approved_Amount_amt__c;
                                                      adjReq.Core_MDF_Reference_Claim_Nbr__c = pfc.Id;
                                                      adjReq.Core_MDF_Adjustment_Claim_Nbr__c = escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Claim_Number_id__c ;
                                                      adjReq.Core_MDF_Reason_Cd__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Review_Results_Positive');
                                                      adjReq.Core_MDF_Escalation_Id__c = escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Id;
                                                      toBeInsertedAdjustmentRec.add(adjReq); 
                                                  }  
                                               
                                               //If claim is in Pending Available Fund, Payment Due, Hold      
                                               if(nonPaidclmStsLst.contains(claimStatus)){ 
                                                   Decimal currentAdjAmount = pfc.Core_MDF_Audit_Adjustment_Amount__c -
                                                       escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Approved_Amount_amt__c;
                                                   //Add Error if adjustment amount is less than 0
                                                   if(currentAdjAmount < 0){ escalationList[0].addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Adjustment_Amount_Error'));                                                             
                                                   }                    
                                               }  
                                               
                                           }  
                                           
                                           toBeUpdatedClaims.add(pfc); 
                                       }
         
            if(toBeUpdatedCases.size() > 0){
                Database.update(toBeUpdatedCases);
            }
            
            if(toBeUpdatedClaims.size() > 0){
                Database.update(toBeUpdatedClaims);
            }
            
            
            if(toBeInsertedAdjustmentRec.size() > 0){
                Database.insert(toBeInsertedAdjustmentRec);  
            }   
         
        }        
        catch(Exception e){errorMessage = Core_MDF_CCP_UtilityClass.getErrorDetails(e); iserrorOccured = true;
            
            //Check for budget cap error
            if(!String.isBlank(errorMessage) && errorMessage.contains(Label.Core_MDF_ClaimExceedsCapRemainder_ErrorMsg)){
                isBusinessErrorOccured = true; 
                
                
                escalationList[0].addError(Label.Core_MDF_Escalation_Approval_Error_Message);
            }
            //Check for activity budget error
            else if(!String.isBlank(errorMessage) && errorMessage.contains(Label.Core_MDF_Retail_Claim_Amount_ShdBeWithIn_ActyBudgetAmt)){
                //Commenting the below lines as tehre is no need to send notification.
                //Approvers can edit the amount and approve in case claim amt is greater than budget amt.
                //isBusinessErrorOccured = true; 
                escalationList[0].addError(Label.Core_MDF_Escalation_Approval_Budget_Error_Msg);            }            else{
                escalationList[0].addError(Label.Core_MDF_ApplicationErrorMessage);                                                           
            }                                      
        }
        finally{
            
            if(iserrorOccured){
                Core_MDF_Notify_Account_Manager__e notificationEvent = new Core_MDF_Notify_Account_Manager__e();
                notificationEvent.Core_MDF_Escalation_Id_txt__c = String.valueOf(escalationList[0].Id);
                notificationEvent.Core_MDF_isBusinessError_ind__c = isBusinessErrorOccured == true ? true : false;
                notificationEvent.Core_MDF_errorMessage_txt__c = errorMessage;
                // Call method to publish events
                Database.SaveResult sr = EventBus.publish(notificationEvent);
            }
        }       
    }*/ 
    
    /****************************************************************************************************** 
    Method Name:        getEscalationFields
    @parameters:        escalation Id
    Description:        This method is used to check if Core_MDF_Do_not_Auto_Create_Claim_Ind__c is checked or not.
    Added By:           Manasa Accenture - 26/01/2020
    *******************************************************************************************************/
    @AuraEnabled
    public static claimCreateEscaltn getEscalationFields(Id escRecord){
        
        claimCreateEscaltn claimCrtEsc = new claimCreateEscaltn();
        Boolean doNotAutoCreateClaim = false;
        
        Id escCaseRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId(); 
        
        try{
            for(Core_MDF_Escalation__c escl: [SELECT Id,Core_MDF_Escalation_Type_nm__c, Core_MDF_Case_ID_Number_id__r.Core_MDF_Activity_ID__c, Core_MDF_Do_not_Auto_Create_Claim_Ind__c, Core_MDF_Claim_Number_id__c 
                                              FROM Core_MDF_Escalation__c
                                              WHERE Id=:escRecord AND RecordTypeId =: escCaseRecTypeId]) {
                if(!escl.Core_MDF_Do_not_Auto_Create_Claim_Ind__c && escl.Core_MDF_Claim_Number_id__c != NULL){
                    claimCrtEsc.doNotAutoCreateClaim = true;
                }
                if(escl.Core_MDF_Escalation_Type_nm__c == 'Claim Case Review Result'){
                    claimCrtEsc.caseReviewEsc = true;                               
                }
                
            }
            
            Schema.DescribeSObjectResult chkPer = Schema.sObjectType.PartnerFundClaim;
            claimCrtEsc.usrHasPer = chkPer.isCreateable();
            claimCrtEsc.mysteryShopperUser = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_PRC_Claim_Operation');
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}return claimCrtEsc;
    }
    /*****************************************************************************************************
    Method Name :   claimCreateEscaltn (Created a Wrapper to reduce the server side call)
    Added By    :   Nuzhath Zaiba on 3-Jun-2020
    ******************************************************************************************************/
    public class claimCreateEscaltn{
        
        @AuraEnabled
        public Boolean doNotAutoCreateClaim = false;
        @AuraEnabled
        public Boolean usrHasPer = false;
        @AuraEnabled
        public string response = '';
        @AuraEnabled
        public Boolean mysteryShopperUser = false;
        @AuraEnabled
        public Boolean caseReviewEsc = false;           
        
    }
    
    /****************************************************************************************************** 
    Method Name:        populateApproverNameAndComments
    @parameters:        List of Escalation
    Description:        This method is used to populate approver comments and approver names into escalation record
    Added By:           Sugathri Accenture - 13/05/2020
    *******************************************************************************************************/
   
   public static void populateApproverNameAndComments(List<Core_MDF_Escalation__c> escalationList){
        
        try{            
            Map<Id,Id> escIdProcessInstanceId = new Map<Id,Id>();
            List<Id> escalationIdList = new List<Id>();
            Map<Id,List<ProcessInstanceStep>> piPiStepMap = new Map<Id,List<ProcessInstanceStep>>();
            List<Core_MDF_Escalation__c> escToBeUpdated = new List<Core_MDF_Escalation__c>();
            
            for(Core_MDF_Escalation__c esc : escalationList){
                escalationIdList.add(esc.Id);
            }
            
            for(ProcessInstance pi : [SELECT Id,TargetObjectId FROM ProcessInstance 
                                      WHERE TargetObjectId IN: escalationIdList]){
                escIdProcessInstanceId.put(pi.TargetObjectId, pi.Id);
            }
            
            
            
            for(ProcessInstanceStep piStep : [SELECT Id,ActorId,StepStatus,ProcessInstanceId,Comments FROM ProcessInstanceStep 
                                              WHERE ProcessInstanceId IN: escIdProcessInstanceId.values() AND StepStatus != 'NoResponse' 
                                              ORDER BY CreatedDate ASC]){
                if(piPiStepMap.containsKey(piStep.ProcessInstanceId)){
                    piPiStepMap.get(piStep.ProcessInstanceId).add(piStep);
                }else{ piPiStepMap.put(piStep.ProcessInstanceId, new List<ProcessInstanceStep>{piStep});
                }
            }
            
           
            
            for(Core_MDF_Escalation__c esc : escalationList){
                if(escIdProcessInstanceId.containsKey(esc.Id) && escIdProcessInstanceId.get(esc.Id) != NULL){
                    Id processInstanceId = escIdProcessInstanceId.get(esc.Id);
                    if(piPiStepMap.containsKey(processInstanceId) && piPiStepMap.get(processInstanceId) != NULL){
                        Core_MDF_Escalation__c escInst = new Core_MDF_Escalation__c();
                        escInst.Id = esc.Id;

                        for(integer i = 1; i < piPiStepMap.get(processInstanceId).Size() ; i++){
                            
                            String approver = 'Core_MDF_Approver_'+i+'_Name_Id__c'; String comments = 'Core_MDF_Approver_'+i+'_Comments_txt__c';
                            
                            if(esc.get(approver) == NULL && piPiStepMap.get(processInstanceId)[i] != NULL){
                                escInst.put(approver,piPiStepMap.get(processInstanceId)[i].ActorId); escInst.put(comments,piPiStepMap.get(processInstanceId)[i].Comments); escInst.Core_MDF_Approval_Flag_ind__c = FALSE;
                            }
                        }
                        escToBeUpdated.add(escInst);
                    }
                }
            }
            
            if(escToBeUpdated != NULL && escToBeUpdated.Size() > 0){
                database.update(escToBeUpdated);
            }
        }
       catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
   }
       
   /****************************************************************************************************** 
    Method Name:        checkEscLateClaimCreation
    @parameters:        escalation Id
    Description:        
    Added By:           Sugathri Accenture - 26/05/2020
    *******************************************************************************************************/
    @AuraEnabled
    public static string checkEscLateClaimCreation(Id RecordId){
        string response ='SUCCESS';
        Map<String,Date> submissionWindowMap = new Map<String,Date>();
        Map<String,Date> closureWindowMap = new Map<String,Date>();
        List<string> ELIGIBLE_PROG = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Escalation_Eligible_Program') != null ? 
                				   Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Escalation_Eligible_Program').split(';') : new List<string>();
            
        // the key will be-> pgm:budgettype:geo:subgeo:country:date
        Core_MDF_Escalation__c esc = [Select Core_MDF_Claim_Number_id__c, Core_MDF_Co_Marketing_Activity_id__c, Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Activity_Level_nm__c, Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Program__c, Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Budget_Type_nm__c, Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Host_Region_txt__c,Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_nm__c, Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_nm__c,
                                      Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Country_nm__c, Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_End_Date__c,
                                      Tolabel(Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode),
                                      Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Geo__c
                                      FROM Core_MDF_Escalation__c 
                                      WHERE id = : RecordId]; 
        
        try{
            if(esc.Core_MDF_Co_Marketing_Activity_id__c != null && esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Activity_Level_nm__c == Core_MDF_CCP_ConstantClass.PFR_SUB_ACTIVITY){
                return Label.Core_MDF_Escalation_Error_Message_Prevent_Sub_Act;
            }
            
            if(esc.Core_MDF_Co_Marketing_Activity_id__c != null && ELIGIBLE_PROG.contains(esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Program__c)){
                map<String,Date> dueDateMap = new map<String,Date>();
                String ultiAccCntryGeo, japanCntry, budType, key, country, geo, subgeo;
                // US949836 : New Budget Type field changes replaced txt field with new global picklist field
                budType = esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Budget_Type_nm__c;
                //As per US846978, getting Ulti Account Country, Geo      
                ultiAccCntryGeo = esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Geo__c;
                japanCntry = esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode;
                
                
                if(String.isNotBlank(japanCntry)) {
                   japanCntry = japanCntry.toUpperCase();
                } 
                country = 'null';//esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Country_nm__c;
                //US1098882
                //geo = esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_cd__c;
                geo = (esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Program__c == 'Intel Partner Alliance') ? esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Host_Region_txt__c : esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_nm__c;
                subgeo = 'null';//esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_cd__c;
                
               //As per US846978, forming key for JAPAN cycle
               //Mohit - Commented to move japan country to 3 months a quarter and 4 cycles
                /*if(System.Label.Core_MDF_Retail_RSA_MD_Budget_Type.equals(budType) && System.Label.Core_MDF_Country_JAPAN.equals(japanCntry)){ 
                    country = japanCntry;  geo = ultiAccCntryGeo;  subgeo = 'null';
                }*/
                // US949836 : New Budget Type field changes replaced txt field with new global picklist field 
			    if(esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Program__c == 'Co-GTM'){
					List<String> geoRegions = geo.split(';');
					for (String region : geoRegions) {
					key = esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Program__c+
                      ':'+esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Budget_Type_nm__c+
                      ':'+geo+
                      ':'+subgeo+
                      ':'+country+
                      ':'+esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_End_Date__c.format();                          
                      
					key = key.deleteWhitespace();
					dueDateMap.put(key,null);
					}
				}
				else{
                key = esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Program__c+
                      ':'+esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Budget_Type_nm__c+
                      ':'+geo+
                      ':'+subgeo+
                      ':'+country+
                      ':'+esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_End_Date__c.format();                          
                      
                key = key.deleteWhitespace();
                dueDateMap.put(key,null);}
                submissionWindowMap = Core_MDF_ProcessClaimSubmissionClosure.getSubmissionDueDate(dueDateMap);
                closureWindowMap = Core_MDF_ProcessClaimSubmissionClosure.getEscSubDate(dueDateMap);
                //Avoid Deeply Nested IF Statements
                Boolean shouldProcess = (dueDateMap != null && submissionWindowMap != null && !submissionWindowMap.isEmpty() && closureWindowMap != null && !closureWindowMap.isEmpty());
                Date dtInstance = System.today();
                Date submissionDueDate = shouldProcess ? submissionWindowMap.values()[0] : null;
                Date closureDueDate = shouldProcess ? closureWindowMap.values()[0] : null;

                Boolean shouldSetError = shouldProcess && (closureDueDate != null) && !(dtInstance > submissionDueDate && dtInstance <= closureDueDate);
                response = shouldSetError ? Label.Core_MDF_Escalation_Error_Message_Late_Claim : response;               
            }
            if(esc.Core_MDF_Co_Marketing_Activity_id__c != null &&
               ELIGIBLE_PROG.contains(esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Program__c) && 
               esc.Core_MDF_Claim_Number_id__c != null){                   response = Label.Core_MDF_Escalation_Error_Message_Create_Multiple_Claim;
            }   
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}return response;
     }
    
    /****************************************************************************************************** 
    Method Name:        removeRecordFromApprovalProcess
    @parameters:        List<Core_MDF_Escalation__c> escalationList, Map<Id,Core_MDF_Escalation__c> escalationOldMap
    Description:        This method is used to remove expired records from approval process
    Added By:           Sugathri Accenture - 11/06/2020
    *******************************************************************************************************/
   
   public static void removeRecordFromApprovalProcess(List<Core_MDF_Escalation__c> recordIdList){
        
        try{       
            
            List<Approval.ProcessWorkitemRequest> processRequestList = new List<Approval.ProcessWorkitemRequest> ();
            List<ProcessInstanceWorkItem> processInstanceWIList = new List<ProcessInstanceWorkItem>();    
                        
            if(recordIdList != null && recordIdList.size() > 0){
                            
                //Get Process Instance Work Items
                processInstanceWIList = [SELECT Id FROM ProcessInstanceWorkItem  WHERE ProcessInstance.TargetObjectId IN :recordIdList AND ProcessInstance.Status = 'Pending']; 
                
                
            } 
                        
            for(ProcessInstanceWorkItem pIWorkItem : processInstanceWIList){                Approval.ProcessWorkitemRequest workItemRequest = new Approval.ProcessWorkitemRequest();workItemRequest.setAction('Removed');workItemRequest.setWorkitemId(pIWorkItem.Id); processRequestList.add(workItemRequest);
            } 
            

            if(!processRequestList.isEmpty()){                List<Approval.ProcessResult> processResults = Approval.process(processRequestList);
                                              
            }
            List<Core_MDF_Escalation__c> escList = new List<Core_MDF_Escalation__c>();
            for(Core_MDF_Escalation__c esc1 : [Select id, Core_MDF_Escalation_Status_nm__c from Core_MDF_Escalation__c
                                               WHERE id in: recordIdList]){                esc1.Core_MDF_Escalation_Status_nm__c = 'Expired';  escList.add(esc1);                                         
            }     Database.update(escList);            
        }   
       
       catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
   }
    
    /***************************************************************************************************** 
    Class Name    :        initialInputs
    Description   :        contains all the invocable variables
    Added By      :        Accenture - Sugathri - 06/15/2020
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    public class InitialInputs{
                            
        @InvocableVariable(label = 'record' required = true)
        public Core_MDF_Escalation__c escRecord;
       
        @InvocableVariable(label = 'status' required = true)
        public string status;   
        
        @InvocableVariable(label = 'approvalFlag' required = true)
        public Boolean approvalFlag;
    } 
    
    /***************************************************************************************************** 
    Method Name   :        determineMethod
    @return       :        void
    @parameters   :        List of initialInputs defined
    Description   :        Analyse the input parameters and call respective methods
    Added By      :        Accenture - Sugathri - 06/15/2020
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/
    @InvocableMethod
    public static void determineMethod(List<initialInputs> processInput){
        List<Core_MDF_Escalation__c> appCommentsList = new List<Core_MDF_Escalation__c>();
        List<Core_MDF_Escalation__c> expiredEscList = new List<Core_MDF_Escalation__c>();
        try{
            for(initialInputs inputs : processInput){
                if(inputs.status == 'Expired'){                    expiredEscList.add(inputs.escRecord);
                }
                if(inputs.status != 'Expired' || inputs.approvalFlag){
                    appCommentsList.add(inputs.escRecord);
                }
            }
            if(expiredEscList != NULL && expiredEscList.Size() > 0){                
                removeRecordFromApprovalProcess(expiredEscList);
            }
            if(appCommentsList != NULL && appCommentsList.Size() > 0){
                populateApproverNameAndComments(appCommentsList);
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    
    /***************************************************************************************************** 
    Method Name   :        validateCampAmt
    @return       :        void
    @parameters   :        List of Core_MDF_Escalation__c (trigger.new)
    Description   :        Validate Camp Amount
    Added By      :        Accenture - Saikat - 06-02-23
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/   
    public static void validateCampAmt(List<Core_MDF_Escalation__c> inputEscalations, Map<Id, Core_MDF_Escalation__c> escalationOldMap){
        List<Core_MDF_Escalation__c> escToValidateList = new List<Core_MDF_Escalation__c>();
        Set<String> pfrIdSet = new Set<String>();
        Map<String, String> pfrToCampBudgetKeyMap = new Map<String, String>();
        //Map contains the campaign-budget's amount against CampaignId+BudgetId+BudgetType
        Map<String, Decimal> cmpIdBudgetIdBudgetTypeToAmountMap = new Map<String, Decimal>();
        Map<String, Boolean> programMap = new Map<String, Boolean>();
        Map<String, String> campaignIdToBudgetIdMap = new Map<String, String>();
        Set<Id> ipaEEFRMFCampaignIdSet = new Set<Id>();
        
        //MDF;OEM CMP;MDF+;Service Provider CMP
        List<String> opalBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_OPAL_BudgetTypes').Split(';');
        //MDF;MDF+;Retail MDF
        
        Boolean isInsert = escalationOldMap == null ? true : false;

        try{
            for(Core_MDF_Escalation__c escalation : inputEscalations){
                if(checkvalidPrgmBudget(escalation, escalationOldMap)){
                    escToValidateList.add(escalation);
                    pfrIdSet.add(escalation.Core_MDF_Co_Marketing_Activity_id__c);
                }
            }
            if(!escToValidateList.isEmpty()){
                for(PartnerFundRequest pfr : [Select Id, CampaignId, Amount, ChannelPartnerId, Core_MDF_Program__c, Core_MDF_Budget_Type_nm__c, Core_MDF_Proposal_Based_Ind__c,
                                              Core_MDF_Activity_Reimbursement_Amt_nbr__c, BudgetId, Core_MDF_Campaign_Amount__c, Core_MDF_Is_Outcome_Based_Ind__c 
                                              FROM PartnerFundRequest WHERE Id In: pfrIdSet]){
                                                  decimal campAmount = 0;
                                                  //decimal ipaAccAmount = 0;
                                                  String budgetType = String.ValueOf(pfr.Core_MDF_Budget_Type_nm__c);
                                                  budgetType = string.isNotBlank(budgetType) ? budgetType.replaceAll('\\s+', '') : '';
                                                  
                                                  if(opalBudgetTypeList.contains(pfr.Core_MDF_Budget_Type_nm__c)){
                                                      programMap.put('isOpal', true);
                                                      String cmpIdAccIdBudgetTypeKey = String.ValueOf(pfr.CampaignId) + pfr.BudgetId + budgetType;
                                                      pfrToCampBudgetKeyMap.put(pfr.Id, cmpIdAccIdBudgetTypeKey);
                                                      campaignIdToBudgetIdMap.put(pfr.CampaignId, pfr.BudgetId);
                                                  }
                                                  /*else if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.RMF_PROGRAM && budgetTypeReqAllocationValidationList.contains(pfr.Core_MDF_Budget_Type_nm__c)){
                                                      rmfAmount =  pfr.Core_MDF_Campaign_Amount__c;
                                                      //String cmpIdAccIdBudgetTypeKey = String.ValueOf(pfr.CampaignId) + pfr.BudgetId + budgetType;
                                                      String cmpIdAccIdBudgetTypeKey = String.ValueOf(pfr.CampaignId) + budgetType;
                                                      cmpIdBudgetIdBudgetTypeToAmountMap.put(cmpIdAccIdBudgetTypeKey, rmfAmount);
                                                      pfrToCampBudgetKeyMap.put(pfr.Id, cmpIdAccIdBudgetTypeKey);
                                                      //campaignIdToBudgetIdMap.put(pfr.CampaignId, pfr.BudgetId);
                                                      ipaOrRMFCampaignIdSet.add(pfr.CampaignId);
                                                  }*/
                                                  else if(isRetailAccountBasedOrEEF(pfr)  && pfr.Core_MDF_Is_Outcome_Based_Ind__c != true){
                                                      campAmount =  pfr.Core_MDF_Campaign_Amount__c;
                                                      String cmpIdAccIdBudgetTypeKey = String.ValueOf(pfr.CampaignId) + budgetType;
                                                      cmpIdBudgetIdBudgetTypeToAmountMap.put(cmpIdAccIdBudgetTypeKey, campAmount);
                                                      pfrToCampBudgetKeyMap.put(pfr.Id, cmpIdAccIdBudgetTypeKey);
                                                      //ipaOrRMFCampaignIdSet.add(pfr.CampaignId);
                                                      ipaEEFRMFCampaignIdSet.add(pfr.CampaignId);
                                                  }
                                              }
            }
            if(!pfrToCampBudgetKeyMap.isEmpty()){
                validateEscalationWithCampaign(campaignIdToBudgetIdMap, pfrToCampBudgetKeyMap, cmpIdBudgetIdBudgetTypeToAmountMap,
                                               escToValidateList, programMap, ipaEEFRMFCampaignIdSet,escalationOldMap);
            }
        }
        catch(exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    } 
    /***************************************************************************************************** 
    Method Name   :        validateEscalationWithCampaign
    @return       :        void
    @parameters   :        List of Core_MDF_Escalation__c 
    Description   :        Validate Camp Amount
    Added By      :        Accenture - Saikat - 06-02-23
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/
    public static void validateEscalationWithCampaign(Map<String, String> campaignIdToBudgetIdMap, Map<String, String> pfrToCampBudgetKeyMap, 
                                                      Map<String, Decimal> cmpIdBudgetIdBudgetTypeToAmountMap, List<Core_MDF_Escalation__c> escalationList,
                                                      Map<String, Boolean> programMap, Set<Id> ipaEEFRMFCampaignIdSet, Map<Id, Core_MDF_Escalation__c> escalationOldMap){
                                                          
        //Map contains sum of all the activities amount against CampaignId+BudgetId+BudgetType
        Map<String, Decimal> budgetAgainstAmountMap = new Map<String, Decimal>(); 
        Map<String, Decimal> budgetAgainstInContMap = new Map<String, Decimal>();
        Map<String, Decimal> budgetAgainstIndPfrAmtMap = new Map<String, Decimal>();
        // Get all the activities with cmp budget
        Map<Id, PartnerFundRequest> cmpEEFBudgetPfrMap = new Map<Id, PartnerFundRequest>();
        //Map<String, PartnerFundRequest> cmpBudgetPfrMap = new Map<String, PartnerFundRequest>();
        Map<String, Decimal> pfrToClaimAmtMap = new Map<String, Decimal>();
        Map<String, Decimal> pfrToEscalationAmtMap = new Map<String, Decimal>();
        
        
        //Paid;Payment Due;Pending Payment;PIC Pending;Hold
        List<string> pfcCloseStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimStatus_ActivityAutoClose').split(';');
        
        //OEM CMP;Service Provider CMP
        List<String> cmpBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CMP_BudgetType').split(';'); 
        try{
                                                              /*if(!programMap.isEmpty() && programMap.containsKey('isIPAAccountBased') && programMap.get('isIPAAccountBased')){
                campReimbAmount = [select Id, Core_MDF_Account__c, Core_MDF_Reimbursement_Amt__c, Core_MDF_Budget__c, Core_MDF_Opal_Budget_Type_Txt__c, Core_MDF_Budget_Type_txt__c 
                                   from Campaign where Core_MDF_Program__c =: Core_MDF_CCP_ConstantClass.IPA_PROGRAM AND Core_MDF_Proposal_Based_Ind__c = false
                                   AND Id IN:campaignIdToBudgetIdMap.keyset()];
                if(!campReimbAmount.isEmpty()){
                    for(Campaign cmp : campReimbAmount){
                        pfrCampaignAmtAccount =(Decimal)cmp.get('Core_MDF_Reimbursement_Amt__c');
                        String budgetType = String.ValueOf(cmp.Core_MDF_Opal_Budget_Type_Txt__c);
                        budgetType = budgetType.replaceAll('\\s+', '');
                        String cmpIdAccIdBudgetType = String.ValueOf(cmp.Id) + cmp.Core_MDF_Account__c + budgetType;
                        cmpIdBudgetIdBudgetTypeToAmountMap.put(cmpIdAccIdBudgetType, pfrCampaignAmtAccount);
                    }
                }
}*/
            
            if(!programMap.isEmpty() && programMap.containsKey('isOpal') && programMap.get('isOpal')){  
                
                for(Core_MDF_Campaign_Budgets__c campBudget : [SELECT Id, Core_MDF_Reimbursement_Amt__c, Core_MDF_Budget_Type_Nm__c, Core_MDF_Campaign_Id__c,Core_MDF_Budget_Name_Id__c
                                                               FROM Core_MDF_Campaign_Budgets__c
                                                               WHERE Core_MDF_Budget_Name_Id__c IN: campaignIdToBudgetIdMap.values() 
                                                               AND Core_MDF_Campaign_Id__c IN: campaignIdToBudgetIdMap.keyset()]){
                    String budgetType = String.ValueOf(campBudget.Core_MDF_Budget_Type_Nm__c);
                    budgetType = budgetType.replaceAll('\\s+', '');
                    String cmpIdBudgetIdBudgetType = String.ValueOf(campBudget.Core_MDF_Campaign_Id__c) + campBudget.Core_MDF_Budget_Name_Id__c + budgetType;
                    cmpIdBudgetIdBudgetTypeToAmountMap.put(cmpIdBudgetIdBudgetType, campBudget.Core_MDF_Reimbursement_Amt__c);            
                }
            }
            
            for(PartnerFundRequest pfr : [SELECT Id, BudgetId, ChannelPartnerId, Core_MDF_Activity_Reimbursement_Amt_nbr__c,Core_MDF_Fund_Request_Status__c, CampaignId, Core_MDF_Budget_Type_nm__c,Amount, Core_MDF_Proposal_Based_Ind__c,Core_MDF_Program__c
                                          FROM PartnerFundRequest
                                          WHERE ((BudgetId IN: campaignIdToBudgetIdMap.values() AND CampaignId IN: campaignIdToBudgetIdMap.keyset())
                                          OR CampaignId IN: ipaEEFRMFCampaignIdSet)
                                          AND Core_MDF_Fund_Request_Status__c != 'Cancelled']){
                                          //Querying for all activities related to the campaign
                String budgetType = String.ValueOf(pfr.Core_MDF_Budget_Type_nm__c);
                budgetType = string.isNotBlank(budgetType) ? budgetType.replaceAll('\\s+', '') : '';
                String cmpIdBudgetIdBudgetType = String.ValueOf(pfr.CampaignId) + pfr.BudgetId + budgetType;
                String campaignIdBudgetType = string.valueOf(pfr.CampaignId) + budgetType;
                
				//Boolean isCmpBudget = false;
                Boolean isCmpOrEEFBudget = false;
                Decimal pfrAmount = pfr.Amount != null ? pfr.Amount : 0.0;
                Decimal pfrIntelCont = pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c != null ? pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c : 0.0;
                budgetAgainstInContMap.put(pfr.Id, pfrIntelCont);
                budgetAgainstIndPfrAmtMap.put(pfr.Id, pfrAmount);
                if((cmpBudgetTypeList != null && cmpBudgetTypeList.contains(pfr.Core_MDF_Budget_Type_nm__c)) || pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.PFR_EEF_PROGRAM){
                    isCmpOrEEFBudget = true;
                    if(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_CLOSED_STATUS){
                        //cmpBudgetPfrMap.put(pfr.Id,pfr);
                        cmpEEFBudgetPfrMap.put(pfr.Id,pfr);
                    }   
                }
                                                                                                if((budgetAgainstAmountMap.containsKey(cmpIdBudgetIdBudgetType) || budgetAgainstAmountMap.containsKey(campaignIdBudgetType))
                                                                                                 && pfr.Amount != null){
                                                                                                    decimal amount = 0;
                                                                                                    Decimal existingAmt = isRetailOrAccountBased(pfr) ? budgetAgainstAmountMap.get(campaignIdBudgetType) : budgetAgainstAmountMap.get(cmpIdBudgetIdBudgetType);
                                                                                                    amount += existingAmt != null ? existingAmt : 0;
                                                     if(isCmpOrEEFBudget){
                                                                                                    if(pfr.Core_MDF_Fund_Request_Status__c != Core_MDF_CCP_ConstantClass.PFR_CLOSED_STATUS && pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c != null){ 
                                                                                                       amount += pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c;
                                                                                                    }
                                                                                                 }else{
                                                                                                     amount += pfr.Amount;
                                                                                                 }
                                                                                                    if(isRetailOrAccountBased(pfr)){
                                                                                                        budgetAgainstAmountMap.put(campaignIdBudgetType, amount);//map to store total of amounts on pfr for each camp+budgettype
                                                                                                    } else {
                                                                                                        budgetAgainstAmountMap.put(cmpIdBudgetIdBudgetType, amount);
                                                                                                    }
                }else{
                    if(pfr.Amount != null){
                        decimal amount = 0;
                        if(isCmpOrEEFBudget){
                            if(pfr.Core_MDF_Fund_Request_Status__c != Core_MDF_CCP_ConstantClass.PFR_CLOSED_STATUS && pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c != null){ 
                                amount += pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c;
                            }
                        }else{
                            amount += pfr.Amount;
                        }
                                                                                                        if(isRetailOrAccountBased(pfr)){
                                                                                                            budgetAgainstAmountMap.put(campaignIdBudgetType, amount);// map to store total of amounts on pfr for each camp+budgettype
                        } else {
                           budgetAgainstAmountMap.put(cmpIdBudgetIdBudgetType, amount);
                        }}
                                                                                                }
                                                                                            }
                                                              
            //Only for CMP Budget Type & EEF program
            if(cmpEEFBudgetPfrMap != NULL && cmpEEFBudgetPfrMap.keyset() != null && !cmpEEFBudgetPfrMap.isEmpty()){
                for(AggregateResult pfc : [SELECT RequestId Id ,sum(Amount)amt
                                           FROM PartnerFundClaim 
                                           WHERE RequestId IN:cmpEEFBudgetPfrMap.keyset() AND Core_MDF_Status__c IN:pfcCloseStatus  
                                           AND Core_MDF_Type_Txt__c =: TYPE_CLAIM AND Core_MDF_Escalation_Id__c = null 
                                           GROUP BY RequestId]){ 
                    ID pfrID =(Id)pfc.get('Id');    
                    Decimal pfrClaimedAmount =(Decimal)pfc.get('amt');
                    pfrToClaimAmtMap.put(pfrID,pfrClaimedAmount);
                }
                for(AggregateResult esc : [SELECT Core_MDF_Co_Marketing_Activity_id__c Id,sum(Core_MDF_Approved_Amount_amt__c)amt
                                           FROM Core_MDF_Escalation__c
                                           WHERE Core_MDF_Co_Marketing_Activity_id__c IN:cmpEEFBudgetPfrMap.keyset() 
                                           AND Core_MDF_Escalation_Status_nm__c =: ESC_APPROVED_STATUS
                                           GROUP BY Core_MDF_Co_Marketing_Activity_id__c]){
                    ID pfrID =(Id)esc.get('Id');
                    Decimal pfrEscAmount =(Decimal)esc.get('amt');
                    pfrToEscalationAmtMap.put(pfrID,pfrEscAmount); 
                }
            }
            
            for(PartnerFundRequest pfr: cmpEEFBudgetPfrMap.Values()){
                Decimal totalEscAmt = 0.0;
                Decimal totalClaimedAmt = 0.0;
                Decimal totalClaimEscConsumedAmt = 0.0;
                Decimal amount = 0.0;
                String budgetType = String.ValueOf(pfr.Core_MDF_Budget_Type_nm__c);
                budgetType = string.isNotBlank(budgetType) ? budgetType.replaceAll('\\s+', '') : '';
                String cmpIdBudgetIdBudgetType = String.ValueOf(pfr.CampaignId) + pfr.BudgetId + budgetType;
                if(pfr.Amount != null){
                    totalEscAmt = pfrToEscalationAmtMap.containskey(pfr.Id) ? pfrToEscalationAmtMap.get(pfr.Id) : 0;
                    totalClaimedAmt = pfrToClaimAmtMap.containskey(pfr.Id) ? pfrToClaimAmtMap.get(pfr.Id) : 0;
                    totalClaimEscConsumedAmt = totalEscAmt + totalClaimedAmt;
                    amount = totalClaimEscConsumedAmt >= pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c
                            ? pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c : totalClaimEscConsumedAmt;
                    budgetAgainstIndPfrAmtMap.put(pfr.Id, amount);
                    if(budgetAgainstAmountMap.containsKey(cmpIdBudgetIdBudgetType)){
                        amount += budgetAgainstAmountMap.get(cmpIdBudgetIdBudgetType);
                        budgetAgainstAmountMap.put(cmpIdBudgetIdBudgetType, amount);
                    }else{
                        budgetAgainstAmountMap.put(cmpIdBudgetIdBudgetType, amount); 
                    }                                                                        
                }
            }
            
            for(Core_MDF_Escalation__c escalation : escalationList){
                decimal totalAmount = 0;
                decimal allocationAmount = 0;
                decimal avalabileAmount = 0;
                String mapKey = '';
                if(pfrToCampBudgetKeyMap.containsKey(escalation.Core_MDF_Co_Marketing_Activity_id__c)){
                    mapKey = pfrToCampBudgetKeyMap.get(escalation.Core_MDF_Co_Marketing_Activity_id__c);
                    if(cmpIdBudgetIdBudgetTypeToAmountMap.containsKey(mapKey)){
                        totalAmount += cmpIdBudgetIdBudgetTypeToAmountMap.get(mapKey);
                                                                          //Amount on campaign
                    }
                    if(budgetAgainstAmountMap.containsKey(mapKey)){
                        allocationAmount += budgetAgainstAmountMap.get(mapKey);
                                                                          //sum of amounts on activity
                    }
                }
                
                decimal diffAmount = 0;
                if(escalationOldMap==null || escalation.Core_MDF_Escalation_Status_nm__c=='Pending Review'){
                    diffAmount = escalation.Core_MDF_Approved_Amount_amt__c;
                }else{
                    //this block will get executed for amount change & for normal approval process
                    diffAmount = ((escalation.Core_MDF_Approved_Amount_amt__c != escalationOldMap.get(escalation.Id).Core_MDF_Approved_Amount_amt__c) && 
                    (escalation.Core_MDF_Approved_Amount_amt__c > escalationOldMap.get(escalation.Id).Core_MDF_Approved_Amount_amt__c)) ? 
                        escalation.Core_MDF_Approved_Amount_amt__c - escalationOldMap.get(escalation.Id).Core_MDF_Approved_Amount_amt__c : escalation.Core_MDF_Approved_Amount_amt__c;
                }
                
                avalabileAmount = totalAmount - allocationAmount;
                if(avalabileAmount < diffAmount){
                    escalation.addError(Label.Core_MDF_OPAL_Amount_Validation_Error);
                } else { 
                   if(escalationList.size() > 1 && String.isNotBlank(mapKey)){
                        String pfrId = String.valueOf(escalation.Core_MDF_Co_Marketing_Activity_id__c);
                        allocationAmount = allocationAmount - budgetAgainstIndPfrAmtMap.get(pfrId);
                        Decimal pfrFinalAmt = budgetAgainstIndPfrAmtMap.get(pfrId) + diffAmount; 
                        if(pfrFinalAmt >= budgetAgainstInContMap.get(pfrId)){ 
                            allocationAmount += budgetAgainstInContMap.get(pfrId);
                            budgetAgainstIndPfrAmtMap.put(pfrId, budgetAgainstInContMap.get(pfrId));
                        } else {
                            budgetAgainstIndPfrAmtMap.put(pfrId, pfrFinalAmt);
                            allocationAmount += pfrFinalAmt; 
                        }
                        budgetAgainstAmountMap.put(mapKey, allocationAmount);
                	}
                }   
            }
        }
        catch(exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
	}
    }
    public static Boolean isRetailOrAccountBased(PartnerFundRequest pfr){
        Boolean isRetailOrAccBased = false;
        if((pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM 
            && pfr.Core_MDF_Proposal_Based_Ind__c == false) || 
            pfr.Core_MDF_Budget_Type_nm__c == System.Label.Core_MDF_RetailMDF_BudgetType){
            isRetailOrAccBased = true;
        }
        return isRetailOrAccBased;
    }
    public static Boolean isRetailAccountBasedOrEEF(PartnerFundRequest pfr){
        Boolean isRetailOrAccBased = false;
        if((pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM 
            && pfr.Core_MDF_Proposal_Based_Ind__c == false) ||
           (pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.PFR_EEF_PROGRAM && pfr.Core_MDF_Budget_Type_nm__c == Core_MDF_CCP_ConstantClass.EEF_BUDGET_TYPE) ||
            pfr.Core_MDF_Budget_Type_nm__c == System.Label.Core_MDF_RetailMDF_BudgetType){
            isRetailOrAccBased = true;
        }
        return isRetailOrAccBased;
    }
    /****************************************************************************************************** 
    Method Name:        checkvalidPrgmBudget
    @return  :          Boolean
    @parameters:        escalation, escalationOldMap, isInsert
    Description:        
    Added By:           Saikat   20-02-2023
    Modified By:         
    *******************************************************************************************************/
    public static Boolean checkvalidPrgmBudget(Core_MDF_Escalation__c escalation, Map<Id, Core_MDF_Escalation__c> escalationOldMap){
        Boolean isvalidPrgmBudget = false;
        Boolean isInsert = escalationOldMap == null ? true : false;
        if(escalation.Core_MDF_Escalation_Type_nm__c == LATECLAIM_TYPE && (isInsert 
           || (!isInsert && (escalation.Core_MDF_Escalation_Status_nm__c != escalationOldMap.get(escalation.Id).Core_MDF_Escalation_Status_nm__c 
           && escalation.Core_MDF_Escalation_Status_nm__c == Core_MDF_CCP_ConstantClass.ESC_APPROVED_STATUS)
           || ((escalation.Core_MDF_Approved_Amount_amt__c != escalationOldMap.get(escalation.Id).Core_MDF_Approved_Amount_amt__c) && 
              escalation.Core_MDF_Escalation_Status_nm__c == Core_MDF_CCP_ConstantClass.ESC_PENDING_REVIEW_STATUS)))
           && escalation.Core_MDF_Co_Marketing_Activity_id__c != NULL && String.isNotBlank(escalation.Core_MDF_Co_Marketing_Activity_id__c)){
                isvalidPrgmBudget = true;
        }
        return isvalidPrgmBudget;
    }
    
    
    /****************************************************************************************************** 
Method Name : validateEscalationAgainstRecoveries      
@parameters : escalation,  before Insert
Description : Method to throw validation when found recoveries.        
Added By    : Shiva               
*******************************************************************************************************/
    public static void validateEscalationAgainstRecoveries(List<Core_MDF_Escalation__c> escalationList, Boolean isInsert){
        Id escCaseRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId(); 
        set<string> caseIdSet = new set<string>();
        Map<string,Set<Id>> caseKeyToCaseIdSetMap = new Map<string,Set<Id>>();
        Map<string,Decimal> caseIdToRecoveryAmtMap = new Map<string,Decimal>();
        Map<string,Decimal> pdsKeyToAmtMap = new Map<string,Decimal>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<string> programSet = new Set<string>();
        set<String> quarterSet =new Set<String>();
        set<String> byPassInValidEscStatus = new set<String>{'Denied','Cancelled'};
        string CREATION_RECOVERY_VALIDATION = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Recovery_On_Escalation_Creation');
        string UPDATE_RECOVERY_VALIDATION = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Recovery_On_Escalation_Update');
        string IPA_PROG = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;
        string RMF_PROG = Core_MDF_CCP_ConstantClass.RMF_PROGRAM;
        //[Xprog] open escalation creation for current quarter and settle and getpaid //indu
        Map<Id,String> caseIdToQuarterMap = new Map<Id,String>();
        Map<Id,Boolean> caseIdToSurePayMap = new Map<Id,Boolean>();
        try{
            for(Core_MDF_Escalation__c esc : escalationList){
                if(!byPassInValidEscStatus.contains(esc.Core_MDF_Escalation_Status_nm__c) && esc.RecordTypeId == escCaseRecTypeId && esc.Core_MDF_Case_ID_Number_id__c != null){
                    caseIdSet.add(esc.Core_MDF_Case_ID_Number_id__c);
                }
            }
            //TWC702-11727 - [KIIT] Claim Case Review Result Escalation- Recovery validation- fix
            if(!caseIdSet.isEmpty()){
                for(Core_MDF_Scorecard__c scorecard:[SELECT Core_MDF_Quarter__c,Core_MDF_Case_Id__c,Core_MDF_Case_Id__r.ClosedDate,Core_MDF_Case_Id__r.AccountId,Core_MDF_Case_Id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c,
                                                    Core_MDF_Case_Id__r.Core_MDF_Claim_ID__c,Core_MDF_Case_Id__r.Core_MDF_Audit_Reversal_Count_Nbr__c,Core_MDF_Case_Id__r.Core_MDF_Claim_Lookup_Id__r.Core_MDF_SurePay_Processed_Ind__c
                                                    FROM Core_MDF_Scorecard__c 
                                                    WHERE Core_MDF_Case_Id__c IN : caseIdSet AND  Core_MDF_Case_Id__r.ClosedDate != NULL]){
                        string accountId = (scorecard.Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c == IPA_PROG || scorecard.Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c == RMF_PROG) ? scorecard.Core_MDF_Case_Id__r.AccountId : scorecard.Core_MDF_Case_Id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c; string accIdProgQuarterkey = accountId + (string)scorecard.Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c + scorecard.Core_MDF_Quarter__c;
                    
                        if(!caseKeyToCaseIdSetMap.containsKey(accIdProgQuarterkey)){
                            caseKeyToCaseIdSetMap.put(accIdProgQuarterkey, new Set<Id>());
                        }
                        caseKeyToCaseIdSetMap.get(accIdProgQuarterkey).add(scorecard.Core_MDF_Case_Id__c); quarterSet.add(scorecard.Core_MDF_Quarter__c); programSet.add(scorecard.Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c); accountIdSet.add(accountId);
			String quarter = Core_MDF_ReverseAuditDecision.determineQuartYear(date.newinstance(scorecard.Core_MDF_Case_Id__r.ClosedDate.year(), scorecard.Core_MDF_Case_Id__r.ClosedDate.month(), scorecard.Core_MDF_Case_Id__r.ClosedDate.day())); caseIdToQuarterMap.put(scorecard.Core_MDF_Case_Id__c,quarter); caseIdToSurePayMap.put(scorecard.Core_MDF_Case_Id__c,scorecard.Core_MDF_Case_Id__r.Core_MDF_Claim_Lookup_Id__r.Core_MDF_SurePay_Processed_Ind__c);
                }
            }
            
            //Check if Account has Recovery for the quarter
            if(!accountIdSet.isEmpty() && !programSet.isEmpty() && !quarterSet.isEmpty()){
                for(Core_MDF_Partnership_Score_Detail__c psd : [SELECT Id, Core_MDF_Recovered_Amt__c,Core_MDF_Account_Id__c,Core_MDF_Program_Nm__c,Core_MDF_Quarter_Year_Nm__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c,Core_MDF_Node_Account_Id__c
                                                                FROM Core_MDF_Partnership_Score_Detail__c 
                                                                WHERE (Core_MDF_Node_Account_Id__c IN: accountIdSet OR Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c IN: accountIdSet)
                                                                AND Core_MDF_Program_Nm__c IN: programSet
                                                                AND Core_MDF_Quarter_Year_Nm__c IN: quarterSet]){
                                                                    string accIdProgQuarterkey = '';
                                                                    if(psd.Core_MDF_Program_Nm__c == IPA_PROG || psd.Core_MDF_Program_Nm__c == RMF_PROG){
                                                                        accIdProgQuarterkey = (string)psd.Core_MDF_Node_Account_Id__c + (string)psd.Core_MDF_Program_Nm__c + psd.Core_MDF_Quarter_Year_Nm__c;
                                                                    }else{
                                                                       accIdProgQuarterkey = (string)psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c + (string)psd.Core_MDF_Program_Nm__c + psd.Core_MDF_Quarter_Year_Nm__c;
                                                                    }
                                                                    
                                                                    if(caseKeyToCaseIdSetMap.containsKey(accIdProgQuarterkey) && !caseKeyToCaseIdSetMap.get(accIdProgQuarterkey).isEmpty()){
                                                                        if(!pdsKeyToAmtMap.containsKey(accIdProgQuarterkey)){
                                                                            pdsKeyToAmtMap.put(accIdProgQuarterkey,psd.Core_MDF_Recovered_Amt__c);
                                                                        }else{
                                                                            decimal amount = pdsKeyToAmtMap.get(accIdProgQuarterkey);
                                                                            amount += psd.Core_MDF_Recovered_Amt__c;
                                                                            pdsKeyToAmtMap.put(accIdProgQuarterkey,amount);
                                                                        }
                                                                        
                                                                    }
                                                                }
            }
            
            if(!pdsKeyToAmtMap.isEmpty()){
                for(string key : pdsKeyToAmtMap.keySet()){
                    Decimal recoveredAmt = pdsKeyToAmtMap.get(key);
                    if(caseKeyToCaseIdSetMap.containsKey(key)){
                        for(String caseId : caseKeyToCaseIdSetMap.get(key)){
                            caseIdToRecoveryAmtMap.put(caseId,recoveredAmt);
                        }   
                    }
                }   
            }
            Date currDate = System.today(); String currentQuarterYear = Core_MDF_ReverseAuditDecision.determineQuartYear(date.newinstance(currDate.year(), currDate.month(), currDate.day()));
                    
            if(!caseIdToRecoveryAmtMap.isEmpty()){
                for(Core_MDF_Escalation__c esc : escalationList){
		    if(caseIdToRecoveryAmtMap.containsKey(esc.Core_MDF_Case_ID_Number_id__c) && caseIdToRecoveryAmtMap.get(esc.Core_MDF_Case_ID_Number_id__c) > 0){
                               if(caseIdToQuarterMap.containsKey(esc.Core_MDF_Case_ID_Number_id__c) && caseIdToSurePayMap.containsKey(esc.Core_MDF_Case_ID_Number_id__c)){                               
                                String caseQuarter = caseIdToQuarterMap.get(esc.Core_MDF_Case_ID_Number_id__c); Boolean surePayInd = caseIdToSurePayMap.get(esc.Core_MDF_Case_ID_Number_id__c);
                                if(caseQuarter == currentQuarterYear && surePayInd != true){
                                    continue;
                                }}
				string errorMsg = (isInsert == true) ? CREATION_RECOVERY_VALIDATION : UPDATE_RECOVERY_VALIDATION; esc.addError(errorMsg);
                            }
                }
               
            }
            
            
        }
        catch(Exception ex){Core_MDF_CCP_UtilityClass.logError(ex);
        }
        
    }
 
    public static string getYearFromQuarter(date dateToBeconverted){
        string result;
        try{
            Integer month = dateToBeconverted.month();
            Integer quarter = math.round((month+1)/3.0);
            Integer year = dateToBeconverted.year();
            result = 'Q' + quarter + ' ' + year;
           
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
        return result;
    }
    
    
    Public static void populateCaseDetails(List<Core_MDF_Escalation__c> caseEscalationList, Set<Id> caseIds){
        Map<Id,Case> caseIdToObjMap = new Map<Id,Case>();
        
        try{
            
            if(!caseIds.isEmpty()){
                for(Case caseRec :  [SELECT Id, Core_MDF_Claim_Review_Closure_Note__c
                                     FROM Case 
                                     WHERE Id IN: caseIds]){
                                         if(string.isNotBlank(caseRec.Core_MDF_Claim_Review_Closure_Note__c)){
                                             caseIdToObjMap.put(caseRec.Id,caseRec);
                                         }
                                     }
            }
            
            if(!caseIdToObjMap.isEmpty()){
                for(Core_MDF_Escalation__c esc: caseEscalationList){
                       esc.Core_MDF_Claim_Review_Closure_Note_txt__c = caseIdToObjMap.containsKey(esc.Core_MDF_Case_ID_Number_id__c) ? caseIdToObjMap.get(esc.Core_MDF_Case_ID_Number_id__c).Core_MDF_Claim_Review_Closure_Note__c : '';
                }
            }


        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    /****************************************************************************************************** 
Method Name : validationAgainstClaim      
@parameters : escalationlist
Description : Method to throw validation when it have associated claims.        
Added By    : Gayathri/Aswin      
*******************************************************************************************************/
    public static void validationAgainstClaim(List<Core_MDF_Escalation__c> escalationList, Map<Id,Core_MDF_Escalation__c> escalationOldMap){

        List<String> INVALID_CLAIM_STATUSES = new List<String>{'Denied', 'Closed', 'Cancelled', 'Adjusted'};
        Id escLateClaimRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId(); 
        Map<Id,Boolean> mapOfEscClaimAmtIncrease = new Map<Id,Boolean>();
        Map<Id,Boolean> mapOfEscClaimAmtDecrease = new Map<Id,Boolean>();
        Map<id, Decimal> mapOfClaimtoApprAmt = new Map<id, Decimal>();
        List<Core_MDF_Escalation__c> escalationIdList = new List<Core_MDF_Escalation__c>();
        if(FeatureManagement.checkPermission('Core_MDF_Internal_CSC_User')){

            for(Core_MDF_Escalation__c esc: escalationList){
    
                if(esc.recordTypeId == escLateClaimRecTypeId && esc.Core_MDF_Claim_Number_id__c != null &&
                    //esc.Core_MDF_Escalation_Status_nm__c == escalationOldMap.get(esc.Id).Core_MDF_Escalation_Status_nm__c && 
                    esc.Core_MDF_Escalation_Status_nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Approved') && 
                    esc.Core_MDF_Approved_Amount_amt__c != escalationOldMap.get(esc.Id).Core_MDF_Approved_Amount_amt__c){
                        escalationIdList.add(esc);
                        if(mapOfClaimtoApprAmt.containsKey(esc.Core_MDF_Claim_Number_id__c)){
                            Decimal approvedAmt=esc.Core_MDF_Approved_Amount_amt__c+mapOfClaimtoApprAmt.get(esc.Core_MDF_Claim_Number_id__c); mapOfClaimtoApprAmt.put(esc.Core_MDF_Claim_Number_id__c,approvedAmt);
                        }else{
                            mapOfClaimtoApprAmt.put(esc.Core_MDF_Claim_Number_id__c,esc.Core_MDF_Approved_Amount_amt__c);
                        }
                    }
            }
            if(mapOfClaimtoApprAmt!=null){
                for(PartnerFundClaim claim : [Select id,Amount,Core_MDF_Escalation_Id__c from PartnerFundClaim where Id IN:mapOfClaimtoApprAmt.keyset() and Core_MDF_Status__c Not IN:INVALID_CLAIM_STATUSES]){
                    //exisitng claims- ccheck with vinodhini
                    Decimal claimAmt = claim.Amount !=null ? claim.Amount : 0;
                    Decimal approvedEscAmt = (mapOfClaimtoApprAmt!=null && mapOfClaimtoApprAmt.containskey(claim.id)) ? mapOfClaimtoApprAmt.get(claim.id) : 0;
                    if(approvedEscAmt > claimAmt){
                        mapOfEscClaimAmtIncrease.put(claim.Core_MDF_Escalation_Id__c, true);
                    } else if(approvedEscAmt < claimAmt){
                        mapOfEscClaimAmtDecrease.put(claim.Core_MDF_Escalation_Id__c, true);
                    }
                }

                if(escalationIdList.size()>0){
                    Boolean escAmtIncrease = false;
                    Boolean escAmtDecrease =  false;
                    for(Core_MDF_Escalation__c esc: escalationIdList){
                        escAmtIncrease = (mapOfEscClaimAmtIncrease!=null && mapOfEscClaimAmtIncrease.containskey(esc.id)) ? mapOfEscClaimAmtIncrease.get(esc.id) : false;
                        escAmtDecrease = (mapOfEscClaimAmtDecrease!=null && mapOfEscClaimAmtDecrease.containskey(esc.id)) ? mapOfEscClaimAmtDecrease.get(esc.id) : false;
                        if(escAmtIncrease){esc.addError(Core_MDF_CCP_ConstantClass.ESC_AMT_INCREASE_CLAIM);
                        }
                        if(escAmtDecrease){esc.addError(Core_MDF_CCP_ConstantClass.ESC_AMT_DECREASE_CLAIM);//confirm with Aradhana
                        }
                    }
                }
            }

        }
    
    }

    /****************************************************************************************************** 
Method Name : releaseEscalationAmount      
@parameters : escalationlist, oldmap
Description : Method to release the unused amount on pfr.        
Added By    : Gayathri/Aswin      
*******************************************************************************************************/   
    public static void releaseEscalationAmount(List<Core_MDF_Escalation__c> escalationList, Map<Id,Core_MDF_Escalation__c> escalationOldMap){

        List<PartnerFundRequest> listOfActtobeUpdated = new List<PartnerFundRequest>();
        Map<Id,Decimal> mapOfPfrtoApprAmt = new Map<Id,Decimal>();
        Set<Id> activityIdSet = new Set<Id>();
        Set<Id> escIdSet = new Set<Id>();
        Map<Id, Decimal> pfrToClaimAmtMap = new Map<Id,Decimal>();
        Map<Id, Decimal> pfrToEscalationAmtMap = new Map<Id, Decimal>();
        Id escLateClaimRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId(); 
        List<String> INVALID_CLAIM_STATUSES = new List<String>{'Denied', 'Resubmission Window Closed', 'Cancelled', 'Adjusted'};
		List<String> budgetTypeList = new List<String>{'MDF', 'MDF+', 'Retail MDF','Account Plan','Proposal I MDF','Proposal II MDF'};
            
        if(FeatureManagement.checkPermission('Core_MDF_Internal_CSC_User')){

            for(Core_MDF_Escalation__c esc: escalationList){

                //PR to Approved && Core_MDF_Co_Marketing_Activity_id__c!=null
                if(esc.recordTypeId == escLateClaimRecTypeId && esc.Core_MDF_Co_Marketing_Activity_id__c != null &&
                    esc.Core_MDF_Escalation_Status_nm__c == escalationOldMap.get(esc.Id).Core_MDF_Escalation_Status_nm__c && 
                    esc.Core_MDF_Escalation_Status_nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Approved') && 
                    esc.Core_MDF_Approved_Amount_amt__c != escalationOldMap.get(esc.Id).Core_MDF_Approved_Amount_amt__c && 
                    budgetTypeList.contains(esc.Core_MDF_Budget_Type_txt__c)){
                        
                        escIdSet.add(esc.Id);
                        activityIdSet.add(esc.Core_MDF_Co_Marketing_Activity_id__c);
                        if(mapOfPfrtoApprAmt.containsKey(esc.Core_MDF_Co_Marketing_Activity_id__c)){
                                Decimal approvedAmt=esc.Core_MDF_Approved_Amount_amt__c+mapOfPfrtoApprAmt.get(esc.Core_MDF_Co_Marketing_Activity_id__c); mapOfPfrtoApprAmt.put(esc.Core_MDF_Co_Marketing_Activity_id__c,approvedAmt);
                        }else{
                            mapOfPfrtoApprAmt.put(esc.Core_MDF_Co_Marketing_Activity_id__c,esc.Core_MDF_Approved_Amount_amt__c);
                        }
                    }
            }
            if(activityIdSet!=null && activityIdSet.size()>0){
                for(AggregateResult pfc : [SELECT RequestId Id ,sum(Amount)amt
                                        FROM PartnerFundClaim 
                                        WHERE RequestId IN:activityIdSet
                                        AND Core_MDF_Type_Txt__c =: TYPE_CLAIM
                                        AND Core_MDF_Status__c NOT IN:INVALID_CLAIM_STATUSES
                                        AND Core_MDF_Escalation_Id__c=NULL
                                        GROUP BY RequestId]){ 
                    ID pfrID =(Id)pfc.get('Id');   Decimal pfrClaimedAmount =(Decimal)pfc.get('amt'); pfrToClaimAmtMap.put(pfrID,pfrClaimedAmount);
                }
                for(AggregateResult esc : [SELECT Core_MDF_Co_Marketing_Activity_id__c Id,sum(Core_MDF_Approved_Amount_amt__c)amt
                                        FROM Core_MDF_Escalation__c
                                        WHERE Core_MDF_Co_Marketing_Activity_id__c IN:activityIdSet 
                                        AND Core_MDF_Escalation_Status_nm__c ='Approved' AND ID NOT IN:escIdSet
                                        GROUP BY Core_MDF_Co_Marketing_Activity_id__c]){
                    ID pfrID =(Id)esc.get('Id'); Decimal pfrEscAmount =(Decimal)esc.get('amt'); pfrToEscalationAmtMap.put(pfrID,pfrEscAmount); 
                }
                
                for(PartnerFundRequest pfr : [Select Id,Amount,Core_MDF_Activity_Reimbursement_Amt_nbr__c from PartnerFundRequest where Id in : activityIdSet and Core_MDF_Fund_Request_Status__c='Closed']){
                
                    if(mapOfPfrtoApprAmt.containsKey(pfr.id)){
    
                        Decimal totalClaimEscConsumedAmt = (pfrToClaimAmtMap!=null && pfrToClaimAmtMap.containsKey(pfr.Id)?pfrToClaimAmtMap.get(pfr.Id):0) + (pfrToEscalationAmtMap!=null && pfrToEscalationAmtMap.containsKey(pfr.Id)?pfrToEscalationAmtMap.get(pfr.Id):0);
                        
                        //Sum of all the claims +all other escalations except this one + new value (incoming escalation's amt)
                        Decimal finalAmount = totalClaimEscConsumedAmt + mapOfPfrtoApprAmt.get(pfr.Id);
    
                        Decimal intelContributionAmt = pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c!=null ? pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c : 0;
    
                        if(intelContributionAmt >= finalAmount){
                            pfr.Amount=finalAmount;
                        }else if(intelContributionAmt < finalAmount){
                            pfr.Amount=intelContributionAmt;
                        }
                        listOfActtobeUpdated.add(pfr);
                    }
                }
            }
            
            if(listOfActtobeUpdated !=null && listOfActtobeUpdated.size()>0){
                update listOfActtobeUpdated;
            }
        }

    }
/****************************************************************************************************** 
Method Name : distributeEscalationAmountToOutcomeSubActivities      
@parameters : escalationlist, oldmap
Description : Method to release the amount among the sub-activities        
Added By    : Ramapriya      
*******************************************************************************************************/   
public static void distributeEscalationAmountToOutcomeSubActivities(List<Core_MDF_Escalation__c> newList, Map<Id, Core_MDF_Escalation__c> oldMap) {
    
        Map<Id, Decimal> parentActToEscAmt = new Map<Id, Decimal>(); Set<Id> parentActivityIds = new Set<Id>();

        for (Core_MDF_Escalation__c esc : newList) {
            Core_MDF_Escalation__c oldEsc = oldMap.get(esc.Id);
            if (oldEsc == null) continue;

            if (esc.Core_MDF_Escalation_Type_nm__c == LATECLAIM_TYPE && esc.Core_MDF_Escalation_Status_nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Approved') &&
                esc.Core_MDF_Approved_Amount_amt__c != null && esc.Core_MDF_Co_Marketing_Activity_id__c != null ) {parentActivityIds.add(esc.Core_MDF_Co_Marketing_Activity_id__c); parentActToEscAmt.put(esc.Core_MDF_Co_Marketing_Activity_id__c,esc.Core_MDF_Approved_Amount_amt__c);
            }
        }

        if (parentActivityIds.isEmpty()) return;

        Map<Id, PartnerFundRequest> validParentActivities = new Map<Id, PartnerFundRequest>([SELECT Id FROM PartnerFundRequest WHERE Id IN :parentActivityIds AND Core_MDF_Is_Outcome_Based_Ind__c = true ]);

        if (validParentActivities.isEmpty()) return;

        List<Core_MDF_Outcome_Account_Mapping__c> mappings = [
            SELECT Id, Core_MDF_Outcome_Based_CampaignId__c,Core_MDF_OutcomeBased_SubAct_Id__c,Core_MDF_Percentage_pct__c,Core_MDF_Amount_nbr__c 
            FROM Core_MDF_Outcome_Account_Mapping__c
            WHERE Core_MDF_Outcome_Based_CampaignId__c IN :validParentActivities.keySet()
            AND Core_MDF_Active_Ind__c = true
            AND Core_MDF_OutcomeBased_SubAct_Id__c != null
        ];

        if (mappings.isEmpty()) return;

        Map<Id, PartnerFundRequest> subActivitiesToUpdate = new Map<Id, PartnerFundRequest>();

        for (Core_MDF_Outcome_Account_Mapping__c mapRec : mappings) {

            Id parentId = mapRec.Core_MDF_Outcome_Based_CampaignId__c;
            if (!parentActToEscAmt.containsKey(parentId)) continue;
            if (mapRec.Core_MDF_Percentage_pct__c == null || mapRec.Core_MDF_Percentage_pct__c <= 0) continue;

            Decimal approvedAmt = parentActToEscAmt.get(parentId); Decimal splitAmt = approvedAmt * (mapRec.Core_MDF_Percentage_pct__c / 100);

            Id subActId = mapRec.Core_MDF_OutcomeBased_SubAct_Id__c;
            PartnerFundRequest subAct = subActivitiesToUpdate.containsKey(subActId) ? subActivitiesToUpdate.get(subActId) : new PartnerFundRequest(Id = subActId);

            Decimal mappingCap = mapRec.Core_MDF_Amount_nbr__c; Decimal existingSubAmt = (subAct.Amount != null) ? subAct.Amount : 0;

            if (mappingCap == null || mappingCap <= 0 || existingSubAmt >= mappingCap) {
                continue;
            }

            Decimal remainingAllowed = mappingCap - existingSubAmt; Decimal amountToAdd = Math.min(splitAmt, remainingAllowed);

            subAct.Amount = existingSubAmt + amountToAdd; subActivitiesToUpdate.put(subActId, subAct);
        }

        if (!subActivitiesToUpdate.isEmpty()) {update subActivitiesToUpdate.values();
        }
}
/****************************************************************************************************** 
Method Name : validateClaimingWindow      
@parameters : List of Escalation escalationlist 
Description : Method to check claiming window of manually closed activities       
Added By    : Mohit      
*******************************************************************************************************/   
    public static void validateClaimingWindow(List<Core_MDF_Escalation__c> escalationList){
        
        try{
            //List to collect Late Claim Escalation
            List<Core_MDF_Escalation__c> esclist = new  List<Core_MDF_Escalation__c>();
            //List of PFR Id's to collect PFR id from corresponding late claim escalation
            List<Id> pfrIdList = new List<Id>();
            //Set of PFR Id's to collect PFR id where closure type is manual and Actual close date before closure is greater than eequal to Today
            set<Id> pfrFinalSet = new set<Id>();
            //Iterating over list of escalation and collecting PFR Id list, Escalation List
            for(Core_MDF_Escalation__c esc : escalationList){
                if(esc.Core_MDF_Escalation_Type_nm__c == LATECLAIM_TYPE && esc.Core_MDF_Co_Marketing_Activity_id__c != null){pfrIdList.add(esc.Core_MDF_Co_Marketing_Activity_id__c);esclist.add(esc);
                }
                
            }
            if(!pfrIdList.isEmpty() && !esclist.isEmpty()){
                //Itertaing over list of PFR associated to late claim escalation
                for(PartnerFundRequest pfr : [Select id,Core_MDF_Actual_closedt_beforeclosure_dt__c,Core_MDF_Activity_Closure_Type__c 
                                              FROM PartnerFundRequest
                                              WHERE Id IN: pfrIdList AND Core_MDF_Activity_Closure_Type__c =: Core_MDF_CCP_ConstantClass.PFR_Manual_Close
                                                    AND Core_MDF_Actual_closedt_beforeclosure_dt__c >=: system.today()]){
                                                  //Entry condition checking activity closure type as Manual and Actual close date is greater then today's date
                                                  //if above condition satisfies then create a set of PFR Id to Actual Close Date
                                                         pfrFinalSet.add(pfr.id);
                                              }
                //Iterate over list of Late Claim Escalation, if Set of PFR Id contains PFR Id associated to escalation then throw error
                if(!pfrFinalSet.isEmpty()){
                    for(Core_MDF_Escalation__c esc : esclist){
                        if(pfrFinalSet.contains(esc.Core_MDF_Co_Marketing_Activity_id__c)){
                            esc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Late_ClaimEsc_ManualClos_Error')); //error msg
                        }
                    } 
                }  
            }   
        }catch(Exception e){Core_MDF_CCP_UtilityClass.getErrorDetails(e);}
    }  
}