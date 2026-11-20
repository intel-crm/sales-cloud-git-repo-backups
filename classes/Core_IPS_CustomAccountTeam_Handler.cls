public without sharing class Core_IPS_CustomAccountTeam_Handler{

    /***************************************************************************************************
    * Version     : 1.0 
    * Created Date: Apr 28 2016
    * Function    : Applies deletes against the Custom_Account_Team__c to the Standard Account Team objects as well.
    * Input Parameters : Old List - AfterDelete trigger list of deleted Custom_Account_Team__c records
    * Output Parameters: None
    * Transactions: After Insert/Delete
    * Used by     : Core_CustomAccountTeamTrigger_Dispatcher
    *
    * Queries Within this Method: 2
    * Queries in Loop: 0
    * Queries from Called methods: 0
    * Called: Once for trigger execution
    *
    * Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Brian Matthews              04/28/2016             Initial Release
    ****************************************************************************************************/
    public static void deleteStandardAccountTeam(List<Core_Account_Team__c> lstCustomDeletes) {
            List <AccountTeamMember> lstAcctTeamMember = new List <AccountTeamMember>();
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        if(!mapFunctionalityNameTriggerExecution.containsKey('deleteStandardAccountTeam') ||
           !mapFunctionalityNameTriggerExecution.get('deleteStandardAccountTeam').Core_Active__c) {
           return;
        }
        
        SET<id> setAcctIds = new SET<id>();
        for (Core_Account_Team__c acctTeamMember : lstCustomDeletes)
            setAcctIds.add(acctTeamMember.Core_Account__c);

        if (setAcctIds.size() == 0)
            return;
        //FLS check added-Venugopal
       if(AccountTeamMember.SObjectType.getDescribe().isAccessible()){        
                                  lstAcctTeamMember = [SELECT Id, AccountId, UserId 
                                                      FROM AccountTeamMember
                                                      WHERE AccountId = :setAcctIds];
       }
        if (lstAcctTeamMember == NULL || lstAcctTeamMember.size() == 0)
            return;    
    
        String searchKey;
        Map <String, AccountTeamMember> mapAcctTeamMembers = new Map <String, AccountTeamMember>();
        for (AccountTeamMember stdAcctTeam : lstAcctTeamMember) {
            searchKey = createSearchKey(stdAcctTeam.AccountId, stdAcctTeam.UserId);
            mapAcctTeamMembers.put(searchKey, stdAcctTeam);
        }

        lstAcctTeamMember.clear();
    
        AccountTeamMember acctTeamMemberId;    
        for (Core_Account_Team__c acctTeam : lstCustomDeletes) {   
            searchKey = createSearchKey(acctTeam.Core_Account__c, acctTeam.Core_Team_Member__c);            
            acctTeamMemberId = mapAcctTeamMembers.get(searchKey);
            if (acctTeamMemberId != NULL)
                lstAcctTeamMember.add(acctTeamMemberId);                
        }

        if (lstAcctTeamMember.size() > 0){ 
            	delete lstAcctTeamMember;
        }
    }
    
    
    /***************************************************************************************************
    * Function      : Utility method for deleteStandardAccountTeam
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Brian Matthews              04/28/2016             Initial Release
    ****************************************************************************************************/
    public static String createSearchKey(Id acctId, Id userId) { 
        return String.valueOf(acctId) + String.valueOf(userId);
    }
    
    
    /***************************************************************************************************
    Version     : 1.0 
    Created Date: 13 Jan 2015
    Function    : This method is used to manage Asset and Project access to FAEs. 
    Input Parameters: New List
    Output Parameters: None
    Transactions: After Insert
    Description: 
    Used in     : Core_CustomAccountTeamTrigger_Dispatcher
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods:
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              01/13/2015              Created
    ****************************************************************************************************/
    public static void  manageSharing(List<Core_Account_Team__c> newList){
        Map<String,Core_Account_Team__c> grantAccessbyUser = new Map<String,Core_Account_Team__c>();
        Map<String,Core_Account_Team__c> revokeAccessbyUser = new Map<String,Core_Account_Team__c>();
        List<Core_Account_Team__c> catList;
        Set<Id> faeUserIds;
        if(newList <> null && newList.size() > 0 && Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('ManageCustomAccountTeam')){        
            Map<Id,List<Core_Account_Team__c>> userIdbyCustAccountTeam = new Map<Id,List<Core_Account_Team__c>>();
            for(Core_Account_Team__c custom_ATObj:newList){
                catList = new List<Core_Account_Team__c>();
                for(Core_Account_Team__c custom_ATObj1:newList){
                    if(custom_ATObj.Core_Team_Member__c == custom_ATObj1.Core_Team_Member__c){
                        catList.add(custom_ATObj1);
                    }
                }
                userIdbyCustAccountTeam.put(custom_ATObj.Core_Team_Member__c,catList);
            }
            if(userIdbyCustAccountTeam.size() > 0)
                faeUserIds = Core_IPS_Helper_Utility.getFAEsFromUsers(userIdbyCustAccountTeam.keyset());
            if(faeUserIds <> null && faeUserIds.size() > 0){
                for(Id faeUserId:faeUserIds){
                    if(userIdbyCustAccountTeam <> null && userIdbyCustAccountTeam.size() > 0 && userIdbyCustAccountTeam.get(faeUserId) <> null){
                        for(Core_Account_Team__c catObj: userIdbyCustAccountTeam.get(faeUserId)){
                            if(catObj.Core_Case_Access__c <> null && catObj.Core_Case_Access__c <> 'None' && catObj.Core_Case_Access__c <> '')
                                grantAccessbyUser.put(String.valueOf(catObj.Core_Team_Member__c)+'#'+String.valueOf(catObj.Core_Account__c),catObj); 
                            if(catObj.Core_Case_Access__c == 'None' || catObj.Core_Case_Access__c == '')
                                revokeAccessbyUser.put(String.valueOf(catObj.Core_Team_Member__c)+'#'+String.valueOf(catObj.Core_Account__c),catObj);       
                        }                            
                    }                    
                }
            }
            /*for(Core_Account_Team__c custom_ATObj:newList){
                if(custom_ATObj.Core_Case_Access__c <> 'None' && custom_ATObj.Core_Case_Access__c <> ''){                    
                    if(faeUserIds <> null && faeUserIds.size() > 0){
                        for(Id faeUserId:faeUserIds){
                            if(userIdbyCustAccountTeam <> null && userIdbyCustAccountTeam.size() > 0 && userIdbyCustAccountTeam.get(faeUserId) <> null)
                                grantAccessList.add(userIdbyCustAccountTeam.get(faeUserId));    
                        }
                    }
                }
                else if(custom_ATObj.Core_Case_Access__c == 'None' || custom_ATObj.Core_Case_Access__c == ''){
                    if(faeUserIds <> null && faeUserIds.size() > 0){
                        for(Id faeUserId:faeUserIds){
                            if(userIdbyCustAccountTeam <> null && userIdbyCustAccountTeam.size() > 0 && userIdbyCustAccountTeam.get(faeUserId) <> null)
                                revokeAccessList.add(userIdbyCustAccountTeam.get(faeUserId));    
                        }
                    }
                } 
            }*/
            
            if(grantAccessbyUser <> null && grantAccessbyUser.size() > 0){
                grantAccess(grantAccessbyUser);
            }
            if(revokeAccessbyUser <> null && revokeAccessbyUser.size() > 0){
                revokeAccess(revokeAccessbyUser);
            }
        }
    }
    
    
    /***************************************************************************************************
    Version     : 1.0 
    Created Date: 02 Mar 2016
    Function    : This method is used to check if the passed List is related to IPS Account or not. 
    Input Parameters: New List
    Output Parameters: List of Custom Account Team
    Transactions: After Insert/Update
    Description: 
    Used in     : ManageAccountTeam Method.
    Number of Queries Within this Method: 1
    Number of Queries in Loop: 0
    Number of Queries from Called methods:
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              03/02/2016              Created
    ****************************************************************************************************/
    public static List<Core_Account_Team__c> ipsRecordsOnly(List<Core_Account_Team__c> newList){        
        List<Core_Account_Team__c> ipsRecords = new List<Core_Account_Team__c>();
        List<Account> accList = new List<Account>();
        if(newList <> null && newList.size() > 0){
            Map<Id,List<Core_Account_Team__c>> accountTeambyAccountId = new Map<Id,List<Core_Account_Team__c>>();
            List<Core_Account_Team__c> catList;
            for(Core_Account_Team__c catObj:newList){
                catList = new List<Core_Account_Team__c>();
                for(Core_Account_Team__c catObj1:newList){
                    if(catObj.Core_Account__c == catObj1.Core_Account__c){
                        catList.add(catObj1);
                    }    
                }
                accountTeambyAccountId.put(catObj.Core_Account__c,catList);
            }
            //FLS check added-Venugopal
            if(Account.SObjectType.getDescribe().isAccessible()){
            accList = [select Id,Core_IPS_Active__c from Account where Id in:accountTeambyAccountId.keyset() and Core_IPS_Active__c = TRUE];
               }
            if(accList <> null && accList.size() > 0){
                for(Account accObj:accList){
                    if(accountTeambyAccountId <> null && accountTeambyAccountId.size() > 0 && accObj.Id <> null && accountTeambyAccountId.get(accObj.Id) <> null && accountTeambyAccountId.get(accObj.Id).size() > 0)
                        ipsRecords.addAll(accountTeambyAccountId.get(accObj.Id));
                }
            }
        }
        return ipsRecords;
    }
    
    /***************************************************************************************************
    Version     : 1.0 
    Created Date: 13 Jan 2015
    Function    : This method is used to grant Asset access to FAEs. 
    Input Parameters: New List
    Output Parameters: None
    Transactions: After Insert/Update
    Description: 
    Used in     : Core_CustomAccountTeamTrigger_Dispatcher
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods:
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              01/13/2015              Created
    ****************************************************************************************************/
    public static void  grantAccess(Map<String,Core_Account_Team__c> customAccountTeambyUser){
        if(customAccountTeambyUser <> null && customAccountTeambyUser.size() > 0 && Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('GrantCustomAccountTeam')){
            Set<Id> userIdSet;
            Map<Id,Set<Id>> faeIdsbyAccountId = new Map<Id,Set<Id>>();
            for(Core_Account_Team__c custom_ATObj:customAccountTeambyUser.values()){
                userIdSet = new Set<Id>();
                for(Core_Account_Team__c custom_ATObj1:customAccountTeambyUser.values()){
                    if(custom_ATObj.Core_Account__c == custom_ATObj1.Core_Account__c && customAccountTeambyUser.get(String.valueOf(custom_ATObj1.Core_Team_Member__c)+'#'+String.valueOf(custom_ATObj1.Core_Account__c)) <> null && customAccountTeambyUser.get(String.valueOf(custom_ATObj1.Core_Team_Member__c)+'#'+String.valueOf(custom_ATObj1.Core_Account__c)).Core_Team_Member__c <> null){
                        //userIdSet.add(custom_ATObj1.Core_Team_Member__c);
                        userIdSet.add(customAccountTeambyUser.get(String.valueOf(custom_ATObj1.Core_Team_Member__c)+'#'+String.valueOf(custom_ATObj1.Core_Account__c)).Core_Team_Member__c);
                    }
                }
                faeIdsbyAccountId.put(custom_ATObj.Core_Account__c,userIdSet);
            }
            
            if(faeIdsbyAccountId <> null && faeIdsbyAccountId.size() > 0){
                Map<Id,Set<Id>> userIdsbyAssetId = new Map<Id,Set<Id>>();
                Map<Id,Set<Id>> userIdsbyProjectId = new Map<Id,Set<Id>>();
                Map<Id,Set<Id>> userIdsbyParsId = new Map<Id,Set<Id>>();
                Map<Id,Set<Id>> assetIdsbyAccountId = Core_IPS_Helper_Utility.getAssetsByAccountId(faeIdsbyAccountId.keyset());
                Map<Id,Set<Id>> projectIdsbyAccountId = Core_IPS_Helper_Utility.getProjectsByAccountId(faeIdsbyAccountId.keyset());
                Map<Id,Set<Id>> parsbyAccountId = Core_IPS_Helper_Utility.getPARsByAccountId(faeIdsbyAccountId.keyset());
                Set<ID> projID=new Set<ID>();
                
                if((assetIdsbyAccountId <> null && assetIdsbyAccountId.size() > 0) || (projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0) || (parsbyAccountId <> null && parsbyAccountId.size() > 0)){
                   //start added by Aayushi US113701
                    for(ID id:projectIdsbyAccountId.keyset()){
                       projID.addAll(projectIdsbyAccountId.get(id)); 
                    }
            Map<Id,Core_IPS_Project__c> projMap=new Map<Id,Core_IPS_Project__c>([Select Id,Core_IPS_Private__c from Core_IPs_Project__c  where Id In: projID ]);		//added by Aayushi US106361
                  //end
                    for(Core_Account_Team__c catObj:customAccountTeambyUser.values()){
                        if(assetIdsbyAccountId <> null && assetIdsbyAccountId.size() > 0 && assetIdsbyAccountId.get(catObj.Core_Account__c) <> null){
                            for(Id astId:assetIdsbyAccountId.get(catObj.Core_Account__c)){
                                if(faeIdsbyAccountId.get(catObj.Core_Account__c) <> null)
                                    userIdsbyAssetId.put(astId,faeIdsbyAccountId.get(catObj.Core_Account__c));
                            }
                        }
                        if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0){
                            for(Id projectId:projectIdsbyAccountId.get(catObj.Core_Account__c)){
                                //If condition modified by Aayushi US113701
                                if(faeIdsbyAccountId.get(catObj.Core_Account__c) <> null && !projMap.get(projectId).Core_IPS_Private__c)
                                    userIdsbyProjectId.put(projectId,faeIdsbyAccountId.get(catObj.Core_Account__c));
                            }
                        }
                        if(parsbyAccountId <> null && parsbyAccountId.size() > 0){
                            for(Id parsId:parsbyAccountId.get(catObj.Core_Account__c)){
                                if(faeIdsbyAccountId.get(catObj.Core_Account__c) <> null)
                                    userIdsbyParsId.put(parsId,faeIdsbyAccountId.get(catObj.Core_Account__c));
                            }
                        }
                    }
                }
                if(userIdsbyProjectId <> null && userIdsbyProjectId.size() > 0 && projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0){
                    //assetId sharing is for userIdsbyProjectId.keyset where Private Project check is present
                    Map<Id,Set<Id>> assetIdsbyProjectId = Core_IPS_Helper_Utility.getAssetsByProjectId(userIdsbyProjectId.keyset());
                    if(assetIdsbyProjectId <> null && assetIdsbyProjectId.size() > 0){
                        for(Core_Account_Team__c catObj:customAccountTeambyUser.values()){
                            if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0 && projectIdsbyAccountId.get(catObj.Core_Account__c) <> null && projectIdsbyAccountId.get(catObj.Core_Account__c).size() > 0){
                                for(Id projectId:projectIdsbyAccountId.get(catObj.Core_Account__c)){
                                    if(assetIdsbyProjectId <> null && assetIdsbyProjectId.size() > 0 && assetIdsbyProjectId.get(projectId) <> null && assetIdsbyProjectId.get(projectId).size() > 0){
                                        for(Id astId:assetIdsbyProjectId.get(projectId)){
                                            userIdsbyAssetId.put(astId,faeIdsbyAccountId.get(catObj.Core_Account__c));
                                        }
                                    }
                                }
                            }
                        }                                
                    }
                }
                if(userIdsbyAssetId <> null && userIdsbyAssetId.size() > 0){
                    Core_SharingUtility.provideAccess('Asset','AssetShare','Read',userIdsbyAssetId);
                }
                if(userIdsbyProjectId <> null && userIdsbyProjectId.size() > 0){
                    Core_SharingUtility.provideAccess('Core_IPS_Project__c','Core_IPS_Project__Share','Read',userIdsbyProjectId);
                }
                if(userIdsbyParsId <> null && userIdsbyParsId.size() > 0){
                    Core_SharingUtility.provideAccess('Core_IPS_MAP_PAR__c','Core_IPS_MAP_PAR__Share','Read',userIdsbyParsId);
                }
            }            
        }
    }
    
    /***************************************************************************************************
    Version     : 1.0 
    Created Date: 13 Jan 2015
    Function    : This method is used to revoke Asset and Project access to FAEs. 
    Input Parameters: New List
    Output Parameters: None
    Transactions: After Insert/Update
    Description: 
    Used in     : Core_CustomAccountTeamTrigger_Dispatcher
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods:
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              01/13/2015              Created
    ****************************************************************************************************/
    public static void  revokeAccess(Map<String,Core_Account_Team__c> customAccountTeambyUser){
        if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('RevokeCustomAccountTeam')){
            Set<Id> userIdSet;
            Map<Id,Set<Id>> faeIdsbyAccountId = new Map<Id,Set<Id>>();
            
            if(customAccountTeambyUser <> null && customAccountTeambyUser.size() > 0){
                for(Core_Account_Team__c custom_ATObj:customAccountTeambyUser.values()){
                    userIdSet = new Set<Id>();
                    for(Core_Account_Team__c custom_ATObj1:customAccountTeambyUser.values()){
                        if(custom_ATObj.Core_Account__c == custom_ATObj1.Core_Account__c && customAccountTeambyUser.get(String.valueOf(custom_ATObj1.Core_Team_Member__c)+'#'+String.valueOf(custom_ATObj1.Core_Account__c)) <> null && customAccountTeambyUser.get(String.valueOf(custom_ATObj1.Core_Team_Member__c)+'#'+String.valueOf(custom_ATObj1.Core_Account__c)).Core_Team_Member__c <> null){
                            //userIdSet.add(custom_ATObj1.Core_Team_Member__c);
                            userIdSet.add(customAccountTeambyUser.get(String.valueOf(custom_ATObj1.Core_Team_Member__c)+'#'+String.valueOf(custom_ATObj1.Core_Account__c)).Core_Team_Member__c);
                        }                    
                    }
                    faeIdsbyAccountId.put(custom_ATObj.Core_Account__c,userIdSet);
                }            
            }
            
            if(faeIdsbyAccountId <> null && faeIdsbyAccountId.size() > 0){
                Map<Id,Set<Id>> userIdsbyAssetId = new Map<Id,Set<Id>>();
                Map<Id,Set<Id>> userIdsbyProjectId = new Map<Id,Set<Id>>();
                Map<Id,Set<Id>> userIdsbyParsId = new Map<Id,Set<Id>>();
                Map<Id,Set<Id>> assetIdsbyAccountId = Core_IPS_Helper_Utility.getAssetsByAccountId(faeIdsbyAccountId.keyset());
                Map<Id,Set<Id>> projectIdsbyAccountId = Core_IPS_Helper_Utility.getProjectsByAccountId(faeIdsbyAccountId.keyset());
                Map<Id,Set<Id>> parsbyAccountId = Core_IPS_Helper_Utility.getPARsByAccountId(faeIdsbyAccountId.keyset());
                
                if((assetIdsbyAccountId <> null && assetIdsbyAccountId.size() > 0) || (projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0) || (parsbyAccountId <> null && parsbyAccountId.size() > 0)){
                    for(Core_Account_Team__c catObj:customAccountTeambyUser.values()){
                        if(assetIdsbyAccountId <> null && assetIdsbyAccountId.size() > 0){
                            for(Id astId:assetIdsbyAccountId.get(catObj.Core_Account__c)){
                                if(faeIdsbyAccountId.get(catObj.Core_Account__c) <> null)
                                    userIdsbyAssetId.put(astId,faeIdsbyAccountId.get(catObj.Core_Account__c));
                            }
                        }
                        if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0){
                            for(Id projectId:projectIdsbyAccountId.get(catObj.Core_Account__c)){
                                if(faeIdsbyAccountId.get(catObj.Core_Account__c) <> null)
                                    userIdsbyProjectId.put(projectId,faeIdsbyAccountId.get(catObj.Core_Account__c));
                            }
                        }
                        if(parsbyAccountId <> null && parsbyAccountId.size() > 0){
                            for(Id parsId:parsbyAccountId.get(catObj.Core_Account__c)){
                                if(faeIdsbyAccountId.get(catObj.Core_Account__c) <> null)
                                    userIdsbyParsId.put(parsId,faeIdsbyAccountId.get(catObj.Core_Account__c));
                            }
                        }
                    }
                }
                if(userIdsbyProjectId <> null && userIdsbyProjectId.size() > 0 && projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0){
                    Map<Id,Set<Id>> assetIdsbyProjectId = Core_IPS_Helper_Utility.getAssetsByProjectId(userIdsbyProjectId.keyset());
                    if(assetIdsbyProjectId <> null && assetIdsbyProjectId.size() > 0){
                        for(Core_Account_Team__c catObj:customAccountTeambyUser.values()){
                            if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0 && projectIdsbyAccountId.get(catObj.Core_Account__c) <> null && projectIdsbyAccountId.get(catObj.Core_Account__c).size() > 0){
                                for(Id projectId:projectIdsbyAccountId.get(catObj.Core_Account__c)){
                                    if(assetIdsbyProjectId <> null && assetIdsbyProjectId.size() > 0 && assetIdsbyProjectId.get(projectId) <> null && assetIdsbyProjectId.get(projectId).size() > 0){
                                        for(Id astId:assetIdsbyProjectId.get(projectId)){
                                            userIdsbyAssetId.put(astId,faeIdsbyAccountId.get(catObj.Core_Account__c));
                                        }
                                    }
                                }
                            }
                        }                                
                    }
                }
                if(userIdsbyAssetId <> null && userIdsbyAssetId.size() > 0){
                    Core_SharingUtility.revokeAccess('Asset','AssetShare',userIdsbyAssetId);
                }
                if(userIdsbyProjectId <> null && userIdsbyProjectId.size() > 0){
                    Core_SharingUtility.revokeAccess('Core_IPS_Project__c','Core_IPS_Project__Share',userIdsbyProjectId);
                }
                if(userIdsbyParsId <> null && userIdsbyParsId.size() > 0){
                    Core_SharingUtility.revokeAccess('Core_IPS_MAP_PAR__c','Core_IPS_MAP_PAR__Share',userIdsbyParsId);
                }
            }
        }
    }
    
    /***************************************************************************************************
    Version     : 1.0 
    Created Date: 13 Jan 2015
    Function    : This method is used to revoke Asset and Project access to FAEs. 
    Input Parameters: New List
    Output Parameters: None
    Transactions: After Delete
    Description: 
    Used in     : Core_CustomAccountTeamTrigger_Dispatcher
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods:
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              03/06/2016              Created
    ****************************************************************************************************/
    public static void  revokeAccessForDelete(List<Core_Account_Team__c> newList){
        if(newList <> null && newList.size() > 0 && Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('RevokeCustomAccountTeam')){
            Set<Id> userIdSet;
            Map<Id,Set<Id>> faeIdsbyAccountId = new Map<Id,Set<Id>>();
            for(Core_Account_Team__c custom_ATObj:newList){
                userIdSet = new Set<Id>();
                for(Core_Account_Team__c custom_ATObj1:newList){
                    if(custom_ATObj.Core_Account__c == custom_ATObj1.Core_Account__c){
                        userIdSet.add(custom_ATObj1.Core_Team_Member__c);
                    }
                }
                faeIdsbyAccountId.put(custom_ATObj.Core_Account__c,userIdSet);
            }            
            if(faeIdsbyAccountId <> null && faeIdsbyAccountId.size() > 0){
                Map<Id,Set<Id>> userIdsbyAssetId = new Map<Id,Set<Id>>();
                Map<Id,Set<Id>> userIdsbyProjectId = new Map<Id,Set<Id>>();
                Map<Id,Set<Id>> userIdsbyParsId = new Map<Id,Set<Id>>();
                Map<Id,Set<Id>> assetIdsbyAccountId = Core_IPS_Helper_Utility.getAssetsByAccountId(faeIdsbyAccountId.keyset());
                Map<Id,Set<Id>> projectIdsbyAccountId = Core_IPS_Helper_Utility.getProjectsByAccountId(faeIdsbyAccountId.keyset());
                Map<Id,Set<Id>> parsbyAccountId = Core_IPS_Helper_Utility.getPARsByAccountId(faeIdsbyAccountId.keyset());
                
                if((assetIdsbyAccountId <> null && assetIdsbyAccountId.size() > 0) || (projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0) || (parsbyAccountId <> null && parsbyAccountId.size() > 0)){
                    for(Core_Account_Team__c catObj:newList){
                        if(assetIdsbyAccountId <> null && assetIdsbyAccountId.size() > 0){
                            for(Id astId:assetIdsbyAccountId.get(catObj.Core_Account__c)){
                                if(faeIdsbyAccountId.get(catObj.Core_Account__c) <> null)
                                    userIdsbyAssetId.put(astId,faeIdsbyAccountId.get(catObj.Core_Account__c));
                            }
                        }
                        if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0){
                            for(Id projectId:projectIdsbyAccountId.get(catObj.Core_Account__c)){
                                if(faeIdsbyAccountId.get(catObj.Core_Account__c) <> null)
                                    userIdsbyProjectId.put(projectId,faeIdsbyAccountId.get(catObj.Core_Account__c));
                            }
                        }
                        if(parsbyAccountId <> null && parsbyAccountId.size() > 0){
                            for(Id parsId:parsbyAccountId.get(catObj.Core_Account__c)){
                                if(faeIdsbyAccountId.get(catObj.Core_Account__c) <> null)
                                    userIdsbyParsId.put(parsId,faeIdsbyAccountId.get(catObj.Core_Account__c));
                            }
                        }
                    }
                }
                if(userIdsbyProjectId <> null && userIdsbyProjectId.size() > 0 && projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0){
                    Map<Id,Set<Id>> assetIdsbyProjectId = Core_IPS_Helper_Utility.getAssetsByProjectId(userIdsbyProjectId.keyset());
                    if(assetIdsbyProjectId <> null && assetIdsbyProjectId.size() > 0){
                        for(Core_Account_Team__c catObj:newList){
                            if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0 && projectIdsbyAccountId.get(catObj.Core_Account__c) <> null && projectIdsbyAccountId.get(catObj.Core_Account__c).size() > 0){
                                for(Id projectId:projectIdsbyAccountId.get(catObj.Core_Account__c)){
                                    if(assetIdsbyProjectId <> null && assetIdsbyProjectId.size() > 0 && assetIdsbyProjectId.get(projectId) <> null && assetIdsbyProjectId.get(projectId).size() > 0){
                                        for(Id astId:assetIdsbyProjectId.get(projectId)){
                                            userIdsbyAssetId.put(astId,faeIdsbyAccountId.get(catObj.Core_Account__c));
                                        }
                                    }
                                }
                            }
                        }                                
                    }
                }
                if(userIdsbyAssetId <> null && userIdsbyAssetId.size() > 0){
                    Core_SharingUtility.revokeAccess('Asset','AssetShare',userIdsbyAssetId);
                }
                if(userIdsbyProjectId <> null && userIdsbyProjectId.size() > 0){
                    Core_SharingUtility.revokeAccess('Core_IPS_Project__c','Core_IPS_Project__Share',userIdsbyProjectId);
                    //Core_SharingUtility.revokeProjectAccess(userIdsbyProjectId);
                }
                if(userIdsbyParsId <> null && userIdsbyParsId.size() > 0){
                    Core_SharingUtility.revokeAccess('Core_IPS_MAP_PAR__c','Core_IPS_MAP_PAR__Share',userIdsbyParsId);
                }
            }
        }
    }   
}