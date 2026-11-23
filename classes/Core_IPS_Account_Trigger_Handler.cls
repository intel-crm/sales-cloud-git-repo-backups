public without sharing class Core_IPS_Account_Trigger_Handler{
    public static void assignEntitlementToIPSAccount(Map<Id,Account> oldMap,List<Account> newList){
        List<Entitlement> entList = new List<Entitlement>();
        //added by amritesh 4/26/2018 US104230 - start
        String entitlementExpiryYearStr = System.Label.Core_IPS_Account_Entitlement_Expiry_Year;
        Integer entitlementExpiryYearInt;
        if(String.isBlank(entitlementExpiryYearStr) || (!entitlementExpiryYearStr.isNumeric())) entitlementExpiryYearInt = Date.Today().year() + 5;
        else entitlementExpiryYearInt = Integer.valueOf(entitlementExpiryYearStr);
        //added by amritesh 4/26/2018 US104230 - end
        
        for(Account acc: newList){
            system.debug(acc.Core_IPS_Active__c);
            system.debug(oldMap.get(acc.id).Core_IPS_Active__c);
            if(acc.Core_IPS_Active__c && acc.Core_IPS_Active__c <> oldMap.get(acc.id).Core_IPS_Active__c){

                Entitlement ent = new Entitlement();
                /*US1021248 - 05/27/2021 - yamini - FLS Check for security vulnerability --*/
                //if (Schema.sObjectType.Entitlement.fields.Name.isCreateable()) {
                ent.Name = Core_IPS_Helper_utility.getIPSLabel('IPS Standard Entitlement');
                //}
               if(Test.isRunningTest()==false && Schema.sObjectType.Entitlement.fields.slaprocessid.isCreateable())
               {
                ent.slaprocessid=Core_IPS_Helper_utility.getIPSLabel('IPS Standard Entitlement Process ID');
               }
               // FlS check added by chetan As part of ATHR fixes 
               //if (Schema.sObjectType.Entitlement.fields.startDate.isCreateable()) {
                ent.startDate = System.today();
               //}
                //ent.endDate = system.today()+730;
                /*---Start US1038641 06/24/2021 - Farhaad - FLS Check for security vulnerability--*/
               // if (Schema.sObjectType.Entitlement.fields.endDate.isCreateable()) {
                    ent.endDate = Date.newInstance(entitlementExpiryYearInt,12,31); //added by amritesh 4/26/2018 US104230
               // }
                //if (Schema.sObjectType.Entitlement.fields.accountid.isCreateable()) {
                    ent.accountid=acc.id;
                //}
               // if (Schema.sObjectType.Entitlement.fields.type.isCreateable()) {
                    ent.type=Core_IPS_Helper_utility.getIPSLabel('Entitlement Type');
               // }
                /*--- End US1038641 06/24/2021 - Farhaad - FLS Check for security vulnerability--*/
                entList.add(ent);
                
            }
        }
        if(entList.size()>0)
            insert entList;
    }
    
    public static void revokeAccess(List<Account> newList,Map<Id,Account> oldMap){
        
        Map<Id,Id> ownerIdbyAccId = new Map<Id,Id>();
        Map<Id,Set<Id>> userIdsbyAssetId = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> userIdsbyProjectId = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> userIdsbyParsId = new Map<Id,Set<Id>>();
        
        if(oldMap <> null && oldMap.size() > 0){
            for(Account acc: newList){
                if(oldMap <> null && oldMap.size() > 0 && acc.Core_IPS_Active__c == True && acc.OwnerId <> oldMap.get(acc.Id).OwnerId)
                    ownerIdbyAccId.put(acc.Id,oldMap.get(acc.Id).OwnerId);        
            }
        }            
        if(ownerIdbyAccId <> null && ownerIdbyAccId.size() > 0){
            Map<Id,Set<Id>> assetIdsbyAccountId = Core_IPS_Helper_Utility.getAssetsByAccountId(ownerIdbyAccId.keyset());
            
            Set<Id> userSet1;
            for(Id accId : ownerIdbyAccId.keyset()){
                if(assetIdsbyAccountId <> null && assetIdsbyAccountId.size() > 0 && assetIdsbyAccountId.get(accId) <> null && assetIdsbyAccountId.get(accId).size() > 0){
                    for(Id astId : assetIdsbyAccountId.get(accId)){
                        userSet1 = new Set<Id>();
                        userSet1.add(ownerIdbyAccId.get(accId));
                        userIdsbyAssetId.put(astId,userSet1);
                    }
                }
            }
            Map<Id,Set<Id>> parsbyAccountId = Core_IPS_Helper_Utility.getPARsByAccountId(ownerIdbyAccId.keyset());
            
            Set<Id> userSet2;
            for(Id accId : ownerIdbyAccId.keyset()){
                if(parsbyAccountId <> null && parsbyAccountId.size() > 0 && parsbyAccountId.get(accId) <> null && parsbyAccountId.get(accId).size() > 0){    
                    for(Id parsId: parsbyAccountId.get(accId)){
                        userSet2 = new Set<Id>();
                        userSet2.add(ownerIdbyAccId.get(accId));
                        userIdsbyParsId.put(parsId,userSet2);
                    }
                }
            }
            
            
            Map<Id,Set<Id>> projectIdsbyAccountId = Core_IPS_Helper_Utility.getProjectsByAccountId(ownerIdbyAccId.keyset());
            
            Set<Id> userSet3;
            for(Id accId : ownerIdbyAccId.keyset()){
                if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0 && projectIdsbyAccountId.get(accId) <> null && projectIdsbyAccountId.get(accId).size() > 0){
                    for(Id projId: projectIdsbyAccountId.get(accId)){
                        userSet3 = new Set<Id>();
                        userSet3.add(ownerIdbyAccId.get(accId));
                        userIdsbyProjectId.put(projId,userSet3);
                    }
                }
            }
            
            Set<Id> projIdSet = new Set<Id>();            
            for(Id accId : ownerIdbyAccId.keyset()){
                if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0 && projectIdsbyAccountId.get(accId) <> null && projectIdsbyAccountId.get(accId).size() > 0){
                    for(Id projId : projectIdsbyAccountId.get(accId)){
                        projIdSet.add(projId);
                    }
                }
            }            
            
            Map<Id,Set<Id>> assetIdsbyProjectId = Core_IPS_Helper_Utility.getAssetsByProjectId(projIdSet);            
            
            Set<Id> userSet4;
            for(Id accId : ownerIdbyAccId.keyset()){
                if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0 && projectIdsbyAccountId.get(accId) <> null && projectIdsbyAccountId.get(accId).size() > 0){
                    for(Id projId : projectIdsbyAccountId.get(accId)){
                        if(assetIdsbyProjectId <> null && assetIdsbyProjectId.size() > 0 && assetIdsbyProjectId.get(projId) <> null && assetIdsbyProjectId.get(projId).size() > 0){
                            for(Id astId: assetIdsbyProjectId.get(projId)){
                                userSet4 = new Set<Id>();
                                userSet4.add(ownerIdbyAccId.get(accId));
                                userIdsbyAssetId.put(astId,userSet4);
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
    
    public static void grantAccess(List<Account> newList,Map<Id,Account> oldMap){
        Map<Id,Id> ownerIdbyAccId = new Map<Id,Id>();
        Map<Id,Set<Id>> userIdsbyAssetId = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> userIdsbyProjectId = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> userIdsbyParsId = new Map<Id,Set<Id>>();
        
        
        if(oldMap <> null && oldMap.size() > 0){
            for(Account acc: newList){
                if(oldMap <> null && oldMap.size() > 0 && acc.Core_IPS_Active__c == True && acc.OwnerId <> oldMap.get(acc.Id).OwnerId)
                    ownerIdbyAccId.put(acc.Id,acc.OwnerId);        
            }
        }        
        
        if(ownerIdbyAccId <> null && ownerIdbyAccId.size() > 0){
            Map<Id,Set<Id>> assetIdsbyAccountId = Core_IPS_Helper_Utility.getAssetsByAccountId(ownerIdbyAccId.keyset());
            
            Set<Id> userSet1;
            for(Id accId : ownerIdbyAccId.keyset()){
                if(assetIdsbyAccountId <> null && assetIdsbyAccountId.size() > 0 && assetIdsbyAccountId.get(accId) <> null && assetIdsbyAccountId.get(accId).size() > 0){
                    for(Id astId : assetIdsbyAccountId.get(accId)){
                        userSet1 = new Set<Id>();
                        userSet1.add(ownerIdbyAccId.get(accId));
                        userIdsbyAssetId.put(astId,userSet1);
                    }
                }
            }
            Map<Id,Set<Id>> parsbyAccountId = Core_IPS_Helper_Utility.getPARsByAccountId(ownerIdbyAccId.keyset());
            
            Set<Id> userSet2;
            for(Id accId : ownerIdbyAccId.keyset()){
                if(parsbyAccountId <> null && parsbyAccountId.size() > 0 && parsbyAccountId.get(accId) <> null && parsbyAccountId.get(accId).size() > 0){    
                    for(Id parsId: parsbyAccountId.get(accId)){
                        userSet2 = new Set<Id>();
                        userSet2.add(ownerIdbyAccId.get(accId));
                        userIdsbyParsId.put(parsId,userSet2);
                    }
                }
            }
            
            
            Map<Id,Set<Id>> projectIdsbyAccountId = Core_IPS_Helper_Utility.getProjectsByAccountId(ownerIdbyAccId.keyset());
            
            Set<Id> userSet3;
            for(Id accId : ownerIdbyAccId.keyset()){
                if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0 && projectIdsbyAccountId.get(accId) <> null && projectIdsbyAccountId.get(accId).size() > 0){
                    for(Id projId: projectIdsbyAccountId.get(accId)){
                        userSet3 = new Set<Id>();
                        userSet3.add(ownerIdbyAccId.get(accId));
                        userIdsbyProjectId.put(projId,userSet3);
                    }
                }
            }
            
            Set<Id> projIdSet = new Set<Id>();            
            for(Id accId : ownerIdbyAccId.keyset()){
                if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0 && projectIdsbyAccountId.get(accId) <> null && projectIdsbyAccountId.get(accId).size() > 0){
                    for(Id projId : projectIdsbyAccountId.get(accId)){
                        projIdSet.add(projId);
                    }
                }
            }            
            
            Map<Id,Set<Id>> assetIdsbyProjectId = Core_IPS_Helper_Utility.getAssetsByProjectId(projIdSet);            
            
            Set<Id> userSet4;
            for(Id accId : ownerIdbyAccId.keyset()){
                if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0 && projectIdsbyAccountId.get(accId) <> null && projectIdsbyAccountId.get(accId).size() > 0){
                    for(Id projId : projectIdsbyAccountId.get(accId)){
                        if(assetIdsbyProjectId <> null && assetIdsbyProjectId.size() > 0 && assetIdsbyProjectId.get(projId) <> null && assetIdsbyProjectId.get(projId).size() > 0){
                            for(Id astId: assetIdsbyProjectId.get(projId)){
                                userSet4 = new Set<Id>();
                                userSet4.add(ownerIdbyAccId.get(accId));
                                userIdsbyAssetId.put(astId,userSet4);
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
    
     /***************************************************************************************************
    Version     : 1.0 
    Created Date: 07 March 2016
    Function    : 
    Input Parameters: newList and OldMap 
    Output Parameters: None
    Transactions: Before Update
    Description: This method is used to restrict Users to change from Partner->Customer/Customer->Partner Account.
    Used in     : Core_Account
    Number of Queries Within this Method : 1
    Number of Queries in Loop : 0
    Number of Queries from Called methods : 0
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                             Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya                        03/07/2016              Created
    ****************************************************************************************************/
    public static void restrictManageExternalAccount(List<Account> newList,Map<Id,Account> oldMap){
        Boolean isProfileRestricted = true;
        if(UserInfo.getUserType() != 'automatedprocess') {//atuomatedprocess user validation US-0048819
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()  LIMIT 1]; /* DE117168 --- 14-06-21 ---Sai Krishna --- Delete cancelled Opportunities flow issue fix */
        String myProflieName = PROFILE.size()>0?PROFILE[0].Name:(Label.Core_IPS_System_Admin_Profile_Name);  /* DE117168 --- 14-06-21 ---Sai Krishna --- Delete cancelled Opportunities flow issue fix */
        for(String profileName : Label.Core_Admin_Profile_Names.split(',')){
            if(myProflieName == profileName){
                isProfileRestricted = false;
            }
        }
        } else {isProfileRestricted = true;} //atuomatedprocess user validation
        Map<string,Core_IPS_Error_Code__c> mapCodes = Core_IPS_Error_Code__c.getAll();          
        // display the Error Message for G115

        for(Account acn:newList){            
            if(isProfileRestricted && ((acn.IsCustomerPortal <> null && acn.IsCustomerPortal <> oldMap.get(acn.Id).IsCustomerPortal) || (acn.IsPartner <> null && acn.IsPartner <> oldMap.get(acn.Id).IsPartner)))
                acn.addError(mapCodes.get('G115').Core_Error_Message__c);
        }
    
    }
    
    /***********************************************************************************************
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : User Story# US36728 : This method executes when Account field named "Export Compliance Block" is true then make IPS Active field on related Contacts to false.
    Input Parameters: Case Old Map, Case New List
    Output Parameters: None
    Transactions: After Insert, After Update
    Description: This method executes when Export Compliance Block =  true as follows:
                 Take respected contact and update Field IPS Active = false
                 
    Used in     : Core_CaseTrigger_Dispatcher
    Number of Queries Within this Method: 1(one per transaction)
    Number of Queries in Loop: 0
    Number of Queries from Called methods:0
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Sunil Chandani              15/03/2016              Created
    * Abhishek Arya               16/03/2016              Modified
    * Sneha Ransing               18/03/2020              Modified
    ****************************************************************************************************/  
    //flow test public static void UpdateContactOnECBCheck(List<Account> newList,Map<id,Account> MapOldAccount){//ECB flag logic validation-gangadhar start
        //flow test Map<Id,Contact> mapContact;
        /* START - US604984 KTBR: Implement quick fix for setting Account (Huawei HQ) Export Compliance Block  - Sneha */
        //flow test if (!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('UpdateContactOnECBCheck'))
            //flow test return;
        /* END - US604984 KTBR: Implement quick fix for setting Account (Huawei HQ) Export Compliance Block  - Sneha */
        //flow test Set<Id> accountIdSet = new Set<Id>();
        //account Id is collected
        //flow test for(Account accObj:newList){
        
         //flow test if((MapOldAccount !=null && MapOldAccount.get(accObj.id).Core_Export_Compliance_Block__c != accObj.Core_Export_Compliance_Block__c && accObj.Core_Export_Compliance_Block__c) || (MapOldAccount == null && accObj.Core_Export_Compliance_Block__c))
         //flow test {
          //flow test accountIdSet.add(accObj.Id);
         //flow test }           
         
        //flow test } 
        
        //Take respected contact
        //FLS check added-Venugopal
        //if(Contact.SObjectType.getDescribe().isAccessible()){
        //flow test mapContact = new Map<Id,Contact>([Select id,Core_IPS_Active__c,Core_IPS_By_Pass_Validation__c,AccountId from Contact where AccountId in :accountIdSet]);
        //}
        
       /* if(mapContact <> null && mapContact.size() > 0 && mapContact.keyset() <> null){
            //update the respected contact data        
            for(Id ContactId:mapContact.keyset()){               
               mapContact.get(ContactId).Core_IPS_Active__c = false;
               mapContact.get(ContactId).Core_IPS_By_Pass_Validation__c = true;        
            }
            if(mapContact.Values() <> null && mapContact.Values().size() > 0)
            {
                try{
                    update mapContact.Values();  
                }catch(DMLException e){
                    Core_Exceptionclass Exce =  new Core_Exceptionclass();
                    string  Str = Exce.InsertException('','Core_IPS_Account_Trigger_Handler','Account','','UpdateContactOnECBCheck',e);
                }         
            }
        }   *///ECB flag logic validation-gangadhar     
    //flow test } //ECB flag logic validation-gangadhar end
    
}