public without sharing class Core_MDF_PnumForIPA implements Queueable {
    
    public static void execute(QueueableContext context) {
        try{
            Map<Id,List<Id>> userToGroupList = new Map<Id,List<Id>>();  
            
            List<id> grpId1 = new List<Id>();
            grpId1.add('00Gg0000005WFKREA4');       
            
            userToGroupList.put('005g0000007XwHm',grpId1);
            userToGroupList.put('005g0000007XwHr',grpId1);            
            
            Set<Id> groupIdSet = new Set<Id>();
            Set<Id> userIdSet = new Set<Id>();
            
            //getting all the groups ids from userToGroupList map        
            for(Id userId : userToGroupList.keyset()){
                //to store userids which is used in getting existing pnum records for these users
                userIdSet.add(userId);
                for(Id grpId : userToGroupList.get(userId)){
                    groupIdSet.add(grpId);
                }            
            }
            
            //map to store group id and its associated acct id from PGM
            Map<Id,Set<Id>> grpIdandIntAcctIdSetMap = new Map<Id,Set<Id>>();
            Set<String> programName = new Set<String>{'Intel Partner Alliance'};
            List<Core_MDF_Partner_Group_Mapping__c> pgmRecords = Core_MDF_PGM_Utility.fetchExternalPGMRecords(programName,null,null,groupIdSet,null,true);
            System.debug('pgmRecords'+pgmRecords);
            for(Core_MDF_Partner_Group_Mapping__c pgm : pgmRecords/*[SELECT id,Core_MDF_Account__c,Core_MDF_Channel_Program__c,Core_MDF_Type_of_Access__c,Core_MDF_Group_Id__c 
                                                         FROM Core_MDF_Partner_Group_Mapping__c where Core_MDF_Group_Id__c IN : groupIdSet
                                                         AND Core_MDF_Type_of_Access__c='External' AND Core_MDF_Channel_Program__r.Name = 'Intel Partner Alliance' 
                                                         AND Core_MDF_CoMarketingActive_Ind__c  = true]*/){
                if(grpIdandIntAcctIdSetMap.containsKey(pgm.Core_MDF_Group_Id__c)){
                    grpIdandIntAcctIdSetMap.get(pgm.Core_MDF_Group_Id__c).add(pgm.Core_MDF_Account__c);
                }
                else{
                    grpIdandIntAcctIdSetMap.put(pgm.Core_MDF_Group_Id__c, new Set<Id>{pgm.Core_MDF_Account__c});
                } 
            }    
            
            //map to store user id and its associated acct id from PGM
            Map<Id,Set<Id>> userIdIntAcctIdSetMap = new Map<id,Set<Id>>();
            if(userToGroupList!=null && userToGroupList.size()>0){
                for(Id userId : userToGroupList.keyset()){
                    for(Id grpId : userToGroupList.get(userId)){
                        if(grpIdandIntAcctIdSetMap!=null && grpIdandIntAcctIdSetMap.size()>0 && grpIdandIntAcctIdSetMap.containsKey(grpId)){
                            if(userIdIntAcctIdSetMap.containskey(userId)){
                                Set<Id> acctIdSet = userIdIntAcctIdSetMap.get(userId);
                                acctIdSet.addAll(grpIdandIntAcctIdSetMap.get(grpId));
                                userIdIntAcctIdSetMap.put(userId,acctIdSet);                        
                            }
                            else{
                                Set<Id> acctIdSet = new Set<Id>();
                                acctIdSet.addAll(grpIdandIntAcctIdSetMap.get(grpId));
                                userIdIntAcctIdSetMap.put(userId, acctIdSet);                        
                            }
                        }
                    }
                }  
            }
            
            //To store list all the intel accts to get their virtual corp accts
            Set<Id> intelAcctIdSet = new Set<Id>();
            
            for(Id userId : userIdIntAcctIdSetMap.keyset()){
                for(Id acctId : userIdIntAcctIdSetMap.get(userId)){
                    intelAcctIdSet.add(acctId);
                }
            }
            
            //Map of intel account Id and their virtual corp account ids
            Map<Id,Set<Id>> intAcctVirtualAcctSetMap = new Map<Id,Set<Id>>();
            Set<Id> virtualCorpAcctIdSet = new Set<Id>();
            
            for(Account virtualCorpAcct : [Select id,name,Core_MDF_CoMarketing_Ultimate_Account__c from Account 
                                           where Core_MDF_CoMarketing_Ultimate_Account__c IN : intelAcctIdSet 
                                           AND Core_MDF_Parent_Fund_Account__r.RecordType.DeveloperName = 'Mastered_Account']){
                virtualCorpAcctIdSet.add(virtualCorpAcct.Id);//
                                               
                if(intAcctVirtualAcctSetMap.containsKey(virtualCorpAcct.Core_MDF_CoMarketing_Ultimate_Account__c)){
                    intAcctVirtualAcctSetMap.get(virtualCorpAcct.Core_MDF_CoMarketing_Ultimate_Account__c).add(virtualCorpAcct.Id);
                }
                else{
                    intAcctVirtualAcctSetMap.put(virtualCorpAcct.Core_MDF_CoMarketing_Ultimate_Account__c, new Set<Id>{virtualCorpAcct.Id});
                }                                   
            }
            
            //map to store user id and corp acct id with which pnum will be created
            Map<Id,Set<Id>> userIdCorpAcctIdSet = new Map<Id,Set<Id>>();
            
            for(Id userId : userIdIntAcctIdSetMap.keyset()){
                for(Id intelAcctId : userIdIntAcctIdSetMap.get(userId)){
                    if(intAcctVirtualAcctSetMap!=null && intAcctVirtualAcctSetMap.size()>0 && intAcctVirtualAcctSetMap.containsKey(intelAcctId)){ 
                        if(userIdCorpAcctIdSet.containskey(userId)){
                            Set<Id> corpAacctIdSet = userIdCorpAcctIdSet.get(userId);
                            corpAacctIdSet.addAll(intAcctVirtualAcctSetMap.get(intelAcctId));
                            userIdCorpAcctIdSet.put(userId,corpAacctIdSet);                        
                        }
                        else{
                            Set<Id> corpAacctIdSet = new Set<Id>();
                            corpAacctIdSet.addAll(intAcctVirtualAcctSetMap.get(intelAcctId));
                            userIdCorpAcctIdSet.put(userId, corpAacctIdSet);                        
                        }           
                    }
                }
            }
            
            //Creating list of pnums to be inserted
            List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>();          
            
            for(Id userId : userIdCorpAcctIdSet.keyset()){
                for(Id acctId : userIdCorpAcctIdSet.get(userId)){
                    Core_MDF_Partner_Node_User_Mapping__c pnum = new Core_MDF_Partner_Node_User_Mapping__c();
                    pnum.Core_MDF_Account__c = acctId;
                    pnum.Core_MDF_User__c = userId;
                    pnumList.add(pnum);                                 
                }
            }
            if(pnumList!=Null && pnumList.size()>0){
                Database.insert(pnumList);
            }            
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); } 
    } 
}