/*********************************************************************************************************************
Apex Class Name  : PRM_accBenefitAssociationUtility
Version       : 1.0
Created Date  : DEC 2018
Function      : partnerBenefitCheck.

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Utkarsh                 12/14/2018              It checks correct partner benefit should be asssociated with partner type.

*********************************************************************************************************************/
public without sharing class PRM_accBenefitAssociationUtility{
    /**
*  @description      : It checks correct partner benefit should be asssociated with partner type.
*  @name             : partnerBenefitCheck
*  @param            : List<PRM_AccountBenefitAssociation__c>
*  @throws exception : NONE
**/
    public static  boolean firstRun = true;
    public static  boolean firstRunBeforeInsert = true;
    public static  boolean firstRunBeforeUpdate = true;
    public static  boolean firstRunAfterInsert = true;
    public static boolean skipvalidationforMPBenefits = false;
    public static boolean preventStagingTableEntry = false;
    public static Map<string,set<string>> mapPartnerTierBenefitsABA = New Map<string,set<string>>() ;
    //public static boolean ipaRefresh = Boolean.valueOf(label.PRM_IPARefresh);  //IPA2.0-TWC727-2861
    
    public static void duplicateRecordCheck(List<PRM_AccountBenefitAssociation__c > lstAccBenefit)
    {
        try
        {
            List<String> uniqstr = new List<String>();
            List<Id> idslist = new List<Id>();
            Set<Id> accid = new Set<Id>();
            //Map<String,Id> uniqueMap = new Map<String,Id>();
            //List<PRM_AccountChannelMembership__c> acmember = new List<PRM_AccountChannelMembership__c>();
            Map<String,Set<String>> duplicateCheckMap = new Map<String,Set<String>>();
            Map<String,Set<PRM_AccountBenefitAssociation__c>> accAbaMap = new Map<String,Set<PRM_AccountBenefitAssociation__c>>();
            List<PRM_AccountBenefitAssociation__c> benefitToUpdate = new List<PRM_AccountBenefitAssociation__c>();
            boolean abaUpdated = false;
            Set<String> tempSet1234 = new Set<String>();
            // Fetching field values
            if(lstAccBenefit!= Null && !lstAccBenefit.isEmpty() && lstAccBenefit.size()>0){
                for(PRM_AccountBenefitAssociation__c aba: lstAccBenefit){
                    uniqstr.add(aba.PRM_Account_Partner_Benefit_Key__c);
                    idslist.add(aba.id);
                    accid.add(aba.PRM_Account_Id__c);
                    if(!Trigger.IsUpdate)
                    {
                        if(!tempSet1234.contains(aba.PRM_Account_Partner_Benefit_Key__c))
                        {
                            tempSet1234.add(aba.PRM_Account_Partner_Benefit_Key__c);
                        }
                        else{aba.addError(System.Label.PRM_ABA_Error3);
                        }
                    }   
                }
            }
            if(accid!= Null && !accid.isEmpty()){
                //Checking for existing ABA records
                for(PRM_AccountBenefitAssociation__c aba :[SELECT Id, PRM_Account_Id__c, PRM_Account_Partner_Benefit_Key__c,PRM_Status_Reason_Txt__c,PRM_Status_Nm__c FROM PRM_AccountBenefitAssociation__c where PRM_Account_Id__c IN :accid]){
                    if(duplicateCheckMap.keySet().contains(aba.PRM_Account_Id__c)) 
                    {
                        Set<String> tempSet1 = duplicateCheckMap.get(aba.PRM_Account_Id__c);
                     tempSet1.add(aba.PRM_Account_Partner_Benefit_Key__c);
                     duplicateCheckMap.put(aba.PRM_Account_Id__c,tempSet1);
                     Set<PRM_AccountBenefitAssociation__c> tempSet2 = accAbaMap.get(aba.PRM_Account_Id__c);
                     tempSet2.add(aba);
                     accAbaMap.put(aba.PRM_Account_Id__c,tempSet2);
                    }
                    else{
                        Set<String> tempSet = new Set<String>();
                        tempSet.add(aba.PRM_Account_Partner_Benefit_Key__c);
                        duplicateCheckMap.put(aba.PRM_Account_Id__c,tempSet);
                        Set<PRM_AccountBenefitAssociation__c> tempSet1 = new Set<PRM_AccountBenefitAssociation__c>();
                        tempSet1.add(aba);
                        accAbaMap.put(aba.PRM_Account_Id__c,tempSet1);
                    }
                } }
            List<PRM_AccountBenefitAssociation__c> finalList = new List<PRM_AccountBenefitAssociation__c>();
            PRM_AccountBenefitAssociation__c  abc;
            //Throwing error message if duplicate ABA records detected.
            for(PRM_AccountBenefitAssociation__c abaDuplicate:lstAccBenefit){
                if((abaDuplicate.id) !=  null ){ 
                    abc =  (PRM_AccountBenefitAssociation__c) trigger.oldMap.get(abaDuplicate.id) ;
                }
                if(trigger.isInsert || (trigger.isUpdate && abc.PRM_Partner_Benefit_Id__c != abaDuplicate.PRM_Partner_Benefit_Id__c ))
                {

        
                    if(duplicateCheckMap!= null && !duplicateCheckMap.isEmpty() && duplicateCheckMap.get(abaDuplicate.PRM_Account_Id__c) != null){
                        if(! duplicateCheckMap.get(abaDuplicate.PRM_Account_Id__c).contains(abaDuplicate.PRM_Account_Partner_Benefit_Key__c) ) {finalList.add(abaDuplicate);
                        }
                        else{Set<PRM_AccountBenefitAssociation__c> benefitSet=accAbaMap.get(abaDuplicate.PRM_Account_Id__c);for(PRM_AccountBenefitAssociation__c aba: benefitSet){
                                if(aba.PRM_Account_Partner_Benefit_Key__c == abaDuplicate.PRM_Account_Partner_Benefit_Key__c && aba.PRM_Status_Nm__c =='Inactive'){benefitToUpdate.add(aba);abaUpdated=true;
                                }
                            }
                                if(!abaUpdated){abaDuplicate.addError(System.Label.PRM_ABA_Error3);
                                }
                            }
                    }
                }
            } 
            if(benefitToUpdate!=null && !benefitToUpdate.isEmpty()){Database.delete(benefitToUpdate,false);
            }
        }catch(Exception ex){String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                            
                            } 
    }
/*********************************************************************************************************************
Method Name  : benefitassignmentcheck
Created Date  : 26/02/2019
Parameters :Trigger.new, Trigger.opldMAp
Description : Check Wether correct benefit is associated with the account.
*********************************************************************************************************************/
    Public static void benefitassignmentcheck(List<PRM_AccountBenefitAssociation__c > lstAccBenefit,Map<Id, PRM_AccountBenefitAssociation__c> abaOldMap)
    {
        Set<Id> accountSet = new Set<Id>();
        Set<Id> benefitIdSet = new Set<Id>();
        List<PRM_VXBnftMatrix__c> vebm = new List<PRM_VXBnftMatrix__c>();
        Map<Id,Set<Id>> accBenefitMap = new Map<Id,Set<Id>>();
        //map<String,Set<String>> mapOfAccountIdAndSpeciality = new map<String,Set<String>>();
        map<String,Set<String>> mapOfAccountIdAndSpeciality = new map<String,Set<String>>();
        Set<string> setOfSpeciality = new Set<string>();
        Map<string,Set<string>> mapOfspecialityAndListOgBenifitGroup = new Map<string,Set<string>>();
        Set<string> benifitGroup = new Set<string>();
        Map<string,Set<String>> mapOfBenifitGroupToBenifit = new Map<string,Set<String>>(); 
        Map<string,Set<String>> mapOfSpeacailityIdAndBenifitId = new Map<string,Set<String>>();
        Map<string,Set<String>> mapOfAccountAndBenifit = new Map<string,Set<String>>();
        Map<Id,String> mapBenefitAccType = new Map<Id,String>();
        Map<Id,String> mapAccIdRecordType = new Map<Id,String>();
        
        
        for(PRM_AccountBenefitAssociation__c aba :lstAccBenefit)
        {
            //Added OR condition to allow MP basic profile benefit with Inactive status - When OPID with no benefits trying to associated with 
            //MPI with enhanced benefit – Insert basic profile with Inactive status and enhanced benefit with Active Status
            if(aba.PRM_Status_Nm__c == 'Active' || PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits == true){
                accountSet.add(aba.PRM_Account_Id__c);
                benefitIdSet.add(aba.PRM_Partner_Benefit_Id__c);              
            }
        }
        if(accountSet != null && !accountSet.isEmpty()){
            for(Account acc :[Select Id, Name,RecordType.DeveloperName From Account Where Id IN :accountSet]){
                mapAccIdRecordType.put(acc.id, acc.RecordType.DeveloperName);
            }
        }
        if(benefitIdSet != null && !benefitIdSet.isEmpty()){
            for(PRM_PartnerBenefit__c pb :[Select Id, Name, PRM_Account_Type_Nm__c From PRM_PartnerBenefit__c Where Id IN :benefitIdSet AND PRM_Account_Type_Nm__c != null]){
                mapBenefitAccType.put(pb.Id, pb.PRM_Account_Type_Nm__c);
            }
        }
        /*Sheetal - Start - US - As part of the story need to check specialty value on account so that we can assign speciality benefits to account*/
        // Creating map of account id and specialty.
       /* if(accountSet != null && !accountSet.isEmpty()){
            for(PRM_Account_Specialty_Association__c asa :[Select Id, PRM_Account_Id__c, PRM_Account_Id__r.Name,PRM_Specialty_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c,PRM_Specialty_Id__r.Name From PRM_Account_Specialty_Association__c Where PRM_InActive_Ind__c = false AND PRM_Account_Id__c IN :accountSet]){
                Set<String> activeSpecSet = new Set<String>();
                    if(mapOfAccountIdAndSpeciality.get(asa.PRM_Account_Id__c) != null && !mapOfAccountIdAndSpeciality.get(asa.PRM_Account_Id__c).IsEmpty()){
                        activeSpecSet = mapOfAccountIdAndSpeciality.get(asa.PRM_Account_Id__c);
                    }
                    activeSpecSet.add(asa.PRM_Specialty_Id__c);
                    mapOfAccountIdAndSpeciality.put(asa.PRM_Account_Id__c,activeSpecSet);
                    setOfSpeciality.add(asa.PRM_Specialty_Id__r.Name);
            }
        }*/
        /*if((!ipaRefresh  || test.isrunningtest())){//IPA2.0-TWC727-2861
        if(accountSet != null && !accountSet.isEmpty()){
            for(PRM_Account_Specialty_Association__c asa :[Select Id,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Specialty_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c,PRM_Specialty_Id__r.Name From PRM_Account_Specialty_Association__c Where PRM_InActive_Ind__c = false AND PRM_Account_Id__c IN :accountSet]){
            if(mapOfAccountIdAndSpeciality.containskey(asa.PRM_Account_Id__c)){Set<String> setOfTempSpeciality = mapOfAccountIdAndSpeciality.get(asa.PRM_Account_Id__c);
                    setOfTempSpeciality.add(asa.PRM_Specialty_Id__r.Name);
                    mapOfAccountIdAndSpeciality.put(asa.PRM_Account_Id__c,setOfTempSpeciality);
                } 
                else{
                    mapOfAccountIdAndSpeciality.put(asa.PRM_Account_Id__c, new Set<string> {asa.PRM_Specialty_Id__r.Name});   
                }
               setOfSpeciality.add(asa.PRM_Specialty_Id__r.Name); 
            }  
        }
        }*/ // IPA Switch Removal
        //Fetching benefit group from speciality. 
        if(setOfSpeciality !=null && !setOfSpeciality.isEmpty()){
            for(PRM_Specialty_Benefit_Group_Association__c sbgRecord: [select id,name,PRM_Specialty_Id__c,PRM_Benefit_Group_Id__c,PRM_Specialty_Id__r.name from PRM_Specialty_Benefit_Group_Association__c where PRM_Specialty_Id__r.name IN: setOfSpeciality AND PRM_InActive_Ind__c = false AND PRM_Benefit_Group_Id__c != null]){
                if(mapOfspecialityAndListOgBenifitGroup.containskey(sbgRecord.PRM_Specialty_Id__r.name)){Set<string> setOfbenifitGroup = mapOfspecialityAndListOgBenifitGroup.get(sbgRecord.PRM_Specialty_Id__r.name);setOfbenifitGroup.add(sbgRecord.PRM_Benefit_Group_Id__c);mapOfspecialityAndListOgBenifitGroup.put(sbgRecord.PRM_Specialty_Id__r.name,setOfbenifitGroup);
                }
                else{mapOfspecialityAndListOgBenifitGroup.put(sbgRecord.PRM_Specialty_Id__r.name, new Set<string> {sbgRecord.PRM_Benefit_Group_Id__c} );                 
                }
                benifitGroup.add(sbgRecord.PRM_Benefit_Group_Id__c);
              
            }     
        }
        
        //Fetching benefits from benefit group.
        //Added Check of PRM_Status_Nm__c in BGBA Query as part of US : US594299
        if(benifitGroup !=null && !benifitGroup.isEmpty()){
            for(PRM_Benefit_Group_Benefit_Association__c bgbRecord: [select id,name,PRM_Benefit_Id__c,PRM_Benefit_Group_Id__c from PRM_Benefit_Group_Benefit_Association__c where PRM_Benefit_Group_Id__c In:benifitGroup AND PRM_InActive_Ind__c = false AND PRM_Benefit_Id__c != null AND PRM_Status_Nm__c ='Live']){
                if(mapOfBenifitGroupToBenifit.containskey(bgbRecord.PRM_Benefit_Group_Id__c)){Set<String> setOfBenifitofBG = mapOfBenifitGroupToBenifit.get(bgbRecord.PRM_Benefit_Group_Id__c);setOfBenifitofBG.add(bgbRecord.PRM_Benefit_Id__c);mapOfBenifitGroupToBenifit.put(bgbRecord.PRM_Benefit_Group_Id__c,setOfBenifitofBG);
                } 
                else{mapOfBenifitGroupToBenifit.put(bgbRecord.PRM_Benefit_Group_Id__c, new Set<string> {bgbRecord.PRM_Benefit_Id__c});   
                }
            }   
        }

        // Associating speciality with benefits.
        if(mapOfspecialityAndListOgBenifitGroup.keyset() != null && !mapOfspecialityAndListOgBenifitGroup.keyset().isEmpty()){
            for(string str: mapOfspecialityAndListOgBenifitGroup.keyset()){Set<string> listOfBenifit = new Set<string>();
                for(string lstOfBG: mapOfspecialityAndListOgBenifitGroup.get(str)){
                    if(lstOfBG != null && mapOfBenifitGroupToBenifit.containskey(lstOfBG)){listOfBenifit.addall(mapOfBenifitGroupToBenifit.get(lstOfBG));  
                        }   
                    }
                if(listOfBenifit != null && !listOfBenifit.IsEmpty()){mapOfSpeacailityIdAndBenifitId.put(str,listOfBenifit);
                }
            }  
        }

        // Associating account with benefits.
        if(mapOfAccountIdAndSpeciality.keyset() !=null && !mapOfAccountIdAndSpeciality.keyset().isEmpty()){
            for (string str: mapOfAccountIdAndSpeciality.keyset()){
                Set<string> listOfSpecialityForObj = new Set<string>();
                //Set<String> strObj;
                //strObj = mapOfAccountIdAndSpeciality.get(str);              
                for(string strObj: mapOfAccountIdAndSpeciality.get(str)){
                    if(strObj !=null){
                        if(mapOfSpeacailityIdAndBenifitId.containskey(strObj)){listOfSpecialityForObj.addall(mapOfSpeacailityIdAndBenifitId.get(strObj));   
                        }   
                    } 
                }
                if(listOfSpecialityForObj != null && !listOfSpecialityForObj.IsEmpty()){mapOfAccountAndBenifit.put(str,listOfSpecialityForObj);
                }
            }    
        }
        vebm = [Select id, PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name, PRM_Channel_Program_Level_Id__c,PRM_Covered_Account_Ind__c,PRM_Approval_Type_Nm__c, PRM_Partner_Benefit_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Role_Nm__c from PRM_VXBnftMatrix__c where PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_IsActive_Ind__c = True AND PRM_Partner_Role_Nm__c != null]; 
        /* UTKARSH - DE69552 and US596757 - 27-02-2020 - As discussed with Lakshman , removed 'Partner Type' from 'Benefit Matrix' query as we don’t need to consider ‘Partner Type’field value on Benefit Matrix*/
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        if(accountSet != null && !accountSet.isEmpty()){
            acmList = [SELECT Id, PRM_Account_Id__c,PRM_Account_Id__r.name, PRM_Channel_Program_Id__c,PRM_Channel_Program_Id__r.name,PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.name,PRM_Status_Nm__c,PRM_Partner_Role__c FROM PRM_AccountChannelMembership__c where PRM_Account_Id__c IN: accountSet AND PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_Status_Nm__c =:System.Label.PRM_Status];// 
        }
        if(acmList != null && !acmList.IsEmpty()){
            for(PRM_AccountChannelMembership__c acm :acmList){ // Comparing ACM and benefit matrix field values to assign appropriate benefits.
                if(vebm != null && !vebm.IsEmpty()){
                    for(PRM_VXBnftMatrix__c bm :vebm){
                        Set<Id> benefitList = new Set<Id>();
                        if(accBenefitMap.get(acm.PRM_Account_Id__c)!= null && !accBenefitMap.get(acm.PRM_Account_Id__c).isEmpty()){
                            benefitList = accBenefitMap.get(acm.PRM_Account_Id__c);
                        }
                        String allApplicableTierNames = getApplicableBenefitTiers(acm.PRM_Channel_Program_Level_Id__r.Name);
                        if((allApplicableTierNames.contains(bm.PRM_Channel_Program_Level_Id__r.Name)) /* (acm.PRM_Channel_Program_Level_Id__r.Name == bm.PRM_Channel_Program_Level_Id__r.Name)*/  && (bm.PRM_IsActive_Ind__c = True) && (acm.PRM_Partner_Role__c == bm.PRM_Partner_Role_Nm__c)){
                            benefitList.add(bm.PRM_Partner_Benefit_Id__c);
                            accBenefitMap.put(acm.PRM_Account_Id__c,benefitList);
                        }
                    }
                }                   
            }
        }
        //Throwing error message if inappropriate benefits assigned.
        for(PRM_AccountBenefitAssociation__c aba :lstAccBenefit){
            Set<Id> applicableBenefits = new Set<Id>();
            Set<string> allowedBenifitForSpeciality = new Set<string>();
            String sourceValue;
            String benefitAccountType;
            String accountRecordType;
            
            /*US763723 -Utkarsh - Start - Update status reason field blank when ABA is activated again*/
            /*if(aba.PRM_Status_Nm__c == System.Label.PRM_Status_Active && aba.PRM_Status_Reason_Txt__c != null){aba.PRM_Status_Reason_Txt__c = '';
            }*/
            /*US763723 - END*/
            if(trigger.isInsert && acmList.IsEmpty()){aba.addError(System.Label.PRM_ABA_Error1);
            }
            if(trigger.isUpdate && acmList.IsEmpty())
            {
                PRM_AccountBenefitAssociation__c oldABA = abaOldMap.get(aba.Id);
                if(oldABA != null && oldABA.PRM_Status_Nm__c == 'Inactive' && aba.PRM_Status_Nm__c == System.Label.PRM_Status_Active){aba.addError(System.Label.PRM_ABA_Error1);
                                                                                                               }
            }
            if(accBenefitMap != null && !accBenefitMap.IsEmpty() && accBenefitMap.containskey(aba.PRM_Account_Id__c)){
                applicableBenefits = accBenefitMap.get(aba.PRM_Account_Id__c);
            }
            if(mapOfAccountAndBenifit != null && !mapOfAccountAndBenifit.IsEmpty() && mapOfAccountAndBenifit.containskey(aba.PRM_Account_Id__c)){
                allowedBenifitForSpeciality = mapOfAccountAndBenifit.get(aba.PRM_Account_Id__c); // Set of specialty benefits.
            }
            if(!string.ISBLANK(aba.PRM_Partner_Benefit_Id__c)){
                benefitAccountType = mapBenefitAccType.get(aba.PRM_Partner_Benefit_Id__c);
                accountRecordType = mapAccIdRecordType.get(aba.PRM_Account_Id__c);
                //US632963 - Added account recordtype check with partner benefit account type check.
                if(benefitAccountType != accountRecordType && benefitAccountType != System.Label.PRM_PB_AccType && aba.PRM_Status_Nm__c == System.Label.PRM_Status_Active){aba.addError(System.Label.PRM_ABA_Error2);
                }
                else{
                    if(applicableBenefits!=null && !applicableBenefits.isEmpty() && !applicableBenefits.contains(aba.PRM_Partner_Benefit_Id__c) && allowedBenifitForSpeciality!=null /*&& !allowedBenifitForSpeciality.isEmpty()*/&& !allowedBenifitForSpeciality.contains(aba.PRM_Partner_Benefit_Id__c) && aba.PRM_Status_Nm__c == System.Label.PRM_Status_Active){
                      
                       aba.addError(System.Label.PRM_ABA_Error2);  
          }
        
                }
                /*Start - US566988 - As part of the story need to check the source of benefits assignment*/
                if(applicableBenefits.contains(aba.PRM_Partner_Benefit_Id__c)){ //source of benefit is benefit matrix.
                    sourceValue = System.Label.PRM_Source_BenefitMatrix;
                }
                if(allowedBenifitForSpeciality.contains(aba.PRM_Partner_Benefit_Id__c)){sourceValue = System.Label.PRM_Source_Specialty;
                }
                if((applicableBenefits.contains(aba.PRM_Partner_Benefit_Id__c)) && (allowedBenifitForSpeciality.contains(aba.PRM_Partner_Benefit_Id__c))){sourceValue = System.Label.PRM_Source_Matrix_Specialty;
                }
                if(!string.ISBLANK(sourceValue)){
                    aba.PRM_Source__c = sourceValue;
                }
                /* END - US566988 */
            }
        }
    }
    
    public static String getApplicableBenefitTiers(String tierName){
         String allApplicableTierNames = '';
        
        if(String.isNotBlank(tierName)){
            //if(ipaRefresh){ // IPA Switch Removal
                if(tierName =='Prestige'){
                    allApplicableTierNames = 'Partner' + ',' + 'Prestige';
                }else if(tierName =='Partner'){
                    allApplicableTierNames = 'Partner';
                }
           /* }else{
            if(tierName == Label.PRM_Tier_Titanium){                
              allApplicableTierNames = Label.PRM_Tier_Titanium + ',' + label.PRM_Tier_Gold + ',' + label.PRM_Program_Level_Member;           
            }else if(tierName == Label.PRM_Tier_Gold){
                allApplicableTierNames = label.PRM_Tier_Gold + ',' + label.PRM_Program_Level_Member;             
            }else{
                allApplicableTierNames = label.PRM_Program_Level_Member;                                                  
            }
        }  */ // IPA Switch Removal              
        }
        
        return allApplicableTierNames;
    }
    
    /************************************************************************************************************************************************************************
    Method Name   : onStatusInactive
    Created Date  : 2 April 2019
    Parameters    : List<PRM_AccountBenefitAssociation__c> lstAccBenefit, Map<Id,PRM_AccountBenefitAssociation__c> oldMap
    Description   : Whenever the benefit association record is Inactivated, corresponding Contact Entitlements are removed/Inactivated. 
    Author        : Utkarsh
    **************************************************************************************************************************************************************************/
    public static void onStatusInactive(List<PRM_AccountBenefitAssociation__c> lstAccBenefit)
    {
        List<Id> benefitList = new List<Id>();
        Set<Id> entitlementList = new Set<Id>();
        List<PRM_Batch_Entitlement__c> beList = new List<PRM_Batch_Entitlement__c>();
        Set<Id> accId = new Set<Id>();
        Set<Id> contactList = new Set<Id>();
        //Query on BatchCustomSetting to fetch Entitlements
        PRM_BatchCustomSetting__c batchCustomSetting;
        List<String> entitlementNotToInactivate = new List<String>();
        batchCustomSetting = [Select Id, Name, PRM_NoOfRecords__c, PRM_SchedulingHour__c,PRM_PartnerType__c,PRM_ChannelProgramLevel__c, PRM_EntitlementsNotToInactivate__c From PRM_BatchCustomSetting__c Where Name =:System.Label.PRM_BatchValues];
        if(batchCustomSetting.PRM_EntitlementsNotToInactivate__c != null){
        entitlementNotToInactivate = batchCustomSetting.PRM_EntitlementsNotToInactivate__c.split(';');
    }
        //Fetching account id of inactive ABA.
        for(PRM_AccountBenefitAssociation__c aba: lstAccBenefit){
            if(aba.PRM_Status_Nm__c == System.label.PRM_Status_Inactive){
                benefitList.add(aba.PRM_Partner_Benefit_Id__c);
                accId.add(aba.PRM_Account_Id__c);
            }
        }
        //Fetching contact id.
        if(accId != null && !accId.IsEmpty()){
            for(PRM_Account_Contact_Relationship__c acrList : [Select id, name, PRM_Account_Id__c, PRM_Contact_Id__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c IN :accId]){
                contactList.add(acrList.PRM_Contact_Id__c);
            }
        }
        //Fetching entitlment id based on inactive benefit id.
        if(benefitList != null && !benefitList.IsEmpty()){
            String query = 'Select Id, Name,PRM_Entitlement_Id__c,PRM_Partner_Benefit_Id__c From PRM_VXEnttlmntMatrix__c  Where PRM_Partner_Benefit_Id__c IN :benefitList and PRM_IsActive_Ind__c = true and recordType.DeveloperName in (\'PRM_EntitlementWithBenefits\', \'PRM_EntitlementWithoutBenefits\')';
            //String filter = ipaRefresh? 'and PRM_IPARefreshCheck__c = true': 'and PRM_IPARefreshCheck__c = false';
            
            List<PRM_VXEnttlmntMatrix__c> matrixRecords = Database.query(query);// +' '+filter);
            
            for(PRM_VXEnttlmntMatrix__c em : matrixRecords){
                entitlementList.add(em.PRM_Entitlement_Id__c);
            }
        }
        //Creating batch entitlement record with contact and entitlement id.
        if(entitlementList != null && !entitlementList.IsEmpty()){
            List<String> nonProcessedRecords = getActvieBatchEntitlement(entitlementList,contactList);//remove duplciate for removal batch entitlement 
            for(Core_Contact_Entitlement__c ce :[Select Id,Core_Contact_Id__c,Core_Entitlement_Id__r.Name,Name,Core_Entitlement_Id__c,Core_Status__c,Core_Data_Loaded__c,Core_DontNotify__c,Core_Selected__c From Core_Contact_Entitlement__c Where Core_Entitlement_Id__c IN :entitlementList AND Core_Contact_Id__c IN :contactList AND Core_Selected__c = true]){
                if( entitlementNotToInactivate == null || (!entitlementNotToInactivate.IsEmpty() && !entitlementNotToInactivate.contains(ce.Core_Entitlement_Id__r.Name)))
                { // added check as part of TWC727-790 [Shivini]
                    String key = ce.Core_Contact_Id__c+'_'+ce.Core_Entitlement_Id__c;
                    if(!nonProcessedRecords.contains(key)){
                        PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
                        be.PRM_Contact_Id__c = ce.Core_Contact_Id__c;
                        be.PRM_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                        be.PRM_Status_Nm__c = System.label.PRM_Status_New;
                        be.PRM_Status_Reason_Txt__c = 'PRM_accBenefitAssociationUtility : Removal of Entitlement';//TWC729-8089 : Adding reason text : NJ
                        be.PRM_IsRemove_Ind__c = true;
                        if(!beList.Contains(be)){
                            beList.add(be);
                        }
                    }
                }
            }
        }
        if((beList != null && !beList.IsEmpty()) && preventStagingTableEntry == false){
            //try{
                insert beList; 
              /* }
            catch(Exception ex){String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                               }*/
        }
        
    }
    /************************************************************************************************************************************************************************
    Method Name   : onStatusInactive
    Created Date  : 2 April 2019
    Parameters    : List<PRM_AccountBenefitAssociation__c> lstAccBenefit, Map<Id,PRM_AccountBenefitAssociation__c> oldMap
    Return        : void
    Description   : Whenever the benefit association record is Inactivated at OPID level, corresponding Contact Entitlements at Acoount level were removed/Inactivated. 
    Author        : Vijay
    User Story    : US639046
    **************************************************************************************************************************************************************************/
    public static void onStatusInactiveParent(List<PRM_AccountBenefitAssociation__c> lstAccBenefit, Map<Id,PRM_AccountBenefitAssociation__c> oldMap){
        
        List<Id> benefitList = new List<Id>();
        Set<Id> entitlementList = new Set<Id>();
        List<PRM_Batch_Entitlement__c> beList = new List<PRM_Batch_Entitlement__c>();
        Set<Id> accId = new Set<Id>();
        Set<Id> contactList = new Set<Id>();
        PRM_AccountBenefitAssociation__c abaOld ;
        Set<Id> intelAccountIds = new Set<Id>();
        List<String> entitlementNotToInactivate = new List<String>();
    PRM_BatchCustomSetting__c batchCustomSetting = [Select Id, Name, PRM_NoOfRecords__c, PRM_SchedulingHour__c,PRM_PartnerType__c,PRM_ChannelProgramLevel__c, PRM_EntitlementsNotToInactivate__c From PRM_BatchCustomSetting__c Where Name =:System.Label.PRM_BatchValues];
        if(batchCustomSetting.PRM_EntitlementsNotToInactivate__c != null){
          entitlementNotToInactivate = batchCustomSetting.PRM_EntitlementsNotToInactivate__c.split(';');
        }
            
        //Fetching the old ABA records and checking the Status, If the Status is 'Inactive' adding them to a list 
        if(lstAccBenefit != null && !lstAccBenefit.IsEmpty()){
            for(PRM_AccountBenefitAssociation__c eachABA : [Select Id,Name,PRM_Account_Id__c,PRM_Partner_Benefit_Id__c,PRM_Status_Nm__c from PRM_AccountBenefitAssociation__c where Id IN :lstAccBenefit]){
                if(oldMap!=null && oldMap.size()>0) {
                    abaOld = (PRM_AccountBenefitAssociation__c) oldMap.get(eachABA.PRM_Account_Id__c);
                }
                if(abaOld != null && abaOld.PRM_Status_Nm__c == System.label.PRM_Status_Inactive){benefitList.add(abaOld.PRM_Partner_Benefit_Id__c);
                    accId.add(abaOld.PRM_Account_Id__c);
                } else if (abaOld == null && eachABA.PRM_Status_Nm__c == System.label.PRM_Status_Inactive){
                    benefitList.add(eachABA.PRM_Partner_Benefit_Id__c);
                    accId.add(eachABA.PRM_Account_Id__c);
                }
            }
        }
        
        Map<Id,Id> intelAccForBenefits = new Map<Id,Id>();
        //Fetching all the Intel Account Ids from OPID Account
        if(accId != null && !accId.isEmpty()){
            for(Core_Account_Group_Member__c eachAcc : [Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c in :accId AND Core_Inactive_Ind__c = FALSE]){ // Utkarsh - Added inactive indicator check as part of defect TWC727-837
                intelAccountIds.add(eachAcc.Core_Intel_Account_Id__c);
                intelAccForBenefits.put(eachAcc.Core_Partner_Account_Id__c,eachAcc.Core_Intel_Account_Id__c);
            }
        }

       
        Set<Id> filterIntelIds = new Set<Id>();

      /*  if(!intelAccountIds.isEmpty()){
            for(Core_Account_Group_Member__c eachAcc : [Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c in :intelAccountIds AND Core_Inactive_Ind__c = FALSE]){  
                intelAccForBenefits.put(eachAcc.Core_Partner_Account_Id__c,eachAcc.Core_Intel_Account_Id__c);
            }
        } */

        if(!intelAccForBenefits.isEmpty()){
            for (PRM_AccountBenefitAssociation__c aba : [Select Id,PRM_Account_Id__c FROM PRM_AccountBenefitAssociation__c WHERE PRM_Account_Id__c IN:intelAccForBenefits.keySet() AND PRM_Partner_Benefit_Id__r.Name = 'Points Redemption' AND PRM_Status_Nm__c='Active']) {
                filterIntelIds.add(intelAccForBenefits.get(aba.PRM_Account_Id__c));
            }
        }
        
        //Fetching all the Contacts associated with Intel Account Ids(Account Level)
        if(accId != null && !accId.IsEmpty()){
            for(PRM_Account_Contact_Relationship__c acrList : [Select id, name, PRM_Account_Id__c, PRM_Contact_Id__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c IN :intelAccountIds]){
                contactList.add(acrList.PRM_Contact_Id__c);
            }
        }
        //Fetching entitlment id based on inactive benefit id.
        if(benefitList != null && !benefitList.IsEmpty()){ 
            String query = 'Select Id, PRM_Entitlement_Id__c From PRM_VXEnttlmntMatrix__c  Where PRM_Partner_Benefit_Id__c IN :benefitList and PRM_IsActive_Ind__c = true and recordType.DeveloperName in (\'PRM_EntitlementWithBenefits\', \'PRM_EntitlementWithoutBenefits\')';
            //String filter = ipaRefresh? 'and PRM_IPARefreshCheck__c = true': 'and PRM_IPARefreshCheck__c = false';
            
            List<PRM_VXEnttlmntMatrix__c> matrixRecords = Database.query(query);
            
            for(PRM_VXEnttlmntMatrix__c em : matrixRecords){//[Select Id, Name,PRM_Entitlement_Id__c,PRM_Partner_Benefit_Id__c From PRM_VXEnttlmntMatrix__c Where PRM_Partner_Benefit_Id__c IN :benefitList  and PRM_IsActive_Ind__c = true]){
                entitlementList.add(em.PRM_Entitlement_Id__c);
            }
        }
        
        //Creating batch entitlement record with contact and entitlement id.
        if(entitlementList != null && !entitlementList.IsEmpty()){
            List<String> nonProcessedRecords = getActvieBatchEntitlement(entitlementList,contactList);//remove duplciate for removal batch entitlement 
            for(Core_Contact_Entitlement__c ce :[Select Id,Core_Contact_Id__c,Name,Core_Entitlement_Id__c,Core_Status__c,Core_Data_Loaded__c,Core_DontNotify__c,Core_Selected__c,Core_Entitlement_Id__r.name,Core_Contact_Id__r.AccountId From Core_Contact_Entitlement__c Where Core_Entitlement_Id__c IN :entitlementList AND Core_Contact_Id__c IN :contactList AND Core_Selected__c = true]){
                if (( entitlementNotToInactivate == null || (!entitlementNotToInactivate.IsEmpty() && !entitlementNotToInactivate.contains(ce.Core_Entitlement_Id__r.Name))) && 
                   (ce.Core_Entitlement_Id__r.name != 'Points Redeem' || (ce.Core_Entitlement_Id__r.name == 'Points Redeem' && !filterIntelIds.contains(ce.Core_Contact_Id__r.AccountId)))){
                    String key = ce.Core_Contact_Id__c+'_'+ce.Core_Entitlement_Id__c;
                    if(!nonProcessedRecords.contains(key)){
                        PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
                        be.PRM_Contact_Id__c = ce.Core_Contact_Id__c;
                        be.PRM_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                        be.PRM_Status_Nm__c = System.label.PRM_Status_New;
                        be.PRM_Status_Reason_Txt__c = 'PRM_accBenefitAssociationUtility : Removal of Entitlement';//TWC729-8089 : Adding reason text : NJ
                        be.PRM_IsRemove_Ind__c = true;
                        if(!beList.Contains(be)  && PRM_ProfileResponse.activateInactivateBenefitExecuted == false){beList.add(be);
                        }
                    }
                
                }
            }
        }
        if(beList != null && !beList.IsEmpty()){
            //try{
                insert beList; 
            /*}
            catch(Exception ex){String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
            }*/
        }
        
    }
     /****************************************************************************************************************************************************************************
    Method Name   : getActvieBatchEntitlement
    Created Date  : 8 Sept, 2025
    Parameters    : Set<Id> entitlementList,Set<Id> contactList
    Return        : List<String>
    Description   : get batch entitlements in new or in progress status
    ****************************************************************************************************************************************************************************/

    public static List<String> getActvieBatchEntitlement(Set<Id> entitlementList,Set<Id> contactList){
        List<String> nonProcessedRecords = new List<String>();
        List<PRM_Batch_Entitlement__c> newinProgressBatchEnt = [Select Id, Name, PRM_Contact_Id__c,PRM_Entitlement_Id__c,PRM_Status_Nm__c,PRM_IsRemove_Ind__c From PRM_Batch_Entitlement__c Where (PRM_Status_Nm__c = 'New' OR PRM_Status_Nm__c = 'In Progress') AND PRM_Contact_Id__c IN:contactList AND PRM_Entitlement_Id__c IN :entitlementList and PRM_IsRemove_Ind__c=true];
        if(newinProgressBatchEnt!=null && !newinProgressBatchEnt.isEmpty()){
            for(PRM_Batch_Entitlement__c be: newinProgressBatchEnt){nonProcessedRecords.add(be.PRM_Contact_Id__c+'_'+be.PRM_Entitlement_Id__c);
            }
        }
        return nonProcessedRecords;
    }

    /****************************************************************************************************************************************************************************
    Method Name   : onOPIDBenefitStatusInactive
    Created Date  : 8 May, 2020
    Parameters    : List<PRM_AccountBenefitAssociation__c> lstABA,Map<Id,PRM_AccountBenefitAssociation__c> oldMap
    Return        : Void
    Description   : Whenever Any Benefit at OPID level is inactivated manually,same benefits will be inactivated at Accounts level.
    Author        : Dinesh
    User Story     : US639046
    ****************************************************************************************************************************************************************************/
    public static void onOPIDBenefitStatusInactive(List<PRM_AccountBenefitAssociation__c> lstABA,Map<Id,PRM_AccountBenefitAssociation__c> oldMap){
        
        Map<id,set<string>> mapLocEligBenefits = new Map<id,set<string>> ();
        Set<Id> acctId = new Set<Id>();
        Set<Id> bnftIds = new Set<Id>();
        String recordTypeName = 'Partner Account Group';
        Set<id> parentIds = new set<id>();
        List<PRM_AccountBenefitAssociation__c> updateChildABA = new List<PRM_AccountBenefitAssociation__c>();
        //List<Core_Account_Group_Member__c> lstChildAct = new List<Core_Account_Group_Member__c>();
        PRM_AccountBenefitAssociation__c abaOld;
        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>();
        List<PRM_AccountBenefitAssociation__c> lstChildABA = new List<PRM_AccountBenefitAssociation__c>();
        List<Id> actChildList = new List<Id>();
        
         //Fetching the old ABA records and checking the Status, If the Status of ABA is 'Inactive' adding them into a list 
        if(lstABA != null && !lstABA.IsEmpty()){
            for(PRM_AccountBenefitAssociation__c eachABA : [Select Id,PRM_Account_Id__c,PRM_Partner_Benefit_Id__c,PRM_Status_Nm__c from PRM_AccountBenefitAssociation__c where Id in :lstABA]){
                if(oldMap!=null && oldMap.size()>0) {
                    abaOld = (PRM_AccountBenefitAssociation__c) oldMap.get(eachABA.id);
                }
                if(abaOld != null && abaOld.PRM_Status_Nm__c == System.label.PRM_Status_Active && eachABA.PRM_Status_Nm__c ==System.label.PRM_Status_Inactive){
                    acctId.add(abaOld.PRM_Account_Id__c);
                    bnftIds.add(abaOld.PRM_Partner_Benefit_Id__c);
                } else if (abaOld == null && eachABA.PRM_Status_Nm__c == System.label.PRM_Status_Inactive){bnftIds.add(eachABA.PRM_Partner_Benefit_Id__c);
                    acctId.add(eachABA.PRM_Account_Id__c);
                } 
            }
            
        }
        //Fetching ABA records for OPID accounts only.
        if(acctId != null && !acctId.isEmpty()){
            abaList = [select PRM_Partner_Benefit_Id__c, PRM_Status_Nm__c,  PRM_Account_Id__c from PRM_AccountBenefitAssociation__c where PRM_Account_Id__r.id in :acctId and PRM_Account_Id__r.RecordType.Name =:recordTypeName ];
        }
        
        //Fetching all the OPID Accounts
        if(abaList != null && !abaList.isEmpty()){
            for(PRM_AccountBenefitAssociation__c ids : abaList){
                parentIds.add(ids.PRM_Account_Id__c);
            }
        }
        //fetching Intel account ids associated with OPID Account
        if(parentIds != null && !parentIds.isEmpty()){
           /* for(Core_Account_Group_Member__c eachAcc : [Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c in :parentIds]){
                
                actChildList.add(eachAcc.Core_Intel_Account_Id__c);
            }*/
            for(PRM_AccountChannelMembership__c eachAcm : [Select Id,Name,PRM_Partner_Role__c,PRM_Account_Id__c, PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Account_Id__r.Core_Account_Record_Type__c,PRM_Status_Nm__c FROM PRM_AccountChannelMembership__c where prm_account_id__r.Core_IPA_One_Partner_Id__c in :parentIds]){
                //mapPartnerTierBenefitsABA=PRM_ACMTriggerHandlerNew.mapPartnerTierBenefits1;
                                                         if(eachAcm.PRM_Status_Nm__c=='Approved'){
                if(!mapPartnerTierBenefitsABA.isEmpty()){
                    if(mapLocEligBenefits.keyset().contains(eachAcm.PRM_Account_Id__c)){
                        set<string> bnftIdsi = mapLocEligBenefits.get(eachAcm.PRM_Account_Id__c);
                        bnftIdsi.addall(mapPartnerTierBenefitsABA.get(eachAcm.PRM_Partner_Role__c.toUpperCase()+'_'+eachAcm.PRM_Channel_Program_Level_Id__r.Name.toUpperCase()));
                        mapLocEligBenefits.put(eachAcm.PRM_Account_Id__c, bnftIdsi);
                    }
                    else{
                        mapLocEligBenefits.put(eachAcm.PRM_Account_Id__c,mapPartnerTierBenefitsABA.get(eachAcm.PRM_Partner_Role__c.toUpperCase()+'_'+eachAcm.PRM_Channel_Program_Level_Id__r.Name.toUpperCase() )) ;
                    }  
                                                                        }
                                                          }
                if(eachAcm.PRM_Account_Id__r.Core_Account_Record_Type__c==System.label.PRM_Intel_Account_Record_Type){
                    actChildList.add(eachAcm.PRM_Account_Id__c);  
               }
            }
        }
        
        //Fetching all the ABA records of Intel Accounts
        if(actChildList != null && !actChildList.isEmpty() && bnftIds != null && !bnftIds.isEmpty()){
            lstChildABA = [select id, PRM_Status_Reason_Txt__c,name,PRM_Partner_Benefit_Id__c,PRM_Account_Id__c,PRM_Status_Nm__c from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c in :actChildList and PRM_Partner_Benefit_Id__c in :bnftIds];
        }
        
        //Updating the Status of Benifit to Inactive and the updating the Status reason for inactivation of Benifit
        if(abaList != null && !abaList.isEmpty()){
            for(PRM_AccountBenefitAssociation__c aba : lstChildABA){
                if(bnftIds.contains(aba.PRM_Partner_Benefit_Id__c) && (mapLocEligBenefits.IsEmpty() || (mapLocEligBenefits.containskey(aba.PRM_Account_Id__c)) && !mapLocEligBenefits.get(aba.PRM_Account_Id__c).contains(aba.PRM_Partner_Benefit_Id__c))){                                                          
                    aba.PRM_Status_Nm__c = System.label.PRM_Status_Inactive;
                    aba.PRM_Status_Reason_Txt__c= System.label.PRM_Benifit_Reason;
                    updateChildABA.add(aba);
                }
            }
        }
        
        try{
            upsert updateChildABA;
        }catch(Exception ex){
      System.debug('Message '+ex.getMessage());
            
        }
        
    }
    
    /* *****************************************************************************************************************************************
    * Method Name   : opidBenefitInactivation
    * Author       : Sheetal Bhargava    
    * Date         : 20/05/2020
    * Parameters   : List<PRM_AccountBenefitAssociation__c > lstAccBenefit,Map<Id, PRM_AccountBenefitAssociation__c> abaOldMap 
    * Return       : Void
    * Description  : This method is used to Inactivate Aba on opid and on its child account as part of US570463
    ****************************************************************************************************************************************** */
    
    Public static void opidBenefitInactivation(List<PRM_AccountBenefitAssociation__c > lstAccBenefit,Map<Id, PRM_AccountBenefitAssociation__c> abaOldMap){
        Set<Id> setOfAccountId = new Set<Id>();
        Set<Id> setOfAccForChildRecordInactivation = new Set<Id>();
        Set<Id> setOfAccIdForOwnAbaInactivation = new Set<Id>();
        Set<Id> setOfChildAccId = new Set<Id>();
        List<PRM_AccountBenefitAssociation__c> lstOfAba = New List<PRM_AccountBenefitAssociation__c>();
        Set<Id> opidsForMpRelationshipDeactivation = new Set<Id>();

        try{
            
            Id OpidAccRecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();

            
            Set<String> setOfBnfts  = new Set<String>{System.Label.PRM_Solution_Marketplace_Basic_Access,System.Label.PRM_Solutions_Marketplace_Basic_Profile,System.Label.PRM_Solutions_Marketplace_Enhanced};
                
                //Iterating aba record to fetch accid for various operation
                if(lstAccBenefit != null && ! lstAccBenefit.isEmpty()){
                     for(PRM_AccountBenefitAssociation__c aba: [Select id,name,PRM_Status_Nm__c,PRM_Account_Id__c,/*PRM_Partner_Benefit_Id__c,*/PRM_Partner_Benefit_Id__r.Name,PRM_Status_Reason_Txt__c from PRM_AccountBenefitAssociation__c where Id IN: lstAccBenefit AND PRM_Account_Id__r.Recordtypeid =: OpidAccRecordTypeId AND PRM_Partner_Benefit_Id__r.Name IN: setOfBnfts]){//ATHR Fix - TWC729-9556 - JB
                        if (aba.PRM_Status_Nm__c == System.Label.PRM_Status_Active) {
                            setOfAccountId.add(aba.PRM_Account_Id__c);
                            if(aba.PRM_Partner_Benefit_Id__r.Name == System.Label.PRM_Solutions_Marketplace_Basic_Profile){
                                setOfAccForChildRecordInactivation.add(aba.PRM_Account_Id__c);  
                            }
                            else if(aba.PRM_Partner_Benefit_Id__r.Name == System.Label.PRM_Solutions_Marketplace_Enhanced){
                                //added by Jambert - Fix for : Basic Access Benefit is not getting inactivated 
                                //when basic profile is created with inactive status
                                if(PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits){
                                    setOfAccForChildRecordInactivation.add(aba.PRM_Account_Id__c);
                                }
                                setOfAccIdForOwnAbaInactivation.add(aba.PRM_Account_Id__c);  
                            }
                        }

                        if (aba.PRM_Status_Nm__c == System.Label.PRM_Status_Inactive && abaOldMap != null &&
                        !abaOldMap.isEmpty() && abaOldMap.get(aba.Id).PRM_Status_Nm__c == System.Label.PRM_Status_Active && 
                        aba.PRM_Status_Reason_Txt__c != System.Label.PMP_DeactivateBenefit_StatusReason) {
                            opidsForMpRelationshipDeactivation.add(aba.PRM_Account_Id__c);
                        }
                    }  
                }

                if (!opidsForMpRelationshipDeactivation.isEmpty()) {
                    List<PMP_OPID_MPI_Rel__c> opidMps = [SELECT Id,Is_Active__c,PMP_RelLastDeactivated__c FROM PMP_OPID_MPI_Rel__c WHERE PMP_One_Partner_ID__c IN:opidsForMpRelationshipDeactivation AND Is_Active__c = TRUE ];
    
                    if (!opidMps.isEmpty()) {for (PMP_OPID_MPI_Rel__c opidmp : opidMps) {opidmp.Is_Active__c = FALSE;opidmp.PMP_RelLastDeactivated__c = System.now(); }update opidMps;
                    }
                }
            
            //finding Associated child account of opid account
            
            if(setOfAccForChildRecordInactivation != null && ! setOfAccForChildRecordInactivation.isEmpty()){
                For(Core_Account_Group_Member__c Cagm: [Select id,name,Core_Inactive_Ind__c,Core_Partner_Account_Id__c,Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c IN: setOfAccForChildRecordInactivation AND Core_Inactive_Ind__c = false]){
                    setOfChildAccId.add(Cagm.Core_Intel_Account_Id__c);  
                }  
            }
            
            //Creating final set to iterate overe aba 
            Set<Id> setofFinalAccid = new Set<Id>();
            if(setOfChildAccId !=null && !setOfChildAccId.isEmpty()){
                setofFinalAccid.addAll(setOfChildAccId);   
            }
            if(setOfAccIdForOwnAbaInactivation !=null && !setOfAccIdForOwnAbaInactivation.isEmpty()){
                setofFinalAccid.addAll(setOfAccIdForOwnAbaInactivation);   
            }    
            
            Set<String> setOfFinalBnft = new Set<String>{System.Label.PRM_Solution_Marketplace_Basic_Access,System.Label.PRM_Solutions_Marketplace_Basic_Profile};
                
                //Inactivating aba as per condition
                if(setofFinalAccid != null && ! setofFinalAccid.isEmpty() && setOfFinalBnft!=null && !setOfFinalBnft.isEmpty()){
                    for(PRM_AccountBenefitAssociation__c abaFinal: [Select id,name,PRM_Status_Nm__c,PRM_Account_Id__c,PRM_Account_Id__r.Recordtypeid,/*PRM_Partner_Benefit_Id__c,*/PRM_Partner_Benefit_Id__r.Name,PRM_Source__c from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c In: setofFinalAccid AND PRM_Status_Nm__c =: System.Label.PRM_Status_Active AND PRM_Partner_Benefit_Id__r.Name IN: setOfFinalBnft]){ //ATHR Fix - TWC729-9556 - JB
                        If(abaFinal.PRM_Partner_Benefit_Id__r.Name == System.Label.PRM_Solution_Marketplace_Basic_Access && setOfChildAccId.contains(abaFinal.PRM_Account_Id__c)){
                            abaFinal.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;abaFinal.PRM_Status_Reason_Txt__c =System.Label.PRM_Aba_Inactive;abaFinal.PRM_Source__c='';
          lstOfAba.add(abaFinal);    
                        }
                        else if(abaFinal.PRM_Partner_Benefit_Id__r.Name == System.Label.PRM_Solutions_Marketplace_Basic_Profile && setOfAccIdForOwnAbaInactivation.contains(abaFinal.PRM_Account_Id__c) && abaFinal.PRM_Account_Id__r.Recordtypeid == OpidAccRecordTypeId){
                            abaFinal.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
                            abaFinal.PRM_Status_Reason_Txt__c =System.Label.PRM_Aba_Inactive;
                            abaFinal.PRM_Source__c='';
                            lstOfAba.add(abaFinal);  
                        }  
                    }  
                }
            
          
            
            if(lstOfAba !=null && !lstOfAba.isEmpty()){
                skipvalidationforMPBenefits=true;
                Database.SaveResult[] results = database.update(lstOfAba,false);
                
                skipvalidationforMPBenefits=false; //set skipvalidationforMPBenefits flag to false after DML
            }   
            
        }catch(Exception e){
            system.debug('error in class PRM_accBenefitAssociationUtility  and in method opidBenefitInactivation :- '+e.getMessage()+' on line no:- '+e.getLineNumber());
        }    
    }
    /* *****************************************************************************************************************************************
    * Method Name  : onManualBenefitInsert
    * Author       : Utkarsh    
    * Date         : 28/07/2022
    * Parameters   : List<PRM_AccountBenefitAssociation__c > lstAccBenefit,Map<Id, PRM_AccountBenefitAssociation__c> abaOldMap 
    * Return       : Void
    * Description  : This method is used to assign entitlement to the child contact of account when benefit assigned manually to the account.
    ****************************************************************************************************************************************** */
    public static void onManualBenefitInsert(List<PRM_AccountBenefitAssociation__c> lstAccBenefit,Map<Id, PRM_AccountBenefitAssociation__c> abaOldMap, boolean assignEntitlement)
    {   
    Set<Id> accId = new Set<Id>(); 
    List<Id> benefitList = new List<Id>();
    List<Id> entitlements = new List<Id>();
    List<PRM_VXEnttlmntMatrix__c> entitlementList;
    List<String> accountBenefitList;
    List<PRM_VXEnttlmntMatrix__c> accountEntitlementList;
    List< PRM_VXEnttlmntMatrix__c> entitlementMatrixlist = new List< PRM_VXEnttlmntMatrix__c>();
    List<PRM_Account_Contact_Relationship__c>  acrRecords= new List<PRM_Account_Contact_Relationship__c>();
    List<PRM_Batch_Entitlement__c> beListTemp = new List<PRM_Batch_Entitlement__c>();
    List<Core_Contact_Entitlement__c> finalCEList = new List<Core_Contact_Entitlement__c>();
    Set<Id> contactRelatedACRList = new Set<Id>();
  Set<Id> accList = new Set<Id>();
    List<PRM_VXEnttlmntMatrix__c> entitlementRec = new List<PRM_VXEnttlmntMatrix__c>();
  //Map<Id,List<Id>> childParAccountMap = new Map<Id,List<Id>>();
    Map<String,List<Id>> benefitMap = new Map<String,List<Id>>();
    Map<Id,List<PRM_VXEnttlmntMatrix__c>> mapEntitlements = new Map<Id,List<PRM_VXEnttlmntMatrix__c>>();
    PRM_AccountBenefitAssociation__c abaOld ;
  Set<Id> childAccId = new Set<Id>();
    Boolean updateCheck = false;
    system.debug('assignEntitlement-->'+assignEntitlement);

        if(!System.isBatch() || assignEntitlement) {
            if(lstAccBenefit != null && ! lstAccBenefit.isEmpty()){
                for(PRM_AccountBenefitAssociation__c aba: lstAccBenefit){
                    if(abaOldMap != null && abaOldMap.size() > 0){
                        abaOld = (PRM_AccountBenefitAssociation__c) abaOldMap.get(aba.id) ;
                    }
                    if((abaOld == null) || (abaOld.PRM_Status_Nm__c != System.Label.PRM_Status_Active && aba.PRM_Status_Nm__c == System.Label.PRM_Status_Active)){
                        benefitList.add(aba.PRM_Partner_Benefit_Id__c);
                        accId.add(aba.PRM_Account_Id__c);
                        benefitMap.put(aba.PRM_Account_Id__c,benefitList);
                        updateCheck = true;
                     }
                }
            }
            if(updateCheck){
        if(accId != null && !accId.isEmpty()){
          for(Account acc :[Select Id,Name,RecordType.Name From Account Where Id IN :accId]){
          if(acc.RecordType.Name == 'Partner Account Group'){
            accList.add(acc.Id);
          }
          else{
            childAccId.add(acc.Id);
          }
          }
        }
        if(accList != null && !accList.isEmpty()){
          for(Core_Account_Group_Member__c pag :[Select id,Core_Intel_Account_Id__c,Core_Partner_Account_Id__c,Core_Inactive_Ind__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c IN :accList AND Core_Inactive_Ind__c = false]){
          if(!childAccId.Contains(pag.Core_Intel_Account_Id__c)){
            childAccId.add(pag.Core_Intel_Account_Id__c);
            }
          }
        }
        if(benefitList != null && !benefitList.isEmpty()){
                        String approvalType = System.Label.PRM_ApprovalType;
                        String query = 'Select id, PRM_Entitlement_Id__c,PRM_Entitlement_Id__r.Name, PRM_Contact_Relationship_Id__c,PRM_Contact_Relationship_Id__r.Name, PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,PRM_IPA_Partner_Role_Nm__c from PRM_VXEnttlmntMatrix__c where PRM_Approval_Type_Nm__c = :approvalType AND PRM_Partner_Benefit_Id__c in :benefitList AND PRM_IsActive_Ind__c = True and recordType.DeveloperName in (\'PRM_EntitlementWithBenefits\', \'PRM_EntitlementWithoutBenefits\')';
                        //String filter = ipaRefresh? 'and PRM_IPARefreshCheck__c = true': 'and PRM_IPARefreshCheck__c = false';
                        
                        entitlementMatrixlist = Database.query(query);//[Select id, PRM_Entitlement_Id__c,PRM_Entitlement_Id__r.Name, PRM_Contact_Relationship_Id__c,PRM_Contact_Relationship_Id__r.Name, PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,PRM_IPA_Partner_Role_Nm__c from PRM_VXEnttlmntMatrix__c where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_Partner_Benefit_Id__c in :benefitList AND PRM_IsActive_Ind__c = True];
        }
        if(lstAccBenefit != null && !lstAccBenefit.IsEmpty()){
           for(PRM_AccountBenefitAssociation__c aba : lstAccBenefit){
            accountBenefitList = new List<String>();
            accountEntitlementList = new List<PRM_VXEnttlmntMatrix__c>();
            accountBenefitList = benefitMap.get(aba.PRM_Account_Id__c);
           }
        }
        if(entitlementMatrixlist != null && !entitlementMatrixlist.IsEmpty()){
          for(PRM_VXEnttlmntMatrix__c em :entitlementMatrixlist){
            if(accountBenefitList.contains(em.PRM_Partner_Benefit_Id__c)){
              accountEntitlementList.add(em);
            }
          }
         }
         if(lstAccBenefit != null && !lstAccBenefit.IsEmpty()){
           for(PRM_AccountBenefitAssociation__c aba : lstAccBenefit){
            if(childAccId.Contains(aba.PRM_Account_Id__c)){
              mapEntitlements.put(aba.PRM_Account_Id__c,accountEntitlementList);
            }
            else{
               if(childAccId != null && !childAccId.IsEmpty()){
                for(Id accountId :childAccId){
                  mapEntitlements.put(accountId,accountEntitlementList);
                }
               }
            }
           }
         }
         if(childAccId != null && ! childAccId.isEmpty()){
          //acrRecords = [Select id,PRM_Account_Id__r.Name,PRM_Relationship_Id__c, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_InActive_Ind__c,PRM_Status_Nm__c,PRM_Partner_Role__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :childAccId AND PRM_InActive_Ind__c!= true AND PRM_Status_Nm__c =:System.Label.PRM_ACR_Status];
            //TWC729-7584 - ApexGuru
             acrRecords = [Select id,PRM_Account_Id__r.Name,PRM_Relationship_Id__c, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_InActive_Ind__c,PRM_Status_Nm__c,PRM_Partner_Role__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :childAccId AND PRM_InActive_Ind__c= false AND PRM_Status_Nm__c =:System.Label.PRM_ACR_Status];

         }
                
         Map<Id, Set<id>> contactIdEntIdMap = new Map<Id, Set<id>>();
         if(acrRecords != null && !acrRecords.IsEmpty()){
          for(PRM_Account_Contact_Relationship__c acr : acrRecords){
            //entitlements = new List<Id>();
            entitlementList = new List<PRM_VXEnttlmntMatrix__c>();
            entitlementList = mapEntitlements.get(acr.PRM_Account_Id__c);
            if(entitlementList != null && !entitlementList.IsEmpty()){
              for(PRM_VXEnttlmntMatrix__c em :entitlementList){
                if(em.PRM_Contact_Relationship_Id__c == acr.PRM_Relationship_Id__c){
                  entitlements.add(em.PRM_Entitlement_Id__c);
                  contactRelatedACRList.add(acr.PRM_Contact_Id__c);
                  entitlementRec.add(em);
                    if(contactIdEntIdMap.containsKey(acr.PRM_Contact_Id__c)){
                      contactIdEntIdMap.get(acr.PRM_Contact_Id__c).add(em.PRM_Entitlement_Id__c);    
                    }else{
                        Set<Id> entSet = new Set<Id>();
                        entSet.add(em.PRM_Entitlement_Id__c);
            contactIdEntIdMap.put(acr.PRM_Contact_Id__c, entSet);                        
                    }
                }
              }
            }
          }
        }
        if((contactRelatedACRList != null && !contactRelatedACRList.IsEmpty()) && (entitlements != null && !entitlements.IsEmpty())){
                        for(PRM_Batch_Entitlement__c batchEntitlements :[Select Id, Name, PRM_Contact_Id__c,PRM_Entitlement_Id__c,PRM_Status_Nm__c,PRM_IsRemove_Ind__c,PRM_Status_Reason_Txt__c From PRM_Batch_Entitlement__c Where PRM_Status_Nm__c = 'New' AND PRM_Contact_Id__c IN:contactRelatedACRList AND PRM_Entitlement_Id__c IN :entitlements])
          {
            batchEntitlements.PRM_Status_Nm__c = 'Success';
                        batchEntitlements.PRM_Status_Reason_Txt__c ='PRM_accBenefitAssociationUtility : Entitlement insertion/removal succeeded';//TWC729-8089 : Adding reason text : NJ
            beListTemp.add(batchEntitlements);
          }
        }
         if((contactRelatedACRList != null && !contactRelatedACRList.IsEmpty()) && (entitlements != null && !entitlements.IsEmpty())){
          finalCEList = [Select Id,Core_Selected__c,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Type__c,Core_Entitlement_Id__r.Name From Core_Contact_Entitlement__c Where /*Core_Selected__c = false AND*/ Core_Contact_Id__c IN :contactRelatedACRList AND Core_Entitlement_Id__c IN :entitlements AND (Core_Type__c =:System.Label.PRM_Entitlement_Type OR Core_Entitlement_Id__r.Name =:System.Label.PRM_PSG)];
        }
        if(finalCEList!= null && !finalCEList.IsEmpty()){
          for(Core_Contact_Entitlement__c ce :finalCEList){
            if(!ce.Core_Selected__c && contactIdEntIdMap.containsKey(ce.Core_Contact_Id__c) && contactIdEntIdMap.get(ce.Core_Contact_Id__c).contains(ce.Core_Entitlement_Id__c)){ // Updating Contact Entitlement status to pending when entitlement is inactive else status will remain same as previous.                
              PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();be.PRM_Contact_Id__c = ce.Core_Contact_Id__c;be.PRM_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
              be.PRM_Status_Nm__c = System.label.PRM_Status_New;be.PRM_Status_Reason_Txt__c = 'PRM_accBenefitAssociationUtility : Activation of Entitlement';//TWC729-8089 : Adding reason text : NJ
        be.PRM_IsRemove_Ind__c = false;
              if(!beListTemp.Contains(be)  && PRM_ProfileResponse.activateInactivateBenefitExecuted == false){beListTemp.add(be);
              }
            }
          }
        }
        else{
          if((entitlementRec != null && !entitlementRec.IsEmpty()) && (acrRecords != null && !acrRecords.IsEmpty())){ // Assigning entitlements based on the benefits get assigned.
            for(PRM_Account_Contact_Relationship__c acr : acrRecords){
              for(integer i=0; i<entitlementRec.size(); i++){
                if((entitlementRec[i].PRM_Contact_Relationship_Id__c == acr.PRM_Relationship_Id__c) && (entitlementRec[i].PRM_IPA_Partner_Role_Nm__c == acr.PRM_Partner_Role__c)){
                  PRM_Batch_Entitlement__c be1 = new PRM_Batch_Entitlement__c();
                  be1.PRM_Contact_Id__c = acr.PRM_Contact_Id__c;
                  be1.PRM_Entitlement_Id__c = entitlementRec[i].PRM_Entitlement_Id__c;
                  be1.PRM_Status_Nm__c = System.label.PRM_Status_New;
                  be1.PRM_Status_Reason_Txt__c = 'PRM_accBenefitAssociationUtility : Activation of Entitlement';//TWC729-8089 : Adding reason text : NJ
                  be1.PRM_IsRemove_Ind__c = false;
                  if(!beListTemp.Contains(be1)  && PRM_ProfileResponse.activateInactivateBenefitExecuted == false){
                    beListTemp.add(be1);
                  }
                }
              }
            }
          }
        }
        //try{
          if(beListTemp != null && !beListTemp.IsEmpty()){
            upsert beListTemp; 
          }
        /*}
        catch(Exception ex){String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
        }*/
      }
    }
  }
//IPA 2.0 TWC 729-7887
  /* *****************************************************************************************************************************************
  * Method Name  : validateMPBenefits
  * Author       : Jambert     
  * Date         : 07/Dec/2021
  * Return       : Void
  * Description  : logic to ensure MP - enhanced benefit,basic profile is not updated manually at 1PID level - TWC729-1570
       The same will be allowed when system is trying to modify it. 
  ****************************************************************************************************************************************** */
    /*      public static void validateMPBenefits(List<PRM_AccountBenefitAssociation__c> lstAccBenefit,Map<Id,PRM_AccountBenefitAssociation__c> oldMap){
        
    String benefitnamesonInsert = System.Label.IPA_Benefit_Validation_onInsert;
    String benefitnamesonUpdate = System.Label.IPA_Benefit_Validation_onUpdate;
    Set<String> benefitNamesInsertSet=new Set<String>();
    Set<String> benefitNamesUpdatetSet=new Set<String>();
    Set<String> locationAccountid = new Set<String>();
    Map<String,PRM_AccountBenefitAssociation__c> locationIDMapper = new Map<String,PRM_AccountBenefitAssociation__c>();
    PRM_AccountBenefitAssociation__c abaOld;
        Set<Id> benefitsRecordIdsSet = new Set<Id>();
    if(lstAccBenefit!= Null && !lstAccBenefit.isEmpty()){
            for(PRM_AccountBenefitAssociation__c aba: lstAccBenefit){
              benefitsRecordIdsSet.add(aba.PRM_Partner_Benefit_Id__c);
            }   
        }
        for(String str: benefitnamesonInsert.split(';')){
      benefitNamesInsertSet.add(str);
    }
    for(String str: benefitnamesonUpdate.split(';')){
      benefitNamesUpdatetSet.add(str);
    }

  
        if(!benefitsRecordIdsSet.isEmpty()){
            Map<Id, PRM_PartnerBenefit__c> benefitRecsMap = new Map<Id, PRM_PartnerBenefit__c>([SELECT Id,Name FROM PRM_PartnerBenefit__c WHERE Id IN: benefitsRecordIdsSet]);
            if((benefitRecsMap !=null && !benefitRecsMap.isEmpty()) && lstAccBenefit!= Null && !lstAccBenefit.isEmpty()){
                for(PRM_AccountBenefitAssociation__c aba: lstAccBenefit){
                    if(Trigger.IsBefore && benefitRecsMap.get(aba.PRM_Partner_Benefit_Id__c).Name == System.Label.PRM_Solution_Marketplace_Basic_Access && aba.PRM_Status_Nm__c== System.Label.PRM_Status_Active){
                        locationIDMapper.put(aba.PRM_Account_Id__c, aba);
                        locationAccountid.add(aba.PRM_Account_Id__c);
                      }
                    if(benefitNamesInsertSet != null && Trigger.IsBefore && Trigger.IsInsert && !PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits && benefitNamesInsertSet.contains(benefitRecsMap.get(aba.PRM_Partner_Benefit_Id__c).Name)){
                        aba.addError(System.Label.PRM_MP_Error_Message_OnInsert);
                    }
                    if(benefitNamesUpdatetSet != null && Trigger.isBefore && Trigger.isUpdate){
                        if(oldMap!=null && oldMap.size()>0) {
                            abaOld = (PRM_AccountBenefitAssociation__c) oldMap.get(aba.id);
                        }
                        if(!PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits && benefitNamesUpdatetSet.contains(benefitRecsMap.get(aba.PRM_Partner_Benefit_Id__c).Name)
                            && (abaOld.PRM_Status_Nm__c != aba.PRM_Status_Nm__c || abaOld.PRM_Partner_Benefit_Id__c != aba.PRM_Partner_Benefit_Id__c)){
                                aba.addError(System.Label.PRM_MP_Error_Message_OnUpdate);
                        }                  
                    }
                }
            }
            //IPA 2.0 simplification TWC729-7887
            /*if(locationAccountid != null && !locationAccountid.isEmpty()){
            preventActivationOfBasicAccess(locationIDMapper,locationAccountid);
                }
        }
    } */
    
/*******************************************************************************************************************************************
* Method Name  : preventActivationOfBasicAccess
* Author       : Riya Singh    
* Date         : 07/July/2024
* Return       : Void
* Description  : prevent activation of Basic access if higher benefit is active 
****************************************************************************************************************************************** */  
 /*  public static void preventActivationOfBasicAccess(Map<String,PRM_AccountBenefitAssociation__c> locationIDMapper,Set<String> locationAccountid){
        Map<String,String> opIDMapper = new Map<String,String>();
        Set<String> setOfopidAccId = new Set<String>();
        String enhancedBenefit = System.Label.PRM_Solutions_Marketplace_Enhanced;
        String basicProfileBenefit = System.Label.PRM_Solutions_Marketplace_Basic_Profile;
        For(Core_Account_Group_Member__c cAgm: [Select id,name,Core_Inactive_Ind__c,Core_Partner_Account_Id__c,Core_Intel_Account_Id__c from Core_Account_Group_Member__c where  Core_Intel_Account_Id__c IN :locationAccountid AND Core_Inactive_Ind__c = false]){
            opIDMapper.put(cAgm.Core_Partner_Account_Id__c,Cagm.Core_Intel_Account_Id__c);
            setOfopidAccId.add(cAgm.Core_Partner_Account_Id__c);  
        } 
        if(setOfopidAccId != null && !setOfopidAccId.isEmpty()){
            For(PRM_AccountBenefitAssociation__c activeOpidBenefits : [Select id,name,PRM_Status_Nm__c,PRM_Account_Id__c,PRM_Account_Id__r.Recordtypeid,PRM_Partner_Benefit_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Source__c from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c In: setOfopidAccId AND PRM_Status_Nm__c =: System.Label.PRM_Status_Active AND (PRM_Partner_Benefit_Id__r.Name =: enhancedBenefit OR PRM_Partner_Benefit_Id__r.Name =: basicProfileBenefit)]){
                PRM_AccountBenefitAssociation__c aba = locationIDMapper.get(opIDMapper.get(activeOpidBenefits.PRM_Account_Id__c));
                aba.addError('Basic access cannot be added if a higher benefit is active on OPID.');
            }
        }
    }*/

       
/*******************************************************************************************************************************************
* Method Name  : updateSuppressEmail
* Author       : Vijay     
* Date         : 012/Dec/2021
* Return       : Void
* Description  : logic to  reset the ‘Suppress Email’  Checkbox  when benefit is inactivated. 
****************************************************************************************************************************************** */   
    public static void updateSuppressEmail(List<PRM_AccountBenefitAssociation__c> abaList,Map<Id,PRM_AccountBenefitAssociation__c> oldMap){
        for(PRM_AccountBenefitAssociation__c aba :abaList){
            PRM_AccountBenefitAssociation__c abaOld ; 
            if(oldMap!=null && !oldMap.isEmpty()) {
                abaOld = (PRM_AccountBenefitAssociation__c) oldMap.get(aba.id) ;
            }
            if(abaOld != null && (abaOld.PRM_Suppress_Email__c==true && abaOld.PRM_Status_Nm__c=='Active' && aba.PRM_Status_Nm__c=='Inactive'))
            {
                aba.PRM_Suppress_Email__c =false;
                //aba.PRM_Status_Reason_Txt__c='';
            }
        }
    }
    
    public static void createTrackerMilestonesForBenefits (List<PRM_AccountBenefitAssociation__c> abaList,Map<Id,PRM_AccountBenefitAssociation__c> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        List<PRM_Tracker__c> trackers = new List<PRM_Tracker__c>();
        Core_CustomMetadataObjectController customMetadata = new Core_CustomMetadataObjectController('PRM_Tracker_steps__mdt');
        if(oldMap==null){
            for (PRM_AccountBenefitAssociation__c abRec: abaList) {
                if ((oldMap == null || abRec.PRM_Status_Nm__c != oldMap.get(abRec.Id).PRM_Status_Nm__c)){
                  
                    if(abRec.PRM_Account_RT__c == 'Core_Partner_Account_Group' && !accountIds.contains(abRec.PRM_Account_Id__c)) {
                        accountIds.add(abRec.PRM_Account_Id__c);
                        trackers.add(PRM_IPA_Utility.createTrackerInstance('OPID Updates 1PID',
                        'BF_Ins_1PID',
                        null,
                        null,
                        abRec.PRM_Account_Id__c,
                        abRec.PRM_Account_Id__c,
                        '',
                        '',
                        true,
                        '',
                        '',
                        String.valueOf(customMetadata.getInstance('BF_Ins_1PID').get('PRM_Milestone_Display_Name__c'))
                        ));
                    }
                    if(abRec.PRM_Account_RT__c == 'Mastered_Account' && !accountIds.contains(abRec.PRM_Account_Id__c)){
                        accountIds.add(abRec.PRM_Account_Id__c);
                        trackers.add(PRM_IPA_Utility.createTrackerInstance('OPID Updates',
                        'BF_Ins_LOC',
                        null,
                        abRec.PRM_Account_Id__c,
                        abRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,
                        abRec.PRM_Account_Id__c,
                        '',
                        '',
                        true,
                        '',
                        '',
                        String.valueOf(customMetadata.getInstance('BF_Ins_LOC').get('PRM_Milestone_Display_Name__c'))
                        ));
                    }
                }
            }
    
        }
        else if(oldMap!=null){
            for (PRM_AccountBenefitAssociation__c abRec: abaList) {
                if ((oldMap == null || abRec.PRM_Status_Nm__c != oldMap.get(abRec.Id).PRM_Status_Nm__c)){
                  
                    if(abRec.PRM_Account_RT__c == 'Core_Partner_Account_Group' && !accountIds.contains(abRec.PRM_Account_Id__c)) {
                        accountIds.add(abRec.PRM_Account_Id__c);
                        trackers.add(PRM_IPA_Utility.createTrackerInstance('OPID Updates 1PID','BF_UPD_1PID',null,null,abRec.PRM_Account_Id__c,abRec.PRM_Account_Id__c,'','', true, '', '',String.valueOf(customMetadata.getInstance('BF_UPD_1PID').get('PRM_Milestone_Display_Name__c'))));
                    }
                    if(abRec.PRM_Account_RT__c == 'Mastered_Account' && !accountIds.contains(abRec.PRM_Account_Id__c)){
                        accountIds.add(abRec.PRM_Account_Id__c);
                        trackers.add(PRM_IPA_Utility.createTrackerInstance('OPID Updates',
                        'BF_UPD_LOC',
                        null,
                        abRec.PRM_Account_Id__c,
                        abRec.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,
                        abRec.PRM_Account_Id__c,
                        '',
                        '',
                        true,
                        '',
                        '',
                        'LOC Benefits updated'
                        ));
                    }
                }
            }
    
        }
        
        if (!trackers.isEmpty()) {
            insert trackers;
        }
    }    
    public static List<PRM_AccountBenefitAssociation__c> getABAList(List<PRM_AccountBenefitAssociation__c> abaList){
      return  ([ select Id,Name,PRM_Suppress_Email__c,PRM_Status_Nm__c,PRM_Partner_Benefit_Id__c,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,PRM_Account_RT__c,PRM_Account_Id__r.Core_User_Defined_Website__c,PRM_Partner_Benefit_Id__r.Name,
        PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,PRM_Account_Id__c,PRM_Account_Id__r.Name from PRM_AccountBenefitAssociation__c where Id IN : abaList ]);

    }
}