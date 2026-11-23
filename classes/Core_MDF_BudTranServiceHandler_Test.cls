/****************************************************************************************************************************************
* Class Name  : Core_MDF_BudTranServiceHandler_Test
* Version     : 1.0 
* Created Date: 27-March-2020
* Modification Log :
* Developer                           Date                        Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture- Krishna Kulkarni         27/March/2020                 Created to test Core_MDF_BudgetTransferServiceHandler
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public without sharing class Core_MDF_BudTranServiceHandler_Test {
    
    @TestSetup static void setUpData(){
        
        //Creating Intel Account with utility class
        Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createAccount('Dell Corporation', null ,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        dellCorpAccount.BillingCity = 'Test City';         
        dellCorpAccount.BillingCountry= 'AUS';
        dellCorpAccount.BillingStreet= 'Test Street';
        Database.insert(dellCorpAccount); 
        dellCorpAccount.IsPartner = true;
        Database.update(dellCorpAccount);    
        
        //Creating Contact for Partner User
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(dellCorpAccount.Id,true);            

        PermissionSet acctBudgetAdm = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Account_Budget_Administrator' LIMIT 1];
        
        List<User> userList = new List<User>();
        List<Account> acctList = new List<Account>();
        List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
        
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        userList.add(usr);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email = 'sysadmin2@example.com';
        userList.add(usr2);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='acctBudgadm@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true; 
        userList.add(usr1);
      
        insert userList;  

		PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = acctBudgetAdm.Id, AssigneeId = usr1.Id);
        system.runAs(usr){
            database.insert(psa1); 
        }
        
        List<ChannelProgram> cpList = new List<ChannelProgram>();      
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', false);
        cpList.add(cp);
        cpList.add(cp1);
        database.insert(cpList);
        
        Test.startTest();
        
        //Creating Co-marketing Account with utility class
        Account dellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF Virtual Corp', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellCCFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        dellCCFVirtualCorp.Core_MDF_CoMarketingActive__c = true;
        acctList.add(dellCCFVirtualCorp);
        
        Account dellDCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell DCF Virtual Corp', cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellDCFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        dellDCFVirtualCorp.Core_MDF_CoMarketingActive__c = true;
        dellDCFVirtualCorp.Core_Geo__c = 'ASMO';
        dellDCFVirtualCorp.Core_Sub_Geo__c = 'LAR';
        acctList.add(dellDCFVirtualCorp);
        
        Database.insert(acctList);
        
        List<Account> listAcct = new List<Account>();
        Account dellCCFAPAC = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF APAC', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        dellCCFAPAC.Core_MDF_Parent_Fund_Account__c = dellCCFVirtualCorp.Id;
        dellCCFAPAC.Core_MDF_CoMarketingActive__c = true;
        listAcct.add(dellCCFAPAC);
        
        Account dellDCFAPAC = Core_MDF_CCP_TestDataUtility.createAccount ('Dell DCF APAC', cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        dellDCFAPAC.Core_MDF_Parent_Fund_Account__c = dellDCFVirtualCorp.Id;
        dellDCFAPAC.Core_MDF_CoMarketingActive__c = true;
        dellDCFAPAC.Core_Geo__c = 'ASMO';
        dellDCFAPAC.Core_Sub_Geo__c = 'LAR';
        listAcct.add(dellDCFAPAC);
        Database.insert(listAcct);

        List<Group> grpList = new List<Group>();
        Group grp = new Group();
        grp.Name = 'CCF_Int_Grp_WW';
        grp.DeveloperName = 'CCF_Int_Grp_WW';
        grpList.add(grp);
        
        Group grp1 = new Group();
        grp1.Name = 'DCF_Int_Grp_ASMO_LAR';
        grp1.DeveloperName = 'DCF_Int_Grp_ASMO_LAR';
        grpList.add(grp1);
        
        Group grp2 = new Group();
        grp2.Name = 'CCF_Int_Grp_APJ';
        grp2.DeveloperName = 'CCF_Int_Grp_APJ';
        grpList.add(grp2);
        system.debug('listofGrpId'+grpList);
        insert grpList;
        
        system.runAs(usr){    

            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = dellCorpAccount.Id;
            pgm.Core_MDF_Group_Name__c = 'CCF_Int_Grp_WW';
            pgm.Core_MDF_Type_of_Access__c = 'Internal';
            pgm.Core_MDF_Source_Txt__c  = 'Test';
            pgm.Core_MDF_Group_Id__c = grp.Id;                
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            pgm.Core_MDF_Region_cd__c='WW';
            Database.insert(pgm);
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = dellCorpAccount.Id;
            pgm1.Core_MDF_Group_Name__c = 'DCF_Int_Grp_ASMO_LAR';
            pgm1.Core_MDF_Type_of_Access__c = 'Internal';
            pgm1.Core_MDF_Source_Txt__c  = 'Test';
            pgm1.Core_MDF_Group_Id__c = grp1.Id;                
            pgm1.Core_MDF_Channel_Program__c = cp1.Id;
            pgm1.Core_MDF_Region_cd__c='ASMO';
            pgm1.Core_MDF_Sub_Region_cd__c='LAR';
            Database.insert(pgm1);
            
            Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
            pgm2.Core_MDF_Account__c = dellCorpAccount.Id;
            pgm2.Core_MDF_Group_Name__c = 'CCF_Int_Grp_APJ';
            pgm2.Core_MDF_Type_of_Access__c = 'Internal';
            pgm2.Core_MDF_Source_Txt__c  = 'Test';
            pgm2.Core_MDF_Group_Id__c = grp2.Id;                
            pgm2.Core_MDF_Channel_Program__c = cp.Id;
            pgm2.Core_MDF_Region_cd__c='APJ';
            Database.insert(pgm2);
        }
        
        Test.stopTest();
        List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        
        Core_MDF_Partner_Node_User_Mapping__c pnum1 = new Core_MDF_Partner_Node_User_Mapping__c();
        pnum1.Core_MDF_Account__c=dellCCFVirtualCorp.Id;
        pnum1.Core_MDF_User__c=usr1.Id;
        pnumList.add(pnum1);
        
        Database.insert(pnumList);

        //Create PMB for the above Account
        List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
        
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,dellCCFVirtualCorp.Id,cp.Id,100000,System.today().addDays(-15),System.today().addDays(15),false);
        pmbList.add(pmbRecord);
        
        PartnerMarketingBudget  pmbRecord1 = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMB1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,dellDCFVirtualCorp.Id,cp1.Id,100000,System.today().addDays(-15),System.today().addDays(15),false);
        pmbList.add(pmbRecord1);

        Database.insert(pmbList);
        
        List<Core_MDF_Budget_Transfer_Log__c> btlList = new List<Core_MDF_Budget_Transfer_Log__c>();
        
        Core_MDF_Budget_Transfer_Log__c atl = new Core_MDF_Budget_Transfer_Log__c();    
        atl.Core_MDF_Partner_Marketing_Budget__c = pmbRecord.Id;
        atl.Core_MDF_From_Account_Current_Balance__c = 3900;
        atl.Core_MDF_From_Account_Opening_Balance__c = 3800;
        atl.Core_MDF_Source_Account__c = dellCCFVirtualCorp.Id;
        atl.Core_MDF_Target_Account__c = dellCCFAPAC.Id;
        atl.Core_MDF_To_Account_Current_Balance__c = 2000;
        atl.Core_MDF_To_Account_Opening_Balance__c = 2100;
        atl.Core_MDF_Transfer_Type__c = 'Manual';
        atl.Core_MDF_Transferred_Amount__c = 100;
        btlList.add(atl);
        
        Core_MDF_Budget_Transfer_Log__c atl1 = new Core_MDF_Budget_Transfer_Log__c();    
        atl1.Core_MDF_Partner_Marketing_Budget__c = pmbRecord1.Id;
        atl1.Core_MDF_From_Account_Current_Balance__c = 3900;
        atl1.Core_MDF_From_Account_Opening_Balance__c = 3800;
        atl1.Core_MDF_Source_Account__c = dellDCFVirtualCorp.Id;
        atl1.Core_MDF_Target_Account__c = dellDCFAPAC.Id;
        atl1.Core_MDF_To_Account_Current_Balance__c = 2000;
        atl1.Core_MDF_To_Account_Opening_Balance__c = 2100;
        atl1.Core_MDF_Transfer_Type__c = 'Manual';
        atl1.Core_MDF_Transferred_Amount__c = 100;
        btlList.add(atl1);
        
        database.insert(btlList);
    }
    
    //Test method to test SharingAccountTransfer
    @isTest static void testpopulateUniqueField(){
               
        Account account1 = [SELECT ID From Account where Name = 'Dell DCF Virtual Corp' LIMIT 1];
        User usr = [SELECT ID From User where Email = 'sysadmin@example.com'];
        
        List<Core_MDF_Budget_Transfer_Log__c> accountTransferList = [SELECT ID, Core_MDF_Source_Account__c, Core_MDF_From_Account_Opening_Balance__c, Core_MDF_From_Account_Current_Balance__c, Core_MDF_Target_Account__c, Core_MDF_To_Account_Opening_Balance__c, Core_MDF_To_Account_Current_Balance__c, Core_MDF_Transfer_Type__c, Core_MDF_Transferred_Amount__c, Core_MDF_Partner_Marketing_Budget__c, CreatedDate From Core_MDF_Budget_Transfer_Log__c where Core_MDF_Source_Account__c =: account1.Id];
        Map<Id,Core_MDF_Budget_Transfer_Log__c> accountTransferIdToAccountTransferMap = new  Map<Id,Core_MDF_Budget_Transfer_Log__c>([Select Id, CreatedDate from  Core_MDF_Budget_Transfer_Log__c where Core_MDF_Source_Account__c =: account1.Id]); 

        Test.startTest();
        system.runas(usr){            
            Core_MDF_BudgetTransferServiceHandler.populateUniqueField(accountTransferList, null);
            Core_MDF_BudgetTransferServiceHandler.populateUniqueField(accountTransferList, accountTransferIdToAccountTransferMap);
        }
        Core_MDF_Budget_Transfer_Log__c budgetTransLogRec = [SELECT Id, Core_MDF_Unique_Key_txt__c from Core_MDF_Budget_Transfer_Log__c where Core_MDF_Source_Account__c =: account1.Id];
        Boolean flag = false;
        if(budgetTransLogRec.Core_MDF_Unique_Key_txt__c != null){
            flag = true;
        }
        System.assertEquals(flag, true);
        Test.stopTest();        
    }
}