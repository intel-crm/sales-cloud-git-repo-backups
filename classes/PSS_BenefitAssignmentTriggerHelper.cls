/**************************************************************************************
Apex Class Name : PSS_BenefitAssignmentTriggerHelper
Version     : 1.0 
Created Date: 18th Feb, 2021
Description : Trigger handler for PSS_BenefitAssignmentTriggerHelper
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Sharukh                  18/02/2021               Original Version
* Manjula                  29/03/2021               Method to tag select benefit to Account
*************************************************************************************/
//IPA2.0: US-TWC729-7976
@isTest
public without sharing class PSS_BenefitAssignmentTriggerHelper{
    /**
    * @description : Method to update benefitassignment
    * @param List
    * @return void
    **/
        /*public static boolean ipaRefresh = Boolean.valueOf(label.PRM_IPARefresh);  //IPA2.0-TWC727-2861
        public static List<ArdiraSurvey__Survey_Result__c> convertSolutionToOffering(List<ArdiraSurvey__Survey_Result__c> solList){
            List<ArdiraSurvey__Survey_Result__c> returnBenefitAssignList = new List<ArdiraSurvey__Survey_Result__c>();
            Set<Id> assignedAccountIds = new Set<Id>();
            Set<String> solutionTypes = new Set<String>();
            Set<String> tierValues = new Set<String>();
            Set<String> solutionCategories = new Set<String>();
            set<string> specialtyIds=new set<string>();
            for(ArdiraSurvey__Survey_Result__c asr : solList) {
                // check and add the solution account Id(Partner Account field stores the company associated Account Id)
                if(asr.PSS_Partner_Account_Id__c != NULL) {  
                    assignedAccountIds.add(asr.PSS_Partner_Account_Id__c);
                    //system.debug('assignedAccountIds'+assignedAccountIds);
                }
                // Add the solution programs in the list
                if(asr.PSS_Programs_Applicable_Nm__c!= NULL) {
                    solutionTypes.addAll(asr.PSS_Programs_Applicable_Nm__c.split(';'));
                    //system.debug('solutionTypes'+solutionTypes);
                }
                // add the solution category IOTG/DCG in the list
                if(asr.PSS_Solution_Category_Nm__c != NULL){ 
                    solutionCategories.add(asr.PSS_Solution_Category_Nm__c);
                    //system.debug('solutionCategories'+solutionCategories);
                }
    
               
                
            }
            
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id,Core_IPA_Badge_Tier__c FROM Account WHERE Id IN :assignedAccountIds AND Core_IPA_Badge_Tier__c != NULL]);
            for(Account acc : accountMap.values()) {
                tierValues.add(acc.Core_IPA_Badge_Tier__c);
                //system.debug('tierValues'+tierValues);
            }
            
    
    //1. Fetch Impact Path Scoring Records based on programs, tier values ,category from solution scoring and priority number 
    //2. Iterate over Impact Path Scoring results by validating the upper/lower bound scoring levels and populate system level benefit accordingly - [US1008156]
         List<PSS_Solutions_Impact_Path_Scoring__c > imps = new List<PSS_Solutions_Impact_Path_Scoring__c >();
            if(Schema.sObjectType.PSS_Solutions_Impact_Path_Scoring__c.isAccessible()){
                imps = [select id,GeTm_Solution_Type__r.PSS_Priority_Nbr__c,GeTm_Solution_Type__r.name,
                        GeTm_IPA_Tier__c,GeTm_Admin_Suggested_Select_Benefit__c,GeTm_Admin_Suggested_Select_Benefit__r.Name,PSS_Solution_Scoring__r.name,GeTm_Solution_Type__r.PSS_Is_Active_Ind__c,
                        PSS_Solution_Scoring__r.PSS_Scoring_Range_Upper_Bound_Nbr__c,PSS_Solution_Scoring__r.PSS_Scoring_Range_Lower_Bound_Nbr__c,PSS_Solution_Scoring__r.PSS_Solution_Category_Nm__c
                        from PSS_Solutions_Impact_Path_Scoring__c     where GeTm_Solution_Type__r.name IN :solutionTypes AND GeTm_IPA_Tier__c IN :tierValues AND PSS_Solution_Scoring__r.PSS_Solution_Category_Nm__c IN :solutionCategories
                        and GeTm_Solution_Type__r.PSS_Priority_Nbr__c!=null and GeTm_Solution_Type__r.PSS_Is_Active_Ind__c=true ORDER BY GeTm_Solution_Type__r.PSS_Priority_Nbr__c DESC];
            for(PSS_Solutions_Impact_Path_Scoring__c impactscores : imps){
                if(impactscores.GeTm_Admin_Suggested_Select_Benefit__c != NULL){ 
                    specialtyIds.add(impactscores.GeTm_Admin_Suggested_Select_Benefit__c);
                }
            }
                
        }
            set<string> lstOfActiveSpecialties=new set<string>();
            if(specialtyIds!=null && !specialtyIds.isEmpty()){
                 for(PRM_Specialty__c spec: [select id from PRM_Specialty__c where PRM_Inactive_Ind__c =false and id in:specialtyIds ]){
                    lstOfActiveSpecialties.add(spec.id);
                }
            }
                    system.debug('imps'+imps.size());
                    system.debug('specialtyIds'+specialtyIds);
                    system.debug('lstOfActiveSpecialties'+lstOfActiveSpecialties);
           
            //system.debug('imps'+imps.size());
            for(ArdiraSurvey__Survey_Result__c sugstedbnft : solList){
                Account acc = accountMap.get(sugstedbnft.PSS_Partner_Account_Id__c) != null ? accountMap.get(sugstedbnft.PSS_Partner_Account_Id__c) : new Account(); 
                for(PSS_Solutions_Impact_Path_Scoring__c     tst : imps){
                     if(sugstedbnft.PSS_Solution_Category_Nm__c == 'IOTG'){
                        if((tst.GeTm_IPA_Tier__c == acc.Core_IPA_Badge_Tier__c) && 
                           (sugstedbnft.PSS_Programs_Applicable_Nm__c.contains(tst.GeTm_Solution_Type__r.name)) && 
                           (sugstedbnft.PSS_Impact_Path_Score__c>=tst.PSS_Solution_Scoring__r.PSS_Scoring_Range_Lower_Bound_Nbr__c) && 
                           (sugstedbnft.PSS_Impact_Path_Score__c<=tst.PSS_Solution_Scoring__r.PSS_Scoring_Range_Upper_Bound_Nbr__c) &&
                           (sugstedbnft.PSS_Solution_Category_Nm__c.contains(tst.PSS_Solution_Scoring__r.PSS_Solution_Category_Nm__c)) && 
                           lstOfActiveSpecialties.contains(tst.GeTm_Admin_Suggested_Select_Benefit__c))
                        {
                                sugstedbnft.PSS_System_Suggested_Benefit_Level__c = tst.GeTm_Admin_Suggested_Select_Benefit__c;
                                
                                sugstedbnft.PSS_Admin_Suggested_Benefit_Level__c = tst.GeTm_Admin_Suggested_Select_Benefit__c; 
                            if(sugstedbnft.PSS_System_Suggested_Benefit_Level__c != null && 
                               sugstedbnft.PSS_System_Suggested_Benefit_Level__r.Name != null &&
                               tst.GeTm_Admin_Suggested_Select_Benefit__c != null){
                                   
                                   sugstedbnft.PSS_System_Suggested_Benefit_Level__r.Name =tst.GeTm_Admin_Suggested_Select_Benefit__r.Name;
                                   sugstedbnft.PSS_Admin_Suggested_Benefit_Level__r.Name = tst.GeTm_Admin_Suggested_Select_Benefit__r.Name; 
                               }
                        }
                        
                    } else if(sugstedbnft.PSS_Solution_Category_Nm__c == 'DCG'){
                        if((tst.GeTm_IPA_Tier__c == acc.Core_IPA_Badge_Tier__c) && 
                           (sugstedbnft.PSS_Programs_Applicable_Nm__c.contains(tst.GeTm_Solution_Type__r.name)) && 
                           (sugstedbnft.PSS_Solution_Revenue_Projection__c>=tst.PSS_Solution_Scoring__r.PSS_Scoring_Range_Lower_Bound_Nbr__c) && 
                           (sugstedbnft.PSS_Solution_Revenue_Projection__c<=tst.PSS_Solution_Scoring__r.PSS_Scoring_Range_Upper_Bound_Nbr__c) &&
                           (sugstedbnft.PSS_Solution_Category_Nm__c.contains(tst.PSS_Solution_Scoring__r.PSS_Solution_Category_Nm__c)))
                        {
                            sugstedbnft.PSS_System_Suggested_Benefit_Level__c = tst.GeTm_Admin_Suggested_Select_Benefit__c;
                               //sugstedbnft.PSS_System_Suggested_Benefit_Level__r.Name =tst.GeTm_Admin_Suggested_Select_Benefit__r.Name;
                            sugstedbnft.PSS_Admin_Suggested_Benefit_Level__c = tst.GeTm_Admin_Suggested_Select_Benefit__c; 
                           // sugstedbnft.PSS_Admin_Suggested_Benefit_Level__r.Name = tst.GeTm_Admin_Suggested_Select_Benefit__r.Name; 
                           //system.debug('tst.GeTm_Admin_Suggested_Select_Benefit__c'+tst.GeTm_Admin_Suggested_Select_Benefit__c);
                            //system.debug('tst.GeTm_Admin_Suggested_Select_Benefit__r.name'+tst.GeTm_Admin_Suggested_Select_Benefit__r.name);
                            if(sugstedbnft.PSS_System_Suggested_Benefit_Level__c != null && 
                               sugstedbnft.PSS_System_Suggested_Benefit_Level__r.Name != null &&
                               tst.GeTm_Admin_Suggested_Select_Benefit__c != null){
                                   
                                   sugstedbnft.PSS_System_Suggested_Benefit_Level__r.Name =tst.GeTm_Admin_Suggested_Select_Benefit__r.Name;
                                   sugstedbnft.PSS_Admin_Suggested_Benefit_Level__r.Name = tst.GeTm_Admin_Suggested_Select_Benefit__r.Name; 
                               }
                        }
                    }else if(String.isBlank(sugstedbnft.PSS_Solution_Category_Nm__c)){
                        sugstedbnft.PSS_System_Suggested_Benefit_Level__c = NULL;
                        sugstedbnft.PSS_Admin_Suggested_Benefit_Level__c = NULL; 
                    }
              
                }
                if(imps ==NULL ||( imps !=NULL && imps.isEmpty())){
                    sugstedbnft.PSS_System_Suggested_Benefit_Level__c = NULL;
                    sugstedbnft.PSS_Admin_Suggested_Benefit_Level__c = NULL;
                }
                //system.debug('the sugst ben==>'+sugstedbnft);
                returnBenefitAssignList.add(sugstedbnft);  
            }
            
            return returnBenefitAssignList;  
        }*/
     /**
    * Added as part of US941484
    * @description : Method to tag account specialty benefit at location level
    * @param propResponses - List of approved ArdiraSurvey__Survey_Result__c records.
    * @return void
    * This method is called from PSS_SolutionResponse_TriggerHandler in before update event.
    **/  
        /*public static void assignBenefitToAccount(List<ArdiraSurvey__Survey_Result__c>  propResponses){
    
            Set<Id> adminSuggestedBenefitIds = new Set<Id>();
            Set<Id> pagAccountIds = new Set<Id>();
            Set<Id> intelAccountIds = new Set<Id>();
            Set<Id> surveyResultIds = new Set<Id>();
            Set<String> accountPartnerRoles = new Set<String>();
            Set<String> accountSpecialties = new Set<String>();
            Set<String> existingASAs = new Set<string>();
            Set<Id> acctIds = new Set<Id>();
            Map<Id,Id> surveyresultIdIntelAccIdMap = new map<Id,Id>();
            Map<Id, Set<String>> accIdandPartnerRolesMap = new Map<Id, Set<String>>();
            List<PRM_Account_Specialty_Association__c> asaList = new List<PRM_Account_Specialty_Association__c>();
            Map<String, PRM_Specialty__c> specialtyBenefitIdValueMap = new Map<String, PRM_Specialty__c>();
            Map<String, PRM_Account_Specialty_Association__c> newASA = new Map<String, PRM_Account_Specialty_Association__c>();
           
            for(ArdiraSurvey__Survey_Result__c response : propResponses){
                //add the admin suggested benefit look up id to adminSuggestedBenefits set
                if(response.PSS_Admin_Suggested_Benefit_Level__c != null){  
                    adminSuggestedBenefitIds.add(response.PSS_Admin_Suggested_Benefit_Level__c);
                }
                //if Intel account id is not null add it in intelAccountIds set
                if(response.PSS_Partner_Account_Id__c != null){
                    intelAccountIds.add(response.PSS_Partner_Account_Id__c);
                    //creating a map with survey result Id as key and intel account id as value
                    surveyresultIdIntelAccIdMap.put(response.Id, response.PSS_Partner_Account_Id__c);
                }
            }
            
            //Fetch the Partner roles associated with the Intel Account Ids
            if(!intelAccountIds.isEmpty()){
                //Iterating over the associated ACM records with partner role value !=null
                for(PRM_AccountChannelMembership__c acm : [SELECT Id,PRM_Partner_Role__c,PRM_Account_Id__c 
                                                           FROM PRM_AccountChannelMembership__c 
                                                           WHERE PRM_Account_Id__c IN: intelAccountIds 
                                                           AND PRM_Partner_Role__c != null AND PRM_Status_Nm__c = 'Approved']){
                    //If accIdAndPartnerRolesMap doesn't contains the key 
                    if(!accIdAndPartnerRolesMap.containsKey(acm.PRM_Account_Id__c)){
                        //create a empty set of string as value and key will be Intel account Id
                        accIdAndPartnerRolesMap.put(acm.PRM_Account_Id__c, new Set<String>());
                    }
                    //get the set value using Intel account Id key and add the partner role into the set value
                    accIdAndPartnerRolesMap.get(acm.PRM_Account_Id__c).add(acm.PRM_Partner_Role__c);	
                }
                            
                //If adminSuggestedBenefitIds set is not empty
                if(!adminSuggestedBenefitIds.isEmpty()){
                    //Iterating over the specialty benefit records of the admin suggested benefit Ids
                    for(PRM_Specialty__c specBenefit: [select Id,Name,PRM_Role_Nm__c from PRM_Specialty__c where Id IN :adminSuggestedBenefitIds]){
                        //key is benefit Id and value is benefit record
                        if(specBenefit!=null){
                            specialtyBenefitIdValueMap.put(specBenefit.Id, specBenefit);
                        }
                    }
                }
                
                //If surveyresultIdIntelAccIdMap is not empty and accIdAndPartnerRolesMap not empty
                if(!surveyresultIdIntelAccIdMap.isEmpty() && !accIdAndPartnerRolesMap.isEmpty()) {
                    //Iterate over the survey result record list
                    for(ArdiraSurvey__Survey_Result__c result : propResponses){
                        if(surveyresultIdIntelAccIdMap.containsKey(result.Id) && 
                            accIdAndPartnerRolesMap.containsKey(surveyresultIdIntelAccIdMap.get(result.Id))){
                            //Iterate over the partner role associated intel account Id
                            for(String accPartnerRole : accIdAndPartnerRolesMap.get(surveyresultIdIntelAccIdMap.get(result.Id))) {
                                //New specialty record instance
                                PRM_Specialty__c selectBenefit = new PRM_Specialty__c();
                                //if admin suggested benefit is not null and specialtyBenefitIdValueMap contains the admin suggested benefit id as key
                                if(result.PSS_Admin_Suggested_Benefit_Level__c!=null && specialtyBenefitIdValueMap.containsKey(result.PSS_Admin_Suggested_Benefit_Level__c)){
                                    //get the specialty value from specialtyBenefitIdValueMap using the admin suggested benefit id as key
                                    selectBenefit = specialtyBenefitIdValueMap.get(result.PSS_Admin_Suggested_Benefit_Level__c);
                                }
                                
                                Set<String> roles = new Set<String>();
                                //if select benefit record and role are not null
                                if(selectBenefit != null && selectBenefit.PRM_Role_Nm__c != null){
                                    //splitting the role values of select benefit record using ';' seperator and storing in a set
                                    for(String role : selectBenefit.PRM_Role_Nm__c.split(';')){
                                        roles.add(role); 
                                    } 
                                }
                                
                                //if roles set is not empty and contains the account partner role
                                if(!roles.isEmpty() && roles.contains(accPartnerRole) && (!ipaRefresh || test.isrunningtest())){ // IPA2.0-TWC727-2861
                                    //Instance for Account specialty association
                                    PRM_Account_Specialty_Association__c asa = New PRM_Account_Specialty_Association__c();
                                    asa.PRM_Partner_Role__c = accPartnerRole;    
                                    asa.PRM_Account_Id__c = surveyresultIdIntelAccIdMap.get(result.id);  
                                    asa.PRM_Specialty_Id__c = selectBenefit.Id;
                                    //creating a unique key using partner  role,benefitId and intel account id
                                    String key = accPartnerRole + '' + selectBenefit.Id + '' + surveyresultIdIntelAccIdMap.get(result.id);
                                    //creating a map with unique key and asa record as value
                                    newASA.put(key, asa);
                                    
                                    //adding the survey results Id to surveyResultIds set
                                    surveyResultIds.add(result.Id);
                                    //adding the account partner roles to accountPartnerRoles set
                                    accountPartnerRoles.add(accPartnerRole);
                                    //adding the account specialties to accountSpecialties set
                                    accountSpecialties.add(selectBenefit.Id);
                                    //adding the account Ids to acctIds set
                                    acctIds.add(surveyresultIdIntelAccIdMap.get(result.id));
                                    }
                                } 
                            }
                    } 		
                }
            }
            
            //Iterating over the exiting account specialty association records of the account to check if the specialty benefit is already present to remove the duplicates
        if(!ipaRefresh || test.isrunningtest()){ // TWC727-2861
            for(PRM_Account_Specialty_Association__c asa : [SELECT Id,PRM_Partner_Role__c,PRM_Account_Id__c,PRM_Specialty_Id__c 
                                                            FROM PRM_Account_Specialty_Association__c 
                                                            WHERE PRM_Account_Id__c IN :acctIds AND 
                                                            PRM_Partner_Role__c IN :accountPartnerRoles AND 
                                                            PRM_Specialty_Id__c IN :accountSpecialties]) {
                String key = asa.PRM_Partner_Role__c + '' + asa.PRM_Specialty_Id__c + '' + asa.PRM_Account_Id__c;
                //adding the unique keys of existing ASA records in to existingASAs set
                existingASAs.add(key);
            }
            
            //Iterating over the new ASA values to be inserted to check if it is already present in existing ASA records of the account
            for(PRM_Account_Specialty_Association__c asa : newASA.values()) {
                String key = asa.PRM_Partner_Role__c + '' + asa.PRM_Specialty_Id__c + '' + asa.PRM_Account_Id__c;
                //if not in existing ASAs set then enter inside
                if(!existingASAs.contains(key)) {
                    //non-duplicate ASA records which can be inserted
                    asaList.add(asa);
                }
            }
            
            try{
                //inserting the non-duplicate ASA records
                if(asaList.size() > 0) {
                    insert asaList;
                    //after the ASA records are inserted successfully, make  the PSS_Is_Benefit_Assigned_Ind__c field to true
                    for(ArdiraSurvey__Survey_Result__c  res : propResponses) {
                        if(surveyResultIds.contains(res.Id)) {
                            res.PSS_Is_Benefit_Assigned_Ind__c = TRUE;
                        }
                    }
                }
            }
            catch(DmlException e) {
                //throwing the error if any DML exception is detected
                throw e;
            }
        }

    }*/
}