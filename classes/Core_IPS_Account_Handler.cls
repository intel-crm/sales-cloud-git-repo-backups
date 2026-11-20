public with sharing class Core_IPS_Account_Handler{ /* Tushar ---- Remove without sharing and add with sharing by tushar for vanuability changes*/
    
   
    
    /***************************************************************************************************
    Version     : 1.0 
    Created Date: 02 Nov 2015
    Function    : This method is used to grant IPS Project access to Account FAEs. 
    Input Parameters: Case New List
    Output Parameters: None
    Transactions: After Insert
    Description: This method is used to grant IPS Project access to External users.                  
    Used in     : Core_IPS_Account_Dispatcher
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods:
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Vaibhav Dubey              11/02/2015              Created
    ****************************************************************************************************/   
    public static void addAccountFAEtoProject(List<Core_IPS_Account__c> trgNew){
        Map<id,id> ipsProjectID = new Map<id,id>();
        Set<id> accountID = new Set<id>();
        Map<id,Set<Id>> acc_ATMIDMap = new Map<id,Set<Id>>();
        Map<id,Set<Id>> ipsPro_ATMIDMap = new Map<id,Set<Id>>();
        List<Core_IPS_Account__c> accList= new List<Core_IPS_Account__c>();
        if(trgNew!=null && trgNew.size()>0){
            //added Private field US113701
            //FLS Check Already added - Aditya
	      //  Added by Chiru - 20-08-24 - APEX GURU - SOQL FIX
            Map<Id, Core_IPS_Account__c> trgNewMap = new Map<Id, Core_IPS_Account__c>(trgNew);
            if(Core_IPS_Account__c.SObjectType.getDescribe().isAccessible()){
               // accList=[Select Id,Core_IPS_Project__c,Core_Account__c,Core_IPS_Project__r.Core_IPS_Private__c from Core_IPS_Account__c where Id In: trgNew ];
                  accList=[Select Id,Core_IPS_Project__c,Core_Account__c,Core_IPS_Project__r.Core_IPS_Private__c from Core_IPS_Account__c where Id In: trgNewMap.keyset()];
            }
        }
        if(accList!=null && accList.size()>0){
            for(Core_IPS_Account__c ipsAcc : accList){
                //added by Aayushi US113701
                if(!ipsAcc.Core_IPS_Project__r.Core_IPS_Private__c){
                accountID.add(ipsAcc.Core_Account__c);
                ipsProjectID.put(ipsAcc.Core_Account__c,ipsAcc.Core_IPS_Project__c);
            }
        }
    }
        if(accountID!=null && accountID.size()>0){
        acc_ATMIDMap = Core_IPS_Helper_Utility.getFAEsByAccount(accountID);
        for(Id accid: acc_ATMIDMap.keyset()){           
            if(ipsPro_ATMIDMap.containskey(ipsProjectID.get(accid))){
                Set<Id> keySet = ipsPro_ATMIDMap.get(ipsProjectID.get(accid));
                keySet.addall(acc_ATMIDMap.get(accid));
                ipsPro_ATMIDMap.put(ipsProjectID.get(accid),keySet);
            }else{
                ipsPro_ATMIDMap.put(ipsProjectID.get(accid),acc_ATMIDMap.get(accid));
            }
        }
        Core_SharingUtility.provideAccess('Core_IPS_Project__c','Core_IPS_Project__Share','read',ipsPro_ATMIDMap); 
        }
    }
    
    
    /***************************************************************************************************
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : This method is used to Add IPS Enabled contacts to Project members object 
    Input Parameters: Case New List
    Output Parameters: None
    Transactions: After Insert, After Update
    Description: This method is used to Add IPS Enabled contacts to Project members object 
                 All the accounts added with All Core_member type are added to project member object
    Used in     : Core_IPS_Account_Dispatcher
    Number of Queries Within this Method: 2
    Number of Queries in Loop: 0
    Number of Queries from Called methods:1
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    * Amritesh                   11/13/2017              Modified - US80097
    ****************************************************************************************************/    
    public static void addIPSUsersToProjectMembers(List<Core_IPS_Account__c> newList){
    
        List<String> accountIdList =  new List<String>();
        Map<Id,Id> projectstoIPSAccounts = new Map<Id,Id>();
        Map<Id,List<Id>> mapAccountId2ProjectIds = new Map<Id,List<Id>>();
        for(Core_IPS_Account__c ipsAccRec : newList){
            if(ipsAccRec.Core_Members__c == 'All') {
                accountIdList.add(ipsAccRec.Core_Account__c);
                projectstoIPSAccounts.put(ipsAccRec.id,ipsAccRec.Core_IPS_Project__c);
                
                /********** Amritesh - 11/13/2017 ************/
                if(!mapAccountId2ProjectIds.containsKey(ipsAccRec.Core_Account__c)) {
                    mapAccountId2ProjectIds.put(ipsAccRec.Core_Account__c, new List<Id>());
                }
                mapAccountId2ProjectIds.get(ipsAccRec.Core_Account__c).add(ipsAccRec.Core_IPS_Project__c);
            }
        }
    
        /********** Amritesh - 11/13/2017 ************/
        List<String> userTypeList = new List<String>();
        if(String.isNotBlank(Label.Core_IPS_CustCommPlus_UserType)) {
            userTypeList.add(Label.Core_IPS_CustCommPlus_UserType);
        }
        // Removed Comments by prem for Partner 12/4/2017
        if(String.isNotBlank(Label.Core_IPS_Partner_Community_User_Type)) {
            userTypeList.add(Label.Core_IPS_Partner_Community_User_Type);
        } 
        // Removed Comments end by prem for Partner 12/4/2017
        /********** Amritesh - 11/13/2017 -end ************/
        
        //List<User> ipsUserList = [select id, name, Contact.Id from user where usertype='PowerCustomerSuccess' and userroleid!=null and Contact.Core_IPS_Active__c = true and Contact.AccountId IN: accountIdList];
        List<User> ipsUserList = [SELECT id, name, Contact.Id,Contact.AccountId FROM user WHERE usertype IN :userTypeList AND userroleid!=null AND Contact.Core_IPS_Active__c = true AND Contact.AccountId IN: accountIdList AND ContactId!=null AND isActive=true]; //added isActive filter by amritesh US80097 1/6/2017 
        List<Core_IPS_Project_Member__c> userList = new List<Core_IPS_Project_Member__c>();       
        if(ipsUserList!=null && ipsUserList.size()>0){
            for(User u : ipsUserList){
                if(mapAccountId2ProjectIds.containsKey(u.Contact.AccountId)) {  //added by amritesh - 11/13/2017
                    for(Id projectId : mapAccountId2ProjectIds.get(u.Contact.AccountId)) {
                        Core_IPS_Project_Member__c ipsUser = new Core_IPS_Project_Member__c();
                        ipsUser.Core_User__c= u.id;
                        ipsUser.Core_Selective_Member__c= true;
                        ipsUser.Core_IPS_Contact__c = u.Contactid;
                        ipsUser.Core_IPS_Project__c = projectId;   //added by amritesh - 11/13/2017
                        /*for(Core_IPS_Account__c ipsAccRec: newList){                
                            ipsUser.Core_IPS_Project__c = projectstoIPSAccounts.get(ipsAccRec.Id);
                        }*/
                        userList.add(ipsUser);
                    }
                }
                
            }
            if(userList!=null && userList.size()>0) {
                insert userList;  
            }
        } else {
            // Logic to add error if account doesnt have IPS ACTIVE CONTACTS IS TO BE ADDED
            /*for(Core_IPS_Account__c ipsAccRec: Trigger.New){
                if(ipsAccRec.)
                ipsAccRec.addError('Cannot add an account that does not have IPS users to a project');
            }
            */
        }
    }
    
    //TWC745-109 START--- Rekha--- Ability to change Slective to All 
    public static void addProjectMembersOnchangeOfAccount (List<Core_IPS_Account__c> newList, Map<Id,Core_IPS_Account__c> oldMap) {
        List<Core_IPS_Project_Member__c> projMemberList = new List<Core_IPS_Project_Member__c>();
        List<id> projectIds = new List<id>();
        Set<Id> acccountIds = new Set<Id>();
        Map<Id,List<Id>> mapAccountId2ProjectIds = new Map<Id,List<Id>>();
        List<Core_IPS_Project_Member__c> lstProjMemberUpdate = new List<Core_IPS_Project_Member__c>();
        for(Core_IPS_Account__c ipsAccount : newList) {
            if(oldMap.get(ipsAccount.Id).core_members__c!= ipsAccount.core_members__c && ipsAccount.core_members__c =='All') {
                   projectIds.add(ipsAccount.Core_IPS_Project__c);
                   acccountIds.add(ipsAccount.Core_Account__c);
                }
            if(!mapAccountId2ProjectIds.containsKey(ipsAccount.Core_Account__c)) {
                    mapAccountId2ProjectIds.put(ipsAccount.Core_Account__c, new List<Id>());
                }
                mapAccountId2ProjectIds.get(ipsAccount.Core_Account__c).add(ipsAccount.Core_IPS_Project__c);
                //if (oldMap.get(ipsAccount.Id).core_members__c!= ipsAccount.core_members__c && ipsAccount.core_members__c =='Selective') 
                 //   deleteProjMembers(newList);
            }
        if(acccountIds.size()>0) {
            List<String> userTypeList = new List<String>();
            if(String.isNotBlank(Label.Core_IPS_CustCommPlus_UserType)) {
               userTypeList.add(Label.Core_IPS_CustCommPlus_UserType);
            }
            if(String.isNotBlank(Label.Core_IPS_Partner_Community_User_Type)) {
               userTypeList.add(Label.Core_IPS_Partner_Community_User_Type);
            } 
            //FLS Check alredy added - aditya
            if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
                projMemberList = [Select Id,Core_Status__c, Core_IPS_Contact__c, Core_IPS_Project__c from Core_IPS_Project_Member__c where Core_IPS_Contact__r.AccountId IN: acccountIds AND Core_IPS_Project__c IN: projectIds];
            }
            List<User> ipsUserList = [SELECT id, name, Contact.Id,Contact.AccountId FROM user WHERE usertype IN :userTypeList AND userroleid!=null AND Contact.Core_IPS_Active__c = true AND Contact.AccountId IN: acccountIds AND ContactId!=null AND isActive=true];
            map<Id, Core_IPS_Project_Member__c> prjMap = new map<Id, Core_IPS_Project_Member__c>();
            map<Id, User> usrMap = new map<Id, User>();
            List<User> usrs= new List<User>();
            List<Core_IPS_Project_Member__c> prjMembers= new List<Core_IPS_Project_Member__c>();
            if(projMemberList != null && projMemberList.size() > 0 &&  ipsUserList != null  && ipsUserList.size() > 0) {
                for (Core_IPS_Project_Member__c prjmem: projMemberList) {
                    prjMap.put(prjmem.Core_IPS_Contact__c, prjmem);
                }
                for (User usr: ipsUserList) {
                     usrMap.put(usr.Contact.Id, usr);
                }
                
                for (Id conId: usrMap.keySet()) {
                    if (prjMap.containsKey(conId) == false) {
                        usrs.add(usrMap.get(conId));
                    } else if (prjMap.containsKey(conId) == true && prjMap.get(conId).Core_Status__c == 'Inactive') {
                        prjMembers.add(prjMap.get(conId));
                    }
                }
                List<Core_IPS_Project_Member__c> prjMems = new List<Core_IPS_Project_Member__c>();
                if (usrs != null && usrs.size () > 0) {
                for (User usr: usrs) {
                    for(Id projectId : mapAccountId2ProjectIds.get(usr.Contact.AccountId)) {
                        Core_IPS_Project_Member__c prjMem = new Core_IPS_Project_Member__c();
                        prjMem.Core_IPS_Contact__c = usr.Contactid;
                        prjMem.Core_User__c = usr.Id;
                        prjMem.Core_Selective_Member__c = true;
                        if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isCreateable() || Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isUpdateable()) {
                            prjMem.Core_IPS_Project__c = projectId;
                        }
                        prjMems.add(prjMem);
                    }
                  }
                }
                if (prjMembers != null && prjMembers.size() > 0) {
                    for (Core_IPS_Project_Member__c pm: prjMembers) {
                        pm.Core_Status__c = 'Active';
                        prjMems.add(pm);
                    }
                }
                if (prjMems.size() > 0 && prjMems != null) upsert prjMems;
          }
            else if ((projMemberList == null || projMemberList.size() == 0) &&  ipsUserList != null  && ipsUserList.size() > 0) {
                List<Core_IPS_Project_Member__c> members = new List<Core_IPS_Project_Member__c>();
                for (User usr: ipsUserList) {
                    for(Id projectId : mapAccountId2ProjectIds.get(usr.Contact.AccountId)) {
                    Core_IPS_Project_Member__c prjMem = new Core_IPS_Project_Member__c();
                    	prjMem.Core_IPS_Contact__c = usr.Contactid;
                        prjMem.Core_User__c = usr.Id;
                        prjMem.Core_Selective_Member__c = true;
                        if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isCreateable() || Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isUpdateable()) {
                            prjMem.Core_IPS_Project__c = projectId;
                        }
                        members.add(prjMem);
                	}
                }
                INSERT members;
            }
     }
 }
    
    //TWC745-109 End--- Rekha--- Ability to change Slective to All 
    
     /***************************************************************************************************
    Version     : 1.0 
    Created Date: 07 Dec 2015
    Function    : 
    Input Parameters: 
    Output Parameters: None
    Transactions: After Insert, After Update
    Description: This method is used to Add IPS Enabled contacts to Project members object 
                 All the accounts added with All Core_member type are added to project member object
    Used in     : Core_IPS_Account_Dispatcher
    Number of Queries Within this Method: 2
    Number of Queries in Loop: 0
    Number of Queries from Called methods:1
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        12/07/2015              Created
    * Aayushi            11/07/2018         Modified US109046
    ****************************************************************************************************/   
     public static void PreventDelete(List<Core_IPS_Account__c> oldList){
         //added trigger execution by Aayushi for US109046
         Map<Id,Core_IPS_Account__c> ipsAccountMap = new Map<Id,Core_IPS_Account__c>();
         if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('PreventDelete'))     return;
          /*added by Aayushi 07-11-2017 US79852*/
        Core_IPS_Labels__c ipsLabels = Core_IPS_Labels__c.getValues('CoreStatus_Draft');
        String status=ipsLabels.Value__c;
        //start added by Aayushi for US109046
         List<Id> projIdList=new List<Id>();
        List<Case> caseList=new List<Case>();  //end
        Map<Id,Account> projAccountCases=new Map<Id,Account>();
        if(oldList<> null && oldList.size()>0){
            //List<Core_IPS_Account__c> ipsAccountList = [Select id,Core_IPS_Project__r.Core_Status__c from Core_IPS_Account__c where id IN: oldList];
            //FLS Check added - aditya
            if(Core_IPS_Account__c.SObjectType.getDescribe().isAccessible()){
                ipsAccountMap = new Map<Id,Core_IPS_Account__c>([Select id,Core_IPS_Project__r.Core_Status__c from Core_IPS_Account__c where id IN: oldList]);
            }
            if(ipsAccountMap <> null && ipsAccountMap.size()>0){
                //start added by Aayushi for US109046
                for(Core_IPS_Account__c ipsAccount: oldList){
                projIdList.add(ipsAccount.Core_IPS_Project__c);    
                }
                //Avoid Deeply Nested IF Statements kamala
                if((projIdList!=null && projIdList.size()>0)&&(Case.SObjectType.getDescribe().isAccessible())){ 
                        caseList=[Select Id,Contact.AccountId,Core_IPS_Project_Case__c from Case where Core_IPS_Project_Case__c In: projIdList AND Status!='Closed'];
                }//end
                for(Core_IPS_Account__c ipsAccount: oldList){
                    //start added by Aayushi for US109046 
                    if(caseList!=null && caseList.size()>0){
                        for(Case case1:caseList) {
                            
                            if(ipsAccount.Core_Account__c==case1.Contact.AccountId && !Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(userInfo.getUserId())){ //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
                             ipsAccount.adderror('Cannot delete this Account when all Cases for this Project Account are not Closed');   
                            }
                            
                            
                            else if(ipsAccount.Core_Account__c!=case1.Contact.AccountId && ipsAccountMap.get(ipsAccount.id).Core_IPS_Project__r.Core_Status__c <> status && !System.Label.Core_IPS_AdminAndSupport_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15)) && !Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(userInfo.getUserId())){ //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
                             ipsAccount.adderror('Cannot delete this Account when status is either Submitted or Active');
                            }
                        }
                    }//end
                    
                    /*modified by Aayushi 11-2-17 US79852*/
                    //modified as part of US109046 
                    
                    if(ipsAccountMap.get(ipsAccount.id).Core_IPS_Project__r.Core_Status__c <> status && !System.Label.Core_IPS_AdminAndSupport_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15)) && !Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(userInfo.getUserId())){ //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
                        ipsAccount.adderror('Cannot delete this Account when status is either Submitted or Active');
                    }
                }
            }     
        }
     }
     
      /***************************************************************************************************
    Version     : 1.0 
    Created Date: 07 Dec 2015
    Function    : 
    Input Parameters: 
    Output Parameters: None
    Transactions: After Insert, After Update
    Description: This method is used to Add IPS Enabled contacts to Project members object 
                 All the accounts added with All Core_member type are added to project member object
    Used in     : Core_IPS_Account_Dispatcher
    Number of Queries Within this Method: 2
    Number of Queries in Loop: 0
    Number of Queries from Called methods:1
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        12/07/2015              Created
    ****************************************************************************************************/  
     
     public static void DeleteProjMembers(List<Core_IPS_Account__c> oldList){
         /*added by Aayushi 07-11-2017 US79852*/
        Core_IPS_Labels__c ipsLabels = Core_IPS_Labels__c.getValues('CoreStatus_Draft');
        List<Core_IPS_Account__c> ipsAccountList = new List<Core_IPS_Account__c>();
        List<Core_IPS_Project_Member__c> projMemberList = new List<Core_IPS_Project_Member__c>();
        String status=ipsLabels.Value__c; 
        if(oldList<> null && oldList.size()>0){
            List<id> projectIds = new List<id>();
            List<Core_IPS_Project_Member__c> deleteProjMembers = new List<Core_IPS_Project_Member__c>();
            //FLS check already added - Aditya
            if(Core_IPS_Account__c.SObjectType.getDescribe().isAccessible()){
                ipsAccountList = [Select id,Core_IPS_Project__c,Core_IPS_Project__r.Core_Status__c,Core_Account__c from Core_IPS_Account__c where id IN: oldList];
            }
            for(Core_IPS_Account__c ipsAccount: ipsAccountList){
                projectIds.add(ipsAccount.Core_IPS_Project__c);
            }
            //FLS Check already added - Aditya
            if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
                projMemberList = [Select id, Core_IPS_Contact__c,Core_IPS_Contact__r.AccountId,Core_Status__c,Core_IPS_Project__c from Core_IPS_Project_Member__c where Core_Status__c <> 'Inactive' and Core_IPS_Project__c IN: projectIds];
            }
            for(Core_IPS_Account__c ipsAccount: ipsAccountList){
                /*modified by Aayushi 11-2-17 US79852*/
                //modified if condition by Aayushi US109046
                
                if((ipsAccount.Core_IPS_Project__r.Core_Status__c == status || System.Label.Core_IPS_AdminAndSupport_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15))) && !Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(userInfo.getUserId())){ //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
                    for(Core_IPS_Project_Member__c projectMember: projMemberList){
                        if(projectMember.Core_IPS_Contact__r.AccountId == ipsAccount.Core_Account__c)
                            deleteProjMembers.add(projectMember);
                            
                    }
                }                                        
            }
            if(deleteProjMembers <> null && deleteProjMembers.size()>0)
                try{
                    /*US1038641 - 06/23/2021 - Yamini - CRUD Delete Check for security vulnerability --*/
                    if (Core_IPS_Project_Member__c.sObjectType.getDescribe().isDeletable()) {
                        delete deleteProjMembers;
                    }
                }
            catch(Exception e){
            }
        }
     }
    
    /***************************************************************************************************
    Version     : 1.0 
    Created Date: 11/13/2017
    Function    : 
    Input Parameters: List, Map
    Output Parameters: None
    Transactions: After Insert, After Update
    Description: This method is used to Deactivate Project Members                  
    Used in     : Core_IPS_Account_Dispatcher
    Number of Queries Within this Method: 2
    Number of Queries in Loop: 0
    Number of Queries from Called methods:0
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                        11/13/2017         Created - US80097
    ****************************************************************************************************/       
     public static void ActivateOrDeactivateProjectMembers(List<Core_IPS_Account__c> newList, Map<Id,Core_IPS_Account__c> oldMap){
     if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('ActivateOrDeactivateProjectMembers')) return;
        if(newList<> null && newList.size()>0){
            List<Core_IPS_Project_Member__c> lstProjMemberUpdate = new List<Core_IPS_Project_Member__c>();
            Set<Id> lstInactiveAccountId = new Set<Id>();
            Set<Id> lstActiveAccountId = new Set<Id>();     
            List<id> projectIds = new List<id>();
            for(Core_IPS_Account__c ipsAccount : newList){                
                if(oldMap.get(ipsAccount.Id).Core_Status__c!= ipsAccount.Core_Status__c && ipsAccount.Core_Status__c=='Inactive')
                    lstInactiveAccountId.add(ipsAccount.Core_Account__c);
                if(oldMap.get(ipsAccount.Id).Core_Status__c!= ipsAccount.Core_Status__c && ipsAccount.Core_Status__c=='Active')
                    lstActiveAccountId.add(ipsAccount.Core_Account__c);
                
                projectIds.add(ipsAccount.Core_IPS_Project__c);
            }
                        
            if(lstInactiveAccountId.size()>0) {
                List<Core_IPS_Project_Member__c> projMemberList = [Select Id,Core_Status__c from Core_IPS_Project_Member__c where Core_Status__c <> 'Inactive' AND Core_IPS_Contact__r.AccountId IN: lstInactiveAccountId AND Core_IPS_Project__c IN: projectIds];
                if(projMemberList <> null) {
                    for(Core_IPS_Project_Member__c projectMember : projMemberList){
                        projectMember.Core_Status__c = 'Inactive';
                        lstProjMemberUpdate.add(projectMember);
                    }                           
                }
            }
            if(lstActiveAccountId.size()>0) {
                List<Core_IPS_Project_Member__c> projMemberList = [Select Id,Core_Status__c from Core_IPS_Project_Member__c where Core_Status__c <> 'Active' AND Core_IPS_Contact__r.AccountId IN: lstActiveAccountId AND Core_IPS_Project__c IN: projectIds];
                if(projMemberList <> null) {
                    for(Core_IPS_Project_Member__c projectMember : projMemberList){
                        projectMember.Core_Status__c = 'Active';
                        lstProjMemberUpdate.add(projectMember);
                    }                           
                }               
            }
            if(lstProjMemberUpdate <> null && lstProjMemberUpdate.size()>0) {
                update lstProjMemberUpdate;
            }
         }
     }
    
    /***************************************************************************************************
    Version     : 1.0 
    Created Date: 16/04/2018
    Function    : 
    Input Parameters: List
    Output Parameters: None
    Transactions: Before Insert
    Description: This method is used to check duplicate account addition on a project                  
    Used in     : Core_IPS_Account_Dispatcher
    Number of Queries Within this Method: 1 
    Number of Queries in Loop: 0
    Number of Queries from Called methods:0
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Aayushi                        16/04/2018         Created - DE37603
    ****************************************************************************************************/       
    public static void checkDuplicateAccount(List<Core_IPS_Account__c> newList){
        
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('checkDuplicateAccount')) {return;}
        
        List<Id> accountId=new List<Id>();
        List<Id> projectId=new List<Id>();
        Core_IPS_Labels__c ipsLabels = Core_IPS_Labels__c.getValues('Core_IPS_DuplicateAccount_Error');
        String duplicateError=ipsLabels.Value__c;
        if(newList!=null && newList.size()>0){
            for(Core_IPS_Account__c projectAccount: newList)   {
                accountId.add(projectAccount.Core_Account__c);
                projectId.add(projectAccount.Core_IPS_Project__c);
            }   
            if(accountId!=null && accountId.size()>0 && projectId!=null && projectId.size()>0) {
                List<Core_IPS_Account__c> projAccList;
                if (Schema.sObjectType.Core_IPS_Account__c.fields.Id.isAccessible()) {
                 projAccList=[Select Id,Core_Account__c,Core_IPS_Project__c from Core_IPS_Account__c where Core_Account__c In: accountId AND Core_IPS_Project__c In: projectId ];
                }
                if(projAccList!=null && projAccList.size()>0){
                    for(Core_IPS_Account__c newProjAccount: newList)  {
                        for(Core_IPS_Account__c projAcc: projAccList){
                            if(newProjAccount.Core_Account__c == projAcc.Core_Account__c && newProjAccount.Core_IPS_Project__c == projAcc.Core_IPS_Project__c){
                                newProjAccount.adderror(duplicateError); 
                            }
                        }
                        
                    }  
                }            
            }   
        }
        
    }
    
    /***************************************************************************************************
    Version     : 1.0 
    Created Date: 24/04/2018
    Function    : 
    Input Parameters: List
    Output Parameters: None
    Transactions: After Insert
    Description: This method is used When a single Account exists on a Project, it should not be possible to 
                 enter text in the MPNDA field and then save the record if the Account does not have a CNDA on 
                 its Account record.                  
    Used in     : Core_IPS_Account_Dispatcher
    Number of Queries Within this Method: 1 
    Number of Queries in Loop: 0
    Number of Queries from Called methods:0
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Aayushi                        24/04/2018         Created - US103460
    ****************************************************************************************************/    
    public static void preventMPNDAforNonNDAAccount(List<Core_IPS_Account__c> newList){
      if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('preventMPNDAforNonNDAAccount')) {return;}
        Map<Id,Core_IPS_Account__c> projAccMap;
        Core_IPS_Labels__c ipsLabels = Core_IPS_Labels__c.getValues('Core_IPS_MPNDAValue_Error');
        String mpndaError=ipsLabels.Value__c;
        if(newList!=null && newList.size()>0){
            List<Id> projAccId=new List<Id>();
            for(Core_IPS_Account__c projAccount:newList){
                projAccId.add(projAccount.Id); 
            }
            
            if(projAccId!=null && projAccId.size()>0 && Schema.sObjectType.Core_IPS_Account__c.fields.Id.isAccessible()){
                projAccMap=new Map<Id,Core_IPS_Account__c>([Select Id,Core_IPS_Project__c,Core_Account__c,Core_IPS_Project__r.Core_MPNDA__c,Core_Account__r.Core_CNDA_Number__c from Core_IPS_Account__c where Id In :projAccId]);
            }
        
        if(projAccMap!=null && projAccMap.size()>0){
            for(Core_IPS_Account__c projAccount: newList) {
                if(!String.isBlank(projAccMap.get(projAccount.Id).Core_IPS_Project__r.Core_MPNDA__c) &&  (projAccMap.get(projAccount.Id).Core_Account__r.Core_CNDA_Number__c==null || projAccMap.get(projAccount.Id).Core_Account__r.Core_CNDA_Number__c=='')){
                    projAccount.addError(mpndaError);   
                }
            }
        }
        }
    }

    /***************************************************************************************************
    Version     : 1.0 
    Created Date: 15/06/2018
    Function    : 
    Input Parameters: List
    Output Parameters: None
    Transactions: After Insert
    Description: This method is used When a Non NDA Account is getting added to an MPNDA Project       
    Used in     : Core_IPS_Account_Dispatcher
    Number of Queries Within this Method: 1 
    Number of Queries in Loop: 0
    Number of Queries from Called methods:0
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Aayushi                        15/06/2018         Created - DE39928
    ****************************************************************************************************/    
    public static void preventNonNDAAccountAddonMPNDAProj(List<Core_IPS_Account__c> newList){
      if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('preventMPNDAforNonNDAAccount')) {return;}
    if(newList!=null && newList.size()>0){
     Map<Id,Core_IPS_Account__c> projAccMap=new Map<Id,Core_IPS_Account__c>([Select Id,Core_IPS_Project__r.Core_Number_of_Accounts__c,Core_IPS_Project__r.Core_MPNDA__c,Core_Account__r.Core_CNDA_Number__c from Core_IPS_Account__c where Id In :newList]) ;
        for(Core_IPS_Account__c projAcc: newList){
            if(projAccMap!=null && projAccMap.size()>0 && projAccMap.get(projAcc.Id).Core_IPS_Project__r.Core_Number_of_Accounts__c>0 && String.isBlank(projAccMap.get(projAcc.Id).Core_Account__r.Core_CNDA_Number__c)){
             Core_IPS_Labels__c ipsLabels = Core_IPS_Labels__c.getValues('Core_IPS_NonNDA_ErrorMSg');
                String errorMessage=ipsLabels.Value__c;
                projAcc.addError(errorMessage);   
            }
        }
    }
    }
 
}