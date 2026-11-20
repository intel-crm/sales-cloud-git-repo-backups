/********************************************************************************************************************************************************************
* Class Name  : Core_MDF_IPA_AccountUserMapping
* Version     : 1.0
* Created Date: 22-May-2020
* Modification Log :
* Developer            Date               Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       22-May-2020        This class will create account user record for the IPA virtual corp account and the contact record 
                                          on which audience list was added. It will process when IPA audience list will be added to any contact.
*****************************************************************************************************************************************/
public  without sharing class Core_MDF_IPA_AccountUserMapping implements Queueable {
    public static Map<Id,Set<Id>> userIdCorpAcctIdSetForInsert = new Map<Id,Set<Id>>();
    public static Map<Id,Id> userIdCorpAcctId = new Map<Id,Id>();
    public Map<Id,Id> userIdToCorpIdMap = new Map<Id,Id>();
    public Core_MDF_IPA_AccountUserMapping(Map<Id,Id> userIdCorpAcctId){
        userIdToCorpIdMap = userIdCorpAcctId;
    }
    
/*****************************************************************************************************
Method Name:        execute
@return  :          void
Description:        This is the main class of Queuable class. This method will create account user record for 
                    IPA account and user which we'll get from calling class.
@Added By:          Accenture - VD - 22-May-2020
Modified By:        Date:       Changes:
******************************************************************************************************/        
    //Main method
    public void execute(QueueableContext context) {
        //storing group id for querying PGM of these groups
        Set<Id> groupIdSet = new Set<Id>();         
        try{                                                                                
            userIdCorpAcctId = userIdToCorpIdMap;
            createPnumRecords(userIdCorpAcctId);
            Core_MDF_PNUM_Insert_Finalizer fc = new Core_MDF_PNUM_Insert_Finalizer(userIdCorpAcctId);
            System.attachFinalizer(fc);           
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); } 
    }
    /*****************************************************************************************************
Method Name:        createPnumRecords
@return  :          void
Description:        This method will create PNUM records.
@Added By:          Accenture - VD - 01-June-2020
Modified By:        Date:       Changes:
******************************************************************************************************/     
    public static void createPnumRecords(Map<Id,Id> userIdCorpAcctIdMap){
        List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>(); 
        for(Core_MDF_Partner_Node_User_Mapping__c existingPnum : [Select id,Core_MDF_User__c,Core_MDF_Account__c,Core_MDF_Active_Ind__c from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_User__c in:userIdCorpAcctIdMap.keyset() and Core_MDF_Active_Ind__c = false]){
            for(Id userId : userIdCorpAcctIdMap.keyset()){
                if(userIdCorpAcctIdMap.get(userId) == existingPnum.Core_MDF_Account__c && userId == existingPnum.Core_MDF_User__c){
                    userIdCorpAcctIdMap.remove(userId);
                    if(existingPnum.Core_MDF_Active_Ind__c == false){
                        Core_MDF_Partner_Node_User_Mapping__c pnum = new Core_MDF_Partner_Node_User_Mapping__c();
                        pnum.id = existingPnum.id;
                        pnum.Core_MDF_Account__c = existingPnum.Core_MDF_Account__c;
                        pnum.Core_MDF_User__c = userId;
                        pnum.Core_MDF_Active_Ind__c = true;
                        pnumList.add(pnum);
                    }
                }
            }
        }
        userIdCorpAcctId = userIdCorpAcctIdMap;
        try{  
            if(pnumList!=Null && pnumList.size()>0){
                Database.update(pnumList,false);
            } 
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); } 
    }
    
    public without sharing class Core_MDF_PNUM_insert_Finalizer implements Finalizer{
        //Added without sharing as part of ATHR fix
        Map<Id,Id> userIdCorpAcctId = new Map<Id,Id>();
        public Core_MDF_PNUM_insert_Finalizer(Map<Id,Id> userIdCorpAcctIdMap){
            userIdCorpAcctId = userIdCorpAcctIdMap;
        }        
        public void execute(FinalizerContext ctx) {
            List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>(); 
            for(Id userId : userIdCorpAcctId.keyset()){
                if(userIdCorpAcctId.get(userId) != null){                    
                    Core_MDF_Partner_Node_User_Mapping__c pnum = new Core_MDF_Partner_Node_User_Mapping__c();
                    pnum.Core_MDF_Account__c = userIdCorpAcctId.get(userId);
                    pnum.Core_MDF_User__c = userId;
                    pnumList.add(pnum);                     
                }
            }
            try{  
                if(pnumList!=Null && pnumList.size()>0){
                    Database.Insert(pnumList,false);
                } 
            }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); } 
        }
    }
}