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
    //Constructor to set the input values from the calling class
   
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
            //getting all the groups ids from userToGroupListMap map  
            /*if(userToGroupListMap!=Null && userToGroupListMap.size()>0){
                for(Id userId : userToGroupListMap.keyset()){
                    groupIdSet.addAll(userToGroupListMap.get(userId));         
                }
            }  
            //calling this method to create map of group id and intel acct by querying PGM
            if(groupIdSet!=Null && groupIdSet.size()>0){
                getGrpIdAndItsIntelAcctFrmPGM(groupIdSet,userToGroupListMap);  
            }*/
            userIdCorpAcctId = userIdToCorpIdMap;
            createPnumRecords(userIdCorpAcctId);
           
             Core_MDF_PNUM_Insert_Finalizer fc = new Core_MDF_PNUM_Insert_Finalizer(userIdCorpAcctId);
        System.attachFinalizer(fc);           
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); } 
    }
    /*****************************************************************************************************
Method Name:        getGrpIdAndItsIntelAcctFrmPGM
@return  :          void
Description:        This method will create map of group id and intel account by querying PGM.
@Added By:          Accenture - VD - 01-June-2020
Modified By:        Date:       Changes:
******************************************************************************************************/   
    
    /*public static void getGrpIdAndItsIntelAcctFrmPGM(Set<Id> groupIdSet,Map<Id,List<Id>> userToGroupListMap){
        //To store list all the intel accts to get their virtual corp accts
        Set<Id> intelAcctIdSet = new Set<Id>();
        
        //map to store group id and its associated acct id from PGM
        Map<Id,Set<Id>> grpIdandIntAcctIdSetMap = new Map<Id,Set<Id>>();
        
        try{            
            for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Core_MDF_Account__c,Core_MDF_Group_Id__c 
                                                         FROM Core_MDF_Partner_Group_Mapping__c where Core_MDF_Group_Id__c IN : groupIdSet
                                                         AND Core_MDF_Type_of_Access__c =: Label.Core_MDF_External_label_for_PGM 
                                                         AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =: Label.Core_MDF_IPA_Technical_program_name AND Core_MDF_Inactive_Ind__c = false AND Core_MDF_Account__r.Core_MDF_CoMarketingActive__c = true])
            {
                if(grpIdandIntAcctIdSetMap.containsKey(pgm.Core_MDF_Group_Id__c)){
                    grpIdandIntAcctIdSetMap.get(pgm.Core_MDF_Group_Id__c).add(pgm.Core_MDF_Account__c);
                }
                else{
                    grpIdandIntAcctIdSetMap.put(pgm.Core_MDF_Group_Id__c, new Set<Id>{pgm.Core_MDF_Account__c});
                }
                //to query all its virtual corp accts
                intelAcctIdSet.add(pgm.Core_MDF_Account__c);
            }
            //calling this method to create map of user and its associated intel account
            if(grpIdandIntAcctIdSetMap!=Null && grpIdandIntAcctIdSetMap.size()>0 && intelAcctIdSet!=Null && intelAcctIdSet.size()>0){
                getUserAndItsIntelAcct(userToGroupListMap,grpIdandIntAcctIdSetMap,intelAcctIdSet);    
            }
                        
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); } 
    }*/
    
    /**********************************************************************************************************************************
Method Name:        getUserAndItsIntelAcct
@return  :          void
Description:        This method will create user and its associated intel account map from userToGroupListMap map and grpIdandIntAcctIdSetMap map
@Added By:          Accenture - VD - 01-June-2020
Modified By:        Date:       Changes:
***********************************************************************************************************************************/                  
    
   /* public static void getUserAndItsIntelAcct(Map<Id,List<Id>> userToGroupListMap, Map<Id,Set<Id>> grpIdandIntAcctIdSetMap, Set<Id> intelAcctIdSet){        
        //map to store user id and its associated acct id from PGM
        Map<Id,Set<Id>> userIdIntAcctIdSetMap = new Map<id,Set<Id>>();
        
        try{            
            for(Id userId : userToGroupListMap.keyset()){
                for(Id grpId : userToGroupListMap.get(userId)){
                    if(grpIdandIntAcctIdSetMap!=null && grpIdandIntAcctIdSetMap.size()>0 && grpIdandIntAcctIdSetMap.containsKey(grpId) && (!userIdIntAcctIdSetMap.containskey(userId))){
                        Set<Id> acctIdSet = new Set<Id>();
                        acctIdSet.addAll(grpIdandIntAcctIdSetMap.get(grpId));
                        userIdIntAcctIdSetMap.put(userId, acctIdSet);                                               
                    }
                }
            }  
            //calling this method to get virtual corp account list of intel account
            if(intelAcctIdSet!=Null && intelAcctIdSet.size()>0 && userIdIntAcctIdSetMap!=Null && userIdIntAcctIdSetMap.size()>0){
                getIntelAcctAndItsVirtualCorpAcct(intelAcctIdSet,userIdIntAcctIdSetMap);  
            }                       
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); } 
    }*/
    /*****************************************************************************************************
Method Name:        getIntelAcctAndItsVirtualCorpAcct
@return  :          void
Description:        This method will create map of intel account and list of all its corp account
@Added By:          Accenture - VD - 01-June-2020
Modified By:        Date:       Changes:
******************************************************************************************************/  
    /*public static void getIntelAcctAndItsVirtualCorpAcct(Set<Id> intelAcctIdSet,Map<Id,Set<Id>> userIdIntAcctIdSetMap){
        //Map of intel account Id and their virtual corp account ids
        Map<Id,Set<Id>> intAcctVirtualAcctSetMap = new Map<Id,Set<Id>>();
        
        try{            
            for(Account virtualCorpAcct : [Select id,Core_MDF_CoMarketing_Ultimate_Account__c from Account 
                                           where Core_MDF_CoMarketing_Ultimate_Account__c IN : intelAcctIdSet 
                                           AND Core_MDF_Parent_Fund_Account__r.RecordType.DeveloperName =: Label.Core_MDF_MasterAccount
                                           AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =: Label.Core_MDF_IPA_Technical_program_name])
            {                                               
                if(intAcctVirtualAcctSetMap.containsKey(virtualCorpAcct.Core_MDF_CoMarketing_Ultimate_Account__c)){
                    intAcctVirtualAcctSetMap.get(virtualCorpAcct.Core_MDF_CoMarketing_Ultimate_Account__c).add(virtualCorpAcct.Id);
                }
                else{
                    intAcctVirtualAcctSetMap.put(virtualCorpAcct.Core_MDF_CoMarketing_Ultimate_Account__c, new Set<Id>{virtualCorpAcct.Id});
                }               
            }    

            //calling this method to get user and account list to create pnum records
            if(userIdIntAcctIdSetMap!=Null && userIdIntAcctIdSetMap.size()>0 && intAcctVirtualAcctSetMap!=Null && intAcctVirtualAcctSetMap.size()>0){
                getUserAndAcctRecordForPnumCreation(userIdIntAcctIdSetMap,intAcctVirtualAcctSetMap);
            }                        
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); } 
    }*/
    
    /*****************************************************************************************************
Method Name:        getUserAndAcctRecordForPnumCreation
@return  :          void
Description:        This method will create map of user and account to create PNUM records
@Added By:          Accenture - VD - 01-June-2020
Modified By:        Date:       Changes:
******************************************************************************************************/      
    /*public static void getUserAndAcctRecordForPnumCreation(Map<Id,Set<Id>> userIdIntAcctIdSetMap,Map<Id,Set<Id>> intAcctVirtualAcctSetMap){
        //map to store user id and corp acct id with which pnum will be created
        Map<Id,Set<Id>> userIdCorpAcctIdSet = new Map<Id,Set<Id>>();
        
        try{            
            for(Id userId : userIdIntAcctIdSetMap.keyset()){
                for(Id intelAcctId : userIdIntAcctIdSetMap.get(userId)){
                    if(intAcctVirtualAcctSetMap!=null && intAcctVirtualAcctSetMap.size()>0 && intAcctVirtualAcctSetMap.containsKey(intelAcctId) && (!userIdCorpAcctIdSet.containskey(userId))){                         
                        Set<Id> corpAacctIdSet = new Set<Id>();
                        corpAacctIdSet.addAll(intAcctVirtualAcctSetMap.get(intelAcctId));
                        userIdCorpAcctIdSet.put(userId, corpAacctIdSet);                                                
                    }
                }
            }

            //calling this method create PNUM records
            if(userIdCorpAcctIdSet!=Null && userIdCorpAcctIdSet.size()>0){
                createPnumRecords(userIdCorpAcctIdSet);
            }
                        
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); } 
    }*/
    
    /*****************************************************************************************************
Method Name:        createPnumRecords
@return  :          void
Description:        This method will create PNUM records.
@Added By:          Accenture - VD - 01-June-2020
Modified By:        Date:       Changes:
******************************************************************************************************/     
    /*public static void createPnumRecords(Map<Id,Set<Id>> userIdCorpAcctIdSet){
        //Creating list of pnums to be inserted
        List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>(); 
        for(Core_MDF_Partner_Node_User_Mapping__c existingPnum : [Select id,Core_MDF_User__c,Core_MDF_Account__c from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_User__c in:userIdCorpAcctIdSet.keyset() and Core_MDF_Active_Ind__c = false]){
            for(Id userId : userIdCorpAcctIdSet.keyset()){
                if(userIdCorpAcctIdSet.get(userId).contains(existingPnum.Core_MDF_Account__c) && userId == existingPnum.Core_MDF_User__c){
                    userIdCorpAcctIdSet.get(userId).remove(existingPnum.Core_MDF_Account__c);
                    Core_MDF_Partner_Node_User_Mapping__c pnum = new Core_MDF_Partner_Node_User_Mapping__c();
                    pnum.id = existingPnum.id;
                    pnum.Core_MDF_Account__c = existingPnum.Core_MDF_Account__c;
                    pnum.Core_MDF_User__c = userId;
                    pnum.Core_MDF_Active_Ind__c = true;
                    pnumList.add(pnum);
                }
            }
        }
        userIdCorpAcctIdSetForInsert = userIdCorpAcctIdSet;
        try{  
            if(pnumList!=Null && pnumList.size()>0){
                Database.update(pnumList,false);
            } 
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); } 
    }*/
    //created by AN
    public static void createPnumRecords(Map<Id,Id> userIdCorpAcctIdMap){
        //Creating list of pnums to be inserted
        List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>(); 
        for(Core_MDF_Partner_Node_User_Mapping__c existingPnum : [Select id,Core_MDF_User__c,Core_MDF_Account__c,Core_MDF_Active_Ind__c from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_User__c in:userIdCorpAcctIdMap.keyset() /*and Core_MDF_Active_Ind__c = false*/]){
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