/****************************************************************************************************************************
Apex Class Name     : PRM_Benefit_Group_Benefit_Assoc_Utility 
Version             : 1.0
Created Date        : Nov 2019

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      27-Nov-2019                   Added a new method specialtyDuplicateCheck to restrict duplicate  in insert and update events 

****************************************************************************************************************************/
public without sharing class PRM_Benefit_Group_Benefit_Assoc_Utility {
    
    public static void benefitDuplicateCheck(List<PRM_Benefit_Group_Benefit_Association__c> benefitAssocNewList,Map<Id,PRM_Benefit_Group_Benefit_Association__c> oldMap)
    {
        Set<String> benefitIdSet = new Set<String>();// To store the PRM_Unique_Combination_Key__c field values from trigger.new
        Set<String> benefitGroupIdSet = new Set<String>();
        Map<String,String> uniqueMap = new Map<String,String>();// To store the PRM_Unique_Combination_Key__c field values from Database
        Set<String> duplicateSet = new Set<String>();
        for(PRM_Benefit_Group_Benefit_Association__c bgba: benefitAssocNewList){
            PRM_Benefit_Group_Benefit_Association__c bgbaOld ; 
            if(oldMap!=null && oldMap.size()>0){ bgbaOld = (PRM_Benefit_Group_Benefit_Association__c) oldMap.get(bgba.id) ;}
            if((oldMap==null) || ((oldMap!=null && oldMap.size()>0)&&(bgbaOld.PRM_Benefit_Id__c != bgba.PRM_Benefit_Id__c)))
            {
                benefitIdSet.add(bgba.PRM_Benefit_Id__c);
                benefitGroupIdSet.add(bgba.PRM_Benefit_Group_Id__c);
                uniqueMap.put(bgba.PRM_Benefit_Id__c+''+bgba.PRM_Benefit_Group_Id__c,bgba.PRM_Benefit_Group_Id__c); 
                system.debug('uniqueMap======>'+uniqueMap);   
            }
        }
        //querying PRM_Benefit_Group_Benefit_Association__c records based on benefitGroupIdSet and benefitIdSet values
        if(uniqueMap != null && uniqueMap.keySet().size()>0)
        {
            for(PRM_Benefit_Group_Benefit_Association__c bgba : [SELECT Id,PRM_Benefit_Id__c,PRM_Benefit_Group_Id__c FROM PRM_Benefit_Group_Benefit_Association__c where PRM_Benefit_Id__c IN: benefitIdSet AND PRM_Benefit_Group_Id__c IN:benefitGroupIdSet]){
                if(bgba.PRM_Benefit_Group_Id__c == uniqueMap.get(bgba.PRM_Benefit_Id__c+''+bgba.PRM_Benefit_Group_Id__c))
                {
                    duplicateSet.add(bgba.PRM_Benefit_Id__c+''+bgba.PRM_Benefit_Group_Id__c);
                }
            }
        } 
        //iterating over the trigger context and throwing error if duplicate record already exists
        if(duplicateSet != null && duplicateSet.size()>0){
            for(PRM_Benefit_Group_Benefit_Association__c bgba: benefitAssocNewList){
                System.debug('benefitAssocNewList=======>'+bgba);
                if(duplicateSet.contains(bgba.PRM_Benefit_Id__c+''+bgba.PRM_Benefit_Group_Id__c)){
                    bgba.addError(System.label.PRM_Benefit_Group_benefit_Association_duplicate_Error);
                }            
            } 
        }
    } 
    
    
    /* *****************************************************************************************************************************************
* author:      Sheetal Bhargava    
* Date:        12/2/2020
* Parameters:  list<PRM_Benefit_Group_Benefit_Association__c> lstOfBGBA , map<id,PRM_Benefit_Group_Benefit_Association__c> mapOfOldBGBA 
* Return:      Void
* Description: This method is used to associate benifit to respective account when A benefit is insernted in a Benifit Group 
****************************************************************************************************************************************** */
    
    public static void updateBenefitOnAccount(list<PRM_Benefit_Group_Benefit_Association__c> lstOfBGBA , map<id,PRM_Benefit_Group_Benefit_Association__c> mapOfOldBGBA){
        System.debug('Inside updateBenefitOnAccount :- '+lstOfBGBA);
        Set<string> setOfBenifitId = new Set<string>(); 
        Set<string> setOfBGId = new Set<string>();
        Map<string,set<String>> mapOfBgIdAndSetOfBenifitId = new Map<string,set<String>>();
        Set<String> setOfSpecialityId = new Set<String>();
        Map<string,set<String>> mapOfSpecialityIdAndBgId = new Map<string,set<String>>();
        Set<String> setOfAccountId = new Set<String>(); 
        Map<string,Set<string>> mapOfAccountIdAndSpecialityId = new Map<string,Set<string>>(); 
        Map<String,Set<String>> mapOfSpecialityIdAndBenifitId = new Map<String,Set<String>>();
        Map<string,Set<String>> mapOfAccountIdAndBenifitId = new Map<string,Set<String>>();
        List<PRM_AccountBenefitAssociation__c> listOfExsistingABARecord = new List<PRM_AccountBenefitAssociation__c>();
        Set<PRM_AccountBenefitAssociation__c> newAbaRecord = new Set<PRM_AccountBenefitAssociation__c>();
        List<PRM_VXEnttlmntMatrix__c> entitlementMatrixlist = new List< PRM_VXEnttlmntMatrix__c>();
        List<PRM_VXEnttlmntMatrix__c> entitlementWithoutBenefit = new List< PRM_VXEnttlmntMatrix__c>();
        
        
            
            if(lstOfBGBA != null && !lstOfBGBA.isEmpty()){
                for(PRM_Benefit_Group_Benefit_Association__c bgba: lstOfBGBA){
                    //Added Check of PRM_Status_Nm__c in bGBA Query as part of US : US594299
                    if(!bgba.PRM_InActive_Ind__c && bgba.PRM_Status_Nm__c == 'Live'){
                        setOfBenifitId.add(bgba.PRM_Benefit_Id__c);
                        setOfBGId.add(bgba.PRM_Benefit_Group_Id__c);  
                        if(mapOfBgIdAndSetOfBenifitId.containsKey(bgba.PRM_Benefit_Group_Id__c)){
                            Set<String> setOfBeifitId = mapOfBgIdAndSetOfBenifitId.get(bgba.PRM_Benefit_Group_Id__c);
                            setOfBeifitId.add(bgba.PRM_Benefit_Id__c);
                            mapOfBgIdAndSetOfBenifitId.put(bgba.PRM_Benefit_Group_Id__c,setOfBeifitId);
                        }else{
                            mapOfBgIdAndSetOfBenifitId.put(bgba.PRM_Benefit_Group_Id__c, new Set<string> {bgba.PRM_Benefit_Id__c});
                        }
                    }  
                }
            }  
            
            system.debug('setOfBenifitId :- '+setOfBenifitId);
            system.debug('setOfBGId :- '+setOfBGId);
            system.debug('mapOfBgIdAndSetOfBenifitId :- '+mapOfBgIdAndSetOfBenifitId);
            
            if(setOfBGId!= null && !setOfBGId.isEmpty()){
                for(PRM_Specialty_Benefit_Group_Association__c  sbga: [Select id,name,PRM_Specialty_Id__c,PRM_Benefit_Group_Id__c from PRM_Specialty_Benefit_Group_Association__c where PRM_Benefit_Group_Id__c IN: setOfBGId AND PRM_InActive_Ind__c = false]){
                    setOfSpecialityId.add(sbga.PRM_Specialty_Id__c); 
                    if(mapOfSpecialityIdAndBgId.containsKey(sbga.PRM_Specialty_Id__c)){
                        Set<String> setOfTempBGId = mapOfSpecialityIdAndBgId.get(sbga.PRM_Specialty_Id__c);
                        setOfTempBGId.add(sbga.PRM_Benefit_Group_Id__c);
                        mapOfSpecialityIdAndBgId.put(sbga.PRM_Specialty_Id__c,setOfTempBGId);
                    }else{
                        mapOfSpecialityIdAndBgId.put(sbga.PRM_Specialty_Id__c, new Set<string> {sbga.PRM_Benefit_Group_Id__c});
                    }
                }
            }
            
            System.debug('setOfSpecialityId :-'+setOfSpecialityId);
            System.debug('mapOfSpecialityIdAndBgId :-'+mapOfSpecialityIdAndBgId);
        if(setOfSpecialityId!=Null && setOfSpecialityId.size()>0){
            //iterating asa to fetch associated account
            for(PRM_Account_Specialty_Association__c asaRecord: [Select id,name,PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_InActive_Ind__c from PRM_Account_Specialty_Association__c where PRM_Specialty_Id__c IN:setOfSpecialityId AND PRM_InActive_Ind__c = false]){
                setOfAccountId.add(asaRecord.PRM_Account_Id__c);  
                if(mapOfAccountIdAndSpecialityId.containsKey(asaRecord.PRM_Account_Id__c)){
                    Set<String> setOfSpeciality = new Set<String>();
                    setOfSpeciality = mapOfAccountIdAndSpecialityId.get(asaRecord.PRM_Account_Id__c);
                    setOfSpeciality.add(asaRecord.PRM_Specialty_Id__c);
                    mapOfAccountIdAndSpecialityId.put(asaRecord.PRM_Account_Id__c,setOfSpeciality);
                }else{
                    mapOfAccountIdAndSpecialityId.put(asaRecord.PRM_Account_Id__c, new set<string>{asaRecord.PRM_Specialty_Id__c}); 
                }
            } }
            
            System.debug('setOfAccountId :-'+setOfAccountId);
            System.debug('mapOfAccountIdAndSpecialityId :-'+mapOfAccountIdAndSpecialityId);
            
            // Associating speciality with benefits.
            if(mapOfSpecialityIdAndBgId.keyset() != null && !mapOfSpecialityIdAndBgId.keyset().isEmpty()){
                for(string str: mapOfSpecialityIdAndBgId.keyset()){
                    Set<string> listOfBenifit = new Set<string>();
                    for(string lstOfBG: mapOfSpecialityIdAndBgId.get(str)){
                        if(lstOfBG != null){
                            if(mapOfBgIdAndSetOfBenifitId.containskey(lstOfBG)){
                                listOfBenifit.addall(mapOfBgIdAndSetOfBenifitId.get(lstOfBG));  
                            }   
                        }
                    }
                    if(listOfBenifit != null && !listOfBenifit.IsEmpty()){
                        mapOfSpecialityIdAndBenifitId.put(str,listOfBenifit);
                    }
                }  
            }
            System.debug('mapOfSpecialityIdAndBenifitId :-'+mapOfSpecialityIdAndBenifitId);
            
            // Associating account with benefits.
            if(mapOfAccountIdAndSpecialityId.keyset() !=null && !mapOfAccountIdAndSpecialityId.keyset().isEmpty()){
                for (string str: mapOfAccountIdAndSpecialityId.keyset()){
                    Set<string> listOfSpecialityForObj = new Set<string>();  
                    for(string strObj: mapOfAccountIdAndSpecialityId.get(str)){
                        if(strObj !=null){
                            if(mapOfSpecialityIdAndBenifitId.containskey(strObj)){
                                listOfSpecialityForObj.addall(mapOfSpecialityIdAndBenifitId.get(strObj));   
                            }   
                        } 
                    }
                    if(listOfSpecialityForObj != null && !listOfSpecialityForObj.IsEmpty()){
                        mapOfAccountIdAndBenifitId.put(str,listOfSpecialityForObj);
                    }
                }    
            }
            System.debug('mapOfAccountIdAndBenifitId :-'+mapOfAccountIdAndBenifitId);
            if(setOfAccountId!=Null && setOfAccountId.size()>0  && setOfBenifitId!=Null && setOfBenifitId.size()>0){
            //Fetch ABA RECORD If Exsist
            listOfExsistingABARecord = [Select id,PRM_Account_Id__c,PRM_Partner_Benefit_Id__c,PRM_Source__c,PRM_Status_Nm__c from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c IN: setOfAccountId AND PRM_Partner_Benefit_Id__c IN: setOfBenifitId];
            System.debug('listOfExsistingABARecord :-'+listOfExsistingABARecord);}
            Set<PRM_AccountBenefitAssociation__c> setOfExsistingABARecord = new Set<PRM_AccountBenefitAssociation__c>(listOfExsistingABARecord);
            System.debug('setOfExsistingABARecord :-'+setOfExsistingABARecord);
            
            //Iterating on exsisting record
            
            if(setOfExsistingABARecord !=null && !setOfExsistingABARecord.isEmpty()){
                for(PRM_AccountBenefitAssociation__c abaRecord: setOfExsistingABARecord){
                    if(abaRecord.PRM_Status_Nm__c == 'Inactive'){
                        abaRecord.PRM_Status_Nm__c = 'Active';
                        newAbaRecord.add(abaRecord); 
                    }
                    if(abaRecord.PRM_Status_Nm__c == 'Active' && abaRecord.PRM_Source__c =='Tier'){
                        newAbaRecord.add(abaRecord);
                    }  
                }   
            }
            
            System.debug('newAbaRecord 123 :-'+newAbaRecord);
            
            for(string accountstr: mapOfAccountIdAndBenifitId.keyset()){
                for(string benefitstr:mapOfAccountIdAndBenifitId.get(accountstr)){
                    if(!duplicateRecordCheck(accountstr,benefitstr,listOfExsistingABARecord)){
                        PRM_AccountBenefitAssociation__c abaObj= new PRM_AccountBenefitAssociation__c(); 
                        abaObj.PRM_Account_Id__c = accountstr;
                        abaObj.PRM_Partner_Benefit_Id__c = benefitstr;
                        abaObj.PRM_Status_Nm__c = 'Active';
                        // abaObj.PRM_Source__c = 'Specialty';
                        newAbaRecord.add(abaObj);
                    }  
                }
            }
            
            System.debug('newAbaRecord :-'+newAbaRecord);
            List<PRM_AccountBenefitAssociation__c> listOfNewAbaRecord;
        try{   
            listOfNewAbaRecord = new List<PRM_AccountBenefitAssociation__c>(newAbaRecord);
            If(listOfNewAbaRecord !=null && !listOfNewAbaRecord.isEmpty()){
                database.UpsertResult[] result = database.upsert(listOfNewAbaRecord,false);
                System.debug('result :-'+result);
            }
            
        }Catch(exception ex){
            system.debug('Error in updateBenefitOnAccount Method of BGBA Trigger :-'+ex.getMessage() +'On line no :-'+ex.getLineNumber());
        } 

        // Assigning contact entitlements.
        Set<Id> acctId = new Set<Id>();
        Set<Id> pbId = new Set<Id>();
        List<Account> accList = new List<Account>();
        Map<String,List<Id>> benefitMap = new Map<String,List<Id>>();
        List<PRM_Account_Contact_Relationship__c> acrRecords = new List<PRM_Account_Contact_Relationship__c>();
        Map<Id,List<PRM_AccountChannelMembership__c>> acmMap = new Map<Id,List<PRM_AccountChannelMembership__c>>();
        Map<Id,Core_Contact_Entitlement__c> ceStatusMap = new Map<Id,Core_Contact_Entitlement__c>();
        boolean updateCheck = true;
        for(PRM_AccountBenefitAssociation__c aba :listOfNewAbaRecord){
            acctId.add(aba.PRM_Account_Id__c);
            pbId.add(aba.PRM_Partner_Benefit_Id__c);
            List<Id> benefitListTemp =new List<Id>();
            if(benefitMap.get(aba.PRM_Account_Id__c)!= null && !benefitMap.get(aba.PRM_Account_Id__c).isEmpty()){
                benefitListTemp = benefitMap.get(aba.PRM_Account_Id__c);
            }
            benefitListTemp.add(aba.PRM_Partner_Benefit_Id__c);
            benefitMap.put(aba.PRM_Account_Id__c,benefitListTemp);
        }
        if(acctId != null && !acctId.isEmpty()){
            accList = [Select Id, Name From Account Where Id IN :acctId];
        }
        if(pbId!= null && !pbId.isEmpty()){
            entitlementMatrixlist = [Select id, PRM_Entitlement_Id__c,PRM_Entitlement_Id__r.Name, PRM_Contact_Relationship_Id__c, PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,RecordType.Name,PRM_Partner_Role_Nm__c,PRM_AGS_Role__c from PRM_VXEnttlmntMatrix__c where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_Partner_Benefit_Id__c in :pbId AND PRM_IsActive_Ind__c = True AND PRM_Partner_Role_Nm__c != null];
        }
        System.debug('entitlementMatrixlist-->'+entitlementMatrixlist);
        // Fetching entitlements when benefit doesn't assigned to account.
        entitlementWithoutBenefit = [Select id, PRM_Entitlement_Id__c,PRM_Entitlement_Id__r.Name, PRM_Contact_Relationship_Id__c, PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__c,PRM_Partner_Role_Nm__c,RecordType.Name,PRM_AGS_Role__c from PRM_VXEnttlmntMatrix__c where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND RecordType.Name = 'EntitlementWithoutBenefits' AND PRM_IsActive_Ind__c = True AND PRM_Partner_Role_Nm__c != null];
        System.debug('entitlementWithoutBenefit-->'+entitlementWithoutBenefit);
        
        //If we have multiple Entitlements for single benefit.
        Map<Id,List<PRM_VXEnttlmntMatrix__c>> benefitEntitlementMap = new Map<Id,List<PRM_VXEnttlmntMatrix__c>>();
        if(entitlementMatrixlist!= null && !entitlementMatrixlist.isEmpty()){
            for(PRM_VXEnttlmntMatrix__c em1 :entitlementMatrixlist){
                List<PRM_VXEnttlmntMatrix__c> entitlements = new List<PRM_VXEnttlmntMatrix__c>();
                if(benefitEntitlementMap.get(em1.PRM_Partner_Benefit_Id__c)!= null && !benefitEntitlementMap.get(em1.PRM_Partner_Benefit_Id__c).isEmpty()){
                    entitlements = benefitEntitlementMap.get(em1.PRM_Partner_Benefit_Id__c);
                }
                entitlements.add(em1);
                benefitEntitlementMap.put(em1.PRM_Partner_Benefit_Id__c,entitlements);
            }
        }
        System.debug('benefitEntitlementMap-->'+benefitEntitlementMap);
        
        Map<Id,Set<PRM_VXEnttlmntMatrix__c>> accEntitlementsMap= new Map<Id,Set<PRM_VXEnttlmntMatrix__c>>();
        for(Account acc :accList){
            List<Id> accBenefits = new List<Id>();
            accBenefits = benefitMap.get(acc.Id);
            System.debug('accBenefits-->'+accBenefits);
            if(accBenefits != null && !accBenefits.IsEmpty()){
                Set<PRM_VXEnttlmntMatrix__c> accEntitlements = new Set<PRM_VXEnttlmntMatrix__c>();
                if(accEntitlementsMap.get(acc.Id)!= null && !accEntitlementsMap.get(acc.Id).isEmpty()){accEntitlements = accEntitlementsMap.get(acc.Id);
                                                                                                      }
                for(integer i=0; i<accBenefits.size(); i++){
                    List<PRM_VXEnttlmntMatrix__c> benfitEntitlements = new List<PRM_VXEnttlmntMatrix__c>();
                    System.debug('accBenefits[i]-->'+accBenefits[i]);
                    benfitEntitlements = benefitEntitlementMap.get(accBenefits[i]);
                    System.debug('benfitEntitlements-->'+benfitEntitlements);
                    if(benfitEntitlements != null && !benfitEntitlements.IsEmpty()){
                        accEntitlements.addAll(benfitEntitlements);
                    }
                    System.debug('accEntitlements-->'+accEntitlements);
                }
                accEntitlementsMap.put(acc.Id, accEntitlements);
                System.debug('accEntitlementsMap-->'+accEntitlementsMap);
            }
        }
        if(acctId!=Null && acctId.size()>0){
        //Fetching ACR records of the accounts which is picked by the batch job to process.
        acrRecords = [Select id,PRM_Account_Id__r.Name,PRM_Relationship_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c,PRM_Account_Id__c, PRM_Contact_Id__c,PRM_Contact_Id__r.Core_IPA_Partner_Role__c,PRM_Partner_Role__c,PRM_Contact_Id__r.Name,PRM_Status_Nm__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :acctId AND  PRM_InActive_Ind__c!= true AND PRM_Status_Nm__c =:System.Label.PRM_ACR_Status];
        }
        System.debug('acrRecords-->'+acrRecords);
        List<PRM_Batch_Entitlement__c> beListTemp = new List<PRM_Batch_Entitlement__c>();
        List<PRM_Batch_Entitlement__c> beListFinal = new List<PRM_Batch_Entitlement__c>();
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> finalCEList = new List<Core_Contact_Entitlement__c>();
        Set<Id> conId = new Set<Id>();
        Set<Id> entId = new Set<Id>();
        Map<Id,String> entAgsMap = new Map<Id,String>();
        String updateReasonCSPFlow = System.Label.PRM_Entitlement_Source;
        Map<Core_Contact_Entitlement__c,Id> ceMap = new Map<Core_Contact_Entitlement__c,Id>();
        if(acrRecords != null && !acrRecords.IsEmpty()){
            for(PRM_Account_Contact_Relationship__c acr :acrRecords){
                Set<PRM_VXEnttlmntMatrix__c> entitlementSet = new Set<PRM_VXEnttlmntMatrix__c>();
                List<string> partnerRole = new List<string>();
                entitlementSet = accEntitlementsMap.get(acr.PRM_Account_Id__c);
                List<PRM_VXEnttlmntMatrix__c> entitlements = new List<PRM_VXEnttlmntMatrix__c>(entitlementSet);
                System.debug('entitlements-->'+entitlements);
                conId.add(acr.PRM_Contact_Id__c);
                if(acr.PRM_Partner_Role__c != null){
                    partnerRole = acr.PRM_Partner_Role__c.split('<br>');
                }
                if(entitlements != null && !entitlements.IsEmpty()){ // Assigning entitlements based on the benefits get assigned.
                    for(integer i=0; i<entitlements.size(); i++){
                        if(entitlements[i].PRM_Contact_Relationship_Id__c == acr.PRM_Relationship_Id__c && (partnerRole != null && !partnerRole.IsEmpty()) && partnerRole.contains(entitlements[i].PRM_Partner_Role_Nm__c)){
                            entId.add(entitlements[i].PRM_Entitlement_Id__c);
                            entAgsMap.put(entitlements[i].PRM_Entitlement_Id__c,entitlements[i].PRM_AGS_Role__c);
                            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
                            ce.Core_Contact_Id__c = acr.PRM_Contact_Id__c;
                            ce.Core_Entitlement_Id__c = entitlements[i].PRM_Entitlement_Id__c;
                            //ce.Core_Status__c = 'Pending';
                            ce.Core_Selected__c = true;
                            ce.Core_Data_Loaded__c = true;
                            ce.Core_DontNotify__c = true;
                            ce.Core_From_Source__c = false;
                            if(entitlements[i].PRM_AGS_Role__c == '' || entitlements[i].PRM_AGS_Role__c == null){
                                ce.Core_From_Source__c = true;
                            }
                            else {
                                ce.Core_Status__c = 'Pending';
                            } 
                            if(!ceList.contains(ce)){
                                ceList.add(ce);
                            }
                        }
                    }
                }
              /*  if(entitlementWithoutBenefit != null && !entitlementWithoutBenefit.IsEmpty()){
                    for(PRM_VXEnttlmntMatrix__c em :entitlementWithoutBenefit){ //Assigning default entitlements.
                        List<PRM_AccountChannelMembership__c> acm = new List<PRM_AccountChannelMembership__c>();
                        if(acmMap !=null && !acmMap.IsEmpty() && acmMap.KeySet().contains(acr.PRM_Account_Id__c)){
                            acm = acmMap.get(acr.PRM_Account_Id__c);
                        }
                        if(acm != null && !acm.IsEmpty()){
                            for(integer i=0; i<acm.size(); i++){
                                if(em.PRM_Contact_Relationship_Id__c == acr.PRM_Relationship_Id__c && (partnerRole != null && !partnerRole.IsEmpty()) && partnerRole.contains(em.PRM_Partner_Role_Nm__c) && em.PRM_Channel_Program_Level_Id__c == acm[i].PRM_Channel_Program_Level_Id__c){
                                    entId.add(em.PRM_Entitlement_Id__c);
                                    entAgsMap.put(em.PRM_Entitlement_Id__c,em.PRM_AGS_Role__c);
                                    Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
                                    ce1.Core_Contact_Id__c = acr.PRM_Contact_Id__c;
                                    ce1.Core_Entitlement_Id__c = em.PRM_Entitlement_Id__c;
                                    //ce1.Core_Status__c = 'Pending';
                                    ce1.Core_Selected__c = true;
                                    ce1.Core_Data_Loaded__c = true;
                                    ce1.Core_DontNotify__c = true;
                                    ce1.Core_From_Source__c = false;
                                    if(em.PRM_AGS_Role__c == '' || em.PRM_AGS_Role__c == null){
                                        ce1.Core_From_Source__c = true;
                                    }
                                    else {
                                        ce1.Core_Status__c = 'Pending';
                                    } 
                                    if(!ceList.contains(ce1)){
                                        ceList.add(ce1);
                                    }
                                }
                            }
                        }
                    }
                } */
            }
        }
        System.debug('conId-->'+conId);
        System.debug('entId-->'+entId);
        System.debug('ceList-->'+ceList);
        List<Id> beCon = new List<Id>();
        List<Id> beEnt = new List<Id>();
        List<Core_Contact_Entitlement__c> contactEntList = new List<Core_Contact_Entitlement__c>();
        
        // Checking existing contact entitlements.
        if((conId !=null && !conId.IsEmpty()) && (entId !=null && !entId.IsEmpty())){
            contactEntList = [Select Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Selected__c,Core_Status__c,Core_Data_Loaded__c,Core_DontNotify__c,Core_Source__c,Core_From_Source__c From Core_Contact_Entitlement__c Where Core_Contact_Id__c IN :conId AND Core_Entitlement_Id__c IN :entId];
        }
        System.debug('contactEntList-->'+contactEntList);
        if(contactEntList !=null && !contactEntList.IsEmpty()){
            for(Core_Contact_Entitlement__c ce :contactEntList){
                Core_Contact_Entitlement__c newCe = new Core_Contact_Entitlement__c();
                newCe.Core_Contact_Id__c = ce.Core_Contact_Id__c;
                newCe.Core_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                if((entAgsMap != null && !entAgsMap.IsEmpty()) && (entAgsMap.get(ce.Core_Entitlement_Id__c) != '' && entAgsMap.get(ce.Core_Entitlement_Id__c) != null)){
                    newCe.Core_Status__c = 'Pending';
                }
                //newCe.Core_Status__c = 'Pending';
                newce.Core_Selected__c = true;
                newCe.Core_Data_Loaded__c = true;
                newCe.Core_DontNotify__c = true;
                newCe.Core_From_Source__c = ce.Core_From_Source__c;
                
                ceMap.put(newCe, ce.Id);
                ceStatusMap.put(ce.Id,ce);
            }
        }
        if(ceList !=null && !ceList.IsEmpty()){
            for(Core_Contact_Entitlement__c ce :ceList){ //Assigning id to existing contact entitlements
                updateCheck = false;
                beCon.add(ce.Core_Contact_Id__c);
                beEnt.add(ce.Core_Entitlement_Id__c);
                if(ceMap!= null && !ceMap.isEmpty() && ceMap.containsKey(ce)){
                    ce.Id = ceMap.get(ce);
                    Core_Contact_Entitlement__c contEnt = ceStatusMap.get(ce.Id);
                    if(contEnt.Core_Source__c != updateReasonCSPFlow){ //Added for US539488:to Identify origin of Entitlement
                        ce.Core_Source__c = updateReasonCSPFlow;
                        updateCheck = true;
                    }
                    if(!contEnt.Core_Selected__c){ //updating contact entitlements.
                        ce.Core_Selected__c = true;
                        updateCheck = true;
                    }
                    if(updateCheck){
                        finalCEList.add(ce);
                    }
                }
                else{
                    ce.Core_Selected__c = true; //Inserting contact entitlements.
                    ce.Core_Source__c = updateReasonCSPFlow;//Added for US539488:to Identify origin of Entitlement creation
                    finalCEList.add(ce);
                }
            }
        }
        System.debug('ceList-->'+ceList);
        System.debug('finalCEList-->'+finalCEList);
        if((beCon != null && !beCon.IsEmpty()) && (beEnt != null && !beEnt.IsEmpty())){ // Updating batch entitlement records.
            for(PRM_Batch_Entitlement__c batchEntitlements :[Select Id, Name, PRM_Contact_Id__c,PRM_Entitlement_Id__c,PRM_Status_Nm__c,PRM_IsRemove_Ind__c From PRM_Batch_Entitlement__c Where PRM_Status_Nm__c = 'New' AND PRM_IsRemove_Ind__c = true AND PRM_Contact_Id__c IN:beCon AND PRM_Entitlement_Id__c IN :beEnt]){
                if(batchEntitlements.PRM_IsRemove_Ind__c == true){
                    batchEntitlements.PRM_IsRemove_Ind__c = false;
                    beListTemp.add(batchEntitlements);
                }
            }
        }
        if(finalCEList != null && !finalCEList.IsEmpty()){
            for(Core_Contact_Entitlement__c ce :finalCEList){ // Inserting batch entitlement records.
                PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
                be.PRM_Contact_Id__c = ce.Core_Contact_Id__c;
                be.PRM_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                be.PRM_Status_Nm__c = 'New';
                if(!beListTemp.Contains(be)){
                    beListTemp.add(be);
                }
            }
        }
        system.debug('Total queries executed before batch entitlement upsertion--->'+Limits.getQueries());
        try{
            If(beListTemp != null && !beListTemp.IsEmpty()){
                upsert beListTemp;
            }
        }catch(exception e){
            system.debug('error in class PRM_Account_Specialty_Assoc_Utility  and in method benefitAssingmentForMemeberAccount :- '+e.getMessage()+' on line no:- '+e.getLineNumber());   
        }
        system.debug('Total queries executed after batch entitlement upsertion--->'+Limits.getQueries());
        System.debug('beListTemp-->'+beListTemp);
    }
    
    /* *****************************************************************************************************************************************
* author:      Sheetal Bhargava    
* Date:        12/2/2020
* Parameters:  string accountId, string benefitId, List<PRM_AccountBenefitAssociation__c> lstOfABARecord
* Return:      Boolean
* Description: This is a generic method to check for if a aba record exsist or not. 
****************************************************************************************************************************************** */
    
    Public Static boolean duplicateRecordCheck(string accountId, string benefitId, List<PRM_AccountBenefitAssociation__c> lstOfABARecord){
        System.debug('Inside recordExsistCheck :-');
        System.debug('Inside recordExsistCheck accountId :-'+accountId);
        System.debug('Inside recordExsistCheck benefitId :-'+benefitId);
        System.debug('Inside recordExsistCheck lstOfABARecord :-'+lstOfABARecord);
        boolean result = false;
        for(PRM_AccountBenefitAssociation__c aBARecord: lstOfABARecord){
            if(aBARecord.PRM_Account_Id__c == accountId && aBARecord.PRM_Partner_Benefit_Id__c == benefitId){
                result = true;
                break;
            }
        }
        return result;
    }
    //Sheetal Changes End 
    
    /* *****************************************************************************************************************************************
* author:      Sheetal Bhargava    
* Date:        12/2/2020
* Parameters:  list<PRM_Benefit_Group_Benefit_Association__c> lstOfBGBA , map<id,PRM_Benefit_Group_Benefit_Association__c> mapOfOldBGBA
* Return:      void
* Description: This method is used to inactivate aba on inactivation of bgba record. 
****************************************************************************************************************************************** */
    
    public static void benefitRemovalFromAccount(list<PRM_Benefit_Group_Benefit_Association__c> lstOfBGBA , map<id,PRM_Benefit_Group_Benefit_Association__c> mapOfOldBGBA){
        system.debug('Inside benefitRemovalFromAccount');
        system.debug('Inside benefitRemovalFromAccount lstOfBGBA :-'+lstOfBGBA);
        system.debug('Inside benefitRemovalFromAccount mapOfOldBGBA :-'+mapOfOldBGBA);
        Set<string> setOfBenifitId = new Set<string>(); 
        Set<string> setOfBGId = new Set<string>();
        Map<string,set<String>> mapOfBgIdAndSetOfBenifitId = new Map<string,set<String>>();
        Set<String> setOfSpecialityId = new Set<String>();
        Map<string,set<String>> mapOfSpecialityIdAndBgId = new Map<string,set<String>>();
        Set<String> setOfAccountId = new Set<String>(); 
        Map<string,Set<string>> mapOfAccountIdAndSpecialityId = new Map<string,Set<string>>(); 
        Map<String,Set<String>> mapOfSpecialityIdAndBenifitId = new Map<String,Set<String>>();
        Map<string,Set<String>> mapOfAccountIdAndBenifitId = new Map<string,Set<String>>();
        List<PRM_AccountBenefitAssociation__c> listOfExsistingABARecord = new List<PRM_AccountBenefitAssociation__c>();
        Set<PRM_AccountBenefitAssociation__c> setOfTempABARecord = new Set<PRM_AccountBenefitAssociation__c>();
        List<PRM_AccountBenefitAssociation__c> finalListOfAbaToUpdate = new List<PRM_AccountBenefitAssociation__c>();
        try{
            if(lstOfBGBA != null && !lstOfBGBA.isEmpty()){
                for(PRM_Benefit_Group_Benefit_Association__c bgba: lstOfBGBA){
                    if(Trigger.isUpdate && (bgba.PRM_InActive_Ind__c) && (bgba.PRM_InActive_Ind__c != mapOfOldBGBA.get(bgba.Id).PRM_InActive_Ind__c)){
                        setOfBenifitId.add(bgba.PRM_Benefit_Id__c);
                        setOfBGId.add(bgba.PRM_Benefit_Group_Id__c);  
                        if(mapOfBgIdAndSetOfBenifitId.containsKey(bgba.PRM_Benefit_Group_Id__c)){
                            Set<String> setOfBeifitId = mapOfBgIdAndSetOfBenifitId.get(bgba.PRM_Benefit_Group_Id__c);
                            setOfBeifitId.add(bgba.PRM_Benefit_Id__c);
                            mapOfBgIdAndSetOfBenifitId.put(bgba.PRM_Benefit_Group_Id__c,setOfBeifitId);
                        }else{
                            mapOfBgIdAndSetOfBenifitId.put(bgba.PRM_Benefit_Group_Id__c, new Set<string> {bgba.PRM_Benefit_Id__c});
                        }
                    }
                }
            }
            
            system.debug('setOfBenifitId :- '+setOfBenifitId);
            system.debug('setOfBGId :- '+setOfBGId);
            system.debug('mapOfBgIdAndSetOfBenifitId :- '+mapOfBgIdAndSetOfBenifitId);
            
            if(setOfBGId!= null && !setOfBGId.isEmpty()){
                for(PRM_Specialty_Benefit_Group_Association__c  sbga: [Select id,name,PRM_Specialty_Id__c,PRM_Benefit_Group_Id__c from PRM_Specialty_Benefit_Group_Association__c where PRM_Benefit_Group_Id__c IN: setOfBGId AND PRM_InActive_Ind__c = false]){
                    setOfSpecialityId.add(sbga.PRM_Specialty_Id__c); 
                    if(mapOfSpecialityIdAndBgId.containsKey(sbga.PRM_Specialty_Id__c)){
                        Set<String> setOfTempBGId = mapOfSpecialityIdAndBgId.get(sbga.PRM_Specialty_Id__c);
                        setOfTempBGId.add(sbga.PRM_Benefit_Group_Id__c);
                        mapOfSpecialityIdAndBgId.put(sbga.PRM_Specialty_Id__c,setOfTempBGId);
                    }else{
                        mapOfSpecialityIdAndBgId.put(sbga.PRM_Specialty_Id__c, new Set<string> {sbga.PRM_Benefit_Group_Id__c});
                    }
                }
            }
            
            System.debug('setOfSpecialityId :-'+setOfSpecialityId);
            System.debug('mapOfSpecialityIdAndBgId :-'+mapOfSpecialityIdAndBgId); 
            if(setOfSpecialityId.size()>0 && setOfSpecialityId!=Null){
            //iterating asa to fetch associated account
            for(PRM_Account_Specialty_Association__c asaRecord: [Select id,name,PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_InActive_Ind__c from PRM_Account_Specialty_Association__c where PRM_Specialty_Id__c IN:setOfSpecialityId AND PRM_InActive_Ind__c = false]){
                setOfAccountId.add(asaRecord.PRM_Account_Id__c);  
                if(mapOfAccountIdAndSpecialityId.containsKey(asaRecord.PRM_Account_Id__c)){
                    Set<String> setOfSpeciality = new Set<String>();
                    setOfSpeciality = mapOfAccountIdAndSpecialityId.get(asaRecord.PRM_Account_Id__c);
                    setOfSpeciality.add(asaRecord.PRM_Specialty_Id__c);
                    mapOfAccountIdAndSpecialityId.put(asaRecord.PRM_Account_Id__c,setOfSpeciality);
                }else{
                    mapOfAccountIdAndSpecialityId.put(asaRecord.PRM_Account_Id__c, new set<string>{asaRecord.PRM_Specialty_Id__c}); 
                }
            } }
            
            System.debug('setOfAccountId :-'+setOfAccountId);
            System.debug('mapOfAccountIdAndSpecialityId :-'+mapOfAccountIdAndSpecialityId);
            
            // Associating speciality with benefits.
            if(mapOfSpecialityIdAndBgId.keyset() != null && !mapOfSpecialityIdAndBgId.keyset().isEmpty()){
                for(string str: mapOfSpecialityIdAndBgId.keyset()){
                    Set<string> listOfBenifit = new Set<string>();
                    for(string lstOfBG: mapOfSpecialityIdAndBgId.get(str)){
                        if(lstOfBG != null){
                            if(mapOfBgIdAndSetOfBenifitId.containskey(lstOfBG)){
                                listOfBenifit.addall(mapOfBgIdAndSetOfBenifitId.get(lstOfBG));  
                            }   
                        }
                    }
                    if(listOfBenifit != null && !listOfBenifit.IsEmpty()){
                        mapOfSpecialityIdAndBenifitId.put(str,listOfBenifit);
                    }
                }  
            }
            System.debug('mapOfSpecialityIdAndBenifitId :-'+mapOfSpecialityIdAndBenifitId);
            
            // Associating account with benefits.
            if(mapOfAccountIdAndSpecialityId.keyset() !=null && !mapOfAccountIdAndSpecialityId.keyset().isEmpty()){
                for (string str: mapOfAccountIdAndSpecialityId.keyset()){
                    Set<string> listOfSpecialityForObj = new Set<string>();  
                    for(string strObj: mapOfAccountIdAndSpecialityId.get(str)){
                        if(strObj !=null){
                            if(mapOfSpecialityIdAndBenifitId.containskey(strObj)){
                                listOfSpecialityForObj.addall(mapOfSpecialityIdAndBenifitId.get(strObj));   
                            }   
                        } 
                    }
                    if(listOfSpecialityForObj != null && !listOfSpecialityForObj.IsEmpty()){
                        mapOfAccountIdAndBenifitId.put(str,listOfSpecialityForObj);
                    }
                }    
            }
            System.debug('mapOfAccountIdAndBenifitId :-'+mapOfAccountIdAndBenifitId);
            if(setOfAccountId!=Null && setOfAccountId.size()>0  && setOfBenifitId!=Null && setOfBenifitId.size()>0){
            //Fetch ABA RECORD If Exsist
            listOfExsistingABARecord = [Select id,PRM_Account_Id__c,PRM_Partner_Benefit_Id__c,PRM_Source__c,PRM_Status_Nm__c from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c IN: setOfAccountId AND PRM_Partner_Benefit_Id__c IN: setOfBenifitId AND PRM_Status_Nm__c ='Active' AND PRM_Source__c INCLUDES ('Specialty')];
            }
			System.debug('listOfExsistingABARecord :-'+listOfExsistingABARecord);
            Set<PRM_AccountBenefitAssociation__c> setOfExsistingABARecord = new Set<PRM_AccountBenefitAssociation__c>(listOfExsistingABARecord);
            System.debug('setOfExsistingABARecord :-'+setOfExsistingABARecord);
           
            //Creating Temporary object of aba through map
            if(mapOfAccountIdAndBenifitId.keyset() !=null && !mapOfAccountIdAndBenifitId.keyset().isEmpty()){
                for(string accId: mapOfAccountIdAndBenifitId.keyset()){
                    if(accId !=null && mapOfAccountIdAndBenifitId.containskey(accId)){
                        for(string benefitId: mapOfAccountIdAndBenifitId.get(accId)){
                            PRM_AccountBenefitAssociation__c abaObj = new PRM_AccountBenefitAssociation__c();
                            abaObj.PRM_Account_Id__c= accId;
                            abaObj.PRM_Partner_Benefit_Id__c= benefitId;  
                            setOfTempABARecord.add(abaObj);
                        }  
                    }
                }
            } 
            // calling Generic method 
            finalListOfAbaToUpdate = processingAba(setOfTempABARecord,setOfExsistingABARecord);
            System.debug('finalListOfAbaToUpdate :-'+finalListOfAbaToUpdate);
            if(finalListOfAbaToUpdate !=null && !finalListOfAbaToUpdate.isEmpty()){
                database.SaveResult[] result = database.update(finalListOfAbaToUpdate,false);
                System.debug('result :-'+result);
            }
        }catch(exception ex){
            system.debug('error in Class :- PRM_Benefit_Group_Benefit_Assoc_Utility in Method :-benefitRemovalFromAccount :'+ex.getMessage() +'On Line number :-'+ex.getLineNumber());
        }    
    }  
    
    /* *****************************************************************************************************************************************
* author:      Sheetal Bhargava    
* Date:        12/2/2020
* Parameters:  Set<PRM_AccountBenefitAssociation__c> tempAbaRecord,Set<PRM_AccountBenefitAssociation__c> exsistingAbaRecord
* Return:      List<PRM_AccountBenefitAssociation__c>
* Description: This is a generic method to check for if a aba record exsist and then process it for inactivation. 
****************************************************************************************************************************************** */
    public static List<PRM_AccountBenefitAssociation__c> processingAba(Set<PRM_AccountBenefitAssociation__c> tempAbaRecord,Set<PRM_AccountBenefitAssociation__c> exsistingAbaRecord){
        System.debug('Inside generic method processingAba');
        system.debug('tempAbaRecord :-'+tempAbaRecord);
        system.debug('exsistingAbaRecord :-'+exsistingAbaRecord);
        Set<PRM_AccountBenefitAssociation__c> setOfAbaToProcess = new Set<PRM_AccountBenefitAssociation__c>();
        List<PRM_AccountBenefitAssociation__c> listOfFinalAbaToProcess = new list<PRM_AccountBenefitAssociation__c>();
        
        if(tempAbaRecord !=null && !tempAbaRecord.isEmpty() && exsistingAbaRecord != null && !exsistingAbaRecord.isEmpty()){
            for(PRM_AccountBenefitAssociation__c aba: exsistingAbaRecord){
                for(PRM_AccountBenefitAssociation__c tempAba: tempAbaRecord){
                    if((tempAba.PRM_Account_Id__c == aba.PRM_Account_Id__c) && (tempAba.PRM_Partner_Benefit_Id__c == aba.PRM_Partner_Benefit_Id__c)){
                        setOfAbaToProcess.add(aba); 
                    }
                }
            }
        }
        
        if(setOfAbaToProcess != null && !setOfAbaToProcess.isempty()){
            for(PRM_AccountBenefitAssociation__c abaRecord: setOfAbaToProcess){
                if(abaRecord.PRM_Source__c =='Specialty'){
                    abaRecord.PRM_Status_Nm__c = 'Inactive';
                    abaRecord.PRM_Source__c='';
                    abaRecord.PRM_Status_Reason_Txt__c = 'Benefit is no longer applicable';
                    listOfFinalAbaToProcess.add(abaRecord);
                }else{
                    abaRecord.PRM_Source__c= 'Tier';
                    listOfFinalAbaToProcess.add(abaRecord);  
                }
            }
        }
        return listOfFinalAbaToProcess;
    }

    
}