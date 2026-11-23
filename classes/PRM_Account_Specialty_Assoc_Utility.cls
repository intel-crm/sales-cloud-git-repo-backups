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

    public static void callAccountAndPgmSyncPlatformEvent(Map<Id,PRM_Account_Specialty_Association__c> newMap, Map<Id,PRM_Account_Specialty_Association__c> oldMap, String dmlOperationType){
        try{
            
            //To By-pass the method execution
             if(Core_MDF_Utility.byPassFeature('Bypass_AccountPgmSync_ASA')){
                return;
            }

            List<Core_MDF_Account_PGM_Sync__e> accountPgmSyncPE = new List<Core_MDF_Account_PGM_Sync__e>();
            for(PRM_Account_Specialty_Association__c asa : newMap.values()){
                if(asa.PRM_Account_Type__c == Label.PRM_Intel_Account_Record_Type){
                    if(dmlOperationType == 'Insert'){
                        PRM_Account_Specialty_Association__c accSpecialAssociation = new PRM_Account_Specialty_Association__c(Id = asa.Id, PRM_Account_Id__c = asa.PRM_Account_Id__c, PRM_InActive_Ind__c = asa.PRM_InActive_Ind__c);
                        accountPgmSyncPE.add(new Core_MDF_Account_PGM_Sync__e(Core_MDF_DML_Operation_Type_txt__c = 'Insert', Core_MDF_JSON_Data__c = JSON.serialize(accSpecialAssociation)));
                    }else if(dmlOperationType == 'Update' && oldMap.containsKey(asa.Id) && asa.PRM_InActive_Ind__c != oldMap.get(asa.Id).PRM_InActive_Ind__c){
                        PRM_Account_Specialty_Association__c accSpecialAssociation = new PRM_Account_Specialty_Association__c(Id = asa.Id, PRM_Account_Id__c = asa.PRM_Account_Id__c, PRM_InActive_Ind__c = asa.PRM_InActive_Ind__c);
                        accountPgmSyncPE.add(new Core_MDF_Account_PGM_Sync__e(Core_MDF_DML_Operation_Type_txt__c = 'Update', Core_MDF_JSON_Data__c = JSON.serialize(accSpecialAssociation)));
                    }
                }
            }

            if(!accountPgmSyncPE.isEmpty()){
                //Publish Platform event(Core_MDF_Account_PGM_Sync__e)
                List<Database.SaveResult> results = EventBus.publish(accountPgmSyncPE);
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
}