/*************************************************************************************************************************************
Apex Class Name     : PRM_Account_Specialty_Assoc_Utility 
Version             : 1.0
Created Date        : Nov 2019

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      02-Dec-2019      Added a new method specialtyDuplicateCheck to restrict duplicate  in insert and update events 
* Sheetal Bhargava   02- April-2020   Made Changes for User Story :- US619513 Reflecting specialist value in place of speciality.

***************************************************************************************************************************************/
public without sharing class PRM_Account_Specialty_Assoc_Utility {
    
    public static void specialtyDuplicateCheck(List<PRM_Account_Specialty_Association__c> specialtyAssocNewList,Map<Id,PRM_Account_Specialty_Association__c> oldMap)
    {
        Set<String> specialtyIdSet = new Set<String>();// To store the PRM_Unique_Combination_Key__c field values from trigger.new
        Set<String> accountIdSet = new Set<String>();
        Map<String,String> uniqueMap = new Map<String,String>();// To store the PRM_Unique_Combination_Key__c field values from Database
        Set<String> duplicateSet = new Set<String>();
        for(PRM_Account_Specialty_Association__c asa: specialtyAssocNewList){
            PRM_Account_Specialty_Association__c asaOld ; 
            if(oldMap!=null && oldMap.size()>0) {asaOld = (PRM_Account_Specialty_Association__c) oldMap.get(asa.id) ;}
            if((oldMap==null) || ((oldMap!=null && oldMap.size()>0)&&(asaOld.PRM_Specialty_Id__c != asa.PRM_Specialty_Id__c)||(asaOld.PRM_Partner_Role__c != asa.PRM_Partner_Role__c)))
            {
                specialtyIdSet.add(asa.PRM_Specialty_Id__c);
                accountIdSet.add(asa.PRM_Account_Id__c);
                uniqueMap.put(asa.PRM_Specialty_Id__c+''+asa.PRM_Account_Id__c+''+asa.PRM_Partner_Role__c,asa.PRM_Account_Id__c); 
                system.debug('uniqueMap======>'+uniqueMap);   
            }
        }
        //querying PRM_Account_Specialty_Association__c records based on accountIdSet and specialtyIdSet values
        if(uniqueMap != null && uniqueMap.keySet().size()>0)
        {
            for(PRM_Account_Specialty_Association__c asa : [SELECT Id,PRM_Specialty_Id__c,PRM_Account_Id__c,PRM_Partner_Role__c FROM PRM_Account_Specialty_Association__c where PRM_Specialty_Id__c IN: specialtyIdSet AND PRM_Account_Id__c IN:accountIdSet]){
                if(asa.PRM_Account_Id__c == uniqueMap.get(asa.PRM_Specialty_Id__c+''+asa.PRM_Account_Id__c+''+asa.PRM_Partner_Role__c))
                {
                    duplicateSet.add(asa.PRM_Specialty_Id__c+''+asa.PRM_Account_Id__c+''+asa.PRM_Partner_Role__c);
                }
            }
        } 
        //iterating over the trigger context and throwing error if duplicate record already exists
        if(duplicateSet != null && duplicateSet.size()>0){
            for(PRM_Account_Specialty_Association__c asa: specialtyAssocNewList){
                asa.PRM_Start_Date_Dt__c=system.today();
                System.debug('specialtyAssocNewList=======>'+asa);
                if(duplicateSet.contains(asa.PRM_Specialty_Id__c+''+asa.PRM_Account_Id__c+''+asa.PRM_Partner_Role__c)){
                    asa.addError(System.label.PRM_Account_Specialty_Assoc_Error);
                }            
            } 
        }
    }
    
/* **********************************************************************************************************************************************
* author       : Sheetal Bhargava    
* Date         : 20/12/2019
* Parameters   : list<PRM_Account_Specialty_Association__c> lstOfASA, map<id,PRM_Account_Specialty_Association__c> mapOldASAById 
* Return       : Void
* Description  : This method is used to update Partner Speciality field on Account with Speciality on insertion and updation of ASA field fpr US533785
* Modification : 2/4/2020 Made Changes for User Story :- US619513 Reflecting specialist value in place of speciality
************************************************************************************************************************************************* */
    
    public static void updatePartnerSpecialityOnAccount(list<PRM_Account_Specialty_Association__c> lstOfASA , map<id,PRM_Account_Specialty_Association__c> mapOldASAById){
        System.debug('Inside updatePartnerSpecialityOnAccount :-');
        System.debug('Inside updatePartnerSpecialityOnAccount :-'+lstOfASA);
        System.debug('Inside updatePartnerSpecialityOnAccount :-'+mapOldASAById);
        
        set<String> setOfAccountId = new set<String>();
        set<String> setOfSpecialityId = new set<String>();
        set<String> setOfAccountPicklistValues = new set<String>();    
        List<Account> lstOfAccountToUpdate = new List<Account>();
        Map<String,Set<String>> mapOfAccountIdToListofSpecialityId = new Map<String,Set<String>>();
        map<string,PRM_Specialty__c> mapOfSpecialityIdWithSpeciality = new map<string,PRM_Specialty__c>();
        Map<String,Set<String>> mapOfAccountIdToListofSpecialityIdMadeInactive = new Map<String,Set<String>>();
        List<PRM_Account_Specialty_Association__c> lstOfExsistingASARecord = new List<PRM_Account_Specialty_Association__c>(); //Updated Code for US619513
        try{
            if(lstOfASA !=null && !lstOfASA.isEmpty() ){
                for(PRM_Account_Specialty_Association__c asa: lstOfASA){
                    
                    if((trigger.IsInsert )||(trigger.IsUpdate && (asa.PRM_Specialty_Id__c != mapOldASAById.get(asa.Id).PRM_Specialty_Id__c || asa.PRM_Account_Id__c != mapOldASAById.get(asa.Id).PRM_Account_Id__c || asa.PRM_InActive_Ind__c != mapOldASAById.get(asa.Id).PRM_InActive_Ind__c))){
                        setOfAccountId.add(asa.PRM_Account_Id__c); 
                        setOfSpecialityId.add(asa.PRM_Specialty_Id__c);
                        
                        // creating map of those asa for which inactive indicator is false
                        
                        if(asa.PRM_InActive_Ind__c == false){
                            if(mapOfAccountIdToListofSpecialityId.containsKey(asa.PRM_Account_Id__c)) {
                                Set<String> specialityId = mapOfAccountIdToListofSpecialityId.get(asa.PRM_Account_Id__c);
                                specialityId.add(asa.PRM_Specialty_Id__c);
                                mapOfAccountIdToListofSpecialityId.put(asa.PRM_Account_Id__c, specialityId);
                            }
                            else {
                                mapOfAccountIdToListofSpecialityId.put(asa.PRM_Account_Id__c, new Set<String> { asa.PRM_Specialty_Id__c });
                            }
                        }
                        
                        // creating map for those asa for which inactive indicator is set true
                        
                        if((asa.PRM_InActive_Ind__c ==true && mapOldASAById.get(asa.Id).PRM_InActive_Ind__c == false) && (asa.PRM_InActive_Ind__c != mapOldASAById.get(asa.Id).PRM_InActive_Ind__c) ){
                            if(mapOfAccountIdToListofSpecialityIdMadeInactive.containsKey(asa.PRM_Account_Id__c)) {
                                Set<String> specialityId = mapOfAccountIdToListofSpecialityIdMadeInactive.get(asa.PRM_Account_Id__c);
                                specialityId.add(asa.PRM_Specialty_Id__c);
                                mapOfAccountIdToListofSpecialityIdMadeInactive.put(asa.PRM_Account_Id__c, specialityId);
                            }
                            else {
                                mapOfAccountIdToListofSpecialityIdMadeInactive.put(asa.PRM_Account_Id__c, new Set<String> { asa.PRM_Specialty_Id__c });
                            }
                        }
                    }
                    
                }
                //Updated code for US619513
                if(setOfAccountId != null && !setOfAccountId.isEmpty() && setOfSpecialityId !=null && !setOfSpecialityId.isEmpty() && mapOfAccountIdToListofSpecialityIdMadeInactive.keyset() !=null && !mapOfAccountIdToListofSpecialityIdMadeInactive.keyset().isempty()){
                    lstOfExsistingASARecord = [Select PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_Specialty_Id__r.Name,PRM_InActive_Ind__c,PRM_Partner_Role__c from PRM_Account_Specialty_Association__c where PRM_Account_Id__c IN: setOfAccountId AND PRM_Specialty_Id__c IN: setOfSpecialityId AND PRM_InActive_Ind__c = False];
                }
            } 
            
            System.debug('setOfAccountId :-'+setOfAccountId);
            System.debug('setOfSpecialityId :-'+setOfSpecialityId);
            System.debug('mapOfAccountIdToListofSpecialityId :-'+mapOfAccountIdToListofSpecialityId);
            System.debug('mapOfAccountIdToListofSpecialityIdMadeInactive :-'+mapOfAccountIdToListofSpecialityIdMadeInactive);
            System.debug('lstOfExsistingASARecord :-'+lstOfExsistingASARecord);
            
            if(setOfSpecialityId !=null && !setOfSpecialityId.isEmpty()){
                for(PRM_Specialty__c speciality:[select id,Name from PRM_Specialty__c where id IN: setOfSpecialityId]){
                    mapOfSpecialityIdWithSpeciality.put(speciality.id,speciality);   
                }
            }
            
            System.debug('mapOfSpecialityIdWithSpeciality :-'+mapOfSpecialityIdWithSpeciality);
            
            if(setOfAccountId !=null && !setOfAccountId.isEmpty() && mapOfSpecialityIdWithSpeciality.keyset() !=null && ! mapOfSpecialityIdWithSpeciality.keyset().isEmpty()){
                for(Account acc:[select id,name,Core_IPA_Partner_Speciality__c from account where Id IN: setOfAccountId]){
                    if(acc.Core_IPA_Partner_Speciality__c != null){
                        system.debug('acc.Core_IPA_Partner_Speciality__c :-'+acc.Core_IPA_Partner_Speciality__c);
                        for(string str: acc.Core_IPA_Partner_Speciality__c.replace(System.Label.PRM_Specialist,System.Label.PRM_Specialty).replace('High Performance Computing Specialty','High Performance Computing Data Center Specialty').split(';')){ // Changes made for US619513
                            setOfAccountPicklistValues.add(str);
                        }
                        System.debug('setOfAccountPicklistValues :-'+setOfAccountPicklistValues);
                        
                        //method to add speciality in account if asa record is active 
                        if(mapOfAccountIdToListofSpecialityId.containsKey(acc.Id) && mapOfAccountIdToListofSpecialityId.keySet() !=null && ! mapOfAccountIdToListofSpecialityId.keySet().isEmpty()){
                            for(string specialityId: mapOfAccountIdToListofSpecialityId.get(acc.id)){
                                if(! setOfAccountPicklistValues.contains(mapOfSpecialityIdWithSpeciality.get(specialityId).name)){
                                    acc.Core_IPA_Partner_Speciality__c= acc.Core_IPA_Partner_Speciality__c+';'+mapOfSpecialityIdWithSpeciality.get(specialityId).name;   
                                }
                            }
                        }
                        
                        //Method to remove speciality from account if asa is inactive
                        if(mapOfAccountIdToListofSpecialityIdMadeInactive.containsKey(acc.Id) && mapOfAccountIdToListofSpecialityIdMadeInactive.keySet() !=null && ! mapOfAccountIdToListofSpecialityIdMadeInactive.keySet().isEmpty()){
                            for(string specialityId: mapOfAccountIdToListofSpecialityIdMadeInactive.get(acc.id)){
                                System.debug('checking result of genreic method :-'+DupeSpecialityCheck(acc.id,specialityId,lstOfExsistingASARecord));
                                if(setOfAccountPicklistValues.contains(mapOfSpecialityIdWithSpeciality.get(specialityId).name) && ! DupeSpecialityCheck(acc.id,specialityId,lstOfExsistingASARecord)){
                                    List<string> lstPicklistValues = acc.Core_IPA_Partner_Speciality__c.replace(System.Label.PRM_Specialist,System.Label.PRM_Specialty).replace('High Performance Computing Specialty','High Performance Computing Data Center Specialty').split(';');// Changes made for US619513
                                    lstPicklistValues.remove(lstPicklistValues.indexOf(mapOfSpecialityIdWithSpeciality.get(specialityId).name));
                                    acc.Core_IPA_Partner_Speciality__c = String.join(lstPicklistValues,';');
                                }   
                            }  
                        }
                    }else{
                        if(mapOfAccountIdToListofSpecialityId.containsKey(acc.Id) && mapOfAccountIdToListofSpecialityId.keySet() !=null && ! mapOfAccountIdToListofSpecialityId.keySet().isEmpty()){
                            for(string specialityId: mapOfAccountIdToListofSpecialityId.get(acc.id)){
                                acc.Core_IPA_Partner_Speciality__c= (acc.Core_IPA_Partner_Speciality__c != NULL ? acc.Core_IPA_Partner_Speciality__c +';' :'') + mapOfSpecialityIdWithSpeciality.get(specialityId).name;      
                            }
                        }
                    }
                    
                    // Updated code for US619513
                    
                    if(acc.Core_IPA_Partner_Speciality__c != null){
                        System.debug('to chck 1 :- '+acc.Core_IPA_Partner_Speciality__c);
                        acc.Core_IPA_Partner_Speciality__c = acc.Core_IPA_Partner_Speciality__c.replace(System.Label.PRM_Specialty,System.Label.PRM_Specialist).replace('High Performance Computing Data Center Specialist','High Performance Computing Specialist'); // added code for US619513
                    }
                    
                    lstOfAccountToUpdate.add(acc);
                    setOfAccountPicklistValues.clear();
                }
            } 
            System.debug('lstOfAccountToUpdate :-'+lstOfAccountToUpdate);
            
            if(lstOfAccountToUpdate !=null && !lstOfAccountToUpdate.isEmpty()){
                database.update(lstOfAccountToUpdate);
            }
            
        }catch(Exception e){
            system.debug('error in class PRM_ASA_TriggerHandler :- '+e.getMessage()+'on line no:- '+e.getLineNumber());
        }   
    }
    
    
    /* *****************************************************************************************************************************************
* author:      Teja Munagala      
* Date:        27/01/2020
* Parameters:  list<PRM_Account_Specialty_Association__c> lstOfASA, map<id,PRM_Account_Specialty_Association__c> mapOldASAById 
* Return:      Void
* Description: This method is used to update Partner Speciality field on Account with Speciality on insertion and updation of ASA field
****************************************************************************************************************************************** */
    
    public static void updateStartandEndDates(List<PRM_Account_Specialty_Association__c> specialtyAssocNewList,Map<Id,PRM_Account_Specialty_Association__c> oldMap){
        List<PRM_Account_Specialty_Association__c> asanewlist = new List<PRM_Account_Specialty_Association__c>();
        for(PRM_Account_Specialty_Association__c asa: specialtyAssocNewList){
            PRM_Account_Specialty_Association__c asaOld ; 
            if(oldMap!=null && oldMap.size()>0) {asaOld = (PRM_Account_Specialty_Association__c) oldMap.get(asa.id) ;}
            if((oldMap==null) || (!oldMap.containskey(asa.Id)||(asaOld.PRM_InActive_Ind__c != asa.PRM_InActive_Ind__c)&&(asa.PRM_InActive_Ind__c==False))){
                asa.PRM_Start_Date_Dt__c= system.today();
                if((asa.PRM_End_Date_Dt__c!=Null)&&(asa.PRM_End_Date_Dt__c<=system.today())){ 
                    asa.PRM_End_Date_Dt__c=Null;
                }    
            }
            else if(((oldMap!=null && oldMap.size()>0)&&(asaOld.PRM_InActive_Ind__c != asa.PRM_InActive_Ind__c)&&(asa.PRM_InActive_Ind__c==true))){
                if((asa.PRM_End_Date_Dt__c==null) ||(asa.PRM_End_Date_Dt__c>system.today())){
                    asa.PRM_End_Date_Dt__c=system.today();
                }
            }   
        }       
    }
    
    //Inactivating Account Specialty Qual Criteria when ASA is inactivated   
    public static void inactivateQualitativeCriteria(List<PRM_Account_Specialty_Association__c> specialtyAssocNewList,Map<Id,PRM_Account_Specialty_Association__c> oldMap){
        List<PRM_Account_Specialty_Association__c> asanewlist = new List<PRM_Account_Specialty_Association__c>();
        for(PRM_Account_Specialty_Association__c asa: specialtyAssocNewList){
            PRM_Account_Specialty_Association__c asaOld ; 
            if(oldMap!=null && oldMap.size()>0) {asaOld = (PRM_Account_Specialty_Association__c) oldMap.get(asa.id) ;}
            if((asaOld.PRM_InActive_Ind__c != asa.PRM_InActive_Ind__c)&&(asa.PRM_InActive_Ind__c==True)){
                asanewlist.add(asa);
            }
        }
        List<PRM_Account_Specialty_Qual_Criteria__c> asqcList = new List<PRM_Account_Specialty_Qual_Criteria__c>();
        if(asanewlist !=null && !asanewlist.isEmpty()){
            for(PRM_Account_Specialty_Qual_Criteria__c asqc: [select id, PRM_Account_Specialty_Association_Id__c,PRM_InActive_Ind__c  from PRM_Account_Specialty_Qual_Criteria__c where PRM_Account_Specialty_Association_Id__c in : asanewlist AND PRM_InActive_Ind__c = FALSE]){
                asqc.PRM_InActive_Ind__c = TRUE;
                asqcList.add(asqc);            
            }        
        }
        if(asqcList !=null && !asqcList.isEmpty()){
            update asqcList;
        }    
    }
    
    /* *****************************************************************************************************************************************
* author       : Sheetal Bhargava    
* Date         : 06/04/2020
* Parameters   : List<PRM_Account_Specialty_Association__c> specialtyAssocNewList,Map<Id,PRM_Account_Specialty_Association__c> oldMap 
* Return       : Void
* Description  : This method is used to inactivate benefits if a asa is inactivated
****************************************************************************************************************************************** */
    
    public static void inactivateBenefitAssociation(List<PRM_Account_Specialty_Association__c> specialtyAssocNewList,Map<Id,PRM_Account_Specialty_Association__c> oldMap){
        Set<string> setOfInitialSpeciality = new Set<string>();
        Set<string> setOfInitialaccountSet = new Set<string>();
        Set<PRM_Account_Specialty_Association__c> initialAsalist = new Set<PRM_Account_Specialty_Association__c>();
        List<PRM_Account_Specialty_Association__c> lstOfExsistingASARecord = new List<PRM_Account_Specialty_Association__c>();
        List<PRM_Account_Specialty_Association__c> processedAsaList = new List<PRM_Account_Specialty_Association__c>();
        Set<string> setOfSpeciality = new Set<string>();
        map<string,set<string>> mapOfAccountIdAndListOfSpecialityId = new map<string,set<string>>();
        map<String,Set<String>> mapOfAccountIdAndSpeciality = new map<String,Set<String>>();
        Map<string,Set<string>> mapOfspecialityAndListOgBenifitGroup = new Map<string,Set<string>>();
        Set<string> benifitGroup = new Set<string>();
        Map<String,Set<String>> mapOfBenifitGroupToBenifit = new Map<String,Set<string>>(); 
        Set<string> accountSet = new Set<string>();
        Set<string> abaSet= new Set<string>();
        Map<String,Set<String>> mapOfSpecialityIdAndBenifitId = new Map<String,Set<String>>();
        Map<String,Set<String>> mapOfAccounIdIdAndBenifitId = new Map<String,Set<String>>();
        Set<PRM_AccountBenefitAssociation__c> setOfTempABARecord = new Set<PRM_AccountBenefitAssociation__c>();
        List<PRM_AccountBenefitAssociation__c> listOfFinalABArecord = new List<PRM_AccountBenefitAssociation__c>();
        
        //Updating code for data model changes for multiple asa Start
        
        if(specialtyAssocNewList != null && !specialtyAssocNewList.isEmpty()){
            for(PRM_Account_Specialty_Association__c asa: specialtyAssocNewList){
                if(asa.PRM_InActive_Ind__c && (asa.PRM_InActive_Ind__c != oldMap.get(asa.Id).PRM_InActive_Ind__c)){
                    setOfInitialaccountSet.add(asa.PRM_Account_Id__c);
                    setOfInitialSpeciality.add(asa.PRM_Specialty_Id__c); 
                    initialAsalist.add(asa);
                }  
            }
        }
        
        // System.debug('setOfInitialaccountSet '+setOfInitialaccountSet);
        // System.debug('setOfInitialSpeciality '+setOfInitialSpeciality);
        // System.debug('initialAsalist '+initialAsalist);
        
        if(setOfInitialaccountSet != null && !setOfInitialaccountSet.isEmpty() && setOfInitialSpeciality !=null && !setOfInitialSpeciality.isEmpty()){
            lstOfExsistingASARecord = [Select PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_Specialty_Id__r.Name,PRM_InActive_Ind__c,PRM_Partner_Role__c from PRM_Account_Specialty_Association__c where PRM_Account_Id__c IN: setOfInitialaccountSet AND PRM_Specialty_Id__c IN: setOfInitialSpeciality AND PRM_InActive_Ind__c = False];    
        }
        
        // System.debug('lstOfExsistingASARecord '+lstOfExsistingASARecord);
        
        if(initialAsalist != null && !initialAsalist.isEmpty()){
            For(PRM_Account_Specialty_Association__c asa: initialAsalist){
                if(! DupeSpecialityCheck(asa.PRM_Account_Id__c,asa.PRM_Specialty_Id__c,lstOfExsistingASARecord)){
                    processedAsaList.add(asa);  
                }  
            }  
        }
        
        // System.debug('processedAsaList '+processedAsaList);
        
        //Updating code for data model changes for multiple asa End
        
        if(processedAsaList != null && !processedAsaList.isEmpty()){
            for(PRM_Account_Specialty_Association__c asa: processedAsaList){
                setOfSpeciality.add(asa.PRM_Specialty_Id__c);
                accountSet.add(asa.PRM_Account_Id__c);
                if(!mapOfAccountIdAndListOfSpecialityId.IsEmpty() && mapOfAccountIdAndListOfSpecialityId.containsKey(asa.PRM_Account_Id__c)){
                    Set<String> setOfSpecialityId = mapOfAccountIdAndListOfSpecialityId.get(asa.PRM_Account_Id__c);
                    setOfSpecialityId.add(asa.PRM_Specialty_Id__c);
                    mapOfAccountIdAndListOfSpecialityId.put(asa.PRM_Account_Id__c,setOfSpecialityId);
                }else{
                    mapOfAccountIdAndListOfSpecialityId.put(asa.PRM_Account_Id__c, new Set<string> {asa.PRM_Specialty_Id__c});
                }                
            }
        }
        
        
        // system.debug('setOfSpeciality'+setOfSpeciality);
        // system.debug('mapOfAccountIdAndListOfSpecialityId'+mapOfAccountIdAndListOfSpecialityId);
        // system.debug('accountSet'+accountSet);
        
        //Fetching benefit group from speciality. 
        if(setOfSpeciality !=null && !setOfSpeciality.isEmpty()){
            for(PRM_Specialty_Benefit_Group_Association__c sbgRecord: [select id,name,PRM_Specialty_Id__c,PRM_Benefit_Group_Id__c,PRM_Specialty_Id__r.name from PRM_Specialty_Benefit_Group_Association__c where PRM_Specialty_Id__c IN: setOfSpeciality AND PRM_InActive_Ind__c = false AND PRM_Benefit_Group_Id__c != null]){
                if(mapOfspecialityAndListOgBenifitGroup.containskey(sbgRecord.PRM_Specialty_Id__c)){
                    Set<string> setOfbenifitGroup = mapOfspecialityAndListOgBenifitGroup.get(sbgRecord.PRM_Specialty_Id__c);
                    setOfbenifitGroup.add(sbgRecord.PRM_Benefit_Group_Id__c);
                    mapOfspecialityAndListOgBenifitGroup.put(sbgRecord.PRM_Specialty_Id__c,setOfbenifitGroup);
                    system.debug('mapOfspecialityAndListOgBenifitGroup if-->'+mapOfspecialityAndListOgBenifitGroup);
                }
                else{
                    mapOfspecialityAndListOgBenifitGroup.put(sbgRecord.PRM_Specialty_Id__c, new Set<string> {sbgRecord.PRM_Benefit_Group_Id__c} ); 
                    system.debug('mapOfspecialityAndListOgBenifitGroup-->'+mapOfspecialityAndListOgBenifitGroup);                   
                }
                benifitGroup.add(sbgRecord.PRM_Benefit_Group_Id__c);
                system.debug('benifitGroup-->'+benifitGroup);
            }     
        }
        
        // System.debug('mapOfspecialityAndListOgBenifitGroup :-'+mapOfspecialityAndListOgBenifitGroup);
        // System.debug('benifitGroup :-'+benifitGroup);
        
        //Fetching benefits from benefit group.
        
        Set<String> setOfBenifitId = new Set<String>(); 
        
        if(benifitGroup !=null && !benifitGroup.isEmpty()){
            for(PRM_Benefit_Group_Benefit_Association__c bgbRecord: [select id,name,PRM_Benefit_Id__c,PRM_Benefit_Group_Id__c from PRM_Benefit_Group_Benefit_Association__c where PRM_Benefit_Group_Id__c In:benifitGroup AND PRM_InActive_Ind__c = false AND PRM_Benefit_Id__c != null]){
                setOfBenifitId.add(bgbRecord.PRM_Benefit_Id__c);
                if(mapOfBenifitGroupToBenifit.containskey(bgbRecord.PRM_Benefit_Group_Id__c)){
                    Set<string> setOfBenifitofBG = new Set<string>();
                    setOfBenifitofBG = mapOfBenifitGroupToBenifit.get(bgbRecord.PRM_Benefit_Group_Id__c);
                    setOfBenifitofBG.add(bgbRecord.PRM_Benefit_Id__c);
                    mapOfBenifitGroupToBenifit.put(bgbRecord.PRM_Benefit_Group_Id__c,setOfBenifitofBG);
                } 
                else{
                    mapOfBenifitGroupToBenifit.put(bgbRecord.PRM_Benefit_Group_Id__c, new Set<string> {bgbRecord.PRM_Benefit_Id__c});   
                }
            }   
        }
        
        // System.debug('mapOfBenifitGroupToBenifit :-'+mapOfBenifitGroupToBenifit);  
        // System.debug('setOfBenifitId :-'+setOfBenifitId);  
        
        
        //associating speciality to benifit
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
                    mapOfSpecialityIdAndBenifitId.put(str,listOfBenifit);
                }
            }  
        }
        
        // system.debug('mapOfSpecialityIdAndBenifitId :-'+mapOfSpecialityIdAndBenifitId);
        
        // associating accountid to benifit id
        
        if(mapOfAccountIdAndListOfSpecialityId.keyset() != null && !mapOfAccountIdAndListOfSpecialityId.keyset().isEmpty()){
            for(string str: mapOfAccountIdAndListOfSpecialityId.keyset()){
                Set<string> listofBenifit = new Set<string>();
                for(string lstOfSpeciality: mapOfAccountIdAndListOfSpecialityId.get(str)){
                    if(lstOfSpeciality != null){
                        if(mapOfSpecialityIdAndBenifitId.containskey(lstOfSpeciality)){
                            listofBenifit.addall(mapOfSpecialityIdAndBenifitId.get(lstOfSpeciality));  
                        }   
                    }
                }
                if(listofBenifit != null && !listofBenifit.IsEmpty()){
                    mapOfAccounIdIdAndBenifitId.put(str,listOfBenifit);
                }
            }  
        }
        
        // System.debug('mapOfAccounIdIdAndBenifitId :-'+mapOfAccounIdIdAndBenifitId);
        
        //Exsisting aba record 
        
        List<PRM_AccountBenefitAssociation__c> exsistingAbaRecord = new List<PRM_AccountBenefitAssociation__c>(); 
        // System.debug('accountSet before query :-'+accountSet);
        // System.debug('setOfBenifitId before query :-'+setOfBenifitId);
        
        exsistingAbaRecord = [select id, PRM_Source__c, PRM_Status_Nm__c, PRM_Account_Id__c, PRM_Partner_Benefit_Id__c  from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c IN: accountSet AND PRM_Partner_Benefit_Id__c In: setOfBenifitId  AND PRM_Status_Nm__c ='Active' AND PRM_Source__c INCLUDES ('Specialty')];
        // System.debug('exsistingAbaRecord :-'+exsistingAbaRecord);
        Set<PRM_AccountBenefitAssociation__c> setOfExsistingAbaRecord = new Set<PRM_AccountBenefitAssociation__c>(exsistingAbaRecord);
        // System.debug('setOfExsistingAbaRecord :-'+setOfExsistingAbaRecord);
        //creating temporary aba to compare
        if(mapOfAccounIdIdAndBenifitId.keyset() !=null && !mapOfAccounIdIdAndBenifitId.keyset().isEmpty()){
            for(string accId: mapOfAccounIdIdAndBenifitId.keyset()){
                if(accId !=null && mapOfAccounIdIdAndBenifitId.containskey(accId)){
                    for(string benefitId: mapOfAccounIdIdAndBenifitId.get(accId)){
                        PRM_AccountBenefitAssociation__c abaObj = new PRM_AccountBenefitAssociation__c();
                        abaObj.PRM_Account_Id__c= accId;
                        abaObj.PRM_Partner_Benefit_Id__c= benefitId;  
                        setOfTempABARecord.add(abaObj);
                    }  
                }
            }
        } 
        
        // System.debug('setOfTempABARecord :-'+setOfTempABARecord);
        
        listOfFinalABArecord = PRM_Benefit_Group_Benefit_Assoc_Utility.processingAba(setOfTempABARecord,setOfExsistingAbaRecord);
        // System.debug('listOfFinalABArecord :-'+listOfFinalABArecord);
        
        if(listOfFinalABArecord !=null && !listOfFinalABArecord.isEmpty()){
            database.SaveResult[] result = database.update(listOfFinalABArecord,false);
            //  System.debug('result :-'+result);
        }
        
        
    }
    
    /* *****************************************************************************************************************************************
* author       : Sheetal Bhargava    
* Date         : 06/04/2020
* Parameters   : String accountId, String specialityId, List<PRM_Account_Specialty_Association__c> listOfASA 
* Return       : Boolean
* Description  : This method is used to Check if for specific Account and specilaity , multiple asa record exisit or not.
****************************************************************************************************************************************** */
    
    Public static Boolean DupeSpecialityCheck(String accountId, String specialityId, List<PRM_Account_Specialty_Association__c> listOfASA){
        // System.debug('Inside DupeSpecialityCheck');
        // System.debug('Inside DupeSpecialityCheck accid:- '+accountId);
        // System.debug('Inside DupeSpecialityCheck specialityId :-'+specialityId);
        // System.debug('Inside DupeSpecialityCheck listOfASA :-'+listOfASA);
        
        boolean result = false;
        List<PRM_Account_Specialty_Association__c> lstOfSpecificAsaRecord = new List<PRM_Account_Specialty_Association__c>();
        
        if(listOfASA != null && !listOfASA.isempty()){
            for(PRM_Account_Specialty_Association__c asa: listOfASA){
                if(asa.PRM_Account_Id__c == accountId && asa.PRM_Specialty_Id__c == specialityId){
                    result = true; 
                    break;
                }
            }
        }
        return result;
    }      
}