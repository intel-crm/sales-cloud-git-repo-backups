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
    public static  boolean firstRunAfterUpdate = true;
    public static  boolean firstRunAfterInsert = true;
    public static  boolean firstRunBeforeUpdate = true;
    public static  boolean firstRunBeforeInsert = true;
    //public static boolean ipaRefresh = Boolean.valueOf(label.PRM_IPARefresh);  //IPA2.0-TWC727-2861
    public static void specialtyDuplicateCheck(List<PRM_Account_Specialty_Association__c> specialtyAssocNewList,Map<Id,PRM_Account_Specialty_Association__c> oldMap)//Cyclomatic Complexity of 17=>14
    {
    /*if(!ipaRefresh  || test.isrunningtest()){ //IPA2.0-TWC727-2861
        Set<String> specialtyIdSet = new Set<String>();// To store the PRM_Unique_Combination_Key__c field values from trigger.new
        Set<String> accountIdSet = new Set<String>();
        Map<String,String> uniqueMap = new Map<String,String>();// To store the PRM_Unique_Combination_Key__c field values from Database
        Set<String> duplicateSet = new Set<String>();
       
        for(PRM_Account_Specialty_Association__c asa: specialtyAssocNewList){
            PRM_Account_Specialty_Association__c asaOld = oldMap != null && !oldMap.isEmpty() ? (PRM_Account_Specialty_Association__c) oldMap.get(asa.id) : null;
            if(asaOld == null || asaOld.PRM_Specialty_Id__c != asa.PRM_Specialty_Id__c||asaOld.PRM_Partner_Role__c != asa.PRM_Partner_Role__c)
            {
                specialtyIdSet.add(asa.PRM_Specialty_Id__c);
                accountIdSet.add(asa.PRM_Account_Id__c);
                uniqueMap.put(asa.PRM_Specialty_Id__c+''+asa.PRM_Account_Id__c+''+asa.PRM_Partner_Role__c,asa.PRM_Account_Id__c); 
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
                if(duplicateSet.contains(asa.PRM_Specialty_Id__c+''+asa.PRM_Account_Id__c+''+asa.PRM_Partner_Role__c)){
                    asa.addError(System.label.PRM_Account_Specialty_Assoc_Error);
                }            
            } 
        }
    }*/ // IPA refresh - switch removal
}
    
    /* **********************************************************************************************************************************************
* author       : Sheetal Bhargava    
* Date         : 20/12/2019
* Parameters   : list<PRM_Account_Specialty_Association__c> lstOfASA, map<id,PRM_Account_Specialty_Association__c> mapOldASAById 
* Return       : Void
* Description  : This method is used to update Partner Speciality field on Account with Speciality on insertion and updation of ASA field fpr US533785
* Modification : 2/4/2020 Made Changes for User Story :- US619513 Reflecting specialist value in place of speciality
************************************************************************************************************************************************* */
  //Commenting down this method as a part of Specialty EOL Story (TWC729-4729 -> Specialty EOL- remove Specialist values from Account)
  /*
    public static void updatePartnerSpecialityOnAccount(list<PRM_Account_Specialty_Association__c> lstOfASA , map<id,PRM_Account_Specialty_Association__c> mapOldASAById){
        
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
                    
                    if(asa.PRM_InActive_Ind__c ==true ){
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
                //Updated code for US619513
                if(setOfAccountId != null && !setOfAccountId.isEmpty() && setOfSpecialityId !=null && !setOfSpecialityId.isEmpty() && mapOfAccountIdToListofSpecialityIdMadeInactive.keyset() !=null && !mapOfAccountIdToListofSpecialityIdMadeInactive.keyset().isempty()){
                    lstOfExsistingASARecord = [Select PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_Specialty_Id__r.Name,PRM_InActive_Ind__c,PRM_Partner_Role__c from PRM_Account_Specialty_Association__c where PRM_Account_Id__c IN: setOfAccountId AND PRM_Specialty_Id__c IN: setOfSpecialityId AND PRM_InActive_Ind__c = False];
                }
            } 

            if(setOfSpecialityId !=null && !setOfSpecialityId.isEmpty()){
                for(PRM_Specialty__c speciality:[select id,Name from PRM_Specialty__c where id IN: setOfSpecialityId]){
                    mapOfSpecialityIdWithSpeciality.put(speciality.id,speciality);   
                }
            }

            if(setOfAccountId !=null && !setOfAccountId.isEmpty() && mapOfSpecialityIdWithSpeciality.keyset() !=null && ! mapOfSpecialityIdWithSpeciality.keyset().isEmpty()){
                for(Account acc:[select id,name,Core_IPA_Partner_Speciality__c from account where Id IN: setOfAccountId]){
                    if(acc.Core_IPA_Partner_Speciality__c != null){
                        for(string str: acc.Core_IPA_Partner_Speciality__c.replace(System.Label.PRM_Specialist,System.Label.PRM_Specialty).replace('High Performance Computing Specialty','High Performance Computing Data Center Specialty').split(';')){ // Changes made for US619513
                            setOfAccountPicklistValues.add(str);
                        }

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
                        acc.Core_IPA_Partner_Speciality__c = acc.Core_IPA_Partner_Speciality__c.replace(System.Label.PRM_Specialty,System.Label.PRM_Specialist).replace('High Performance Computing Data Center Specialist','High Performance Computing Specialist'); // added code for US619513
                    }
                    
                    lstOfAccountToUpdate.add(acc);
                    setOfAccountPicklistValues.clear();
                }
            } 

            /*if(lstOfAccountToUpdate !=null && !lstOfAccountToUpdate.isEmpty()){
                database.update(lstOfAccountToUpdate,false);
            }
            if(lstOfAccountToUpdate != null && !lstOfAccountToUpdate.IsEmpty()){
                if(!System.isBatch()){
                    Schema.SObjectType acc = Schema.Account.getSObjectType();
                    System.enqueueJob(new ContactERPMIntegrationStatusHandler(lstOfAccountToUpdate,acc));
                }
                else if(System.isBatch()){update lstOfAccountToUpdate;
                }
            
            }
        }catch(Exception e){
            system.debug('error in class PRM_ASA_TriggerHandler :- '+e.getMessage()+'on line no:- '+e.getLineNumber());
        }   
    } */
    
    /* *****************************************************************************************************************************************
* author:      Teja Munagala      
* Date:        27/01/2020
* Parameters:  list<PRM_Account_Specialty_Association__c> lstOfASA, map<id,PRM_Account_Specialty_Association__c> mapOldASAById 
* Return:      Void
* Description: This method is used to update Partner Speciality field on Account with Speciality on insertion and updation of ASA field
****************************************************************************************************************************************** */

    public static void updateStartandEndDates(List<PRM_Account_Specialty_Association__c> specialtyAssocNewList, Map<Id, PRM_Account_Specialty_Association__c> oldMap) {//Cyclomatic Complexity of 19=>14
   /*if(!ipaRefresh  || test.isrunningtest()){ //IPA2.0-TWC727-2861)
    for (PRM_Account_Specialty_Association__c asa : specialtyAssocNewList) {
        PRM_Account_Specialty_Association__c asaOld = oldMap != null ? oldMap.get(asa.Id) : null;
        boolean inActiveChanged = asaOld != null && asa.PRM_InActive_Ind__c != asaOld.PRM_InActive_Ind__c;

        if (oldMap == null || !oldMap.containsKey(asa.Id) || (inActiveChanged && !asa.PRM_InActive_Ind__c)) {
            asa.PRM_Start_Date_Dt__c = Date.today();
            if (asa.PRM_End_Date_Dt__c != null && asa.PRM_End_Date_Dt__c <= Date.today()) {
                asa.PRM_End_Date_Dt__c = null;
            }
        } else if (inActiveChanged && asa.PRM_InActive_Ind__c) {
            if (asa.PRM_End_Date_Dt__c == null || asa.PRM_End_Date_Dt__c > Date.today()) {
                asa.PRM_End_Date_Dt__c = Date.today();
            }
        }

        if (inActiveChanged) {
            asa.PRM_Status_Change_Dt__c = DateTime.now();
        }
    }
}*/ // IPA Refresh- switch removal
}

    
    //Inactivating Account Specialty Qual Criteria when ASA is inactivated   
    public static void inactivateQualitativeCriteria(List<PRM_Account_Specialty_Association__c> specialtyAssocNewList,Map<Id,PRM_Account_Specialty_Association__c> oldMap){//Cyclomatic Complexity of 11=>10
        List<PRM_Account_Specialty_Association__c> asanewlist = new List<PRM_Account_Specialty_Association__c>();
        /*if(!ipaRefresh  || test.isrunningtest()){ //IPA2.0-TWC727-2861
        for(PRM_Account_Specialty_Association__c asa: specialtyAssocNewList){
        PRM_Account_Specialty_Association__c asaOld = oldMap != null ? oldMap.get(asa.Id) : null;
            if(asaOld.PRM_InActive_Ind__c != asa.PRM_InActive_Ind__c && asa.PRM_InActive_Ind__c==True){
                asanewlist.add(asa);
            }
        }
        List<PRM_Account_Specialty_Qual_Criteria__c> asqcList = new List<PRM_Account_Specialty_Qual_Criteria__c>();
        if(asanewlist !=null && !asanewlist.isEmpty()){
            Map<Id,PRM_Account_Specialty_Association__c> asanewListMap=new Map<Id,PRM_Account_Specialty_Association__c>(asanewlist);
            for(PRM_Account_Specialty_Qual_Criteria__c asqc: [select id, PRM_Account_Specialty_Association_Id__c,PRM_InActive_Ind__c  from PRM_Account_Specialty_Qual_Criteria__c where PRM_Account_Specialty_Association_Id__c in : asanewListMap.keySet() AND PRM_InActive_Ind__c = FALSE]){
                asqc.PRM_InActive_Ind__c = TRUE;
                asqcList.add(asqc);            
            }        
        }
        if(asqcList !=null && !asqcList.isEmpty()){
            update asqcList;
        }    
    }*/ // IPA Refresh - switch removal
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
        Map<string,Set<string>> mapOfspecialityAndListOgBenifitGroup = new Map<string,Set<string>>();
        Set<string> benifitGroup = new Set<string>();
        Map<String,Set<String>> mapOfBenifitGroupToBenifit = new Map<String,Set<string>>(); 
        Set<string> accountSet = new Set<string>();
        Map<String,Set<String>> mapOfSpecialityIdAndBenifitId = new Map<String,Set<String>>();
        Map<String,Set<String>> mapOfAccounIdIdAndBenifitId = new Map<String,Set<String>>();
        Set<PRM_AccountBenefitAssociation__c> setOfTempABARecord = new Set<PRM_AccountBenefitAssociation__c>();
        List<PRM_AccountBenefitAssociation__c> listOfFinalABArecord = new List<PRM_AccountBenefitAssociation__c>();
        
        //Updating code for data model changes for multiple asa Start
        /*if((!ipaRefresh  || test.isrunningtest())){//IPA2.0-TWC727-2861
        if(specialtyAssocNewList != null && !specialtyAssocNewList.isEmpty()){
            for(PRM_Account_Specialty_Association__c asa: specialtyAssocNewList){
                if(asa.PRM_InActive_Ind__c == true){
                    setOfInitialaccountSet.add(asa.PRM_Account_Id__c);
                    setOfInitialSpeciality.add(asa.PRM_Specialty_Id__c); 
                    initialAsalist.add(asa);
                }  
            }
        }
        
        if(setOfInitialaccountSet != null && !setOfInitialaccountSet.isEmpty() && setOfInitialSpeciality !=null && !setOfInitialSpeciality.isEmpty()){
            lstOfExsistingASARecord = [Select PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_Specialty_Id__r.Name,PRM_InActive_Ind__c,PRM_Partner_Role__c from PRM_Account_Specialty_Association__c where PRM_Account_Id__c IN: setOfInitialaccountSet AND PRM_Specialty_Id__c IN: setOfInitialSpeciality AND PRM_InActive_Ind__c = False];    
        }
        
        if(initialAsalist != null && !initialAsalist.isEmpty()){
            For(PRM_Account_Specialty_Association__c asa: initialAsalist){
                if(! DupeSpecialityCheck(asa.PRM_Account_Id__c,asa.PRM_Specialty_Id__c,lstOfExsistingASARecord)){
                    processedAsaList.add(asa);  
                }  
            }  
        }
        
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
        //Fetching benefit group from speciality. 
        if(setOfSpeciality !=null && !setOfSpeciality.isEmpty()){
            for(PRM_Specialty_Benefit_Group_Association__c sbgRecord: [select id,name,PRM_Specialty_Id__c,PRM_Benefit_Group_Id__c,PRM_Specialty_Id__r.name from PRM_Specialty_Benefit_Group_Association__c where PRM_Specialty_Id__c IN: setOfSpeciality AND PRM_InActive_Ind__c = false AND PRM_Benefit_Group_Id__c != null]){
                if(mapOfspecialityAndListOgBenifitGroup.containskey(sbgRecord.PRM_Specialty_Id__c)){
                    Set<string> setOfbenifitGroup = mapOfspecialityAndListOgBenifitGroup.get(sbgRecord.PRM_Specialty_Id__c);
                    setOfbenifitGroup.add(sbgRecord.PRM_Benefit_Group_Id__c);
                    mapOfspecialityAndListOgBenifitGroup.put(sbgRecord.PRM_Specialty_Id__c,setOfbenifitGroup);
                }
                else{
                    mapOfspecialityAndListOgBenifitGroup.put(sbgRecord.PRM_Specialty_Id__c, new Set<string> {sbgRecord.PRM_Benefit_Group_Id__c} );
                }
                benifitGroup.add(sbgRecord.PRM_Benefit_Group_Id__c);
            }     
        }
        
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
        
        // associating accountid to benifit id
        
        if(mapOfAccountIdAndListOfSpecialityId.keyset() != null && !mapOfAccountIdAndListOfSpecialityId.keyset().isEmpty()){
            for(string str: mapOfAccountIdAndListOfSpecialityId.keyset()){
                Set<string> listofBenifit = new Set<string>();
                for(string lstOfSpeciality: mapOfAccountIdAndListOfSpecialityId.get(str)){
                    if(lstOfSpeciality != null && mapOfSpecialityIdAndBenifitId.containskey(lstOfSpeciality)){
                        listofBenifit.addall(mapOfSpecialityIdAndBenifitId.get(lstOfSpeciality));    
                    }
                }
                if(listofBenifit != null && !listofBenifit.IsEmpty()){
                    mapOfAccounIdIdAndBenifitId.put(str,listOfBenifit);
                }
            }  
        }
        
        //Exsisting aba record 
        
        List<PRM_AccountBenefitAssociation__c> exsistingAbaRecord = new List<PRM_AccountBenefitAssociation__c>(); 
        exsistingAbaRecord = [select id, PRM_Source__c, PRM_Status_Nm__c, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, PRM_Partner_Benefit_Id__c  from PRM_AccountBenefitAssociation__c 
        where (PRM_Account_Id__c IN: accountSet or PRM_Account_Id__r.Core_IPA_One_Partner_Id__c IN:accountSet) AND PRM_Partner_Benefit_Id__c In: setOfBenifitId  AND PRM_Status_Nm__c ='Active' AND PRM_Source__c INCLUDES ('Specialty','Select Benefit')];
        Set<PRM_AccountBenefitAssociation__c> setOfExsistingAbaRecord = new Set<PRM_AccountBenefitAssociation__c>(exsistingAbaRecord);
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
        
        listOfFinalABArecord = PRM_Benefit_Group_Benefit_Assoc_Utility.processingAba(setOfTempABARecord,setOfExsistingAbaRecord);
        
        //To avoid too many queable issue from BatchContext, we added System.isBatch()
        if(listOfFinalABArecord !=null && !listOfFinalABArecord.isEmpty() && !System.isBatch()){
            //database.SaveResult[] result =database.update(listOfFinalABArecord,false);
            database.update(listOfFinalABArecord,false);
        }
        
    } */ // IPA refresh - switch removal
    }
    
    /* *****************************************************************************************************************************************
* author       : Sheetal Bhargava    
* Date         : 25/06/2020
* Parameters   : List<PRM_Account_Specialty_Association__c> specialtyAssocNewList,Map<Id,PRM_Account_Specialty_Association__c> oldMap 
* Return       : Void
* Description  : This method is used to roll up Specialty/Select Benefit on its associated opid Account
* User Story   : US688694 
****************************************************************************************************************************************** */
    
    public static void opidSpecialityRollup(List<PRM_Account_Specialty_Association__c> specialtyAssocNewList,Map<Id,PRM_Account_Specialty_Association__c> oldMap){
        set<PRM_Account_Specialty_Association__c> setOfAsaToProcess = new set<PRM_Account_Specialty_Association__c>();
        set<String> setOfAccountId = new set<String>();
        set<String> setOfSpecialityId = new set<String>();
        Set<String> specPartnerRole = new Set<String>();
        map<String,String> mapOfAccToOpidAcc = new map<String,String>();
        set<String> setOfParentAccId = new set<String>();
        map<string,set<String>> mapOfPartnerAccountToAcmRole = new map<string,set<String>>(); 
        list<PRM_Account_Specialty_Association__c> lstOfAsaToUpsert = new list<PRM_Account_Specialty_Association__c>();
        /*if(!ipaRefresh  || test.isrunningtest()){//IPA2.0-TWC727-2861
        if(specialtyAssocNewList != null && !specialtyAssocNewList.isEmpty()){
            for(PRM_Account_Specialty_Association__c asa: specialtyAssocNewList){
                if(!asa.PRM_InActive_Ind__c){
                    setOfAsaToProcess.add(asa);
                    setOfAccountId.add(asa.PRM_Account_Id__c);
                    setOfSpecialityId.add(asa.PRM_Specialty_Id__c); 
                    specPartnerRole.add(asa.PRM_Partner_Role__c);
                }
            } 
        }
        
        //Fetching opid Parent account of intel account
        if(setOfAccountId != null && !setOfAccountId.isEmpty()){
            for(Core_Account_Group_Member__c cagm: [Select id,name,Core_Inactive_Ind__c,Core_Partner_Account_Id__c,Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c IN: setOfAccountId AND Core_Inactive_Ind__c = false AND Core_Partner_Account_Id__c != null]){
                mapOfAccToOpidAcc.put(cagm.Core_Intel_Account_Id__c,cagm.Core_Partner_Account_Id__c);
                setOfParentAccId.add(cagm.Core_Partner_Account_Id__c);  
            }
        }
        
        //Finding Acm Role of partner account
        if(setOfParentAccId != null && !setOfParentAccId.isEmpty()){
            for(PRM_AccountChannelMembership__c acm: [select id,PRM_Account_Id__c,PRM_Channel_Program_Id__c,PRM_Channel_Program_Id__r.name, PRM_Partner_Role__c, PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Status_Nm__c =:System.Label.PRM_Status AND PRM_Account_Id__c IN: setOfParentAccId AND PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance]){
                if(mapOfPartnerAccountToAcmRole.containskey(acm.PRM_Account_Id__c)){
                    Set<string> setOfRole = mapOfPartnerAccountToAcmRole.get(acm.PRM_Account_Id__c);
                    setOfRole.add(acm.PRM_Partner_Role__c);
                    mapOfPartnerAccountToAcmRole.put(acm.PRM_Account_Id__c,setOfRole);
                }
                else{
                    mapOfPartnerAccountToAcmRole.put(acm.PRM_Account_Id__c, new Set<string> {acm.PRM_Partner_Role__c} ); 
                }    
            }   
        }
        
        //Finding Exsisting ASA for parent account
        List<PRM_Account_Specialty_Association__c> lstOfExsistingAsa = new List<PRM_Account_Specialty_Association__c>();
        set<PRM_Account_Specialty_Association__c> setOfExsistingASA = new set<PRM_Account_Specialty_Association__c>();
        
        if(setOfParentAccId != null && !setOfParentAccId.isEmpty() && setOfSpecialityId != null && !setOfSpecialityId.isEmpty() && specPartnerRole != null && !specPartnerRole.isEmpty()){
            lstOfExsistingAsa = [Select id,name,PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Specialty_Association__c where PRM_Account_Id__c IN: setOfParentAccId AND PRM_Specialty_Id__c IN: setOfSpecialityId AND PRM_Partner_Role__c IN:specPartnerRole];
        } 
        if(lstOfExsistingAsa != null && !lstOfExsistingAsa.isEmpty()){
            setOfExsistingASA.addAll(lstOfExsistingAsa);   
        }
        
        //Creating temporary asa record
        set<PRM_Account_Specialty_Association__c> setOfTempAsa = new set<PRM_Account_Specialty_Association__c>(); 
        if(setOfAsaToProcess != null && !setOfAsaToProcess.isEmpty()){
            for(PRM_Account_Specialty_Association__c asa: setOfAsaToProcess){
                PRM_Account_Specialty_Association__c asaobj = new PRM_Account_Specialty_Association__c();
                if(mapOfAccToOpidAcc.keyset() != null && mapOfAccToOpidAcc.containskey(asa.PRM_Account_Id__c)){
                    asaobj.PRM_Account_Id__c = mapOfAccToOpidAcc.get(asa.PRM_Account_Id__c);   
                }
                asaobj.PRM_Specialty_Id__c= asa.PRM_Specialty_Id__c;
                asaobj.PRM_Partner_Role__c= asa.PRM_Partner_Role__c;
                asaobj.PRM_InActive_Ind__c= False;
                set<string> setofRole = new set<string>(); 
                if(mapOfPartnerAccountToAcmRole != null && mapOfPartnerAccountToAcmRole.keyset() != null && !mapOfPartnerAccountToAcmRole.keyset().isEmpty() && mapOfPartnerAccountToAcmRole.containsKey(asaobj.PRM_Account_Id__c)){
                    setofRole = mapOfPartnerAccountToAcmRole.get(asaobj.PRM_Account_Id__c);   
                }
                if(setofRole != null && !setofRole.isEmpty() && setofRole.contains(asaobj.PRM_Partner_Role__c)){
                    setOfTempAsa.add(asaobj);   
                }  
            }  
        }
        
        //checking if need to create a new record or to update a exsisting one 
        if(setOfTempAsa != null && !setOfTempAsa.isEmpty()){
            for(PRM_Account_Specialty_Association__c tempasa: setOfTempAsa){
                Boolean newRecord = true;
                if(setOfExsistingASA != null && !setOfExsistingASA.isEmpty()){
                    for(PRM_Account_Specialty_Association__c exsistingAsa: setOfExsistingASA){
                        if((tempasa.PRM_Account_Id__c == exsistingAsa.PRM_Account_Id__c) && (tempasa.PRM_Specialty_Id__c == exsistingAsa.PRM_Specialty_Id__c) && (tempasa.PRM_Partner_Role__c == exsistingAsa.PRM_Partner_Role__c)){
                            if(exsistingAsa.PRM_InActive_Ind__c == True){
                                exsistingAsa.PRM_InActive_Ind__c = False;
                                exsistingAsa.PRM_End_Date_Dt__c=Null;
                                lstOfAsaToUpsert.add(exsistingAsa);
                            } 
                            newRecord= false;
                            break;
                        }
                    }  
                }
                if(newRecord){
                    tempasa.PRM_Start_Date_Dt__c= system.today();
                    lstOfAsaToUpsert.add(tempasa);
                }
            }   
        }
        database.upsertResult[] result;
        if(lstOfAsaToUpsert != null && !lstOfAsaToUpsert.isEmpty() && setOfParentAccId != null && !setOfParentAccId.isEmpty()){
            result = database.upsert(lstOfAsaToUpsert,false);
        }
        
        set<string> setOfOpidAsa = new set<string>(); 
        string asaId;
        list<PRM_Account_Specialty_Association__c> lstOfAsa = new list<PRM_Account_Specialty_Association__c>();
        
        if(result != null && !result.isEmpty()){
            for(Database.UpsertResult sr : result){
                if(sr.isSuccess()){
                    asaId = sr.getId();
                    if(asaId != null && asaId !=''){
                        setOfOpidAsa.add(asaId);  
                    }
                }
            }  
        }
        if(setOfOpidAsa != null && !setOfOpidAsa.isEmpty() &&(!ipaRefresh  || test.isrunningtest())){//IPA2.0-TWC727-2861
        for(PRM_Account_Specialty_Association__c asaObj: [select id,name,PRM_Account_Id__c,PRM_InActive_Ind__c,PRM_Notes_Txt__c,PRM_Partner_Role__c,PRM_Specialty_Id__c,PRM_Specialty_Type__c,PRM_Account_Type__c from PRM_Account_Specialty_Association__c where Id IN: setOfOpidAsa]){
            lstOfAsa.add(asaObj);
        }    
        }
    }*/ // IPA Refresh - switch removal
        
      /*  if(lstOfAsa !=null && !lstOfAsa.isEmpty()){
            updatePartnerSpecialityOnAccount(lstOfAsa,null);
        }*/
    }
    
    /* *****************************************************************************************************************************************
* author       : Sheetal Bhargava    
* Date         : 06/04/2020
* Parameters   : String accountId, String specialityId, List<PRM_Account_Specialty_Association__c> listOfASA 
* Return       : Boolean
* Description  : This method is used to Check if for specific Account and specilaity , multiple asa record exisit or not.
****************************************************************************************************************************************** */
    
    Public static Boolean DupeSpecialityCheck(String accountId, String specialityId, List<PRM_Account_Specialty_Association__c> listOfASA){
        boolean result = false;
        //List<PRM_Account_Specialty_Association__c> lstOfSpecificAsaRecord = new List<PRM_Account_Specialty_Association__c>();
        
        /*if(listOfASA != null && !listOfASA.isempty() && (!ipaRefresh  || test.isrunningtest())){ //IPA2.0-TWC727-2861
            for(PRM_Account_Specialty_Association__c asa: listOfASA){
                if(asa.PRM_Account_Id__c == accountId && asa.PRM_Specialty_Id__c == specialityId){
                    result = true; 
                    break;
                }
            }
        }*/ // IPA Refresh - switch removal
        return result;
    }
    /* *****************************************************************************************************************************************
* author       : UTKARSH    
* Date         : 03/07/2020
* Description  : This method inactivates ASA on parent account if ASA got inactivated from child account.
* User story number    :US706417
****************************************************************************************************************************************** */
    public static void InactiveASAOnParentAcc(List<PRM_Account_Specialty_Association__c> asaList,Map<Id,PRM_Account_Specialty_Association__c> oldMap){
        boolean executeLogic = false;
        Set<Id> accidSet = new Set<Id>();
        Set<Id> specialtyIdSet = new Set<Id>();
        Set<Id> parentAccId = new Set<Id>();
        Set<Id> childAccId = new Set<Id>();
        Set<Id> activeParentAccIdSet = new Set<Id>();
        Set<String> specPartnerRole = new Set<String>();
        List<PRM_Account_Specialty_Association__c> updateParentASA = new List<PRM_Account_Specialty_Association__c>();
        Map<Id,Id> mapLocationAccOpid = new Map<Id,Id>();
        Map<Id,Set<Id>> mapofAccSpec = new Map<Id,Set<Id>>();
        /*if(!ipaRefresh  || test.isrunningtest()){//IPA2.0-TWC727-2861
        for(PRM_Account_Specialty_Association__c asa: asaList){ 
            PRM_Account_Specialty_Association__c asaOld = oldMap != null && !oldMap.isEmpty() ? (PRM_Account_Specialty_Association__c) oldMap.get(asa.id) : null;
            if(asaOld != null && (asaOld.PRM_InActive_Ind__c == false && asa.PRM_InActive_Ind__c == true))
            {
                executeLogic = true; 
                accidSet.add(asa.PRM_Account_Id__c);
                specialtyIdSet.add(asa.PRM_Specialty_Id__c);
                specPartnerRole.add(asa.PRM_Partner_Role__c);
            }
        }
        if(executeLogic){
            if(accidSet != null && !accidSet.IsEmpty()){ //Fetching parent account id.
                for(Core_Account_Group_Member__c agm : [Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Intel_Account_Id__c IN :accidSet AND Core_Inactive_Ind__c = false]){
                    parentAccId.add(agm.Core_Partner_Account_Id__c);
                }
            }
            if(parentAccId != null && !parentAccId.IsEmpty()){ //Fetching other child accounts id from the parent accounts.
                for(Core_Account_Group_Member__c agm : [Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Partner_Account_Id__c IN :parentAccId AND Core_Inactive_Ind__c = false]){
                    childAccId.add(agm.Core_Intel_Account_Id__c);
                    mapLocationAccOpid.put(agm.Core_Intel_Account_Id__c,agm.Core_Partner_Account_Id__c);
                }
            }
            if((childAccId != null && !childAccId.IsEmpty()) && (specialtyIdSet != null && !specialtyIdSet.IsEmpty()) && (specPartnerRole != null && !specPartnerRole.IsEmpty())){ //Fetching parent account id if its child account has same ASA configuration present.
                for(PRM_Account_Specialty_Association__c asa :[Select Id,Name,PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_Specialty_Id__r.Name,PRM_InActive_Ind__c,PRM_Account_Id__r.Name,PRM_Partner_Role__c From PRM_Account_Specialty_Association__c Where PRM_Partner_Role__c IN :specPartnerRole AND PRM_Account_Id__c IN :childAccId AND PRM_Specialty_Id__c IN :specialtyIdSet AND PRM_InActive_Ind__c = false]){
                    Set<Id> activeSpecSet = new Set<Id>();
                    activeParentAccIdSet.add(mapLocationAccOpid.get(asa.PRM_Account_Id__c));
                    if(mapofAccSpec.get(asa.PRM_Account_Id__c) != null && !mapofAccSpec.get(asa.PRM_Account_Id__c).IsEmpty()){
                        activeSpecSet = mapofAccSpec.get(asa.PRM_Account_Id__c);
                    }
                    activeSpecSet.add(asa.PRM_Specialty_Id__c);
                    mapofAccSpec.put(mapLocationAccOpid.get(asa.PRM_Account_Id__c),activeSpecSet);
                }
            }
            if((parentAccId != null && !parentAccId.IsEmpty()) && (specialtyIdSet != null && !specialtyIdSet.IsEmpty())){ //Inactivating ASA from parent account
                for(PRM_Account_Specialty_Association__c asa :[Select Id,Name,PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_Specialty_Id__r.Name,PRM_InActive_Ind__c,PRM_Partner_Role__c From PRM_Account_Specialty_Association__c Where PRM_Account_Id__c IN :parentAccId AND PRM_Specialty_Id__c IN :specialtyIdSet AND PRM_InActive_Ind__c = false]){
                    if((activeParentAccIdSet == null || activeParentAccIdSet.IsEmpty() || !mapofAccSpec.get(asa.PRM_Account_Id__c).contains(asa.PRM_Specialty_Id__c)) && specPartnerRole.contains(asa.PRM_Partner_Role__c)){
                        asa.PRM_InActive_Ind__c = true;
                        asa.PRM_End_Date_Dt__c=system.today();
                        updateParentASA.add(asa);
                    }
                }
            }
            try{
                Database.SaveResult[] result;
                if(updateParentASA != null && !updateParentASA.IsEmpty()){
                    result= Database.update(updateParentASA,false);
                }

                set<string> setOfOpidAsa = new set<string>(); 
                string asaId;
                list<PRM_Account_Specialty_Association__c> lstOfAsa = new list<PRM_Account_Specialty_Association__c>();
                
                if(result != null && !result.isEmpty()){
                    for(Database.SaveResult sr : result){
                        if(sr.isSuccess()){
                            asaId = sr.getId();
                            if(asaId != null && asaId !=''){
                                setOfOpidAsa.add(asaId);  
                            }
                        }
                    }  
                }
                if(setOfOpidAsa != null  && !setOfOpidAsa.isEmpty()){
                for(PRM_Account_Specialty_Association__c asaObj: [select id,name,PRM_Account_Id__c,PRM_InActive_Ind__c,PRM_Notes_Txt__c,PRM_Partner_Role__c,PRM_Specialty_Id__c,PRM_Specialty_Type__c,PRM_Account_Type__c from PRM_Account_Specialty_Association__c where Id IN: setOfOpidAsa]){
                    lstOfAsa.add(asaObj);
                }    
                }
                
              /*  if(lstOfAsa !=null && !lstOfAsa.isEmpty()){
                    updatePartnerSpecialityOnAccount(lstOfAsa,null);
                }*/
                /*if(lstOfAsa !=null && !lstOfAsa.isEmpty()){
                    inactivateBenefitAssociation(lstOfAsa,null);    
                }           
                
            }catch(Exception e){
                system.debug('Exception occured :- '+e.getMessage()+'on line no:- '+e.getLineNumber());
            }
        }
    }*/ // IPA Refresh - switch removal
}
    //Added by Vijay(Agate Team) as a part Suppress Email functionality from Userstory TWC729-174
    public static void suppressEmail(List<PRM_Account_Specialty_Association__c> asaList){
        //Map<Id,String> conIdConEmailMap = new Map<Id,String>();
        List<PRM_Email_Handler__c> emailHandlerRecordsToInsert= new List<PRM_Email_Handler__c>();
        Set<Id>asaAccountIdSet = new Set<Id>();
        String asaPartnerrolestring ='';
        //Set<Id>contactId = new Set<Id>();
        /*if(!ipaRefresh  || test.isrunningtest()){//IPA2.0-TWC727-2861
        for(PRM_Account_Specialty_Association__c eachAsa : asaList){
            // Fetching Partner role and Speciality Id from Success ASA records 
            if(eachAsa.PRM_Suppress_Email__c == true){
                asaAccountIdSet.add(eachAsa.PRM_Account_Id__c);                      
                asaPartnerrolestring = asaPartnerrolestring != null ? asaPartnerrolestring + ';' + eachAsa.PRM_Partner_Role__c : eachAsa.PRM_Partner_Role__c;
                asaPartnerrolestring = asaPartnerrolestring.removeEnd(';');
            }
        }
    }*/ // IPA refresh - switch removal
        
        if((asaAccountIdSet != null && !asaAccountIdSet.IsEmpty()) && (asaPartnerrolestring != null)){
            for(PRM_Account_Contact_Relationship__c accCon : [Select PRM_Account_Id__c,PRM_Contact_Id__c, PRM_Contact_Id__r.email,PRM_Partner_Role__c,PRM_Contact_Id__r.Core_IPA_PartnerRole__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :asaAccountIdSet and PRM_Relationship_Id__r.name=:System.Label.PRM_Primary_Contact AND PRM_InActive_Ind__c = false AND PRM_Status_Nm__c =:System.Label.PRM_ACR_Status]){
                if(accCon.PRM_Contact_Id__r.Core_IPA_PartnerRole__c != null && asaPartnerrolestring.containsAny(accCon.PRM_Contact_Id__r.Core_IPA_PartnerRole__c)){
                    //contactId.add(accCon.PRM_Contact_Id__c);
                    PRM_Email_Handler__c emailHandler = new PRM_Email_Handler__c();
                    emailHandler.PRM_Contact__c =accCon.PRM_Contact_Id__c;				  
                    emailHandler.PRM_Event__c = 'Specialty Addition';
                    emailHandler.PRM_Email_Handler_Status__c = 'Requested For Suppression';
                    emailHandler.PRM_Suppress_Email__c = true;
                    emailHandlerRecordsToInsert.add(emailHandler);                      
                }                
            }
        }
        if(emailHandlerRecordsToInsert!=null && !emailHandlerRecordsToInsert.isEmpty()){
            insert emailHandlerRecordsToInsert;
        }
    }
    
    public static void updateSuppressEmail(List<PRM_Account_Specialty_Association__c> asaList,Map<Id,PRM_Account_Specialty_Association__c> oldMap){
         /*if(!ipaRefresh  || test.isrunningtest()){//IPA2.0-TWC727-2861
        for(PRM_Account_Specialty_Association__c asa :asaList){
            PRM_Account_Specialty_Association__c asaOld ; 
            if(oldMap!=null && !oldMap.isEmpty()) {
                asaOld = (PRM_Account_Specialty_Association__c) oldMap.get(asa.id) ;
            }
            if(asaOld != null && (asaOld.PRM_InActive_Ind__c == false && asa.PRM_InActive_Ind__c == true) && asaOld.PRM_Suppress_Email__c==true)
            {
                asa.PRM_Suppress_Email__c =false;
            }
        }
    }*/ //IPA refresh - switch removal
}
}