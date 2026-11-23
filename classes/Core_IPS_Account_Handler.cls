public class Core_IPS_Account_Handler{
    
   
    
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
        Map<id,id> IPSProjectID = new Map<id,id>();
        Set<id> AccountID = new Set<id>();
        Map<id,Set<Id>> Acc_ATMIDMap = new Map<id,Set<Id>>();
        Map<id,Set<Id>> IPSPro_ATMIDMap = new Map<id,Set<Id>>();
        List<Core_IPS_Account__c> accList= new List<Core_IPS_Account__c>();
        if(trgNew!=null && trgNew.size()>0){
            //added Private field US113701
            accList=[Select Id,Core_IPS_Project__c,Core_Account__c,Core_IPS_Project__r.Core_IPS_Private__c from Core_IPS_Account__c where Id In: trgNew ];
        }
        if(accList!=null && accList.size()>0){
            for(Core_IPS_Account__c ipsAcc : accList){
                //added by Aayushi US113701
                if(!ipsAcc.Core_IPS_Project__r.Core_IPS_Private__c){
                AccountID.add(ipsAcc.Core_Account__c);
                IPSProjectID.put(ipsAcc.Core_Account__c,ipsAcc.Core_IPS_Project__c);
            }
        }
    }
        if(AccountID!=null && AccountID.size()>0){
        Acc_ATMIDMap = Core_IPS_Helper_Utility.getFAEsByAccount(AccountID);
        for(Id accid: Acc_ATMIDMap.keyset()){           
            if(IPSPro_ATMIDMap.containskey(IPSProjectID.get(accid))){
                Set<Id> keySet = IPSPro_ATMIDMap.get(IPSProjectID.get(accid));
                keySet.addall(Acc_ATMIDMap.get(accid));
                IPSPro_ATMIDMap.put(IPSProjectID.get(accid),keySet);
            }else{
                IPSPro_ATMIDMap.put(IPSProjectID.get(accid),Acc_ATMIDMap.get(accid));
            }
        }
            
        system.debug('map sent for sharing &&&&&&&&&'+IPSPro_ATMIDMap);
        Core_SharingUtility.provideAccess('Core_IPS_Project__c','Core_IPS_Project__Share','read',IPSPro_ATMIDMap); 
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
        Map<Id,Id> ProjectstoIPSAccounts = new Map<Id,Id>();
        Map<Id,List<Id>> mapAccountId2ProjectIds = new Map<Id,List<Id>>();
        for(Core_IPS_Account__c IPSAccRec : newList){
            if(IPSAccRec.Core_Members__c == 'All') {
                accountIdList.add(IPSAccRec.Core_Account__c);
                ProjectstoIPSAccounts.put(IPSAccRec.id,IPSAccRec.Core_IPS_Project__c);
                
                /********** Amritesh - 11/13/2017 ************/
                if(!mapAccountId2ProjectIds.containsKey(IPSAccRec.Core_Account__c)) {
                    mapAccountId2ProjectIds.put(IPSAccRec.Core_Account__c, new List<Id>());
                }
                mapAccountId2ProjectIds.get(IPSAccRec.Core_Account__c).add(IPSAccRec.Core_IPS_Project__c);
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
                        ipsUser.Core_Selective_Member__c= false;
                        ipsUser.Core_IPS_Contact__c = u.Contactid;
                        ipsUser.Core_IPS_Project__c = projectId;   //added by amritesh - 11/13/2017
                        /*for(Core_IPS_Account__c IPSAccRec: newList){                
                            ipsUser.Core_IPS_Project__c = ProjectstoIPSAccounts.get(IPSAccRec.Id);
                        }*/
                        userList.add(ipsUser);
                    }
                }
                
            }
            if(userList!=null && userList.size()>0) {
                System.debug('User List'+userList);
                insert userList;
            }
        } else {
            // Logic to add error if account doesnt have IPS ACTIVE CONTACTS IS TO BE ADDED
            /*for(Core_IPS_Account__c IPSAccRec: Trigger.New){
                if(IPSAccRec.)
                IPSAccRec.addError('Cannot add an account that does not have IPS users to a project');
            }
            */
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
    * Aayushi            11/07/2018         Modified US109046
    ****************************************************************************************************/   
     public static void PreventDelete(List<Core_IPS_Account__c> oldList){
         //added trigger execution by Aayushi for US109046
         if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('PreventDelete'))     return;
          /*added by Aayushi 07-11-2017 US79852*/
        Core_IPS_Labels__c IpsLabels = Core_IPS_Labels__c.getValues('CoreStatus_Draft');
        String status=IpsLabels.Value__c;
        //start added by Aayushi for US109046
         List<Id> projIdList=new List<Id>();
        List<Case> caseList=new List<Case>();  //end
        Map<Id,Account> projAccountCases=new Map<Id,Account>();
        if(oldList<> null && oldList.size()>0){
            //List<Core_IPS_Account__c> IPSAccountList = [Select id,Core_IPS_Project__r.Core_Status__c from Core_IPS_Account__c where id IN: oldList];
            Map<Id,Core_IPS_Account__c> IPSAccountMap = new Map<Id,Core_IPS_Account__c>([Select id,Core_IPS_Project__r.Core_Status__c from Core_IPS_Account__c where id IN: oldList]);
            if(IPSAccountMap <> null && IPSAccountMap.size()>0){
                //start added by Aayushi for US109046
                for(Core_IPS_Account__c IPSAccount: oldList){
                projIdList.add(IPSAccount.Core_IPS_Project__c);    
                }
                
                if(projIdList!=null && projIdList.size()>0){
                caseList=[Select Id,Contact.AccountId,Core_IPS_Project_Case__c from Case where Core_IPS_Project_Case__c In: projIdList AND Status!='Closed'];
                }//end
                for(Core_IPS_Account__c IPSAccount: oldList){
                    //start added by Aayushi for US109046 
                    if(caseList!=null && caseList.size()>0){
                        for(Case case1:caseList) {
                            if(IPSAccount.Core_Account__c==case1.Contact.AccountId && !System.Label.Core_IPS_Data_Migration_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15))){
                             IPSAccount.adderror('Cannot delete this Account when all Cases for this Project Account are not Closed');   
                            }
                            
                            else if(IPSAccount.Core_Account__c!=case1.Contact.AccountId && IPSAccountMap.get(IPSAccount.id).Core_IPS_Project__r.Core_Status__c <> status && !System.Label.Core_IPS_AdminAndSupport_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15)) && !System.Label.Core_IPS_Data_Migration_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15))){
                             IPSAccount.adderror('Cannot delete this Account when status is either Submitted or Active');
                            }
                        }
                    }//end
                    system.debug('ips account - header status'+ IPSAccount.Core_IPS_Project__r.Core_Status__c);
                    /*modified by Aayushi 11-2-17 US79852*/
                    //modified as part of US109046 
                    if(IPSAccountMap.get(IPSAccount.id).Core_IPS_Project__r.Core_Status__c <> status && !System.Label.Core_IPS_AdminAndSupport_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15)) && !System.Label.Core_IPS_Data_Migration_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15))){
                        IPSAccount.adderror('Cannot delete this Account when status is either Submitted or Active');
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
        Core_IPS_Labels__c IpsLabels = Core_IPS_Labels__c.getValues('CoreStatus_Draft');
        String status=IpsLabels.Value__c; 
        if(oldList<> null && oldList.size()>0){
            List<id> ProjectIds = new List<id>();
            List<Core_IPS_Project_Member__c> DeleteProjMembers = new List<Core_IPS_Project_Member__c>();
            List<Core_IPS_Account__c> IPSAccountList = [Select id,Core_IPS_Project__c,Core_IPS_Project__r.Core_Status__c,Core_Account__c from Core_IPS_Account__c where id IN: oldList];
            for(Core_IPS_Account__c IPSAccount: IPSAccountList){
                ProjectIds.add(IPSAccount.Core_IPS_Project__c);
            }
            System.debug('IPSAccountList********@@@-->>'+IPSAccountList);
            List<Core_IPS_Project_Member__c> ProjMemberList = [Select id, Core_IPS_Contact__c,Core_IPS_Contact__r.AccountId,Core_Status__c,Core_IPS_Project__c from Core_IPS_Project_Member__c where Core_Status__c <> 'Inactive' and Core_IPS_Project__c IN: ProjectIds];
            for(Core_IPS_Account__c IPSAccount: IPSAccountList){
                /*modified by Aayushi 11-2-17 US79852*/
                //modified if condition by Aayushi US109046
                if((IPSAccount.Core_IPS_Project__r.Core_Status__c == status || System.Label.Core_IPS_AdminAndSupport_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15))) && !System.Label.Core_IPS_Data_Migration_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15))){
                    for(Core_IPS_Project_Member__c ProjectMember: ProjMemberList){
                        if(ProjectMember.Core_IPS_Contact__r.AccountId == IPSAccount.Core_Account__c)
                            DeleteProjMembers.add(ProjectMember);
                            system.debug('delete ips acc- proj members to delete'+DeleteProjMembers);
                    }
                }                                        
            }
            //Deepak Debug
            System.debug('DeleteProjMembers********@@@-->>'+DeleteProjMembers);
            if(DeleteProjMembers <> null && DeleteProjMembers.size()>0)
                try{delete DeleteProjMembers;}catch(Exception e){System.debug('Error Message: '+e.getMessage()+e.getLineNumber());}
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
            List<id> ProjectIds = new List<id>();
            for(Core_IPS_Account__c IPSAccount : newList){                
                if(oldMap.get(IPSAccount.Id).Core_Status__c!= IPSAccount.Core_Status__c && IPSAccount.Core_Status__c=='Inactive')
                    lstInactiveAccountId.add(IPSAccount.Core_Account__c);
                if(oldMap.get(IPSAccount.Id).Core_Status__c!= IPSAccount.Core_Status__c && IPSAccount.Core_Status__c=='Active')
                    lstActiveAccountId.add(IPSAccount.Core_Account__c);
                
                ProjectIds.add(IPSAccount.Core_IPS_Project__c);
            }
                        
            if(lstInactiveAccountId.size()>0) {
                List<Core_IPS_Project_Member__c> ProjMemberList = [Select Id,Core_Status__c from Core_IPS_Project_Member__c where Core_Status__c <> 'Inactive' AND Core_IPS_Contact__r.AccountId IN: lstInactiveAccountId AND Core_IPS_Project__c IN: ProjectIds];
                if(ProjMemberList <> null) {
                    for(Core_IPS_Project_Member__c ProjectMember : ProjMemberList){
                        ProjectMember.Core_Status__c = 'Inactive';
                        lstProjMemberUpdate.add(ProjectMember);
                    }                           
                }
            }
            if(lstActiveAccountId.size()>0) {
                List<Core_IPS_Project_Member__c> ProjMemberList = [Select Id,Core_Status__c from Core_IPS_Project_Member__c where Core_Status__c <> 'Active' AND Core_IPS_Contact__r.AccountId IN: lstActiveAccountId AND Core_IPS_Project__c IN: ProjectIds];
                if(ProjMemberList <> null) {
                    for(Core_IPS_Project_Member__c ProjectMember : ProjMemberList){
                        ProjectMember.Core_Status__c = 'Active';
                        lstProjMemberUpdate.add(ProjectMember);
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
                System.debug('MPNDA-->'+projAccMap.get(projAccount.Id).Core_IPS_Project__r.Core_MPNDA__c+'<--CNDA-->'+projAccMap.get(projAccount.Id).Core_Account__r.Core_CNDA_Number__c);
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