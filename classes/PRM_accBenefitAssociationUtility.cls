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
    public static boolean skipvalidationforMPBenefits = false;
    public static void duplicateRecordCheck(List<PRM_AccountBenefitAssociation__c > lstAccBenefit)
    {
        try
        {
            List<String> uniqstr = new List<String>();
            List<Id> idslist = new List<Id>();
            Set<Id> accid = new Set<Id>();
            Map<String,Id> uniqueMap = new Map<String,Id>();
            List<PRM_AccountChannelMembership__c> acmember = new List<PRM_AccountChannelMembership__c>();
            Map<String,Set<String>> duplicateCheckMap = new Map<String,Set<String>>();
            Set<String> tempSet1234 = new Set<String>();
            system.debug('lstofAccountBenefit' +lstAccBenefit);
            // Fetching field values
            if(lstAccBenefit!= Null && !lstAccBenefit.isEmpty() && lstAccBenefit.size()>0){
                for(PRM_AccountBenefitAssociation__c aba: lstAccBenefit){
                    system.debug('aba record-Account Id' +aba.PRM_Account_Id__c);
                    uniqstr.add(aba.PRM_Account_Partner_Benefit_Key__c);
                    idslist.add(aba.id);
                    accid.add(aba.PRM_Account_Id__c);
                    system.debug('accIdSet' +accId);
                    if(!Trigger.IsUpdate)
                    {
                        if(!tempSet1234.contains(aba.PRM_Account_Partner_Benefit_Key__c))
                        {
                            tempSet1234.add(aba.PRM_Account_Partner_Benefit_Key__c);
                        }
                        else{aba.addError(System.Label.PRM_ABA_Error3);
                             System.debug('error display');
                            }
                    }   
                }
            }
            if(accid!= Null && !accid.isEmpty()){
                //Checking for existing ABA records
                for(PRM_AccountBenefitAssociation__c aba :[SELECT Id, PRM_Account_Id__c, PRM_Account_Partner_Benefit_Key__c FROM PRM_AccountBenefitAssociation__c where PRM_Account_Id__c IN :accid]){
                    if(duplicateCheckMap.keySet().contains(aba.PRM_Account_Id__c)) 
                    {   Set<String> tempSet1 = duplicateCheckMap.get(aba.PRM_Account_Id__c);
                     tempSet1.add(aba.PRM_Account_Partner_Benefit_Key__c);
                     duplicateCheckMap.put(aba.PRM_Account_Id__c,tempSet1);
                    }
                    else{
                        Set<String> tempSet = new Set<String>();
                        tempSet.add(aba.PRM_Account_Partner_Benefit_Key__c);
                        duplicateCheckMap.put(aba.PRM_Account_Id__c,tempSet);
                    }
                } }
            List<PRM_AccountBenefitAssociation__c> finalList = new List<PRM_AccountBenefitAssociation__c>();
            PRM_AccountBenefitAssociation__c  abc;
            //Throwing error message if duplicate ABA records detected.
            for(PRM_AccountBenefitAssociation__c abaDuplicate:lstAccBenefit){
                if((abaDuplicate.id) !=  null ){ 
                    System.debug('came in if 1');
                    abc =  (PRM_AccountBenefitAssociation__c) trigger.oldMap.get(abaDuplicate.id) ;
                }
                if(trigger.isInsert || (trigger.isUpdate && abc.PRM_Partner_Benefit_Id__c != abaDuplicate.PRM_Partner_Benefit_Id__c ))
                {
                    if(duplicateCheckMap!= null && !duplicateCheckMap.isEmpty() && duplicateCheckMap.get(abaDuplicate.PRM_Account_Id__c) != null){
                        if(! duplicateCheckMap.get(abaDuplicate.PRM_Account_Id__c).contains(abaDuplicate.PRM_Account_Partner_Benefit_Key__c) ) {finalList.add(abaDuplicate);
                                                                                                                                               }
                        else{abaDuplicate.addError(System.Label.PRM_ABA_Error3);
                             System.debug('error display');
                            }
                    }
                }
            } 
        }catch(Exception ex){String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                             System.debug('##### Exception: ' + exceptionMessage);   
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
        system.debug('Inside benefitassignmentcheck :- '+lstAccBenefit);
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
        Set<String> prereqBenefitList = new Set<String>();
        PRM_BatchCustomSetting__c batchCustomSetting;
        Map<String,String> pbMap = new Map<String,String>();
        List<String> mpPartnerBenefits = new List<String>();
        List<String> mpbenefits = new List<String>();
        Set<Id> InactivebenefitIdSet = new Set<Id>();
        Map<String,String> MpBenefitMap = new Map<String,String>();
        
        for(PRM_AccountBenefitAssociation__c aba :lstAccBenefit)
        {
            //Added OR condition to allow MP basic profile benefit with Inactive status - When OPID with no benefits trying to associated with 
            //MPI with enhanced benefit – Insert basic profile with Inactive status and enhanced benefit with Active Status
            if(aba.PRM_Status_Nm__c == 'Active' || PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits == true){
                accountSet.add(aba.PRM_Account_Id__c);
                benefitIdSet.add(aba.PRM_Partner_Benefit_Id__c);              
            }
            InactivebenefitIdSet.add(aba.PRM_Partner_Benefit_Id__c);
        }
        for(PRM_PartnerBenefit__c bpbenefit :[Select Id, Name from PRM_PartnerBenefit__c Where Id IN :InactivebenefitIdSet]){
            MpBenefitMap.put(bpbenefit.Name,bpbenefit.Id);
        }
        System.debug('benefitIdSet-->'+benefitIdSet);
        System.debug('accountSet-->'+accountSet);
        
        if(accountSet != null && !accountSet.isEmpty()){
            for(Account acc :[Select Id,Core_IPA_One_Partner_Id__c, Name,RecordType.DeveloperName From Account Where Id IN :accountSet]){
                mapAccIdRecordType.put(acc.id, acc.RecordType.DeveloperName);                
            }
        }
        
        System.debug('mapAccIdRecordType -->'+mapAccIdRecordType);
        
        
        Set<String> bnftcodesSet = new set<String>{'BFTMKTPLBC','BFTMKTPLED','BNFTSMBA'};
            if(accountSet != null && !accountSet.isEmpty()){
                for(PRM_AccountBenefitAssociation__c aba :[Select Id, Name,PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Benefit_Id__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c From PRM_AccountBenefitAssociation__c Where PRM_Account_Id__c IN :accountSet]){                    
                    prereqBenefitList.add(aba.PRM_Partner_Benefit_Id__r.Name);
                    system.debug('prereqBenefitList for inside--> '+ prereqBenefitList);
                }
            }
        
        System.debug('prereqBenefitList -->'+prereqBenefitList);
        
        
        if(benefitIdSet != null && !benefitIdSet.isEmpty()){
            for(PRM_PartnerBenefit__c pb :[Select Id, Name, PRM_Account_Type_Nm__c From PRM_PartnerBenefit__c Where Id IN :benefitIdSet AND PRM_Account_Type_Nm__c != null]){
                mapBenefitAccType.put(pb.Id, pb.PRM_Account_Type_Nm__c);
            }
        }
        System.debug('mapAccIdRecordType-->'+mapAccIdRecordType);
        System.debug('mapBenefitAccType-->'+mapBenefitAccType);
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
        
        System.debug('setOfSpeciality :- '+setOfSpeciality);
        System.debug('mapOfAccountIdAndSpeciality :- '+mapOfAccountIdAndSpeciality);
        //Fetching benefit group from speciality. 
        if(setOfSpeciality !=null && !setOfSpeciality.isEmpty()){
            for(PRM_Specialty_Benefit_Group_Association__c sbgRecord: [select id,name,PRM_Specialty_Id__c,PRM_Benefit_Group_Id__c,PRM_Specialty_Id__r.name from PRM_Specialty_Benefit_Group_Association__c where PRM_Specialty_Id__r.name IN: setOfSpeciality AND PRM_InActive_Ind__c = false AND PRM_Benefit_Group_Id__c != null]){
                if(mapOfspecialityAndListOgBenifitGroup.containskey(sbgRecord.PRM_Specialty_Id__r.name)){
                    Set<string> setOfbenifitGroup = mapOfspecialityAndListOgBenifitGroup.get(sbgRecord.PRM_Specialty_Id__r.name);
                    setOfbenifitGroup.add(sbgRecord.PRM_Benefit_Group_Id__c);
                    mapOfspecialityAndListOgBenifitGroup.put(sbgRecord.PRM_Specialty_Id__r.name,setOfbenifitGroup);
                    // system.debug('mapOfspecialityAndListOgBenifitGroup if-->'+mapOfspecialityAndListOgBenifitGroup);
                }
                else{
                    mapOfspecialityAndListOgBenifitGroup.put(sbgRecord.PRM_Specialty_Id__r.name, new Set<string> {sbgRecord.PRM_Benefit_Group_Id__c} ); 
                    // system.debug('mapOfspecialityAndListOgBenifitGroup-->'+mapOfspecialityAndListOgBenifitGroup);                   
                }
                benifitGroup.add(sbgRecord.PRM_Benefit_Group_Id__c);
                // system.debug('benifitGroup-->'+benifitGroup);
            }     
        }
        System.debug('mapOfspecialityAndListOgBenifitGroup :-'+mapOfspecialityAndListOgBenifitGroup);
        System.debug('benifitGroup :-'+benifitGroup);
        
        //Fetching benefits from benefit group.
        //Added Check of PRM_Status_Nm__c in BGBA Query as part of US : US594299
        if(benifitGroup !=null && !benifitGroup.isEmpty()){
            for(PRM_Benefit_Group_Benefit_Association__c bgbRecord: [select id,name,PRM_Benefit_Id__c,PRM_Benefit_Group_Id__c from PRM_Benefit_Group_Benefit_Association__c where PRM_Benefit_Group_Id__c In:benifitGroup AND PRM_InActive_Ind__c = false AND PRM_Benefit_Id__c != null AND PRM_Status_Nm__c ='Live']){
                if(mapOfBenifitGroupToBenifit.containskey(bgbRecord.PRM_Benefit_Group_Id__c)){
                    Set<String> setOfBenifitofBG = mapOfBenifitGroupToBenifit.get(bgbRecord.PRM_Benefit_Group_Id__c);
                    setOfBenifitofBG.add(bgbRecord.PRM_Benefit_Id__c);
                    mapOfBenifitGroupToBenifit.put(bgbRecord.PRM_Benefit_Group_Id__c,setOfBenifitofBG);
                } 
                else{
                    mapOfBenifitGroupToBenifit.put(bgbRecord.PRM_Benefit_Group_Id__c, new Set<string> {bgbRecord.PRM_Benefit_Id__c});   
                }
            }   
        }
        System.debug('mapOfBenifitGroupToBenifit :-'+mapOfBenifitGroupToBenifit);
        // Associating speciality with benefits.
        if(mapOfspecialityAndListOgBenifitGroup.keyset() != null && !mapOfspecialityAndListOgBenifitGroup.keyset().isEmpty()){
            for(string str: mapOfspecialityAndListOgBenifitGroup.keyset()){
                Set<string> listOfBenifit = new Set<string>();
                for(string lstOfBG: mapOfspecialityAndListOgBenifitGroup.get(str)){
                    if(lstOfBG != null){
                        if(mapOfBenifitGroupToBenifit.containskey(lstOfBG)){
                            listOfBenifit.addall(mapOfBenifitGroupToBenifit.get(lstOfBG));  
                        }   
                    }
                }
                if(listOfBenifit != null && !listOfBenifit.IsEmpty()){
                    mapOfSpeacailityIdAndBenifitId.put(str,listOfBenifit);
                }
            }  
        }
        System.debug('mapOfSpeacailityIdAndBenifitId :-'+mapOfSpeacailityIdAndBenifitId);
        // Associating account with benefits.
        if(mapOfAccountIdAndSpeciality.keyset() !=null && !mapOfAccountIdAndSpeciality.keyset().isEmpty()){
            for (string str: mapOfAccountIdAndSpeciality.keyset()){
                Set<string> listOfSpecialityForObj = new Set<string>();
                //Set<String> strObj;
                //strObj = mapOfAccountIdAndSpeciality.get(str);              
                for(string strObj: mapOfAccountIdAndSpeciality.get(str)){
                    if(strObj !=null){
                        if(mapOfSpeacailityIdAndBenifitId.containskey(strObj)){
                            listOfSpecialityForObj.addall(mapOfSpeacailityIdAndBenifitId.get(strObj));   
                        }   
                    } 
                }
                if(listOfSpecialityForObj != null && !listOfSpecialityForObj.IsEmpty()){
                    mapOfAccountAndBenifit.put(str,listOfSpecialityForObj);
                }
            }    
        }
        System.debug('mapOfAccountAndBenifit :-'+mapOfAccountAndBenifit);
        vebm = [Select id, PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name, PRM_Channel_Program_Level_Id__c,PRM_Covered_Account_Ind__c,PRM_Approval_Type_Nm__c, PRM_Partner_Benefit_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Role_Nm__c from PRM_VXBnftMatrix__c where PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_IsActive_Ind__c = True AND PRM_Partner_Role_Nm__c != null]; 
        /* UTKARSH - DE69552 and US596757 - 27-02-2020 - As discussed with Lakshman , removed 'Partner Type' from 'Benefit Matrix' query as we don’t need to consider ‘Partner Type’field value on Benefit Matrix*/
        
        System.debug('vebm-->'+vebm);
        
        List<PRM_AccountChannelMembership__c> acmList = [SELECT Id, PRM_Account_Id__c,PRM_Account_Id__r.name, PRM_Channel_Program_Id__c,PRM_Channel_Program_Id__r.name,PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.name,PRM_Status_Nm__c,PRM_Partner_Role__c FROM PRM_AccountChannelMembership__c where PRM_Account_Id__c IN: accountSet AND PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_Status_Nm__c =:System.Label.PRM_Status];// 
        if(acmList != null && !acmList.IsEmpty()){
            for(PRM_AccountChannelMembership__c acm :acmList){ // Comparing ACM and benefit matrix field values to assign appropriate benefits.
                System.debug('acm-->'+acm);
                if(vebm != null && !vebm.IsEmpty()){
                    for(PRM_VXBnftMatrix__c bm :vebm){
                        Set<Id> benefitList = new Set<Id>();
                        if(accBenefitMap.get(acm.PRM_Account_Id__c)!= null && !accBenefitMap.get(acm.PRM_Account_Id__c).isEmpty()){
                            benefitList = accBenefitMap.get(acm.PRM_Account_Id__c);
                        }
                        String allApplicableTierNames = getApplicableBenefitTiers(acm.PRM_Channel_Program_Level_Id__r.Name);
                        if((allApplicableTierNames.contains(bm.PRM_Channel_Program_Level_Id__r.Name)) && (bm.PRM_IsActive_Ind__c = True) && (acm.PRM_Partner_Role__c == bm.PRM_Partner_Role_Nm__c)){
                            benefitList.add(bm.PRM_Partner_Benefit_Id__c);
                            System.debug('benefitList-->'+benefitList);
                            accBenefitMap.put(acm.PRM_Account_Id__c,benefitList);
                        }
                    }
                    System.debug('accBenefitMap-->'+accBenefitMap);
                }                   
            }
        }
        
        /*US860593 -Utkarsh - Start - Bypass benefit matrix configuration check if solution marketplace enhanced need to assign*/
        batchCustomSetting = [Select Id, PRM_MP_Benefits__c From PRM_BatchCustomSetting__c Where Name =:System.Label.PRM_BatchValues];
        if(batchCustomSetting !=null){
            mpPartnerBenefits = batchCustomSetting.PRM_MP_Benefits__c.split(';');
        }
        System.debug('mpPartnerBenefits-->'+mpPartnerBenefits);
        for(PRM_PartnerBenefit__c pb :[Select Id, Name from PRM_PartnerBenefit__c Where Name IN :mpPartnerBenefits]){
            pbMap.put(pb.Name,pb.Id);
        }
        for(String mpb :mpPartnerBenefits){
            mpbenefits.add(pbMap.get(mpb));
        }
        System.debug('mpbenefits-->'+mpbenefits);
        /*US860593-END*/
        //Throwing error message if inappropriate benefits assigned.
        for(PRM_AccountBenefitAssociation__c aba :lstAccBenefit){
            Set<Id> applicableBenefits = new Set<Id>();
            Set<string> allowedBenifitForSpeciality = new Set<string>();
            String sourceValue;
            String benefitAccountType;
            String accountRecordType;
            
            /*US763723 -Utkarsh - Start - Update status reason field blank when ABA is activated again*/
            if(aba.PRM_Status_Nm__c == System.Label.PRM_Status_Active && aba.PRM_Status_Reason_Txt__c != null){aba.PRM_Status_Reason_Txt__c = '';
                                                                                                              }
            /*US763723 - END*/
            if(trigger.isInsert && acmList.IsEmpty()){aba.addError(System.Label.PRM_ABA_Error1);
                                                     }
            if(trigger.isUpdate && acmList.IsEmpty())
            {
                PRM_AccountBenefitAssociation__c oldABA = abaOldMap.get(aba.Id);
                System.debug('oldABA.PRM_Status_Nm__c-->'+oldABA.PRM_Status_Nm__c);
                if(oldABA != null && oldABA.PRM_Status_Nm__c == 'Inactive' && aba.PRM_Status_Nm__c == System.Label.PRM_Status_Active){aba.addError(System.Label.PRM_ABA_Error1);
                                                                                                                                     }
            }
            if(accBenefitMap != null && !accBenefitMap.IsEmpty() && accBenefitMap.containskey(aba.PRM_Account_Id__c)){
                applicableBenefits = accBenefitMap.get(aba.PRM_Account_Id__c);
                System.debug('applicableBenefits :-'+applicableBenefits);
            }
            if(mapOfAccountAndBenifit != null && !mapOfAccountAndBenifit.IsEmpty() && mapOfAccountAndBenifit.containskey(aba.PRM_Account_Id__c)){
                allowedBenifitForSpeciality = mapOfAccountAndBenifit.get(aba.PRM_Account_Id__c); // Set of specialty benefits.
                System.debug('allowedBenifitForSpeciality :-'+allowedBenifitForSpeciality);
            }
            if(!string.ISBLANK(aba.PRM_Partner_Benefit_Id__c)){
                benefitAccountType = mapBenefitAccType.get(aba.PRM_Partner_Benefit_Id__c);
                accountRecordType = mapAccIdRecordType.get(aba.PRM_Account_Id__c);
                //US632963 - Added account recordtype check with partner benefit account type check.
                if((benefitAccountType != accountRecordType && benefitAccountType != System.Label.PRM_PB_AccType) && aba.PRM_Status_Nm__c == System.Label.PRM_Status_Active){ System.debug('Error from here 1');aba.addError(System.Label.PRM_ABA_Error2);
                                                                                                                                                                            }
                else{
                    if(mpbenefits.contains(aba.PRM_Partner_Benefit_Id__c)) {
                        if(!prereqBenefitList.contains(System.Label.PRM_Solutions_Marketplace_Basic_Profile) && aba.PRM_Status_Nm__c == System.Label.PRM_Status_Active) {
                            System.debug('Error from here 2');
                            aba.addError(System.Label.PRM_ABA_Error2);
                        }
                    }
                    else if(applicableBenefits!=null && !applicableBenefits.isEmpty() && !applicableBenefits.contains(aba.PRM_Partner_Benefit_Id__c) && allowedBenifitForSpeciality!=null /*&& !allowedBenifitForSpeciality.isEmpty()*/&& !allowedBenifitForSpeciality.contains(aba.PRM_Partner_Benefit_Id__c) && aba.PRM_Status_Nm__c == System.Label.PRM_Status_Active){System.debug('Error from here 3');aba.addError(System.Label.PRM_ABA_Error2);
                                                                                                                                                                                                                                                                                                                                                                      System.debug('error throw because benefit mismatch');
                                                                                                                                                                                                                                                                                                                                                                      System.debug('mpbenefits.contains(aba.PRM_Partner_Benefit_Id__c)-->'+mpbenefits.contains(aba.PRM_Partner_Benefit_Id__c));
                                                                                                                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                                                                                                     }
                }
                /*Start - US566988 - As part of the story need to check the source of benefits assignment*/
                if(applicableBenefits.contains(aba.PRM_Partner_Benefit_Id__c)){ //source of benefit is benefit matrix.
                    sourceValue = System.Label.PRM_Source_BenefitMatrix;
                }
                if(allowedBenifitForSpeciality.contains(aba.PRM_Partner_Benefit_Id__c)){ //source of benefit is specialty.
                    sourceValue = System.Label.PRM_Source_Specialty;
                }
                if((applicableBenefits.contains(aba.PRM_Partner_Benefit_Id__c)) && (allowedBenifitForSpeciality.contains(aba.PRM_Partner_Benefit_Id__c))){ //Benefit is available from both the place, benefit matrix awa specialty.
                    sourceValue = System.Label.PRM_Source_Matrix_Specialty;
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
            if(tierName == Label.PRM_Tier_Titanium){                
            	allApplicableTierNames = Label.PRM_Tier_Titanium + ',' + label.PRM_Tier_Gold + ',' + label.PRM_Program_Level_Member;           
            }else if(tierName == Label.PRM_Tier_Gold){
                allApplicableTierNames = label.PRM_Tier_Gold + ',' + label.PRM_Program_Level_Member;             
            }else{
                allApplicableTierNames = label.PRM_Program_Level_Member;                                                  
            }
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
                system.debug('contactList-->'+contactList);
            }
        }
        //Fetching entitlment id based on inactive benefit id.
        if(benefitList != null && !benefitList.IsEmpty()){
            for(PRM_VXEnttlmntMatrix__c em : [Select Id, Name,PRM_Entitlement_Id__c,PRM_Partner_Benefit_Id__c From PRM_VXEnttlmntMatrix__c Where PRM_Partner_Benefit_Id__c IN :benefitList]){                
                entitlementList.add(em.PRM_Entitlement_Id__c);
            }
        }
        system.debug('entitlementList-->'+entitlementList);
        //Creating batch entitlement record with contact and entitlement id.
        if(entitlementList != null && !entitlementList.IsEmpty()){
            for(Core_Contact_Entitlement__c ce :[Select Id,Core_Contact_Id__c,Name,Core_Entitlement_Id__c,Core_Status__c,Core_Data_Loaded__c,Core_DontNotify__c,Core_Selected__c From Core_Contact_Entitlement__c Where Core_Entitlement_Id__c IN :entitlementList AND Core_Contact_Id__c IN :contactList AND Core_Selected__c = true]){
                PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
                be.PRM_Contact_Id__c = ce.Core_Contact_Id__c;
                be.PRM_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                be.PRM_Status_Nm__c = System.label.PRM_Status_New;
                be.PRM_IsRemove_Ind__c = true;
                if(!beList.Contains(be)){
                    beList.add(be);
                }
            }
        }
        system.debug('beList-->'+beList);
        if(beList != null && !beList.IsEmpty()){
            try{insert beList; 
                system.debug('beList after insert-->'+beList);
               }
            catch(Exception ex){String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                               }
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
        System.debug('Entered onStatusInactive Method '+' Account benefits'+lstAccBenefit);
        
        List<Id> benefitList = new List<Id>();
        Set<Id> entitlementList = new Set<Id>();
        List<PRM_Batch_Entitlement__c> beList = new List<PRM_Batch_Entitlement__c>();
        Set<Id> accId = new Set<Id>();
        Set<Id> contactList = new Set<Id>();
        PRM_AccountBenefitAssociation__c abaOld ;
        List<Id> intelAccountIds = new List<Id>();
        
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
        
        System.debug('Benifit List=====>'+benefitList);
        System.debug('Account Ids List List=====>'+accId);
        
        //Fetching all the Intel Account Ids from OPID Account
        if(accId != null && !accId.isEmpty()){
            for(Core_Account_Group_Member__c eachAcc : [Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c in :accId]){
                
                intelAccountIds.add(eachAcc.Core_Intel_Account_Id__c);
            }
        }
        
        //Fetching all the Contacts associated with Intel Account Ids(Account Level)
        if(accId != null && !accId.IsEmpty()){
            for(PRM_Account_Contact_Relationship__c acrList : [Select id, name, PRM_Account_Id__c, PRM_Contact_Id__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c IN :intelAccountIds]){
                contactList.add(acrList.PRM_Contact_Id__c);
            }
            system.debug('Contact List=====>'+contactList);
        }
        //Fetching entitlment id based on inactive benefit id.
        if(benefitList != null && !benefitList.IsEmpty()){
            System.debug('u r on line no 313');    
            for(PRM_VXEnttlmntMatrix__c em : [Select Id, Name,PRM_Entitlement_Id__c,PRM_Partner_Benefit_Id__c From PRM_VXEnttlmntMatrix__c Where PRM_Partner_Benefit_Id__c IN :benefitList]){                
                entitlementList.add(em.PRM_Entitlement_Id__c);
            }
        }
        system.debug('Entitlement List=====>-->'+entitlementList);
        
        //Creating batch entitlement record with contact and entitlement id.
        if(entitlementList != null && !entitlementList.IsEmpty()){
            for(Core_Contact_Entitlement__c ce :[Select Id,Core_Contact_Id__c,Name,Core_Entitlement_Id__c,Core_Status__c,Core_Data_Loaded__c,Core_DontNotify__c,Core_Selected__c From Core_Contact_Entitlement__c Where Core_Entitlement_Id__c IN :entitlementList AND Core_Contact_Id__c IN :contactList AND Core_Selected__c = true]){
                
                PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
                be.PRM_Contact_Id__c = ce.Core_Contact_Id__c;
                be.PRM_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                be.PRM_Status_Nm__c = System.label.PRM_Status_New;
                be.PRM_IsRemove_Ind__c = true;
                if(!beList.Contains(be)){beList.add(be);
                                        }
                
            }
            
        }
        system.debug('beList-->'+beList);
        if(beList != null && !beList.IsEmpty()){
            try{insert beList; 
                system.debug('Benifit List After Insert====>'+beList);
               }
            catch(Exception ex){String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                               }
        }
        
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
        
        Set<Id> acctId = new Set<Id>();
        Set<Id> bnftIds = new Set<Id>();
        String recordTypeName = 'Partner Account Group';
        Set<id> parentIds = new set<id>();
        List<PRM_AccountBenefitAssociation__c> updateChildABA = new List<PRM_AccountBenefitAssociation__c>();
        List<Core_Account_Group_Member__c> lstChildAct = new List<Core_Account_Group_Member__c>();
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
        System.debug('Account ids List====>'+acctId );
        System.debug('Benifit ids======>'+bnftIds );
        //Fetching ABA records for OPID accounts only.
        if(acctId != null && !acctId.isEmpty()){
            abaList = [select PRM_Partner_Benefit_Id__c, PRM_Status_Nm__c,  PRM_Account_Id__c from PRM_AccountBenefitAssociation__c where PRM_Account_Id__r.id in :acctId and PRM_Account_Id__r.RecordType.Name =:recordTypeName ];
        }
        System.debug('ABA List====>'+abaList );
        
        //Fetching all the OPID Accounts
        if(abaList != null && !abaList.isEmpty()){
            for(PRM_AccountBenefitAssociation__c ids : abaList){
                parentIds.add(ids.PRM_Account_Id__c);
            }
        }
        
        System.debug('Parent Account Ids=====>'+parentIds);
        //fetching Intel account ids associated with OPID Account
        if(parentIds != null && !parentIds.isEmpty()){
            for(Core_Account_Group_Member__c eachAcc : [Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c in :parentIds]){
                
                actChildList.add(eachAcc.Core_Intel_Account_Id__c);
            }
        }
        System.debug('Intel Account Ids'+actChildList);
        
        //Fetching all the ABA records of Intel Accounts
        if(actChildList != null && !actChildList.isEmpty() && bnftIds != null && !bnftIds.isEmpty()){
            lstChildABA = [select id, PRM_Status_Reason_Txt__c,name,PRM_Partner_Benefit_Id__c,PRM_Account_Id__c,PRM_Status_Nm__c from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c in :actChildList and PRM_Partner_Benefit_Id__c in :bnftIds];
            System.debug(' List '+lstChildABA+ 'Size '+lstChildABA.size());
        }
        
        //Updating the Status of Benifit to Inactive and the updating the Status reason for inactivation of Benifit
        if(abaList != null && !abaList.isEmpty()){
            for(PRM_AccountBenefitAssociation__c aba : lstChildABA){
                if(bnftIds.contains(aba.PRM_Partner_Benefit_Id__c)){aba.PRM_Status_Nm__c = System.label.PRM_Status_Inactive;
                                                                    aba.PRM_Status_Reason_Txt__c= System.label.PRM_Benifit_Reason;
                                                                    updateChildABA.add(aba);
                                                                   }
            }
        }
        
        try{
            upsert updateChildABA;
            System.debug('Child record Updated');
        }catch(Exception ex){
            System.debug('Message '+ex.getMessage());
            System.debug(ex.getStackTraceString());
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
        
        // System.debug('Inside opidBenefitInactivation'); 
        Set<Id> setOfAccountId = new Set<Id>();
        Set<Id> setOfAccForChildRecordInactivation = new Set<Id>();
        Set<Id> setOfAccIdForOwnAbaInactivation = new Set<Id>();
        Set<Id> setOfChildAccId = new Set<Id>();
        List<PRM_AccountBenefitAssociation__c> lstOfAba = New List<PRM_AccountBenefitAssociation__c>();
        
        try{
            
            Id OpidAccRecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
            // System.debug('OpidAccRecordTypeId :- '+OpidAccRecordTypeId);
            
            Set<String> setOfBnfts  = new Set<String>{System.Label.PRM_Solution_Marketplace_Basic_Access,System.Label.PRM_Solutions_Marketplace_Basic_Profile,System.Label.PRM_Solutions_Marketplace_Enhanced};
                
                //Iterating aba record to fetch accid for various operation
                if(lstAccBenefit != null && ! lstAccBenefit.isEmpty()){
                    for(PRM_AccountBenefitAssociation__c aba: [Select id,name,PRM_Status_Nm__c,PRM_Account_Id__c,PRM_Partner_Benefit_Id__c,PRM_Partner_Benefit_Id__r.Name from PRM_AccountBenefitAssociation__c where Id IN: lstAccBenefit AND PRM_Account_Id__r.Recordtypeid =: OpidAccRecordTypeId AND PRM_Status_Nm__c =: System.Label.PRM_Status_Active AND PRM_Partner_Benefit_Id__r.Name IN: setOfBnfts]){
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
                }
            
            System.debug('setOfAccountId :- '+setOfAccountId);
            System.debug('setOfAccForChildRecordInactivation :- '+setOfAccForChildRecordInactivation);
            System.debug('setOfAccIdForOwnAbaInactivation :- '+setOfAccIdForOwnAbaInactivation);
            
            //finding Associated child account of opid account
            
            if(setOfAccForChildRecordInactivation != null && ! setOfAccForChildRecordInactivation.isEmpty()){
                For(Core_Account_Group_Member__c Cagm: [Select id,name,Core_Inactive_Ind__c,Core_Partner_Account_Id__c,Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c IN: setOfAccForChildRecordInactivation AND Core_Inactive_Ind__c = false]){
                    setOfChildAccId.add(Cagm.Core_Intel_Account_Id__c);  
                }  
            }
            
            System.debug('setOfChildAccId :- '+setOfChildAccId);
            
            //Creating final set to iterate overe aba 
            Set<Id> setofFinalAccid = new Set<Id>();
            if(setOfChildAccId !=null && !setOfChildAccId.isEmpty()){
                setofFinalAccid.addAll(setOfChildAccId);   
            }
            if(setOfAccIdForOwnAbaInactivation !=null && !setOfAccIdForOwnAbaInactivation.isEmpty()){
                setofFinalAccid.addAll(setOfAccIdForOwnAbaInactivation);   
            }    
            
            System.debug('setofFinalAccid :- '+setofFinalAccid);
            
            Set<String> setOfFinalBnft = new Set<String>{System.Label.PRM_Solution_Marketplace_Basic_Access,System.Label.PRM_Solutions_Marketplace_Basic_Profile};
                
                //Inactivating aba as per condition
                if(setofFinalAccid != null && ! setofFinalAccid.isEmpty()){
                    for(PRM_AccountBenefitAssociation__c abaFinal: [Select id,name,PRM_Status_Nm__c,PRM_Account_Id__c,PRM_Account_Id__r.Recordtypeid,PRM_Partner_Benefit_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Source__c from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c In: setofFinalAccid AND PRM_Status_Nm__c =: System.Label.PRM_Status_Active AND PRM_Partner_Benefit_Id__r.Name IN: setOfFinalBnft]){
                        If(abaFinal.PRM_Partner_Benefit_Id__r.Name == System.Label.PRM_Solution_Marketplace_Basic_Access && setOfChildAccId.contains(abaFinal.PRM_Account_Id__c)){
                            abaFinal.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
                            abaFinal.PRM_Status_Reason_Txt__c =System.Label.PRM_Aba_Inactive;
                            abaFinal.PRM_Source__c='';
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
            
            System.debug('lstOfAba :- '+lstOfAba);
            
            if(lstOfAba !=null && !lstOfAba.isEmpty()){
                skipvalidationforMPBenefits=true;
                Database.SaveResult[] results = database.update(lstOfAba,false);
                System.debug(results);
            }   
            
        }catch(Exception e){
            system.debug('error in class PRM_accBenefitAssociationUtility  and in method opidBenefitInactivation :- '+e.getMessage()+' on line no:- '+e.getLineNumber());
        }    
    }
    
        public static void profileResponseOnBenefitUpdate(List<PRM_AccountBenefitAssociation__c> newABARecord){
        Map<id, PRM_AccountBenefitAssociation__c> actIdABA = new Map<id, PRM_AccountBenefitAssociation__c>();        
        Map<String, boolean> pointOptInCheckMap = new Map<String, boolean>();
        set<Id> accId=new set<Id>();
        set<Id> intelAccountIds=new set<Id>();
       
        for(PRM_AccountBenefitAssociation__c abaRec : [select id,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c, PRM_Account_Id__c, PRM_Partner_Benefit_Id__c,PRM_Source__c,PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c  from PRM_AccountBenefitAssociation__c where id in :newABARecord and PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c in :Label.PRM_benefits_for_point_not_eligible_flag.split(';') ]){            
            //actIdABA.put(abaRec.PRM_Account_Id__c, abaRec);
            if(abaRec.PRM_Status_Nm__c=='active'){
                pointOptInCheckMap.put(abaRec.PRM_Account_Id__c, true); // add profile response if true
            }
            if(abaRec.PRM_Status_Nm__c=='inactive'){
                pointOptInCheckMap.put(abaRec.PRM_Account_Id__c, false);// inactive pr if false
            }
        }
        
        if(pointOptInCheckMap.size()>0){
            System.debug('pointOptInCheckMap'+pointOptInCheckMap);
            PRM_ProfileResponseApexForABA.updateProfileResponse(pointOptInCheckMap);
        }
    }
    
    /*DO NOT DELETE BELOW METHOD AS WE NEED IT AFTER WW:42/*

public static void onManualBenefitInsert(List<PRM_AccountBenefitAssociation__c> lstAccBenefit)
{   
Set<Id> accId = new Set<Id>(); 
List<Id> benefitList = new List<Id>();
List<Id> entitlements;
List<PRM_VXEnttlmntMatrix__c> entitlementList;
List<String> accountBenefitList;
List<PRM_VXEnttlmntMatrix__c> accountEntitlementList;
List<Core_Contact_Entitlement__c> entitlementsToInsert = new List<Core_Contact_Entitlement__c>();
List< PRM_VXEnttlmntMatrix__c> entitlementMatrixlist = new List< PRM_VXEnttlmntMatrix__c>();
List<PRM_Account_Contact_Relationship__c>  acrRecords= new List<PRM_Account_Contact_Relationship__c>();
Map<String,List<Id>> benefitMap = new Map<String,List<Id>>();
Map<Id,List<PRM_VXEnttlmntMatrix__c>> mapEntitlements = new Map<Id,List<PRM_VXEnttlmntMatrix__c>>();

if(!System.isBatch()) {
for(PRM_AccountBenefitAssociation__c aba: lstAccBenefit){
benefitList.add(aba.PRM_Partner_Benefit_Id__c);
accId.add(aba.PRM_Account_Id__c);
benefitMap.put(aba.PRM_Account_Id__c,benefitList);
}

entitlementMatrixlist = [Select id, PRM_Entitlement_Id__c,PRM_Entitlement_Id__r.Name, PRM_Contact_Relationship_Id__c, PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c from PRM_VXEnttlmntMatrix__c where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_Partner_Benefit_Id__c in :benefitList AND PRM_IsActive_Ind__c = True];
System.debug(' matrix List '+entitlementMatrixlist);
if(lstAccBenefit != null && !lstAccBenefit.IsEmpty()){

for(PRM_AccountBenefitAssociation__c aba : lstAccBenefit){
accountBenefitList = new List<String>();
accountEntitlementList = new List<PRM_VXEnttlmntMatrix__c>();
accountBenefitList = benefitMap.get(aba.PRM_Account_Id__c);
for(PRM_VXEnttlmntMatrix__c em :entitlementMatrixlist){
if(accountBenefitList.contains(em.PRM_Partner_Benefit_Id__c)){
accountEntitlementList.add(em);
}
}
mapEntitlements.put(aba.PRM_Account_Id__c,accountEntitlementList);
}
}

acrRecords = [Select id,PRM_Account_Id__r.Name,PRM_Relationship_Id__c, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :accId];
System.debug('R - SIZE'+acrRecords.size());
if(acrRecords != null && !acrRecords.IsEmpty()){
for(PRM_Account_Contact_Relationship__c acr : acrRecords){
entitlements = new List<Id>();
entitlementList = new List<PRM_VXEnttlmntMatrix__c>();
entitlementList = mapEntitlements.get(acr.PRM_Account_Id__c);
for(PRM_VXEnttlmntMatrix__c em :entitlementList){
if(em.PRM_Contact_Relationship_Id__c == acr.PRM_Relationship_Id__c){
entitlements.add(em.PRM_Entitlement_Id__c);
}
}
System.debug(' Ent List '+entitlements);
for (integer i=0; i<entitlements.size(); i++) {
Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
ce.Core_Contact_Id__c = acr.PRM_Contact_Id__c;
ce.Core_Entitlement_Id__c = entitlements[i];
ce.Core_Selected__c = true;
ce.Core_Status__c = 'Pending';
ce.Core_Data_Loaded__c = true;
ce.Core_DontNotify__c = true;

if(Test.isRunningTest() && i==0){
ce.Core_Update_Reason__c = '*****************************************************************************************************************************************************************************************************************************************************************************';
}
entitlementsToInsert.add(ce);
} 
}
} 
if(entitlementsToInsert != null && !entitlementsToInsert.IsEmpty()){
//try{
System.debug(' Ent List final '+entitlementsToInsert);
//if(ceList != null && !ceList.IsEmpty()){
Database.SaveResult[] conEntList = Database.insert(entitlementsToInsert, false); 
System.debug('conEntList------------>'+conEntList);
integer index = 0;
for (Database.SaveResult sr : conEntList){                    
if (!sr.isSuccess()){
system.debug('>>debugging sr');
system.debug(sr);
system.debug(entitlementsToInsert[index]);
for(Database.Error err : sr.getErrors()){
Id sId;
String sObjectType = '';
sId =entitlementsToInsert[index].Id;
if(sId != null){
sObjectType =  sId.getSObjectType().getDescribe().getName();
}

//String tags = '';
//String accName =  '';
//  accName =mapConToName.get(entitlementsToInsert[index].Core_Contact_Id__c) == null?'':mapConToName.get(entitlementsToInsert[index].Core_Contact_Id__c);
// String benName =  '';
// benName =conToEntMap.get(entitlementsToInsert[index].Core_Contact_Id__c) == null?'':conToEntMap.get(entitlementsToInsert[index].Core_Contact_Id__c);
// String accId =  '';
// accId = mapConToId.get(entitlementsToInsert[index].Core_Contact_Id__c) == null ?'':mapConToId.get(entitlementsToInsert[index].Core_Contact_Id__c);
// tag format used - <Account Name> ; <Benefit Name> ; <Account ID>
// tags = accName + ';' + benName + ';' + accId;
Core_Log_Entry.logEntryWithDetails('PRM_accBenefitassociationUtility', 'IPA','Message', 'CRITICAL', err.getMessage(),'','','','');                             } 
}
index ++;
}
//  }
// Database.insert(entitlementsToInsert); 
System.debug(' Ent List after Insert '+entitlementsToInsert);
//}
/*catch(Exception ex){
String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();  
System.debug('##### Exception: ' + exceptionMessage);
}
}
}           
}
*/
/* *****************************************************************************************************************************************
* Method Name  : validateMPBenefits
* Author       : Jambert     
* Date         : 07/Dec/2021
* Return       : Void
* Description  : logic to ensure MP - enhanced benefit,basic profile is not updated manually at 1PID level - TWC729-1570
				 The same will be allowed when system is trying to modify it. 
****************************************************************************************************************************************** */
    public static void validateMPBenefits(List<PRM_AccountBenefitAssociation__c> lstAccBenefit,Map<Id,PRM_AccountBenefitAssociation__c> oldMap){
        
		String benefitnamesonInsert = System.Label.IPA_Benefit_Validation_onInsert;
		String benefitnamesonUpdate = System.Label.IPA_Benefit_Validation_onUpdate;
		Set<String> benefitNamesInsertSet=new Set<String>();
		Set<String> benefitNamesUpdatetSet=new Set<String>();
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
            if(benefitRecsMap !=null && !benefitRecsMap.isEmpty()){
                if(lstAccBenefit!= Null && !lstAccBenefit.isEmpty()){
                    for(PRM_AccountBenefitAssociation__c aba: lstAccBenefit){
                        if(benefitNamesInsertSet != null){
                            if(Trigger.IsBefore && Trigger.IsInsert){
                                if(!PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits && benefitNamesInsertSet.contains(benefitRecsMap.get(aba.PRM_Partner_Benefit_Id__c).Name)){
                                    aba.addError(System.Label.PRM_MP_Error_Message_OnInsert);
                                }
                            }
                        }
                        if(benefitNamesUpdatetSet != null){
                            if(Trigger.isBefore && Trigger.isUpdate){
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
                }
            }
        }
    } 
       
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
    
        
}