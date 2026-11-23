/******************************************************************************************************
* Class Name  : Core_MDF_PartnerFundClaim 
* Version     : 1.0 
* Created Date: 10-30-2018
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Intel - SM      10/30/2018          Controller class for New Claim creation functionality
Aura enabled class calling from Create claim lightning component.
*******************************************************************************************************/

public without sharing class Core_MDF_PartnerFundClaim {
    /****************************************************************************************************** 
Method Name:        saveClaim
@return  :          String value (Upsert record Id / Failed)
@parameters:        PartnerFundClaim object
Description:        This method is used to create and save new claim data.
Added By:           Accenture - JV - 10/30/2018
Test Class:	    Core_MDF_PartnerFundClaim_Test, Core_MDF_PFC_IPAClaim_Test
Modified By:        Date:       Changes: 
Areefa          25-Sept-19    POP changes added to saveClaim method
Vinodhini       27-Oct-10     New Param - AI PIC MDF POP Validation
*******************************************************************************************************/ 
    @AuraEnabled
    public static ClaimWrap saveClaim(PartnerFundClaim claim, List<Core_MDF_Audit_Document__c> auditDocList, String amountFields,string docId, Boolean isOutcomeBased, List<Core_MDF_Claim_Attributes__c> claimAttributeList, Boolean hasAnyChangeOnClaim, List<PartnerFundClaim> subClaimList, Boolean isClone){
        ClaimWrap clmWrap = new ClaimWrap();
        Savepoint sp = Database.setSavepoint();
        try{
            List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
            PartnerFundClaim claimRecord = new PartnerFundClaim();
            if(amountFields != Null)
            {
                AmountFieldsWrapper wrapper=(AmountFieldsWrapper)JSON.deserialize(amountFields,AmountFieldsWrapper.class);  
                if(wrapper.totalAmountLocal !=Null){
                    claim.Core_MDF_Total_Invoice_Amount_Local__c = decimal.valueOf(wrapper.totalAmountLocal);
                    
                    if(wrapper.costNotReimbursable !=Null)
                        claim.Core_MDF_OtherCostsnotReimbursable_Local__c = decimal.valueOf(wrapper.costNotReimbursable);
                    
                    if(wrapper.taxesLocal !=Null)
                        claim.Core_MDF_Taxes_Local__c = decimal.valueOf(wrapper.taxesLocal);
                }
                if(subClaimList != null && !subClaimList.isEmpty() && subClaimList.size()>0)
                    claim.Core_MDF_Has_Sub_Claims_Ind__c = true;
            }
            if(claim != null){
                Boolean isUpdate = false;
                if(claim.Id == null){   
                    Database.insert(claim);
                    if(isClaimEzyEnabled() && String.isNotBlank(docId)){
                        updateActualValues(claim,docId);
                    }
                } 
                else {
                    isUpdate = true;
                    Database.update(claim);
                }   
                //call assignDocumentList to attach documents to claimID if documents are uploaded  
                if(claim.id!=null && auditDocList!=null && auditDocList.size()>0){
                    assignDocumentList(auditDocList,claim);
                }
                //Populate ClaimId in Claim Attribute records to insert
                if(claim.Id != null && isOutcomeBased && !claimAttributeList.isEmpty()){
                    
                    
                    List<Core_MDF_Claim_Attributes__c> claimAttributeListToInsert = new List<Core_MDF_Claim_Attributes__c>();
                    Map<String, Decimal> tacticToNewValueMap = new Map<String, Decimal>();
                    for(Core_MDF_Claim_Attributes__c claimAttribute : claimAttributeList){
                        if(String.isBlank(claimAttribute.Id)){
                            claimAttribute.Core_MDF_Claim_Id__c = claim.Id;
                        }
                        tacticToNewValueMap.put(claimAttribute.Core_MDF_Tactics_nm__c, claimAttribute.Core_MDF_Field_Value_nbr__c);
                        claimAttributeListToInsert.add(claimAttribute);
                    }
                    
                    Map<String, Decimal> tacticToDifferanceValueMap = new Map<String, Decimal>();
                    Map<String, String> claimIdToClaimRefNumberMap = new Map<String, String>();
                    if(isUpdate){
                        for(Core_MDF_Claim_Attributes__c existingClaimAttr : [SELECT Id,Core_MDF_Claim_Id__c, Core_MDF_Claim_Id__r.Core_MDF_Claim_Ref_Number__c, Core_MDF_Tactics_nm__c, Core_MDF_Field_Name_nm__c, Core_MDF_Field_Value_nbr__c FROM Core_MDF_Claim_Attributes__c WHERE Core_MDF_Claim_Id__c =: claim.Id AND Core_MDF_Type_nm__c = 'Spend This Period']){
                            if(tacticToNewValueMap.containsKey(existingClaimAttr.Core_MDF_Tactics_nm__c)){
                                tacticToDifferanceValueMap.put(existingClaimAttr.Core_MDF_Tactics_nm__c, (existingClaimAttr.Core_MDF_Field_Value_nbr__c - tacticToNewValueMap.get(existingClaimAttr.Core_MDF_Tactics_nm__c)));
                                claimIdToClaimRefNumberMap.put(existingClaimAttr.Core_MDF_Claim_Id__c, existingClaimAttr.Core_MDF_Claim_Id__r.Core_MDF_Claim_Ref_Number__c);
                            }
                        }
                    }
                    
                    Database.upsert(claimAttributeListToInsert);//@@Add save point
                    
                    if(tacticToDifferanceValueMap != null && !tacticToDifferanceValueMap.isEmpty()){
                        Map<String,Map<String, Decimal>> claimIdToTacticToDifferanceValueMap = new Map<String,Map<String, Decimal>>();
                        claimIdToTacticToDifferanceValueMap.put(claim.Id, tacticToDifferanceValueMap);
                        Core_MDF_Tactics_Controller.updateClaimAttributes(claimIdToClaimRefNumberMap ,claimIdToTacticToDifferanceValueMap, 'Edit');
                    }
                }
                
                //Added by VB - AI PIC
                try
                {
                    if(!(Core_MDF_Claim_Utility.bypassCDBCalloutValidationCheck('Core_MDF_ProcessClaimsWithAIForPICReview','Core_MDF_Bypass_AI_CDB_CallForClaims'))) {
                        List<String> aiPICEnabledPgms = Label.Core_MDF_AI_POP_Validation_EnabledPrograms.split(';');
                        PartnerFundClaim pfc = new PartnerFundClaim();
                        if(!isUpdate && !claim.Core_MDF_OutcomeBased_Ind__c) {
                            pfc  = [select Id,Core_MDF_Program__c, CreatedDate, Core_MDF_Status__c,Core_MDF_Budget_Type_Nm__c, Core_MDF_OutcomeBased_Ind__c, Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,
                                    Core_MDF_Ad_Run_Start_Date__c, Core_MDF_Ad_Run_End_Date__c, Core_MDF_Reimbursable_TransactionAmt_Loc__c, Core_MDF_Total_Invoice_Amount_Local__c, Core_MDF_Currency__c, Core_MDF_Activity_Types__c, request.Core_MDF_Activity_Description__c, request.Core_MDF_POP_Requirements_txt__c, request.Core_MDF_Attribution_Requirements_txt__c, Amount, Core_MDF_Budget_Type_Options_Nm__c from PartnerFundClaim where Id =: claim.Id];
                            pfc.Core_MDF_Status__c = !Claim.Core_MDF_OutcomeBased_Ind__c ? label.Core_MDF_Claim_Status_PIC_Pending : claim.Core_MDF_Status__c;
                            
                        } else {
                            pfc = claim;
                        }
                        
                        if(Core_MDF_Claim_Utility.isClaimEligibleForAICDBCallout(pfc) && (!isUpdate || (isUpdate && hasAnyChangeOnClaim))) {
                            Map<Id, PartnerFundClaim> claimIdToClaimRecMap = new Map<Id, PartnerFundClaim>();
                            claimIdToClaimRecMap.put(claim.Id, claim);
                            String Context = isUpdate ? 'update' : 'insert';
                            Core_MDF_AI_Integration_Outbound.generateAIResponseForPICProcess(claimIdToClaimRecMap, Context);
                        }
                    }
                }
                catch (Exception e) {
                    Core_MDF_CCP_UtilityClass.logError(e);
                }
                
                claimRecord = [Select id,Core_MDF_Excess_Requested_Amount__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Status__c,Core_MDF_Claim_Submitter_Id__c,Core_MDF_Processing_Preference_nm__c,Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Reimbursable_TransactionAmt_Loc__c,Core_MDF_Requested_Reimbursement_Amt__c,Amount,Title,Core_MDF_Claim_Ref_Number__c,Core_MDF_Currency__c from PartnerFundClaim where id = : claim.id];
                List<PartnerFundClaim> cloneClaimList = new List<PartnerFundClaim>();
                if(isClone==null) isClone=false;
                if (subClaimList != null && !subClaimList.isEmpty()) {
                    for (PartnerFundClaim subClm : subClaimList) {
                        if(subClm.isSet('Id')){
                            if(isClone){
                                PartnerFundClaim pfc =  subClm.clone(false, false, false, false);
                                pfc.Core_MDF_Bank__c =  String.valueOf(subClm.Core_MDF_Bank__c).startsWith('a40') ? subClm.Core_MDF_Bank__c : null;
                                pfc.Core_MDF_VAT_Opt_In__c = subClm.Core_MDF_VAT_Opt_In__c;
                                pfc.Core_MDF_Claim_Id__c = claim.Id;
                                pfc.Core_MDF_Status__c = claim.Core_MDF_Status__c;
                                pfc.Core_MDF_Ad_Run_Start_Date__c = claim.Core_MDF_Ad_Run_Start_Date__c;
                                pfc.Core_MDF_Ad_Run_End_Date__c = claim.Core_MDF_Ad_Run_End_Date__c;
                                pfc.Core_MDF_Country_Location_nm__c = claim.Core_MDF_Country_Location_nm__c;
                                pfc.Core_MDF_Currency__c = claim.Core_MDF_Currency__c;
                                pfc.Core_MDF_Claim_Submitter_Id__c  = claim.Core_MDF_Claim_Submitter_Id__c;
                                pfc.Core_MDF_Processing_Preference_nm__c = claim.Core_MDF_Processing_Preference_nm__c;
                                pfc.Title = (claimRecord.Core_MDF_Claim_Ref_Number__c + '-' + claimRecord.Title).left(255);
                                pfc.Core_MDF_Invoice_Date__c = claim.Core_MDF_Invoice_Date__c;
                                pfc.Core_MDF_Invoice_Number__c = claim.Core_MDF_Invoice_Number__c;
                                pfc.Core_MDF_Claim_Comments__c = claim.Core_MDF_Claim_Comments__c;
                                cloneClaimList.add(pfc);
                            }
                            //continue;
                            else{
                                subClm.Title = (claimRecord.Core_MDF_Claim_Ref_Number__c + '-' + claimRecord.Title).left(255);
                                subClm.Core_MDF_Ad_Run_Start_Date__c = claim.Core_MDF_Ad_Run_Start_Date__c;
                                subClm.Core_MDF_Ad_Run_End_Date__c = claim.Core_MDF_Ad_Run_End_Date__c;
                                subClm.Core_MDF_Country_Location_nm__c = claim.Core_MDF_Country_Location_nm__c;
                                subClm.Core_MDF_Currency__c = claim.Core_MDF_Currency__c;
                                subClm.Core_MDF_Invoice_Date__c = claim.Core_MDF_Invoice_Date__c;
                                subClm.Core_MDF_Invoice_Number__c = claim.Core_MDF_Invoice_Number__c;
                                subClm.Core_MDF_Claim_Comments__c = claim.Core_MDF_Claim_Comments__c;
                            }
                        }
                        else{
                            subClm.Core_MDF_Claim_Id__c = claim.Id;
			                subClm.Core_MDF_Escalation_Id__c = claim.Core_MDF_Escalation_Id__c;
                            subClm.Core_MDF_Status__c = claim.Core_MDF_Status__c;
                            subClm.Core_MDF_Ad_Run_Start_Date__c = claim.Core_MDF_Ad_Run_Start_Date__c;
                            subClm.Core_MDF_Ad_Run_End_Date__c = claim.Core_MDF_Ad_Run_End_Date__c;
                            subClm.Core_MDF_Country_Location_nm__c = claim.Core_MDF_Country_Location_nm__c;
                            subClm.Core_MDF_Currency__c = claim.Core_MDF_Currency__c;
                            subClm.Core_MDF_Claim_Submitter_Id__c  = claim.Core_MDF_Claim_Submitter_Id__c;
                            subClm.Core_MDF_Processing_Preference_nm__c = claim.Core_MDF_Processing_Preference_nm__c;
                            subClm.Title = (claimRecord.Core_MDF_Claim_Ref_Number__c + '-' + claimRecord.Title).left(255);
                            subClm.Core_MDF_Invoice_Date__c = claim.Core_MDF_Invoice_Date__c;
                            subClm.Core_MDF_Invoice_Number__c = claim.Core_MDF_Invoice_Number__c;
                            subClm.Core_MDF_Claim_Comments__c = claim.Core_MDF_Claim_Comments__c;
                            Decimal pct = subClm.Core_MDF_Amount_Percentage__c; 
                            if (pct == null) continue;
                            Decimal ratio = pct / 100;
                            subClm.Core_MDF_Requested_Reimbursement_Amt__c = claimRecord.Core_MDF_Requested_Reimbursement_Amt__c * ratio;
                            if (!String.valueOf(subClm.Core_MDF_Bank__c).startsWith('a40')) {
                                subClm.Core_MDF_Bank__c = null; 
                            }
                        }
                    }
                    if(!cloneClaimList.isEmpty()){
                        insert cloneClaimList;
                    } else {                        
                        upsert subClaimList;
                    }
                }
                clmWrap.claimDetail = claimRecord;
                clmWrap.errorDetail = '';
                return clmWrap;
                
            }else{  
                clmWrap.claimDetail = null;
                clmWrap.errorDetail = '';
                return clmWrap; }
        }catch(Exception e){
            Database.rollback(sp);
            Core_MDF_CCP_UtilityClass.logError(e);
            clmWrap.claimDetail = null;
            clmWrap.errorDetail = 'Exception: '+e.getMessage();
            return clmWrap;
            
        }
    }
    
    /****************************************************************************************************** 
Method Name:        assignDocumentList
@return  :          boolean
@parameters:        auditDocList and claimId
Description:        This method is used to assignDocumentList to claimId .
Added By:           Intel - Areefa - 15 Oct 2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    public static boolean assignDocumentList(List<Core_MDF_Audit_Document__c> auditDocList,PartnerFundClaim claim) {
        try {
            //list of content document link to be insert/update
            List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
            if(auditDocList != null && auditDocList.size() >0){
                for(Core_MDF_Audit_Document__c auditDoc : auditDocList){
                    //ContentDocumentLink instance will not be created , if record already exists
                    if(String.isBlank(auditDoc.Core_MDF_Claim__c)){
                        ContentDocumentLink conDocLink = new ContentDocumentLink();
                        auditDoc.Core_MDF_Claim__c = claim.Id;  
                        //Documents uploaded during claim edit should be attached over case as well.
                        if(claim.Core_MDF_Claim_Review_Case__c!=null){
                            auditDoc.Core_MDF_Audit__c = claim.Core_MDF_Claim_Review_Case__c;
                        }
                        conDocLink.ContentDocumentId = auditDoc.Core_MDF_Document_Id__c;    // documentId
                        conDocLink.LinkedEntityId = claim.Id;                                //LinkedEntityId: attaching to ClaimId
                        conDocLink.ShareType='I';
                        conDocLink.Visibility='AllUsers';
                        contentDocLinkList.add(conDocLink);
                    }
                }
                if(auditDocList != null && auditDocList.size() > 0){
                    Database.upsert(auditDocList); 
                }
                if(contentDocLinkList.size()>0){
                    Database.upsert(contentDocLinkList);
                }
                return true;
            }else { return false;}            
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
        
    }
    
    /****************************************************************************************************** 
Method Name:        getActivityFields
@return  :          PartnerFundRequest object
@parameters:        Activity record ID
Description:        This method is used to fetch record based on activity ID.
Added By:           Accenture JV- 10/30/2018
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    public static PartnerFundRequest getActivityFields(Id activityId){
        
        try{
            PartnerFundRequest activityObj = [SELECT Id,Core_MDF_Region_nm__c,Core_MDF_Activity_Number__c,Core_MDF_ActivityCategory__c,Core_MDF_End_Date__c,
                                              Core_MDF_Start_Date__c,Core_MDF_Activity_Types__c,
                                              Core_MDF_Brand_nm__c,toLabel(Core_MDF_Country_nm__c) countryNameLocalized,Status,Core_MDF_Country_nm__c,Core_MDF_Fund_Request_Status__c,Title,
                                              Core_MDF_TargetAudience__c,Core_MDF_Reimbursement_Rate__c,
                                              ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name,
                                              ChannelPartner.Name,ChannelPartner.Id,RecordType.DeveloperName,Core_MDF_Budget_Type_nm__c,toLabel(Core_MDF_Budget_Type_nm__c) LocalizedBudgetType,
                                              RequestedAmount, Core_MDF_Program__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,
                                              CampaignId,Campaign.Name,Campaign.Description,toLabel(Core_MDF_Activity_SubType_nm__c) LocalizedActivitySubType,Core_MDF_Activity_SubType_nm__c,Core_MDF_POP_Requirements_txt__c,Core_MDF_Activity_Closure_Type__c,
                                              Core_MDF_Proposal_Based_Ind__c, ChannelPartner.Core_MDF_Channel_Program__r.Name, ChannelPartner.Core_MDF_Payment_Type_nm__c, ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c, 
                                              Core_MDF_NEX_Ind__c, Core_MDF_Key_Marketing_Indicator_nm__c, Core_MDF_Deployment_Quantity_nbr__c, Core_MDF_Lead_Quantity_nbr__c, Core_MDF_Other_Quantity_nbr__c,Core_MDF_CSP_Intel_Based_Revenue_amt__c,Core_MDF_Is_Outcome_Based_Ind__c,Core_MDF_Activity_Description__c,Core_MDF_Parent_Activity_Id__c,Core_MDF_Activity_Level_nm__c
                                              FROM PartnerFundRequest WHERE Id=:activityId LIMIT 1];
            if(activityObj != null){
                return activityObj;
            }
            
            else{return null;}
        }catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }
    
    /****************************************************************************************************** 
Method Name:        getActivityDetails
@return  :          ActivityDetailsWrapper
@parameters:        Activity record ID
Description:        This method is used to activity details based on activity ID.
Added By:           Accenture VB- 18/06/2024
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static ActivityDetailsWrapper getActivityDetails(Id activityId){
        Map<String,String> countryLabelToAPINameMap = new Map<String,String>();
        List<String> nonLocCountriesFromAct = new List<String>();
        List<String> locCountriesFromAct = new List<String>();
        String nonLocalizedCountryValues;
        String localizedCountryValues;
        Boolean isOutComeBasedActivity = false;
        try{
            ActivityDetailsWrapper activityDetailsWrap = new ActivityDetailsWrapper();
            PartnerFundRequest activityDetails = getActivityFields(activityId);
            if(activityDetails != null){
                if(activityDetails.Core_MDF_Program__c != Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM) {
                    isOutComeBasedActivity = activityDetails.Core_MDF_Is_Outcome_Based_Ind__c;
                    countryLabelToAPINameMap = getPickListvalues('PartnerFundClaim', 'Core_MDF_Country_Location_nm__c');
                    nonLocCountriesFromAct =  activityDetails.Core_MDF_Country_nm__c.split(';');
                    nonLocCountriesFromAct.sort();
                    if(nonLocCountriesFromAct != null && nonLocCountriesFromAct.size() > 0 && !countryLabelToAPINameMap.isEmpty()) {
                        for(String country: nonLocCountriesFromAct) {
                            if(countryLabelToAPINameMap.containsKey(country) && countryLabelToAPINameMap.get(country) != null) {
                                locCountriesFromAct.add(countryLabelToAPINameMap.get(country));
                            }
                        }
                        nonLocalizedCountryValues = String.join(nonLocCountriesFromAct, ';');
                    }
                    if(locCountriesFromAct != null && locCountriesFromAct.size() > 0) {
                        localizedCountryValues = String.join(locCountriesFromAct, ';');
                    }
                }
                activityDetailsWrap.localizedCountryValues = localizedCountryValues;
                activityDetailsWrap.nonLocalizedCountryValues = nonLocalizedCountryValues;
                activityDetailsWrap.isOutComeBasedActivity = isOutComeBasedActivity; 
                activityDetailsWrap.activityDetails = activityDetails;
                return activityDetailsWrap;
            }
            
            else{return null;}
        }catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }
    
    
    /****************************************************************************************************** 
Method Name:        getPickListvalues
@return  :          List<String>
@parameters:        Object Name and api name
Description:        This method is used to fetch pick list values for specific field.
Added By:           Accenture - AD - 11/1/2018
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static Map<String,String> getPickListvalues(String objectName, String fieldApiName){
        Map<String,String> optionlist = new Map<String,String>();
        try {
            Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
            Map<String, Schema.SObjectField> fieldmap = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap(); 
            List<Schema.PicklistEntry> picklistValues = fieldmap.get(fieldApiName).getDescribe().getPickListValues();
            
            for (Schema.PicklistEntry pv : picklistValues) {
                optionlist.put(pv.getValue(),pv.getLabel());
            }
            
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        return optionlist;
    }
    
    /****************************************************************************************************** 
Method Name:        fetchClaimSubmitters
@return  :          List<Id>
@parameters:        ultimateAccountId and techProgramName
Description:        This method is used to fetch claim submitters
Added By:           Accenture - VD - 03/12/2020
Modified By:        Date:      Changes: 
Roshan              19/01/2925  Added changes for "Reclaiming SF Partner License"
*******************************************************************************************************/    
    @AuraEnabled
    public static List<Id> fetchClaimSubmitters(Id ultimateAccountId, String techProgramName){
        Set<Id> listOfClaimSubId = new Set<Id>();   
        Map<Id,Id> contIdUserIdMap = new Map<Id,Id>();
        String retailPgm = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name');
        String pRCClaimSubmitter = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_PRC_ClaimSubmitter');
        for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Core_MDF_Account__c, Core_MDF_User__c, Core_MDF_User__r.ContactId 
                                                          FROM Core_MDF_Partner_Node_User_Mapping__c 
                                                          WHERE Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c =: ultimateAccountId 
                                                          AND (Core_MDF_User__r.IsActive = TRUE OR Core_MDF_User__r.Partner_License_Reclaimed__c = TRUE) AND Core_MDF_Active_Ind__c = true
                                                          AND Core_MDF_Account__r.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =: techProgramName limit 10000])
        {
            contIdUserIdMap.put(pnum.Core_MDF_User__r.ContactId,pnum.Core_MDF_User__c);
        }
        List<Core_MDF_ChannelProgram__mdt> channelProgRec = [Select Core_MDF_Technical_Program_Name__c,Core_MDF_ClaimSubEntitlementName_Txt__c 
                                                       from Core_MDF_ChannelProgram__mdt where Core_MDF_Technical_Program_Name__c =:techProgramName LIMIT 1];                  
        
        Set<String> claimSubEntNameSet = new Set<String>();
        if(channelProgRec != Null && !channelProgRec.isEmpty() && channelProgRec[0].Core_MDF_ClaimSubEntitlementName_Txt__c != Null){
            claimSubEntNameSet.addAll(channelProgRec[0].Core_MDF_ClaimSubEntitlementName_Txt__c.split(';'));       
        }
        
        if(contIdUserIdMap!=null && contIdUserIdMap.size()>0 && claimSubEntNameSet != Null && claimSubEntNameSet.size()>0){
            for(Core_Contact_Entitlement__c contEnt : [select id,Core_Contact_Id__c, Core_Entitlement_Id__r.name 
                                                       from Core_Contact_Entitlement__c 
                                                       where Core_Contact_Id__c IN : contIdUserIdMap.keyset() 
                                                       AND Core_Selected__c = true AND Core_Status__c='Complete' 
                                                       AND Core_Entitlement_Id__r.name IN : claimSubEntNameSet])
            {        
                if(contIdUserIdMap.containskey(contEnt.Core_Contact_Id__c)){
                    listOfClaimSubId.add(contIdUserIdMap.get(contEnt.Core_Contact_Id__c));
                }                
            }
        }
        
        // Adding logic for to add mystery shopper user into the list, based on IUPGM
        if(techProgramName == retailPgm) {  
            // Roshan - License Reclaim Changes for Internal Users 
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm:[SELECT id,Core_MDF_User_id__c FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c WHERE (Core_MDF_User_id__r.IsActive = true OR Core_MDF_User_id__r.Partner_License_Reclaimed__c = TRUE) and Core_MDF_Active_Ind__c = true 
                                                                 and Core_MDF_Program_nm__c =: retailPgm and Core_MDF_Account_id__r.Core_MDF_CoMarketing_Ultimate_Account__c =:ultimateAccountId 
                                                                 and Core_MDF_Role_nm__c =:pRCClaimSubmitter]){           
                                                                     if(iupgm.Core_MDF_User_id__c <> null) 
                                                                     { 
                                                                         listOfClaimSubId.add(iupgm.Core_MDF_User_id__c);
                                                                     }
                                                                 }
        }
        
        // Additionally adding the users from the exceptional permission set - Core_MDF_CCP_Internal_System_User
        for(PermissionSetAssignment psa: [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name =: 'Core_MDF_CCP_Internal_System_User']){
            if(!listOfClaimSubId.contains(psa.AssigneeId)){
                listOfClaimSubId.add(psa.AssigneeId);
            }
        }                    
        return new List<Id>(listOfClaimSubId);
    }
    
    
    /****************************************************************************************************** 
Method Name:        fetchBankRecords
@return  :          List<sObject>
@parameters:        N/A
Description:        This method is used to fetch bank object records
Added By:           Accenture - AD - 11/2/2018
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static List<sObject> fetchBankRecords(Id accountId){
        List<sObject> listValues= new List<sObject>();
        try {
            Set<String> bankStatusSet = new Set<String>();
            String bankStatusList = System.label.Core_MDF_Claim_Bank_StatusList;
            if(!String.IsBlank(bankStatusList)){
                for(String bankStatus : bankStatusList.split(';')){
                    bankStatusSet.add(bankStatus);
                }
            } 
            listValues = [SELECT Core_MDF_Bank__r.Id, Core_MDF_Bank__r.Name, Core_MDF_Bank__r.Core_MDF_Bank_Status__c, Core_MDF_Bank__r.Core_MDF_Bank_Alias_Name__c,Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c, Core_MDF_Bank__r.Core_MDF_VAT_pct__c,Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c FROM Core_MDF_Account_Bank_Mapping__c Where Core_MDF_Bank__r.Core_MDF_Bank_Status__c IN: bankStatusSet and Core_MDF_Account__r.id =: accountId and Core_MDF_Active_ind__c=TRUE];
            
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
        return listValues;
    }
    @AuraEnabled
    public static Map<String,String> fetchBankRegion(List<Core_MDF_Bank__c> bankList){
        
        List<String> countryCodeList = new List<String>();
        String geoStr ='';
        String region ='';
        Map<String,String> geoCodeToRegionMap = new Map<String,String>();
        try {
            if(bankList != null && bankList.size() >0){
                for(Core_MDF_Bank__c bank : bankList)
                {
                    countryCodeList.add(bank.Core_MDF_Supplier_Country_txt__c);
                }
            }
            
            geoStr ='(\'' + String.join(countryCodeList, '\', \'') + '\')';
            region = String.escapeSingleQuotes(geoStr).replaceAll('\\\\','');
            
            String objectApiName ='Core_MDF_CCP_Country_Geo_Mapping__mdt';
            String whereClause ='Core_MDF_Code_2_Digits__c  IN ' + region;
            
            List<sObject> metadataRecords = Core_MDF_GenericMetadata.getObjectRecords(objectApiName,whereClause);
            
            if(metadataRecords != null && metadataRecords.size() >0) {
                for(sObject obj : metadataRecords) {
                    geoCodeToRegionMap.put(String.valueOf(obj.get('Core_MDF_Code_2_Digits__c')),String.valueOf(obj.get('Core_MDF_Geo__c')));
                }
            }
        } catch (Exception e) { 
            Core_MDF_CCP_UtilityClass.logError(e);
            //throw new AuraHandledException(e.getMessage());
        }
        return geoCodeToRegionMap;
    }
    
    /****************************************************************************************************** 
Method Name:        checkClaimFromActivity
@return  :          Wrapper which will hold Activity Record and Create Permission Flag
@parameters:        N/A
Description:        This method is used to fetch create permission and activity Record
Added By:           Accenture - AH - 11/7/2018
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static CreateClaimWrapper checkClaimFromActivity(String objectName,Id activityId, Boolean isPartnerUser){
        try {
            CreateClaimWrapper ccw = new CreateClaimWrapper();
            PartnerFundRequest activity = new PartnerFundRequest();
            activity = getActivityFields(activityId);
            Boolean hasCreateAccess = Core_MDF_checkSObjectCRUDPermission.checkSObjectCreatePermission(objectName);
            if(activity != null && activity.Core_MDF_Program__c == Label.Core_MDF_IPA_Program_Name ) {
                Boolean isProposalBasedActivity = activity.Core_MDF_Proposal_Based_Ind__c;
                if(!isPartnerUser) {
                    ccw.checkCreate = hasCreateAccess;
                } else {
                    if(hasCreateAccess && isPartnerUser && ((FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Account_Based_User') && !isProposalBasedActivity) || (FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Proposal_Based_User') && isProposalBasedActivity))) {
                        ccw.checkCreate = true;
                    } else {
                        ccw.checkCreate = false;  
                    }       
                }
                ccw.activityObj = activity;
            } else {
                ccw.checkCreate= hasCreateAccess;
                ccw.activityObj=activity;
            }
            return ccw;
        } catch (Exception e) { 
            Core_MDF_CCP_UtilityClass.logError(e); 
            return null;
        }
    }
    
    /****************************************************************************************************** 
Class Name:        CreateClaimWrapper
@parameters:        N/A
Description:        Wrapper which will hold Activity Record and Create Permission Flag
Added By:           Accenture - AH - 11/7/2018
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    public class CreateClaimWrapper{
        @AuraEnabled   
        public PartnerFundRequest activityObj; 
        @AuraEnabled
        public Boolean checkCreate;
    }
    
    /***************************************************************************************************** 
Method Name:        duplicateClaimCheck
@return  :          List of Duplicate Claims from Database
@parameters:        claimList - This will contain all the pfc records to be inserted/updated.
Description:        Whenever a record is inserted/updated of Partner Fund Claim, this method checks whether the current record is duplicate or not
@Added By:          Accenture - AH - 11-11-2018
Modified By:        Date:       Changes: 
******************************************************************************************************/
    @AuraEnabled
    public static List<PartnerFundClaim> duplicateClaimCheck(PartnerFundClaim newClaim) {
        List<PartnerFundClaim> duplicateClaimList= new List<PartnerFundClaim>();
        try {
            List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
            claimList.add(newClaim);
            if(claimList!=null && claimList.size()>0){
                duplicateClaimList = Core_MDF_Claim_Utility.duplicateClaimCheckOnInsert(claimList);
            } } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}     
        return duplicateClaimList;
    }
    
    /****************************************************************************************************** 
Method Name:        isInternalAuditUser
@return  :          Boolean
@parameters:        String userId,String permissionName
Description:        This method is used to check the permission set over logged in user
Added By:           Accenture - AD - 11/26/2018
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static Boolean isInternalAuditUser(String custPermissionName){
        Boolean isAuditUser = false;
        try {
            Boolean hasCustomPermission = FeatureManagement.checkPermission(custPermissionName);
            if(hasCustomPermission){
                isAuditUser=true;
            }
            return isAuditUser; } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }
    
    /****************************************************************************************************** 
Class Name:        UserAndPicklistInfoWrapper
@parameters:        N/A
Description:        Wrapper which will hold logged in user and currency pickList information
Added By:           Accenture - AD - 12/12/2018
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    public class UserAndPicklistInfoWrapper{
        @AuraEnabled   
        public Map<String,String> pickListValuesMap; 
        @AuraEnabled
        public User userDtls;
    }  
    
    /****************************************************************************************************** 
Method Name:        fetchUserAndPicklistInfo
@return  :          Wrapper which will hold logged in user and currency pickList information
@parameters:        object name and field api name
Description:        This method is used to fetch Logged in user details and currency pickList values
Added By:           Accenture - AD - 12/12/2018
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static UserAndPicklistInfoWrapper fetchUserAndPicklistInfo(String objectName, String fieldApiName){
        try{
            UserAndPicklistInfoWrapper userAndPicklistWrapper = new UserAndPicklistInfoWrapper();
            userAndPicklistWrapper.pickListValuesMap= getPickListvalues(objectName, fieldApiName);
            userAndPicklistWrapper.userDtls=fetchLoggedInUserDetails();
            return userAndPicklistWrapper; }catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null;}
    } 
    
    /****************************************************************************************************** 
Method Name:        fetchLoggedInUserDetails
@return  :          User Info
@parameters:        N/A
Description:        This method is used to fetch Logged in user information
Added By:           Accenture - AH - 12/12/2018
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    
    @AuraEnabled 
    public static User fetchLoggedInUserDetails(){
        
        // query current user information  
        User oUser = [select id,Name,Email,FirstName,LastName,IsActive,IsPortalEnabled,UserType 
                      FROM User Where id =: userInfo.getUserId()];
        return oUser;        
    }
    
    /****************************************************************************************************** 
Class Name:        UserInfoWrapper
@parameters:        N/A
Description:        Wrapper which will hold logged in user information
Added By:           Accenture - VD - 14/06/2019
Modified By:        Date:      Changes: 
******************************************************************************************************/
    public class UserInfoWrapper{
        @AuraEnabled
        public User userInfo;
        @AuraEnabled
        public Boolean isUserClaimCaseReviewerOrManager;
        @AuraEnabled
        public Boolean isUserPaymentAdmin;
        @AuraEnabled
        public Boolean isRetailClaimSubmitter;
        @AuraEnabled
        public Boolean isRMFPRCClaimOperation;
        @AuraEnabled
        public Boolean isCSCClaimSubmitter;
    }
    
    /****************************************************************************************************** 
Method Name:        fetchUserDetails
@return  :          Wrapper
@parameters:        N/A
Description:        This method is used to fetch Logged in user information
Added By:           Accenture - VD - 14/06/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    
    @AuraEnabled 
    public static UserInfoWrapper fetchUserDetails(){
        try {
            String pRCRMFClaimOperationCustPerName = Core_MDF_Configuration__c.getValues('PRC_CLAIM_OPERATION_CUSTOM_PERMISSION').Core_MDF_Value__c;
            UserInfoWrapper userInfoWrap = new UserInfoWrapper(); 
            // query current user information 
            userInfoWrap.userInfo =[select id,Name,Email,FirstName,LastName,IsActive,IsPortalEnabled,UserType 
                                    FROM User Where id =: userInfo.getUserId()];
            //checking if user has custom permission to create claim on closed activity
            userInfoWrap.isUserClaimCaseReviewerOrManager = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimCaseReviewerManager'));        
            //Core_MDF_PaymentAdmin
            userInfoWrap.isUserPaymentAdmin = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PaymentAdmin'));    
            //checking is user has CSC claim submitter role
            userInfoWrap.isCSCClaimSubmitter = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Internal_CSC_Claim_Submiter')); 
            //Retail Claim Submitter
            userInfoWrap.isRetailClaimSubmitter = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RetailClaimSubmitter'));
            userInfoWrap.isRMFPRCClaimOperation = FeatureManagement.checkPermission(pRCRMFClaimOperationCustPerName);//added by vaishali to check if user is RMF PRC Internal claim submitter
            return userInfoWrap; } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }
    
    /****************************************************************************************************** 
Method Name:        fetchRecordTypeMetaData
@return  :          Map of claim and activity recordtype 
@parameters:        N/A
Description:        This method is used to fetch record type meta data and create a map
Added By:           Accenture - AD - 3/4/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/    
    @AuraEnabled
    public static Map<String,Core_MDF_ObjRecType_Budget_FieldSetMap__mdt> fetchRecordTypeMetaData(){ //TWC3117-18333
        Map<String,Core_MDF_ObjRecType_Budget_FieldSetMap__mdt> mapOfRecordTypes = new Map<String,Core_MDF_ObjRecType_Budget_FieldSetMap__mdt>();
        for(Core_MDF_ObjRecType_Budget_FieldSetMap__mdt recTypeMetaData:[Select Id,Core_MDF_Claim_Activity_Name_Swap_Ind__c,Core_MDF_POP_Mandatory_Ind__c,Core_MDF_Activity_RecordType_txt__c,Core_MDF_Allocation_RecordType_txt__c,Core_MDF_Claim_RecordType_txt__c,Core_MDF_Enable_Fund_Reservation_chk__c,
                                                                       Core_MDF_isProposalBased__c
                                                                       from Core_MDF_ObjRecType_Budget_FieldSetMap__mdt Limit 1000]){
                                                                           mapOfRecordTypes.put(recTypeMetaData.Core_MDF_Claim_RecordType_txt__c,recTypeMetaData);
                                                                       }
        return mapOfRecordTypes;
    }
    
    /****************************************************************************************************** 
Method Name:        getEscalationFields
@return  :          Escalation object
@parameters:        Escalation record ID
Description:        This method is used to fetch record based on escalation ID.
Added By:           Accenture AD - 3/4/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static Core_MDF_Escalation__c getEscalationFields(Id escalationId){    
        try{
            Core_MDF_Escalation__c escalationObj = [SELECT Id,Name,RecordType.DeveloperName,Core_MDF_Claim_Submitter_Id__c FROM Core_MDF_Escalation__c WHERE Id=:escalationId LIMIT 1];            
            if(escalationObj != null){
                return escalationObj;
            } else{return null;} }catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }
    
    /****************************************************************************************************** 
Method Name:        ckeckProgramLEForVatOptIn
@return  :          Boolean value
@parameters:        Bank'sLegal Entity, CLaim's Program
Description:        This method returns whether for Selected Banks legal Entity and Claim's 
Program Will the Vat Process would be Required Or will be Optional for the User
Added By:           Pranav - 20/01/2021
Modified By:        Date:      Changes: 
JB                  Oct-2022    Added Core_MDF_Show_Applicable_VAT_Percentage__c field
*******************************************************************************************************/
    
    @AuraEnabled
    public static Core_MDF_CCP_VAT_Config__mdt ckeckProgramLEForVatOptIn(String legalEntity, String channelProgram){
        
        // Query Vat Config metadata for Selected legal Entity and Channel Program
        // For Mandatory Vat - Core_MDF_VAT_Mandatory__c is checked and return false
        // For Optional Vat - Core_MDF_VAT_Opt_in_Option_Required__c is checked and return true Else Return NULL
        List<Core_MDF_CCP_VAT_Config__mdt> vatConfigList = new List<Core_MDF_CCP_VAT_Config__mdt>();            
        vatConfigList = [SELECT DeveloperName,MasterLabel,Core_MDF_VAT_Mandatory__c,Core_MDF_Program__c,Core_MDF_VAT_Opt_in_Option_Required__c,Core_MDF_Legal_Entity__c, Core_MDF_Show_Applicable_VAT_Percentage__c FROM Core_MDF_CCP_VAT_Config__mdt WHERE Core_MDF_Legal_Entity__c =:legalEntity AND Core_MDF_Program__c =:channelProgram AND Core_MDF_Is_Active__c =: true LIMIT 1];
        
        if(!vatConfigList.isEmpty()){
            return vatConfigList[0];               
        }else{
            return null;
        }
    }
    
    /****************************************************************************************************** 
Method Name:        getBudgetTypetoHideBank
@return  :          True/False
@parameters:        N/A
Description:        This method is used to check the config to Hide Bank
Added By:           Intel - SM - 08/04/2021
Modified By:        Date:      Changes: 
*******************************************************************************************************/    
    @AuraEnabled
    public static String getBudgetTypetoHideBank(){
        Core_MDF_Configuration__c mc = Core_MDF_Configuration__c.getValues('BUDGET_TYPE_CLAIM_BANK_HIDE');
        return mc.Core_MDF_Value__c;
    }
    
    /****************************************************************************************************** 
Method Name:        getBudgetTypetoMakePOPMandate
@return  :          True/False
@parameters:        N/A
Description:        This method is used to check the config to make POP Mandatory for OPAL based on Budget Type
Added By:           Intel - SM - 08/04/2021
Modified By:        Date:      Changes: 
*******************************************************************************************************/    
    /*
@AuraEnabled
public static String getBudgetTypetoMakePOPMandate(){
Core_MDF_Configuration__c mc = Core_MDF_Configuration__c.getValues('BUDGET_TYPE_CLAIM_POP_MANDATE'); 
return mc.Core_MDF_Value__c;
}*/
    
    
    /*************************************************************************************************************
Method Name : checkPopDocRequired
@return     : True/False
@parameters : Recordtype , Budget type
Description : This method checks if pop is required based on Record and budget type
custom label: when we make 100% POP, please update this label "Core_MDF_ActivityBudgetTypesForAllocationCheck" for all POP type check
**************************************************************************************************************/
    @AuraEnabled
    public static Boolean isCheckPopDocRequired(String program,String budgetType){ 
        boolean retvalue = false;
        for(Core_MDF_POP_Document_Types_Revamp__mdt claimPOPMandatoryInfo: [select id, Core_MDF_Program_nm__c, Core_MDF_Budget_Type_txt__c, Core_MDF_Req_Doc_Types_ind__c,Core_MDF_RecordType_DeveloperName_txt__c, Core_MDF_Active_ind__c from Core_MDF_POP_Document_Types_Revamp__mdt 
                                                                            where Core_MDF_Program_nm__c=:program  
                                                                            And Core_MDF_Active_ind__c=true And Core_MDF_Req_Doc_Types_ind__c=true ]){
                                                                                String key = claimPOPMandatoryInfo.Core_MDF_Program_nm__c + (claimPOPMandatoryInfo.Core_MDF_Budget_Type_txt__c==null?'':claimPOPMandatoryInfo.Core_MDF_Budget_Type_txt__c) ;
                                                                                if(key.equals(program+budgetType)){
                                                                                    retvalue = true;
                                                                                }else if(key.equals(program) && claimPOPMandatoryInfo.Core_MDF_Budget_Type_txt__c == null){
                                                                                    retvalue = true;
                                                                                }
                                                                            }
        return retvalue;
    }
    
    /*************************************************************************************************************
Method Name : checkClaimStatusForPICProcess
@return     : True/False
@parameters : claimId
Description : This method is to check on whether the claim status is resubmission required or not
custom label: Core_MDF_Claim_Status_Resubmission_Required - Resubmission required claim status
@Added By:        Accenture - VB - 1-28-2022
Modified By:        Date:       Changes: 
**************************************************************************************************************/
    @AuraEnabled
    public static Boolean checkClaimStatusForPICProcess(Id claimId){
        Boolean isClaimAvailableForPIC = false;
        List<String> claimStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SubmitForPIC_ClaimStatusOnEdit').split(';');
        PartnerFundClaim pfc = new PartnerFundClaim();
        try {
            pfc = [select Id, Core_MDF_Status__c, Core_MDF_Eligible_for_PIC__c from PartnerFundClaim where Id =: claimId];
            if(pfc.Core_MDF_Eligible_for_PIC__c == true && claimStatus.contains(pfc.Core_MDF_Status__c)) {
                isClaimAvailableForPIC = true;
            } else {
                isClaimAvailableForPIC = false;
            }
            
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        return isClaimAvailableForPIC;
    }
    /****************************************************************************************************** 
Method Name:        showModalForDocSubmissionConfirmation
@return  :          boolean
Description:        This method is used to decide whether the confirm modal popup is disabled/enabled
Added By:           Aditya - 10/12/2021
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public  static Boolean showModalForDocSubmissionConfirmation() {
        Core_MDF_Configuration__c config = Core_MDF_Configuration__c.getValues('Core_MDF_DocUploadConfirm');
        
        if(config.Core_MDF_Value__c == 'true') {
            
            
            return true;
        } else {
            return false;
        }
    }
    
    /****************************************************************************************************** 
Method Name:        checkRetailerAccount
@return  :          Boolean Flag [If Claim UltimateAcctId is having Retail Program Access 3rd Party POP meassage will not display]
@parameters:        PartnerFundClaim pfc
Description:        This method is used to identify weather Claim Ultimate Account is ir part of Retail program or not
Added By:           Areefa          02-Feb-2022    
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static boolean checkRetailerAccount(PartnerFundClaim pfc){
        boolean isNotRetailerAcct = false;
        List<Core_MDF_Partner_Group_Mapping__c> pGM = new List<Core_MDF_Partner_Group_Mapping__c>();
        pGM =[select id,Core_MDF_Account__c, Core_MDF_Account__r.Name, Core_MDF_Channel_Program__r.Name from Core_MDF_Partner_Group_Mapping__c where  Core_MDF_Account__c =: pfc.Core_MDF_Ultimate_Account_ID__c  and Core_MDF_Type_of_Access__c='External' and Core_MDF_Channel_Program__r.Name='Retail Marketing Funds' and Core_MDF_Inactive_Ind__c = false];  
        if (pGM.isEmpty()){
            isNotRetailerAcct = true;
        }
        return isNotRetailerAcct;
    }
    
    /****************************************************************************************************** 
Method Name:        fetchLogInfoByPassCheckValue
@return  :          boolean
Description:        This method is used to fetch the Log Info by-pass value to add a value in the Core_MDF_Log_Info_txt__c field or not.
Added By:           Accenture - JB      07/04/2022
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static Boolean fetchLogInfoByPassCheckValue(){
        return Core_MDF_Utility.byPassFeature('Bypass_LogInfoTextFieldMapping');
    }
    public class ClaimWrap{
        @AuraEnabled public String errorDetail {get;set;}   // holds the exception message to be sent to component
        @AuraEnabled public PartnerFundClaim claimDetail {get;set;}  // holds claim details to be sent to component
    }
    public class AmountFieldsWrapper
    {
        @auraenabled
        public string totalAmountLocal{get;set;}
        @auraenabled
        public string costNotReimbursable{get;set;}
        @AuraEnabled
        public string taxesLocal { get; set; }
    }
    public class ActivityDetailsWrapper
    {
        @AuraEnabled
        public PartnerFundRequest activityDetails{get;set;}
        @AuraEnabled
        public string localizedCountryValues{get;set;}
        @AuraEnabled
        public string nonLocalizedCountryValues { get; set; }
        @AuraEnabled
        public Boolean isOutcomeBasedActivity { get; set; } 
    }    
    
    /****************************************************************************************************** 
Method Name:        getProposedData
@return  :          ProposedDataWrapper
@parameters:        String imageData (base64 doc content),string docId (content document id) 
Description:        This method is used to make callouts and get ProposedDataWrapper
Added By:           Aditya - 01-07-2024
Modified By:        Date:       Changes:
*******************************************************************************************************/ 
    public static ProposedDataWrapper getProposedData(String imageData,String docId)
    {
        ProposedDataWrapper dataWrap = new ProposedDataWrapper();
        try{       
            PartnerFundClaim record = new PartnerFundClaim();
            if(String.isNotBlank(imageData)){ 
                //Azure callout to get ocr request Id 
                String outputWithOperationLocId = Core_MDF_FormRecognizerIntegration.readDocumentContents(imageData);
                //Azure callout to get data as string
                if(outputWithOperationLocId != null){
                    String prebuildReadText = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimEzy_PrebuildRead');//prebuilt-read
                    String rawData = Core_MDF_FormRecognizerIntegration.getDocumentAsString(prebuildReadText, outputWithOperationLocId);
                    
                    //ChatGPT callout to get JSON string
                    if(rawData != null){
                        Core_MDF_GenAIProcessing.contentWrap contentWrapper = Core_MDF_GenAIProcessing.getQueryData(rawData);
                        
                        String output = (contentWrapper != null  && !String.isBlank(contentWrapper.contentFromChatGPT)) ? contentWrapper.contentFromChatGPT : '';
                        //Create claim instance details from GPT response
                        record = createAIClaimInstance(output);
                        dataWrap.proposedClaimData = record;
                        dataWrap.docId = docId;
                        // create AI log record with proposed data and content document Id
                        saveProposedData(record,contentWrapper.rawContent,output,docId);
                    }else{
                        Core_MDF_CCP_UtilityClass.logErrorAsNormal('Retured value is blank in Azure OCR2 Endpoint', 'Core_MDF_AI_Tracking__c');
                    }
                }else{
                    Core_MDF_CCP_UtilityClass.logErrorAsNormal('Operation Location Id is blank in Azure OCR1 Endpoint', 'Core_MDF_AI_Tracking__c');
                }
            }
        }
        catch(exception ex){
            throw ex;
        }
        
        if(dataWrap.proposedClaimData != null){
            return dataWrap;
        }
        else{
            throw new StringException('');
        } 
    }
    
    /****************************************************************************************************** 
Method Name:        getProposedData
@return  :          List<Map<String, String>>
@parameters:        String invoiceString
Description:        Used to parse the result to populate on claim fields
Added By:           Aditya - 01-07-2024
Modified By:        Date:       Changes:
*******************************************************************************************************/ 
    public static List<Map<String, String>> parseInvoiceString(String invoiceString) {
        
        List<Map<String, String>> detailsList = new List<Map<String, String>>();
        List<String> detailsArray = invoiceString.split('&');
        for(String detail : detailsArray) {
            List<String> detailParts = detail.split(':');
            if (detailParts.size() >= 2) {
            Map<String, String> detailMap = new Map<String, String>{detailParts[0].trim() => detailParts[1].trim()};
                detailsList.add(detailMap);
            }
        }
        return detailsList;
    }
    
    /****************************************************************************************************** 
Method Name:        getCurrencyCode
@return  :          String
@parameters:        String inputCurrency
Description:        Used to validate the currency is match with the picklist values
Added By:           Aditya - 01-07-2024
Modified By:        Date:       Changes:
*******************************************************************************************************/ 
    public static String getCurrencyCode(String inputCurrency){
        String code;
        // Specify the object and field API name
        String objectApiName = 'PartnerFundClaim';
        String fieldApiName = 'Core_MDF_Currency__c';
        
        // Describe the object and field
        Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe();
        
        // Check if the field is a picklist
        if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST) {
            // Get the picklist values
            List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
            
            // Check if the picklist values contain the string
            for (Schema.PicklistEntry picklistEntry : picklistValues) {
                if (picklistEntry.getValue().contains(inputCurrency)) {
                    code=picklistEntry.getValue();
                    break;
                }
            }
        }
        return code;
    }
    
    
    /****************************************************************************************************** 
Method Name:        createAIClaimInstance
@return  :          partnerfundclaim
@parameters:        string gptJson 
Description:        This method is used to create claim instance to display values on UI
Added By:           Aditya - 01-07-2024
Modified By:        Date:       Changes:
*******************************************************************************************************/ 
    public static partnerfundclaim createAIClaimInstance(string gptJson){
        PartnerFundClaim record = new PartnerFundClaim();
        List<Map<String, String>> outputMap = new List<Map<String, String>>();
        sObject sObj = Schema.getGlobalDescribe().get('PartnerFundClaim').newSObject();
        outputMap = parseInvoiceString(gptJson);
        boolean noValuePopulated = true;
        String notProvidedText = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Not_Provided');//Not Provided
        for(Map<String, String> o : outputMap) {
            for(String key : o.keySet()) {
                String value = o.get(key);
                if(value != null && value != notProvidedText){
                    noValuePopulated = false;
                    if(key.toLowerCase().contains('number')){
                        sObj.put('Core_MDF_Invoice_Number__c', value);
                    }
                    else if(key.toLowerCase().contains('amount')){
                        sObj.put('Core_MDF_Total_Invoice_Amount_Local__c', Decimal.valueOf(value.replaceAll('[^0-9.]', '')));
                    }
                    else if(key.toLowerCase().contains('tax')){
                        sObj.put('Core_MDF_Taxes_Local__c', Decimal.valueOf(value.replaceAll('[^0-9.]', '')));
                    }
                    else if(key.toLowerCase().contains('date')){
                        // Convert the date string to 'YYYY-MM-DD' format
                        List<String> dateParts = value.split('/');
                        String formattedDateString = dateParts[2] + '-' + dateParts[1] + '-' + dateParts[0];
                        Date parsedDate = Date.valueOf(formattedDateString);
                        sObj.put('Core_MDF_Invoice_Date__c', parsedDate);
                    }
                    else if(key.toLowerCase().contains('currency')){
                        sObj.put('Core_MDF_Currency__c', getCurrencyCode(value));
                    }
                }
                
            }
        }
        if(noValuePopulated){
            string error = Core_MDF_CCP_ConstantClass.FIELD_CUSTOM_VALIDATION_EXCEPTION + System.Label.Core_MDF_Claim_ezy_NovaluePopulatedError + ':';
            throw new StringException(error);
        }        
        record = (PartnerFundClaim)sObj;
        return record;
    }
    
    /****************************************************************************************************** 
Method Name:        saveProposedData
@return  :          --
@parameters:        PartnerFundClaim proposedData,string ocrData,string aiContentData,String contentDocId
Description:        This method is used to create AI Tracking record
Added By:           Aditya - 01-07-2024
Modified By:        Date:       Changes:
*******************************************************************************************************/
    public static void saveProposedData(PartnerFundClaim proposedData,string ocrData,string aiContentData,String contentDocId){
        Core_MDF_AI_Tracking__c aiTrack = new Core_MDF_AI_Tracking__c();
        aiTrack.Core_MDF_Proposed_Amount_Amt__c=proposedData.Core_MDF_Total_Invoice_Amount_Local__c; 
        aiTrack.Core_MDF_Proposed_Currency_Cd__c=proposedData.Core_MDF_Currency__c;
        aiTrack.Core_MDF_Proposed_Invoice_Date_Dt__c=proposedData.Core_MDF_Invoice_Date__c;
        aiTrack.Core_MDF_Proposed_Invoice_Number_Nbr__c=proposedData.Core_MDF_Invoice_Number__c;
        aiTrack.Core_MDF_Proposed_Tax_Amt__c=proposedData.Core_MDF_Taxes_Local__c;
        aiTrack.Core_MDF_Extracted_Content_Txt__c = ocrData;
        aiTrack.Core_MDF_Result_Txt__c = aiContentData;
        aiTrack.Core_MDF_Content_Document_Id__c = contentDocId;
        insert aiTrack;
    }
    
    /****************************************************************************************************** 
Method Name:        
@return  :          --
@parameters:        PartnerFundClaim actualData,String contentDocId
Description:        This method is used to update AI Tracking record with actual claim values entered by user
Added By:           Aditya - 01-07-2024
Modified By:        Date:       Changes:
*******************************************************************************************************/
    public static void updateActualValues( PartnerFundClaim actualData,String contentDocId){        
        List<Core_MDF_AI_Tracking__c> aiTrackingList = [SELECT Id FROM Core_MDF_AI_Tracking__c WHERE Core_MDF_Content_Document_Id__c =: contentDocId LIMIT 1];
        if(aiTrackingList != null && aiTrackingList.size() > 0){
            aiTrackingList[0].Core_MDF_Actual_Amount_Amt__c = actualData.Core_MDF_Total_Invoice_Amount_Local__c;
            aiTrackingList[0].Core_MDF_Actual_Currency_Cd__c = actualData.Core_MDF_Currency__c;
            aiTrackingList[0].Core_MDF_Actual_Invoice_Date_Dt__c = actualData.Core_MDF_Invoice_Date__c;
            aiTrackingList[0].Core_MDF_Actual_Invoice_Number_Nbr__c = actualData.Core_MDF_Invoice_Number__c;
            aiTrackingList[0].Core_MDF_Actual_Tax_Amt__c = actualData.Core_MDF_Taxes_Local__c;
            aiTrackingList[0].Core_MDF_Claim_Id__c = actualData.Id;
            
            //If the tax not applicable for the claim then remove from the Proposed value
            List<String> opalBudgetList = System.Label.Core_MDF_ClaimEzy_Taxes_Not_Applicable.split(';');
            if(opalBudgetList.contains(actualData.Core_MDF_Budget_Type_Options_Nm__c)){
                aiTrackingList[0].Core_MDF_Proposed_Tax_Amt__c = actualData.Core_MDF_Taxes_Local__c;
            }      
            update aiTrackingList; 
        }
    }
    
    
    /****************************************************************************************************** 
Method Name:        getDocumentData
@return  :          --
@parameters:        String docId
Description:        This method is called from claim create form and returns Gen AI proposed values
Added By:           Aditya - 01-07-2024
Modified By:        Date:       Changes:
*******************************************************************************************************/
    @AuraEnabled
    public static ProposedDataWrapper getDocumentData(String docId){     
        ProposedDataWrapper dataWrap = new ProposedDataWrapper();
        try{
                // Query metadata first - avoids allocating 40+ MB into the heap
        	ContentVersion fileInfo = [SELECT Id, ContentSize FROM ContentVersion WHERE ContentDocumentId = :docId LIMIT 1];

        	if (fileInfo.ContentSize > Long.valueOf(System.Label.Core_MDF_ClaimEzy_MaxFileSize)) {
    			dataWrap.isError = true;
    			dataWrap.errorMsg = Core_MDF_CCP_ConstantClass.FIELD_CUSTOM_VALIDATION_EXCEPTION + System.Label.Core_MDF_Claim_ezy_MaxStringLimitError + ':';
    			return dataWrap;
			}
            //Get the versiondata based on ContentDocumentId
            ContentVersion conVer = [SELECT Id,versiondata FROM ContentVersion WHERE ContentDocumentId =: docId];
            //Convert to base64
            String base64Data = EncodingUtil.base64Encode(conVer.VersionData);
            //Callout to push the uploaded file in Azure OCR
            dataWrap = getProposedData(base64Data, docId);
            
        }catch(Exception ex){
            String error = ex.getMessage();
            if( ex.getMessage().contains(Core_MDF_CCP_ConstantClass.STRING_LENGTH_EXCEEDS_MAXIMUM)){ //String length exceeds maximum:
                // move to label and localize
                String fieldCustomError = Core_MDF_CCP_ConstantClass.FIELD_CUSTOM_VALIDATION_EXCEPTION;
                error = Core_MDF_CCP_ConstantClass.FIELD_CUSTOM_VALIDATION_EXCEPTION + System.Label.Core_MDF_Claim_ezy_MaxStringLimitError + ':';
            }
            Core_MDF_CCP_UtilityClass.logError(ex);
            dataWrap.isError = true;
            dataWrap.errorMsg = error;
        }
        return dataWrap;
    }
    
    /****************************************************************************************************** 
Method Name:        isClaimEzyEnabled
@return  :          Boolean
@parameters:        
Description:        This method is used to enable or disable Claim Ezy process.
Added By:           Aditya - 01-07-2024
Modified By:        Date:       Changes:
*******************************************************************************************************/
    @AuraEnabled
    public static Boolean isClaimEzyEnabled(){
        Boolean claimEzyCheck = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_ClaimEzyEnabled');
        return claimEzyCheck;
    }
    
    /****************************************************************************************************** 
Method Name:        deleteDocuments
@return  :          void
@parameters:        String (contentDocumentId)
Description:        This method is used to delete uploaded content document incase of any errors
Added By:           Aditya - 01-07-2024
Modified By:        Date:       Changes:
*******************************************************************************************************/ 
    @AuraEnabled   
    public static void deleteDocuments(String contentDocumentId) {
        try{
            ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId LIMIT 1];
            if (contentDoc != null) {
                delete contentDoc;
            }
        }catch (exception ex){                
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
    
    public class ProposedDataWrapper{
        @AuraEnabled Public PartnerFundClaim proposedClaimData;  
        @AuraEnabled public string docId;
        @AuraEnabled public Boolean isError;
        @AuraEnabled public String errorMsg;
    }
    
    /****************************************************************************************************** 
Method Name:        setDefaultSurePayValue
@return  :          Boolean
@parameters:        
Description:        This method is used to return the value for Processing Preference on Claim Create/Clone
Added By:           Roshan - 19-02-2025
Modified By:        Date:       Changes:
*******************************************************************************************************/
    @AuraEnabled
    public static PayTypeWrapper getDefaultPayTypePicklist(Date claimCreatedDate, String program, String budgetType) {
        try {
            if (program == Label.Core_MDF_Co_GTM_program_name || program == Label.Core_MDF_Retail_Channel_Program_Name || ((program == Label.Core_MDF_CCF_Program_Name || program == Label.Core_MDF_Non_Localized_DCF_Program_Name) && (budgetType == 'MDF' || budgetType == 'MDF+'))) {
                return new PayTypeWrapper(false, true); // Fast Pay
            }
            // Getting all weekly periods for the fiscal quarter
            List<Period> currentFiscalQuarterDetails = Core_MDF_Calendar_Utility.getFiscalQuarterWeekPeriods(claimCreatedDate);
            
            // Getting all weeks allowed for Fast Pay
            List<Integer> allowedWeeksForFastPay = Core_MDF_CustomLabelConfig.getIntegerList('Core_MDF_ClaimWeeksForFastPay');  // 1, 2, 3, 4
            
            // If current date falls inside allowedWeeksForFastPay
            for (Period week : currentFiscalQuarterDetails) {
                Integer adjustedWeekNumber = Core_MDF_Calendar_Utility.getWeekNumberOfQuarter(week.Number);
                if (allowedWeeksForFastPay.contains(adjustedWeekNumber)) {
                    if (claimCreatedDate >= week.StartDate && claimCreatedDate <= week.EndDate) {
                        return new PayTypeWrapper(false, true); // Fast Pay for M1
                    }
                }
            }
            
            return new PayTypeWrapper(true, false); // Sure Pay for M2/M3
        }
        catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.triggerErrLoggingPE(ex,'Critical',Label.Core_MDF_Program_Name,'PartnerFundClaim',null,null);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public class PayTypeWrapper {
        @AuraEnabled public Boolean surePay;
        @AuraEnabled public Boolean fastPay;
        
        public PayTypeWrapper(Boolean surePay, Boolean fastPay) {
            this.surePay = surePay;
            this.fastPay = fastPay;
        }
    } 
    
    /****************************************************************************************************** 
Method Name:        calculateAmountFields
@return  :          Boolean
@parameters:        
Description:        This method is used to return Calculated Amount field values
Added By:           JB - 06/09/2025
Test Class:		Core_MDF_PFC_IPAClaim_Test
Modified By:        Date:       Changes:
*******************************************************************************************************/
     @AuraEnabled(cacheable=true)
    public static PartnerFundClaim calculateAmountFields(PartnerFundClaim claim, String amountFields) {
        
        //To support for Brazil and German languages
        if(String.isNotBlank(amountFields)){
            AmountFieldsWrapper wrapper = (AmountFieldsWrapper)JSON.deserialize(amountFields,AmountFieldsWrapper.class);  
            if(wrapper.totalAmountLocal != Null)
                claim.Core_MDF_Total_Invoice_Amount_Local__c = Decimal.valueOf(wrapper.totalAmountLocal);
            
            if(wrapper.costNotReimbursable != Null)
                claim.Core_MDF_OtherCostsnotReimbursable_Local__c = Decimal.valueOf(wrapper.costNotReimbursable);
            
            if(wrapper.taxesLocal != Null)
                claim.Core_MDF_Taxes_Local__c = Decimal.valueOf(wrapper.taxesLocal);
        }
        
        List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
        claimList.add(claim);
        
        Core_MDF_Claim_Utility.calculateClaimFieldsForInsert(claimList);
        return claimList[0];
    }   
    
    
    /****************************************************************************************************** 
Method Name:        getCampaignPurposeDetails
@return  :          Boolean
@parameters:        
Description:        This method is used to return Campaign Purpose Details
Added By:           JB - 06/09/2025
Test Class:		Core_MDF_PFC_IPAClaim_Test
Modified By:        Date:       Changes:
*******************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static CampaignPurposeWrappper getCampaignPurposeDetails(String activityId, String claimId) {
        try {
            //To get the table header based on loggedin user language
            //If Claim Id is present get the attribute details from Claim Attribute
            //If Activity Id is present get the attribute details from Activity Attribute
            //Get Campaign Purpose details from Campaign Purpose active record
            //List<String> objectList = new List<String>{'PartnerFundClaim','Core_MDF_Campaign_Outcomes__c'};
            //List<String> fieldList = new List<String>{'Core_MDF_Quantity_to_Date_Nbr__c','Core_MDF_Outcomes_nm__c','Core_MDF_Initial_Baseline_Quantity_nbr__c','Core_MDF_Goal_Quantity_nbr__c','Core_MDF_Outcome_Criteria_txt__c'};
            //List<Core_MDF_Tactics_Controller.FieldInfo> fieldInfoList = Core_MDF_Tactics_Controller.getLocalizedFieldMetadata(objectList, fieldList);
			List<String> programList = Label.Core_MDF_Program_Enabled_Tactics.split(',');
            CampaignPurposeWrappper campPurposeWrapper = new CampaignPurposeWrappper();
            campPurposeWrapper.metricsEditable = false;
            Id campId;
            if(String.isNotBlank(claimId)){
                PartnerFundClaim claim = [SELECT Id, RequestId, Request.Core_MDF_ActivityCategory__c, Core_MDF_Program__c, Request.CampaignId, Core_MDF_Quantity_to_Date_Nbr__c, Core_MDF_Status__c FROM PartnerFundClaim WHERE Id =: claimId LIMIT 1];
                campPurposeWrapper.quantityToDate = String.valueOf(claim.Core_MDF_Quantity_to_Date_Nbr__c);
                campPurposeWrapper.showTacticMetric = (programList.contains(claim.Core_MDF_Program__c) && claim.Request.Core_MDF_ActivityCategory__c == Label.Core_MDF_Outcome_Based_CatType) ? true : false;
                List<String> allowedStatusesToEditTacticMetric = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AllowedStatsTacticMetric').split(','); //new List<String>{'Draft','Pending Clarification','Resubmission Required','Pending Account Manager Clarification', 'PIC Pending'};
                if(campPurposeWrapper.showTacticMetric && allowedStatusesToEditTacticMetric.contains(claim.Core_MDF_Status__c)){
                    campPurposeWrapper.metricsEditable = true;
                }
                campId = claim.Request.CampaignId;
            }else if(String.isNotBlank(activityId)){
                PartnerFundRequest activity = [SELECT Id, Core_MDF_ActivityCategory__c, Core_MDF_Program__c, CampaignId FROM PartnerFundRequest WHERE Id =: activityId LIMIT 1];
                campPurposeWrapper.showTacticMetric = (programList.contains(activity.Core_MDF_Program__c) && activity.Core_MDF_ActivityCategory__c == Label.Core_MDF_Outcome_Based_CatType) ? true : false;
                campPurposeWrapper.metricsEditable = true;
                campId = activity.CampaignId;
            }
            
            if(String.isNotBlank(campId) && campPurposeWrapper.showTacticMetric){
                Core_MDF_Campaign_Outcomes__c campOutcome = [SELECT Id, Core_MDF_Campaign_Id__c, toLabel(Core_MDF_Outcomes_nm__c), Core_MDF_Initial_Baseline_Quantity_nbr__c, Core_MDF_Goal_Quantity_nbr__c, Core_MDF_Outcome_Criteria_txt__c, Core_MDF_Active_Ind__c 
                                                             FROM Core_MDF_Campaign_Outcomes__c 
                                                             WHERE Core_MDF_Campaign_Id__c =: campId AND Core_MDF_Active_Ind__c = true LIMIT 1];
                if(campOutcome != null){
                    campPurposeWrapper.outcomeMetric = campOutcome.Core_MDF_Outcomes_nm__c;
                    campPurposeWrapper.baselineQuantity = String.valueOf(campOutcome.Core_MDF_Initial_Baseline_Quantity_nbr__c);
                    campPurposeWrapper.goalQuantity = String.valueOf(campOutcome.Core_MDF_Goal_Quantity_nbr__c);
                    campPurposeWrapper.outcomeCriteria = campOutcome.Core_MDF_Outcome_Criteria_txt__c;
                }
            }
            
            else if (String.isBlank(campId) && String.isNotBlank(activityId) && campPurposeWrapper.showTacticMetric){
                Core_MDF_Activity_Outcome__c actOutcome = [SELECT Id, Core_MDF_Activity_Id__c, toLabel(Core_MDF_Outcome_Metric_nm__c), Core_MDF_Baseline_Value_nbr__c, Core_MDF_Goal_Value_nbr__c, Core_MDF_Baseline_Period_nm__c, Core_MDF_Active_Ind__c,Core_MDF_Result_Value_nbr__c 
                                                           FROM Core_MDF_Activity_Outcome__c 
                                                           WHERE Core_MDF_Activity_Id__c =: activityId AND Core_MDF_Active_Ind__c = true LIMIT 1];
                if(actOutcome != null){
                    campPurposeWrapper.outcomeMetric = actOutcome.Core_MDF_Outcome_Metric_nm__c;
                    campPurposeWrapper.baselineQuantity = String.valueOf(actOutcome.Core_MDF_Baseline_Value_nbr__c);
                    campPurposeWrapper.goalQuantity = String.valueOf(actOutcome.Core_MDF_Goal_Value_nbr__c);
                    campPurposeWrapper.baselinePeriod = actOutcome.Core_MDF_Baseline_Period_nm__c;
                    campPurposeWrapper.resultValue = String.valueOf(actOutcome.Core_MDF_Result_Value_nbr__c);
                }
            }           
            List<String> objectList;
            List<String> fieldList;
            objectList = String.isNotBlank(campId) ? new List<String>{'PartnerFundClaim','Core_MDF_Campaign_Outcomes__c'} : new List<String>{'PartnerFundClaim','Core_MDF_Activity_Outcome__c'};
                fieldList = String.isNotBlank(campId) ? new List<String>{'Core_MDF_Quantity_to_Date_Nbr__c','Core_MDF_Outcomes_nm__c','Core_MDF_Initial_Baseline_Quantity_nbr__c','Core_MDF_Goal_Quantity_nbr__c','Core_MDF_Outcome_Criteria_txt__c'} : new List<String>{'Core_MDF_Quantity_to_Date_Nbr__c','Core_MDF_Activity_Id__c','Core_MDF_Outcome_Metric_nm__c','Core_MDF_Activity_Id__c','Core_MDF_Baseline_Value_nbr__c','Core_MDF_Goal_Value_nbr__c','Core_MDF_Goal_Value_nbr__c','Core_MDF_Result_Value_nbr__c','Core_MDF_Baseline_Period_nm__c'};
                    List<Core_MDF_Tactics_Controller.FieldInfo> fieldInfoList = Core_MDF_Tactics_Controller.getLocalizedFieldMetadata(objectList, fieldList);
            for(Core_MDF_Tactics_Controller.FieldInfo fieldInfo : fieldInfoList){
                switch on fieldInfo.fieldName {
                    when 'Core_MDF_Outcomes_nm__c', 'Core_MDF_Outcome_Metric_nm__c'{
                        campPurposeWrapper.outcomeMetricLabel = fieldInfo.label;
                    }
                    when 'Core_MDF_Initial_Baseline_Quantity_nbr__c', 'Core_MDF_Baseline_Value_nbr__c' {
                        campPurposeWrapper.baselineQuantityLabel = fieldInfo.label;
                        campPurposeWrapper.baselineQuantityHelpText = fieldInfo.helpText;
                    }
                    when 'Core_MDF_Goal_Quantity_nbr__c', 'Core_MDF_Goal_Value_nbr__c' {
                        campPurposeWrapper.goalQuantityLabel = fieldInfo.label;
                        campPurposeWrapper.goalQuantityHelpText = fieldInfo.helpText;
                    }
                    when 'Core_MDF_Outcome_Criteria_txt__c' {
                        campPurposeWrapper.outcomeCriteriaLabel = fieldInfo.label;
                        campPurposeWrapper.outcomeCriteriaHelpText = fieldInfo.helpText;
                    }
                    when 'Core_MDF_Quantity_to_Date_Nbr__c' {
                        campPurposeWrapper.quantityToDateLabel = fieldInfo.label;
                        campPurposeWrapper.quantityToDateHelpText = fieldInfo.helpText;
                    }
                    when 'Core_MDF_Baseline_Period_nm__c'{
                        campPurposeWrapper.baselinePeriodLabel = fieldInfo.label;
                        campPurposeWrapper.baselinePeriodHelpText = fieldInfo.helpText;
                    }
                    when 'Core_MDF_Result_Value_nbr__c'{
                        campPurposeWrapper.resultValueLabel = fieldInfo.label;
                        campPurposeWrapper.resultValueHelpText = fieldInfo.helpText;
                    }
                }
            }
            
            return campPurposeWrapper;
        }
        catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        
        return null;
    }
    
    @AuraEnabled
    public static List<String> getClaimFieldsForAIPICProcess() {
        List<String> claimFields = new List<String>();
        try {
            for(Schema.FieldSetMember f : Schema.SObjectType.PartnerFundClaim.FieldSets.Core_MDF_Claim_Fields_For_AI_PIC.getFields()) {
                claimFields.add(f.getFieldPath()); 
            }
        }
        catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return claimFields;
    }
    
    public class CampaignPurposeWrappper {
        @AuraEnabled public String outcomeMetric {get; set;}
        @AuraEnabled public String baselineQuantity {get; set;}
        @AuraEnabled public String goalQuantity {get; set;}
        @AuraEnabled public String quantityToDate {get; set;}
        @AuraEnabled public String outcomeCriteria {get; set;}
        @AuraEnabled public Boolean showTacticMetric {get; set;}
        @AuraEnabled public Boolean metricsEditable {get; set;}
        @AuraEnabled public String outcomeMetricLabel {get; set;}
        @AuraEnabled public String baselineQuantityLabel {get; set;}
        @AuraEnabled public String goalQuantityLabel {get; set;}
        @AuraEnabled public String quantityToDateLabel {get; set;}
        @AuraEnabled public String outcomeCriteriaLabel {get; set;}
        //@AuraEnabled public String outcomeMetricLabel {get; set;}
        @AuraEnabled public String baselineQuantityHelpText {get; set;}
        @AuraEnabled public String goalQuantityHelpText {get; set;}
        @AuraEnabled public String quantityToDateHelpText {get; set;}
        @AuraEnabled public String outcomeCriteriaHelpText {get; set;}
        @AuraEnabled public String baselinePeriod {get; set;}
        @AuraEnabled public String baselinePeriodLabel {get; set;}
        @AuraEnabled public String baselinePeriodHelpText {get; set;}
        @AuraEnabled public String resultValue {get; set;}
        @AuraEnabled public String resultValueLabel {get; set;}
        @AuraEnabled public String resultValueHelpText {get; set;}
    }
    /****************************************************************************************************** 
Method Name:        getAccountNodes
@return  :          AccountNodeWrapper list
Description:        This method is used to fetch account nodes based on the parent activity ID.
Added By:           Accenture - TK - 22/12/2025
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<AccountNodeWrapper> getAccountNodes(Id superActivityId) {
        String cancelledStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Cancelled_Status');
        List<PartnerFundRequest> pfrList = [select id, ChannelPartnerId, ChannelPartner.name,Title,ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c,ChannelPartner.Core_MDF_Payment_Type_nm__c from PartnerFundRequest where Core_MDF_Parent_Activity_Id__c =:superActivityId AND Core_MDF_Fund_Request_Status__c != :cancelledStatus];
        Set<Id> accountIds = new Set<Id>();
        for (PartnerFundRequest pfr : pfrList) {
            accountIds.add(pfr.ChannelPartnerId);
        }
        Map<Id, Decimal> accountToPercentageMap = new Map<Id, Decimal>();
        for (Core_MDF_Outcome_Account_Mapping__c rec : [SELECT Id, Core_MDF_AccountId__c, Core_MDF_AccountId__r.Name, Core_MDF_Percentage_pct__c FROM Core_MDF_Outcome_Account_Mapping__c WHERE Core_MDF_Outcome_Based_CampaignId__c = :superActivityId and Core_MDF_Active_Ind__c = TRUE]) {
            accountToPercentageMap.put(rec.Core_MDF_AccountId__c, rec.Core_MDF_Percentage_pct__c);
        }
        List<AccountNodeWrapper> result = new List<AccountNodeWrapper>();
        for (PartnerFundRequest pfr : pfrList) {
            AccountNodeWrapper accWrap = new AccountNodeWrapper();
            accWrap.activityId = pfr.Id;
            accWrap.accountId = pfr.ChannelPartnerId;
            accWrap.accountName = pfr.ChannelPartner.Name;
            accWrap.activityTitle = pfr.Title;
            accWrap.percentage = accountToPercentageMap.get(pfr.ChannelPartnerId);
            accWrap.paymentType = (pfr.ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c != null && pfr.ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c != '') ? pfr.ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c : pfr.ChannelPartner.Core_MDF_Payment_Type_nm__c;
            result.add(accWrap);
        }
        return result;
    }
    public class AccountNodeWrapper {
        @AuraEnabled public Id accountId;
        @AuraEnabled public String accountName;
        @AuraEnabled public Decimal percentage;
        @AuraEnabled public Id activityId;
        @AuraEnabled public String activityTitle;
        @AuraEnabled public String paymentType;
    }
    
    /****************************************************************************************************** 
Method Name:        fetchBankRecordsForAccounts
@return  :          AccountNodeWrapper List
Description:        This method is used to fetch eligible banks for each account node
Added By:           Accenture - TK - 22/12/2025
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<Id, List<BankWrapper>> fetchBankRecordsForAccounts(List<Id> accountIds) {
        Map<Id, List<BankWrapper>> accountIdToBanksMap = new Map<Id, List<BankWrapper>>();
        if (accountIds == null || accountIds.isEmpty()) return accountIdToBanksMap;
        try {
            Set<String> bankStatusSet = new Set<String>();
            String bankStatusList = System.Label.Core_MDF_Claim_Bank_StatusList;
            if (!String.isBlank(bankStatusList)) {
                for (String bankStatus : bankStatusList.split(';')) bankStatusSet.add(bankStatus);
            }
            List<Core_MDF_Account_Bank_Mapping__c> bankRecords = [SELECT Core_MDF_Bank__c, Core_MDF_Bank__r.Name, Core_MDF_Bank__r.Core_MDF_Bank_Status__c, Core_MDF_Bank__r.Core_MDF_Bank_Alias_Name__c, Core_MDF_Account__c,Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c, Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Bank__r.Core_MDF_Bank_Status__c IN :bankStatusSet AND Core_MDF_Account__c IN :accountIds AND Core_MDF_Active_ind__c = TRUE];
            
	    //Sub claim VAT sync
            Map<Id, Core_MDF_Bank__c> banksById = new Map<Id, Core_MDF_Bank__c>();
            for (Core_MDF_Account_Bank_Mapping__c record : bankRecords) {
                banksById.put(record.Core_MDF_Bank__c, record.Core_MDF_Bank__r);
            }
            Map<String, String> countryCodeToRegionMap = banksById.isEmpty() ? new Map<String, String>() : fetchBankRegion(banksById.values());
            
            for (Core_MDF_Account_Bank_Mapping__c record : bankRecords) {
                BankWrapper bw = new BankWrapper();
                bw.bankId = record.Core_MDF_Bank__c;
                bw.bankName = record.Core_MDF_Bank__r.Name;
                bw.bankAlias = record.Core_MDF_Bank__r.Core_MDF_Bank_Alias_Name__c;
                bw.bankStatus = record.Core_MDF_Bank__r.Core_MDF_Bank_Status__c;
                bw.companyCode = record.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c;
                //Sub claim VAT Sync
                bw.supplierCountryCode = record.Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c;
                bw.bankRegion = countryCodeToRegionMap.get(bw.supplierCountryCode);
                bw.isVatEligible = (record.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c == String.valueOf('420') || record.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c == String.valueOf('650')) ? true : false;
                bw.vatOptIn = !bw.isVatEligible ? 'No' : null;
                if (!accountIdToBanksMap.containsKey(record.Core_MDF_Account__c)) {
                    accountIdToBanksMap.put(record.Core_MDF_Account__c, new List<BankWrapper>());
                }
                accountIdToBanksMap.get(record.Core_MDF_Account__c).add(bw);
            }            
        } catch (Exception e) {
            System.debug('Error fetching banks: ' + e.getMessage());
        }
        return accountIdToBanksMap;
    }
    public class BankWrapper {
        @AuraEnabled public String bankId;
        @AuraEnabled public String bankName;
        @AuraEnabled public String bankAlias;
        @AuraEnabled public String bankStatus;
        @AuraEnabled public String companyCode;
        //Sub claim VAT sync
        @AuraEnabled public String supplierCountryCode;
        @AuraEnabled public String bankRegion;
        @AuraEnabled public Boolean isVatEligible;
        @AuraEnabled public String vatOptIn;
    }
    
    public class subClaimWrapper {
        @AuraEnabled public Id recordId;
        @AuraEnabled public Id accountId;
        @AuraEnabled public String accountName;
        @AuraEnabled public Decimal nodeAmount;
        @AuraEnabled public String paymentType;
        @AuraEnabled public String status;
        @AuraEnabled public String bankName;
        @AuraEnabled public String invoiceType;
        @AuraEnabled public Id activityId;
        @AuraEnabled public String activityTitle;
        @auraEnabled public Decimal reimbursableAmount;
        @auraEnabled public Decimal percentage;
        @auraEnabled public PartnerFundClaim claimObj;
        @auraEnabled public String claimPaymentType;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<subClaimWrapper> getSubClaims(Id recordId) {
        if(recordId!=null){
            List<PartnerFundClaim> pfcList = [select Id,ChannelPartnerId,ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c,ChannelPartner.name,Core_MDF_Bank__c,Core_MDF_Bank__r.name,Core_MDF_VAT_Opt_In__c,Core_MDF_Amount_Percentage__c,ChannelPartner.Core_MDF_Payment_Type_nm__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Claim_Id__c,Core_MDF_Status__c,RequestId,Request.title,Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Ad_Run_End_Date__c,Core_MDF_Country_Location_nm__c,Core_MDF_Currency__c,Core_MDF_Claim_Submitter_Id__c,Core_MDF_Processing_Preference_nm__c,Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Payment_Type_nm__c FROM PartnerFundClaim WHERE Core_MDF_Claim_Id__c =:recordId];
            Set<Id> accountIds = new Set<Id>();
            List<subClaimWrapper> result = new List<subClaimWrapper>();
            for (PartnerFundClaim pfc : pfcList) {
                subClaimWrapper claimWrap = new subClaimWrapper();
                claimWrap.recordId = pfc.Id;
                claimWrap.accountId = pfc.ChannelPartnerId;
                claimWrap.accountName = pfc.ChannelPartner.Name;
                claimWrap.status = pfc.Core_MDF_Status__c;
                claimWrap.nodeAmount = pfc.Core_MDF_Total_Invoice_Amount_Local__c;
                claimWrap.bankName = pfc.Core_MDF_Bank__c;
                claimWrap.invoiceType = pfc.Core_MDF_VAT_Opt_In__c;
                claimWrap.paymentType = (pfc.ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c != null && pfc.ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c != '') ? pfc.ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c : pfc.ChannelPartner.Core_MDF_Payment_Type_nm__c;
                claimWrap.activityId = pfc.RequestId;
                claimWrap.activityTitle = pfc.Request.Title;
                claimWrap.reimbursableAmount = pfc.Core_MDF_OtherCostsnotReimbursable_Local__c;
                claimWrap.percentage = pfc.Core_MDF_Amount_Percentage__c;
                claimWrap.claimObj = pfc;
                claimWrap.claimPaymentType = pfc.Core_MDF_Payment_Type_nm__c;
                result.add(claimWrap);
            }
            return result;
        }
        else{
            return null;
        }
        
    }
}