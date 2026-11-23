@isTest public class Core_ExternalUser_IPS_TestV2 {
    
    @testSetup static void setup() {
        Test.startTest();
        //Parameters for the below method : AccountName, NoOFAcconts, NoOFContacts(IPS), NoOfContacts(NonIPS), NoOfCommUsers , profile for community Users, , NoOfAssets
        TestUtilities.getCustomerUsersWithAccountsAndContacts('TestAcct',1, 5, 5, 5,  'IPS External Customer', 4);
        Test.stopTest();
        
    }
    
    //Validate test Data
    public static testMethod void test_DataSetup(){
        system.debug('>>>>>>>>>>>>>>> test_DataSetup  \n\n ');
        
        for(User u : [Select Id, Name, Email, UserType, Profile.Name, UserRole.Name From User where createddate = today AND Name Like '%TestAcct%'])
            system.debug('>>>>>>>>>>>>>>>' +u);
        
        for(Account acct: [Select Id, Name, (Select Id, Name, Account.Name FROM Assets), (Select Id, Name From Contacts) FROM Account ]){
            System.debug(' \n Account ++++ '+acct.Name);
            for(Asset a : acct.assets)
                System.debug(' asset '+a);
            for(contact c : acct.Contacts)
                System.debug(' Contact '+c);
        }
        
    }
    
    
    //Test : Page can be accessed by External User
    public static testMethod void test_Step1_CreateIPSProject_Positive() {

        Contact con = [Select Id FROM Contact WHERE  Account.Name = 'TestAcct0' Limit 1];
        User ipsExternalUser = [Select Id FROM User where ContactId =:con.id];
        system.runAs(ipsExternalUser){
            RecordType rc  = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'];
            System.debug(' ++++ '+rc);
            Core_IPS_Project__c cip=new Core_IPS_Project__c();
            ApexPages.StandardController sc = new ApexPages.standardController(cip);
            Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);  
            
            cep.ipsProject.Name ='testIPSProjectCreation';
            cep.ipsProject.Core_Project_Description__c ='testIPSProjectCreation';
            
            cep.nextStep();
            Core_IPS_Project__c newIpsProj = [Select Id, Name from Core_IPS_Project__c where Name = 'testIPSProjectCreation'];
            System.assertNotEquals(null, newIpsProj);
            System.assertEquals('testIPSProjectCreation', newIpsProj.Name);
        }   
    }
    
    //Test : Page cannot be accessed by Admin User or internal User
    public static testMethod void test_Step1_CreateIPSProject_Negative() {
        User internalUser = [Select Id FROM User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        system.runAs(internalUser){
            ApexPages.StandardController sc = new ApexPages.standardController(new Core_IPS_Project__c());
            Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);  
            ApexPages.Message[] pageMessages = ApexPages.getMessages();
            ApexPages.Message message = pageMessages[0];
            System.assert(message.getSummary().contains('user or user not authorized'));
        }
    } 
    
    //Test : Navigation to make sure controller is not throwing any exceptions any for all the actions of the pages
    public static testMethod void test_AllSteps_Navigation() {
        Contact con = [Select Id FROM Contact WHERE  Account.Name = 'TestAcct0' Limit 1];
        User ipsExternalUser = [Select Id FROM User where ContactId =:con.id];
        system.runAs(ipsExternalUser){
            RecordType rc  = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'];
            System.debug(' ++++ '+rc);
            Boolean excpOccured = false;
            try{
                Core_IPS_Project__c cip=new Core_IPS_Project__c();
                ApexPages.StandardController sc = new ApexPages.standardController(cip);
                Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);  
                
                cep.ipsProject.Name ='testIPSMember_Success';
                cep.ipsProject.Core_Project_Description__c ='testIPSMember_Success';
                cep.nextStep();
                cep.previousStep();
                cep.nextStep();
                cep.btnActionSource='AvailableRecords';
                
                //Step 2
                cep.firstPage();
                cep.previousPage();
                cep.nextPage();
                cep.lastPage();
                cep.reset();
                cep.nextStep();
                //Step 3
                cep.firstPage();
                cep.previousPage();
                cep.nextPage();
                cep.lastPage();
                cep.reset();
                cep.saveAll();
            }catch(Exception e){
                excpOccured = true;
            }
            System.assertEquals(false, excpOccured);

        }
        
    }
	
    
    //Test : IPS project account and member should be created for the logged in user immediately after creating project.
    public static testMethod void test_Step1_CreateIPSAccount_Member_Success() {
        Contact con = [Select Id, AccountId FROM Contact WHERE  Account.Name = 'TestAcct0' Limit 1];
        User ipsExternalUser = [Select Id FROM User where ContactId =:con.id];
        system.runAs(ipsExternalUser){
            RecordType rc  = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'];
            System.debug(' ++++ '+rc);
            Core_IPS_Project__c cip=new Core_IPS_Project__c();
            ApexPages.StandardController sc = new ApexPages.standardController(cip);
            Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);  
            
            cep.ipsProject.Name ='testIPSMember_Success';
            cep.ipsProject.Core_Project_Description__c ='testIPSMember_Success';
            cep.nextStep();
            Core_IPS_Account__c  ipsAcct = [Select Id, Name, Core_Status__c FROM Core_IPS_Account__c  where Core_Account__c =: con.AccountId Limit 1]; 
            Core_IPS_Project_Member__c  ipsCont =  [Select Id, Name, Core_User__c, Core_Status__c  FROM Core_IPS_Project_Member__c  where Core_IPS_Contact__c =: con.Id Limit 1]; 
            System.assertNotEquals(null, ipsAcct);
            System.assertEquals('Active', ipsAcct.Core_Status__c );
            System.assertNotEquals(null, ipsCont);
            System.assertEquals('Active', ipsCont.Core_Status__c );
            System.assertEquals(ipsExternalUser.id, ipsCont.Core_User__c );
        }
    } 
    
    
    //Test Step 2: verify Only & all IPS Contacts available for Selection
    public static testMethod void test_Step2_Contacts_AvailableForSelection_Positive() {
        Contact con = [Select Id, AccountId FROM Contact WHERE  Account.Name = 'TestAcct0' Limit 1];
        List<Contact> ipsContacts = [Select Id, Name FROM Contact where Core_IPS_Active__c  = true AND Account.Name = 'TestAcct0'];
        List<Contact> nonIpsContacts = [Select Id, Name FROM Contact where Core_IPS_Active__c  = false AND Account.Name = 'TestAcct0'];
        System.debug(' No IPS Contacts '+ipsContacts.size());
        System.debug(' No of NON IPS Contacts '+nonIpsContacts.size());
        User ipsExternalUser = [Select Id FROM User where ContactId =:con.id];
        system.runAs(ipsExternalUser){
            RecordType rc  = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'];
            System.debug(' ++++ '+rc);
            Core_IPS_Project__c cip=new Core_IPS_Project__c();
            ApexPages.StandardController sc = new ApexPages.standardController(cip);
            Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);  
            cep.ipsProject.Name ='testIPSMember_Success';
            cep.ipsProject.Core_Project_Description__c ='testIPSMember_Success';
            cep.nextStep();
            //
            Core_CustomSetController setCntrlr = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');
            List<Core_CustomSetController.Wrapper> wl = setCntrlr.sobjectRecords;
            //System.debug('  SIZE '+wl.size());
            System.assertEquals(ipsContacts.size()-1, wl.size());
        }
    } 
   
    
    //Step 2: Test Create Project members 
    //Test project members are creating succesfully for all the selected contacts.
    public static testMethod void test_Step2_CreateIPSMembers_Positive() {
        Contact con = [Select Id, AccountId FROM Contact WHERE  Account.Name = 'TestAcct0' Limit 1];
        List<Contact> ipsContacts = [Select Id, Name FROM Contact where Core_IPS_Active__c  = true AND Account.Name = 'TestAcct0'];
        List<Contact> nonIpsContacts = [Select Id, Name FROM Contact where Core_IPS_Active__c  = false AND Account.Name = 'TestAcct0'];
        System.debug(' No IPS Contacts '+ipsContacts.size());
        System.debug(' No of NON IPS Contacts '+nonIpsContacts.size());
        User ipsExternalUser = [Select Id FROM User where ContactId =:con.id];
        system.runAs(ipsExternalUser){
            RecordType rc  = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'];
            System.debug(' ++++ '+rc);
            Core_IPS_Project__c cip=new Core_IPS_Project__c();
            ApexPages.StandardController sc = new ApexPages.standardController(cip);
            Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);  
            cep.ipsProject.Name ='testIPSMember_Success';
            cep.ipsProject.Core_Project_Description__c ='testIPSMember_Success';
            cep.nextStep();
            //
            Core_CustomSetController setCntrlr = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');
            List<Core_CustomSetController.Wrapper> wl = setCntrlr.sobjectRecords;
            Set<Id> selContIds = new Set<Id>();
            for(Integer i=0;i<2;i++){
                Core_CustomSetController.Wrapper w = wl[i];
                w.selected = true;
                selContIds.add(w.sobj.Id);
            }
            cep.updateSelectedRecords();
            
            cep.nextStep();
            //Validate:
            //1. Selected contacts are added as project members 
            //2. Status of all the project members are active
			List<Core_IPS_Project_Member__c>  projMembers =  [Select Id, Name, Core_User__c, Core_Status__c  FROM Core_IPS_Project_Member__c 
                                                              where Core_IPS_Contact__c  IN : selContIds AND Core_Status__c = 'Active']; 
            System.assertEquals(2, projMembers.size());
			//3. Core_user should not be null
			List<Core_IPS_Project_Member__c>  projMembers2 =  [Select Id, Name, Core_User__c, Core_Status__c  FROM Core_IPS_Project_Member__c 
                                                              where Core_IPS_Contact__c  IN : selContIds AND Core_Status__c = 'Active' AND Core_User__c = null]; 
			System.assertEquals(0, projMembers2.size());
            
        }
    } 
    
    
    //Test Step 3: Verify all the account.assets are available for selecting and creating IPSProdcuts
    public static testMethod void test_Step3_Assets_AvailableForIPSProduct_Success() {
        Contact con = [Select Id, AccountId FROM Contact WHERE  Account.Name = 'TestAcct0' Limit 1];
        List<Asset> allAssets = [Select Id, Name FROM Asset where Account.Id =: con.AccountId];
        System.debug(' test_IPSContactsAvailableForSelection_Success All assets for the contacts account '+allAssets.size());
        User ipsExternalUser = [Select Id FROM User where ContactId =:con.id];
        system.runAs(ipsExternalUser){
            RecordType rc  = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'];
            System.debug(' test_IPSContactsAvailableForSelection_Success ++++ '+rc);
            Core_IPS_Project__c cip=new Core_IPS_Project__c();
            ApexPages.StandardController sc = new ApexPages.standardController(cip);
            Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);  
            cep.ipsProject.Name ='testIPSMember_Success';
            cep.ipsProject.Core_Project_Description__c ='testIPSMember_Success';
            //Goto step2
            cep.nextStep();
            //Goto step3
            cep.nextStep();
            Core_CustomSetController setCntrlr = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');
            List<Core_CustomSetController.Wrapper> wl = setCntrlr.sobjectRecords;
            System.debug(' test_IPSContactsAvailableForSelection_Success  Assets available '+wl.size());
            System.assertEquals(allAssets.size(), wl.size());
        }
    } 
	
    
    //Step 3: Test Create IPS Products
    //Test all selected assets are creating succesfully and all the fields area populated 
    public static testMethod void test_Step3_CreateIPSProducts_Success() {
        Contact con = [Select Id, AccountId FROM Contact WHERE  Account.Name = 'TestAcct0' Limit 1];
        List<Asset> allAssets = [Select Id, Name FROM Asset where Account.Id =: con.AccountId];
        System.debug(' test_IPSContactsAvailableForSelection_Success All assets for the contacts account '+allAssets.size());
        User ipsExternalUser = [Select Id FROM User where ContactId =:con.id];
        system.runAs(ipsExternalUser){
            Test.startTest();
            RecordType rc  = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'];
            System.debug(' test_IPSContactsAvailableForSelection_Success ++++ '+rc);
            Core_IPS_Project__c cip=new Core_IPS_Project__c();
            ApexPages.StandardController sc = new ApexPages.standardController(cip);
            Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);  
            cep.ipsProject.Name ='testIPSMember_Success';
            cep.ipsProject.Core_Project_Description__c ='testIPSMember_Success';
            //Goto step2
            cep.nextStep();
            //Goto step3
            cep.nextStep();
            Core_CustomSetController setCntrlr = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');
            List<Core_CustomSetController.Wrapper> wl = setCntrlr.sobjectRecords;
            Set<Id> selContIds = new Set<Id>();
            //Select 2 assets among availble(i.e. 4 assets)
            for(Integer i=0;i<2;i++){
                Core_CustomSetController.Wrapper w = wl[i];
                w.selected = true;
                selContIds.add(w.sobj.Id);
            }
            cep.updateSelectedRecords();
            cep.saveAll();
            Test.stopTest();
            
            //Test all the ipsproducts are saved successfully
            List<Asset>  ipsProjAssets =  [Select Id, Name,  status  FROM Asset 
                                           where Core_IPS_Project__c =: cep.ipsProject.Id AND AccountId = null
                                           AND Status  = 'Active' AND InstallDate = TODAY
                                           AND Core_Project_Asset_Status__c = 'Active' AND RecordType.Name ='IPS Asset']; 
            System.assertEquals(2, ipsProjAssets.size());
            
            
        }
    }
	
    
    //Step 2: Edit  Project members 
    //Do Not show already selected contacts for selection under available selected list
   	public static testMethod void test_Step2_IPSMembers_AvoidDuplicates_Success() {
        Contact con = [Select Id, AccountId FROM Contact WHERE  Account.Name = 'TestAcct0' Limit 1];
        System.debug(' \n\n\n\n test_IPSMembersDuplicates_Success ');
        User ipsExternalUser = [Select Id FROM User where ContactId =:con.id];
        system.runAs(ipsExternalUser){
            RecordType rc  = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'];
            System.debug(' ++++ '+rc);
            Core_IPS_Project__c cip=new Core_IPS_Project__c();
            ApexPages.StandardController sc = new ApexPages.standardController(cip);
            Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);  
            cep.ipsProject.Name ='test_IPSMembersDuplicates_Success';
            cep.ipsProject.Core_Project_Description__c ='test_IPSMembersDuplicates_Success';
            cep.nextStep();
            //Initialize set controller
            Core_CustomSetController setCntrlr = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');
            List<Core_CustomSetController.Wrapper> wl = setCntrlr.sobjectRecords;
            Set<Id> selContIds = new Set<Id>();
            for(Integer i=0;i<2;i++){
                Core_CustomSetController.Wrapper w = wl[i];
                w.selected = true;
                selContIds.add(w.sobj.Id);
            }
            cep.updateSelectedRecords();
            
            cep.nextStep();
            
            //Test Closing the session and re-intialing the page controller
            Core_ExternalUser_IPS_Project_Controller cep2 = new Core_ExternalUser_IPS_Project_Controller(
                new ApexPages.standardController([Select Id FROM Core_IPS_Project__c where Id=:cep.ipsProject.id]));  
            cep2.nextStep();
            //
            Core_CustomSetController setCntrlr2 = cep2.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');
            List<Core_CustomSetController.Wrapper> availableContacts = setCntrlr.sobjectRecords;   
            //Query the IPS members
            Map<Id,Core_IPS_Project_Member__c> mConId_IPSMember = new Map<Id,Core_IPS_Project_Member__c>();
            for(Core_IPS_Project_Member__c ipsMem :  [Select Id, Core_IPS_Contact__c , Name, Core_User__c, Core_Status__c  
                                                      FROM Core_IPS_Project_Member__c 
                                                      where Core_IPS_Project__c =:cep.ipsProject.id  AND Core_Status__c = 'Active'])
            {
                mConId_IPSMember.put(ipsMem.Core_IPS_Contact__c,  ipsMem);
            } 
            //Verify any contact which is already selected shows in available records selection
            for(Core_CustomSetController.Wrapper w: availableContacts){
                Contact c = (Contact) w.sobj;
                System.assertEquals(null, mConId_IPSMember.get(c.Id));
            }
        }
    } 
    
    
    //Step 2: Edit  Project members 
    //Do Not show already selected products for selection under available selected list
    public static testMethod void test_Step3_IPSProducts_AvoidDuplicates_Success() {
        Contact con = [Select Id, AccountId FROM Contact WHERE  Account.Name = 'TestAcct0' Limit 1];
        System.debug(' \n\n\n\n test_IPSMembersDuplicates_Success ');
        User ipsExternalUser = [Select Id FROM User where ContactId =:con.id];
        system.runAs(ipsExternalUser){
            RecordType rc  = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'];
            System.debug(' ++++ '+rc);
            Core_IPS_Project__c cip=new Core_IPS_Project__c();
            ApexPages.StandardController sc = new ApexPages.standardController(cip);
            Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);  
            cep.ipsProject.Name ='test_IPSMembersDuplicates_Success';
            cep.ipsProject.Core_Project_Description__c ='test_IPSMembersDuplicates_Success';
            cep.nextStep();
            //
            Core_CustomSetController setCntrlr = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');
            List<Core_CustomSetController.Wrapper> wl = setCntrlr.sobjectRecords;
            Set<Id> selContIds = new Set<Id>();
            for(Integer i=0;i<2;i++){
                Core_CustomSetController.Wrapper w = wl[i];
                w.selected = true;
                selContIds.add(w.sobj.Id);
            }
            cep.updateSelectedRecords();
            
            cep.nextStep();
            
            //Test Closing the session and re-intialing the page controller
            Core_ExternalUser_IPS_Project_Controller cep2 = new Core_ExternalUser_IPS_Project_Controller(
                new ApexPages.standardController([Select Id FROM Core_IPS_Project__c where Id=:cep.ipsProject.id]));  
            cep2.nextStep();
            //
            Core_CustomSetController setCntrlr2 = cep2.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');
            List<Core_CustomSetController.Wrapper> availableContacts = setCntrlr.sobjectRecords;   
            //Query the IPS members
            Map<Id,Core_IPS_Project_Member__c> mConId_IPSMember = new Map<Id,Core_IPS_Project_Member__c>();
            for(Core_IPS_Project_Member__c ipsMem :  [Select Id, Core_IPS_Contact__c , Name, Core_User__c, Core_Status__c  
                                                      FROM Core_IPS_Project_Member__c 
                                                      where Core_IPS_Project__c =:cep.ipsProject.id  AND Core_Status__c = 'Active'])
            {
                mConId_IPSMember.put(ipsMem.Core_IPS_Contact__c,  ipsMem);
            } 
            //Verify any contact which is already selected shows in available records selection
            for(Core_CustomSetController.Wrapper w: availableContacts){
                Contact c = (Contact) w.sobj;
                System.assertEquals(null, mConId_IPSMember.get(c.Id));
            }
        }
    } 
	
    //Step 2: Remove IPS members  
    //Inactive all the removed IPS members
    public static testMethod void test_Step2_Remove_IPSMembers_Success() {
        Contact con = [Select Id, AccountId FROM Contact WHERE  Account.Name = 'TestAcct0' Limit 1];
        System.debug(' \n\n\n\n test_Step2_Remove_IPSMembers_Success ');
        User ipsExternalUser = [Select Id FROM User where ContactId =:con.id];
        system.runAs(ipsExternalUser){
            RecordType rc  = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'];
            System.debug(' ++++ '+rc);
            Core_IPS_Project__c cip=new Core_IPS_Project__c();
            ApexPages.StandardController sc = new ApexPages.standardController(cip);
            Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);  
            cep.ipsProject.Name ='test_Step2_Remove_IPSMembers_Success';
            cep.ipsProject.Core_Project_Description__c ='test_Step2_Remove_IPSMembers_Success';
            cep.nextStep();
            //Initialize set controller
            Core_CustomSetController setCntrlr = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');
            List<Core_CustomSetController.Wrapper> wl = setCntrlr.sobjectRecords;
             System.debug(' >>>>>>>>>>>>>>>>>>> test_Step2_Remove_IPSMembers_Success wl '+wl);
            Set<Id> selContIds = new Set<Id>();
            for(Integer i=0;i<2;i++){
                Core_CustomSetController.Wrapper w = wl[i];
                w.selected = true;
                selContIds.add(w.sobj.Id);
            }
            cep.updateSelectedRecords();
            
            cep.nextStep();
            sc.cancel();
            
            //Test Closing the session and re-intialing the page controller
            Core_ExternalUser_IPS_Project_Controller cep2 = new Core_ExternalUser_IPS_Project_Controller(
                new ApexPages.standardController([Select Id FROM Core_IPS_Project__c where Id=:cep.ipsProject.id]));  
            cep2.nextStep();
            //
            Core_CustomSetController setCntrlr2 = cep2.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');
            List<Core_CustomSetController.Wrapper> availableContacts = setCntrlr.sobjectRecords;   
            System.debug(' >>>>>>>>>>>>>>>>>>> test_Step2_Remove_IPSMembers_Success availableContacts '+availableContacts);
            
            
            //Query the IPS members
            Map<Id,Core_IPS_Project_Member__c> mConId_IPSMember = new Map<Id,Core_IPS_Project_Member__c>();
            for(Core_IPS_Project_Member__c ipsMem :  [Select Id, Core_IPS_Contact__c , Name, Core_User__c, Core_Status__c  
                                                      FROM Core_IPS_Project_Member__c 
                                                      where Core_IPS_Project__c =:cep.ipsProject.id  AND Core_Status__c = 'Active'])
            {
                mConId_IPSMember.put(ipsMem.Core_IPS_Contact__c,  ipsMem);
                System.debug(' >>>>>>>>>>>>>>>>>>> test_Step2_Remove_IPSMembers_Success ipsMem '+availableContacts);
            } 
            //Verify any contact which is already selected shows in available records selection
            
            for(Core_CustomSetController.Wrapper w: availableContacts){
                Contact c = (Contact) w.sobj;
                //System.assertEquals(null, mConId_IPSMember.get(c.Id));
            }
        }
    } 

}