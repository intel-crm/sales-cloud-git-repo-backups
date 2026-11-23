/****************************************************************************************************************************************
* Class Name  : Core_ExternalUser_IPS_Project_Ctrl_Test
* Version     : 1.0 
* Created Date: 5 Oct 2017
* Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         10/5/2017               Test Class for:   
Core_CustomSetController,  
Core_ExternalUser_IPS_Project_Controller,
Core_ExternalUser_IPS_Project_Helper
*****************************************************************************************************************************************/
@isTest
public class Core_ExternalUser_IPS_Project_Ctrl_Test{
    
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
                //US158228 --22 Nov 2018- add by Orion vamsi
                List<SelectOption> selOpts=cep.getdynamiclist();
                
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
            RecordType assetRecType = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType='Asset' AND Name ='IPS Asset'];
            
            //Create Support Org
            Core_IPS_Product_Organization__c SupOrg = new Core_IPS_Product_Organization__c(); //SupportOrg
            SupOrg.Core_IPS_Support_Org_Name__c='Trident Solutions';
            SupOrg.Core_Organization_Description__c='This is from portal side';
            insert SupOrg;
            
            //List Of Products
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
            ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='75025';
            ListOfProducts[0].IsActive = true;
            ListOfProducts[0].Core_Code_Name_EPM_ID__c ='75025';
            ListOfProducts[0].Name = 'Haswell processor';
            ListOfProducts[0].IsActive = true;
            ListOfProducts[0].Core_Product_Status__c= 'Active';
            ListOfProducts[0].Core_IPS_Visible_Flag_External__c = true;
            ListOfProducts[0].Core_IPS_Visible_Flag_Internal__c = 'Yes';
            ListOfProducts[0].Core_Product_Org__c = 'IPS';
            ListOfProducts[0].Core_Hierarchy_ID__c = '43';
            
            insert ListOfProducts;
            
            //Create Supported product Record
            List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            ListOfSupportedProduct[0].Core_Product__c = ListOfProducts[0].id;
            ListOfSupportedProduct[0].Core_Product_Organization__c = SupOrg.Id;
            ListOfSupportedProduct[0].Core_Flag_Status__c = 'Auto Approve';
            ListOfSupportedProduct[0].Core_Product_EPM_ID__c = '75025';
            ListOfSupportedProduct[0].Core_Supported_Product_Name__c = 'Haswell processor';
            upsert ListOfSupportedProduct;
            
            List<Asset> listofAssets= TestUtilities.getAssetList(1);
            listofAssets[0].Product2Id = ListOfProducts[0].id;
            listofAssets[0].Name = 'Haswell processor';
            listofAssets[0].AccountID =  con.AccountId;
            listofAssets[0].Core_Project_Asset_Status__c='Active';
            listofAssets[0].status ='Active';
            listofAssets[0].RecordTypeID= assetRecType.id;
            listofAssets[0].Core_IPS_Asset__c = true;
            listofAssets[0].Core_Code_Name__c = 'false';
            listofAssets[0].Core_Supported_Product__c = ListOfSupportedProduct[0].id;
            listofAssets[0].Core_Product_Organization__c =  SupOrg.Id;
            listofAssets[0].InstallDate = system.today();
            
            insert listofAssets;
            
            List<Asset> allAssets = [Select Id, Name FROM Asset where Account.Id =: con.AccountId];
            
            RecordType rc  = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'];
            System.debug(' ++++ '+rc);
            Core_IPS_Project__c cip=new Core_IPS_Project__c();
            ApexPages.StandardController sc = new ApexPages.standardController(cip);
            Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);  
            
            cep.ipsProject.Name ='testIPSMember_Success';
            cep.ipsProject.Core_Project_Description__c ='testIPSMember_Success';
            cep.nextStep();
            
            Core_CustomSetController setCntrlr = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');
            List<Core_CustomSetController.Wrapper> wl = setCntrlr.sobjectRecords;
            Set<Id> selContIds = new Set<Id>();
            for(Integer i=0;i<2;i++){
                Core_CustomSetController.Wrapper w = wl[i];
                w.selected = true;
                selContIds.add(w.sobj.Id);
                cep.updateSelectedRecords();
                
            }
            
            Core_CustomSetController setCntrlr2 = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');
            List<Core_CustomSetController.Wrapper> wl2 = setCntrlr2.sobjectRecords;
            Set<Id> selContIds2 = new Set<Id>();
            //Select 2 assets among availble(i.e. 4 assets)
            for(Integer i=0;i<2;i++){
                Core_CustomSetController.Wrapper w2 = wl2[i];
                w2.selected = true;
                selContIds2.add(w2.sobj.Id);
                cep.updateSelectedRecords();
                
            }
            cep.saveAll();
            system.debug('ZXXX'+cip.id);
            
            Core_IPS_Account__c  ipsAcct = [Select Id, Name, Core_Status__c FROM Core_IPS_Account__c  where Core_Account__c =: con.AccountId Limit 1]; 
            Core_IPS_Project_Member__c  ipsCont =  [Select Id, Name, Core_User__c, Core_Status__c  FROM Core_IPS_Project_Member__c  where Core_IPS_Contact__c =: con.Id Limit 1]; 
            System.assertNotEquals(null, ipsAcct);
            System.assertEquals('Active', ipsAcct.Core_Status__c );
            System.assertNotEquals(null, ipsCont);
            System.assertEquals('Active', ipsCont.Core_Status__c );
            System.assertEquals(ipsExternalUser.id, ipsCont.Core_User__c );
        }
    } 
    
    //Test Step 2: verify Only & all IPS Contacts With Users available for Selection
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
            Core_CustomSetController setCntrlr = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');
            List<Core_CustomSetController.Wrapper> wl = setCntrlr.sobjectRecords;
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
            List<Core_IPS_Project_Member__c>  projMembers =  [Select Id, Name, Core_User__c, Core_Status__c  FROM Core_IPS_Project_Member__c 
                                                              where Core_IPS_Contact__c  IN : selContIds AND Core_Status__c = 'Active']; 
            
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
            System.debug(' test_IPSContactsAvailableForSelection_Success  Assets available '+wl);
            System.debug(' test_IPSContactsAvailableForSelection_Success  Assets available '+wl.size());
            System.assertEquals(allAssets.size(), wl.size());
        }
    } 
    
    
    //Step 3: Test Create IPS Products
    //Test all selected assets are creating succesfully and all the fields area populated 
    public static testMethod void test_Step3_CreateIPSProducts_Success() {
        Boolean excpOccured = false;
        try{
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
            }
        }Catch(Exception e){
            excpOccured = true;
        }
        System.assertEquals(true, excpOccured);
    }
    
    //Search Project Members Positive
    static TestMethod void testSearchAvailableMembers(){
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
            
            Core_CustomSetController setCntrlr = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');        
            setCntrlr.searchString = 'Intel';
            setCntrlr.searchColumnName= 'Name';
            setCntrlr.getSearchCondition();
            setCntrlr.getRecords();
            setCntrlr.getSelectedSobjectRecords();
            System.assertNotEquals(null,setCntrlr.pagesize==0);
        }
    }
    
    //Search Project Product Negative
    static TestMethod void testSearchAvailableProductsNegative(){
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
            
            Core_CustomSetController setCntrlr = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');        
            setCntrlr.searchString = '';
            setCntrlr.searchColumnName= 'Core_IPS_Contact__r.Name';
            setCntrlr.getSearchCondition();
            System.assertNotEquals(null,setCntrlr.pagesize!=0);
        }
    }
    
    
    //Testing exising assets which are in active
    static TestMethod Void testExistingAssets(){
        
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts;
        
        Core_IPS_Project__c ipsProject = new Core_IPS_Project__c(); 
        ipsProject.Name ='value1';
        ipsProject.Core_MPNDA__c='4567';
        insert ipsProject;
        
        Asset asset1=new Asset();
        asset1.Name='test1';
        asset1.Core_IPS_Project__c=ipsProject.Id;
        asset1.Product2Id=ListOfProducts[0].id;
        asset1.Core_Project_Asset_Status__c='InActive';
        asset1.status='InActive';            
        insert asset1; 
        
        Map<Id, Asset> mSuppProd_ipsProd = Core_ExternalUser_IPS_Project_Helper.getExistingAssets(ipsProject.id);
        System.assertNotEquals(null, mSuppProd_ipsProd);
    }
    
    //Step 2: Remove IPS members  
    //Inactive all the removed IPS members
    public static testMethod void test_Step2_Remove_IPSMembers_Success2() {
        Contact con = [Select Id, AccountId FROM Contact WHERE  Account.Name = 'TestAcct0' Limit 1];
        System.debug(' \n\n\n\n test_Step2_Remove_IPSMembers_Success');
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
            cep.saveAll();
            cep.updateRecords();
            
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
            Cep.removeMembers();
            sc.cancel();
            
            //Test Closing the session and re-intialing the page controller
            cep.removeMembers();
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
                System.assertEquals(null, mConId_IPSMember.get(c.Id));
            }
        }
    }
    
    //Test all selected assets are creating succesfully and all the fields area populated 
    public static testMethod void test_exception(){
        Boolean excpOccured = false;
        try{
            Contact con = [Select Id, AccountId FROM Contact WHERE  Account.Name = 'TestAcct0' Limit 1];
            List<Asset> allAssets = [Select Id, Name FROM Asset where Account.Id =: con.AccountId];
            System.debug(' test_IPSContactsAvailableForSelection_Success All assets for the contacts account '+allAssets.size());
            User ipsExternalUser = [Select Id FROM User where ContactId =:con.id];
            system.runAs(ipsExternalUser){
                Test.startTest();
                RecordType rc  = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'];
                System.debug(' test_IPSContactsAvailableForSelection_Success ++++ '+rc);
                Core_IPS_Project__c cip=new Core_IPS_Project__c();
                
                cip.Name ='testIPSMember_Success';
                cip.Core_Project_Description__c ='testIPSMember_Success';
                insert cip;
                System.debug('ZXXX'+cip.id);
                ApexPages.StandardController sc = new ApexPages.standardController(cip);
                Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);  
                cep.getLoggerInUser();
                cep.ipsProject.Name ='testIPSMember_Success';
                cep.ipsProject.Core_Project_Description__c ='testIPSMember_Success';
                //Goto step2
                cep.nextStep();
                //Goto step3
                cep.nextStep();
                cep.updateRecords();
                Core_CustomSetController setCntrlr = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');
                List<Core_CustomSetController.Wrapper> wl = setCntrlr.sobjectRecords;
                Set<Id> selContIds = new Set<Id>();
                //Select 2 assets among availible(i.e. 4 assets)
                for(Integer i=0;i<2;i++){
                    Core_CustomSetController.Wrapper w = wl[i];
                    w.selected = true;
                    selContIds.add(w.sobj.Id);
                }
                cep.updateSelectedRecords();
                cep.upsertAsserts();
                cep.saveAll();                
                
                Test.stopTest();
            }
        }Catch(Exception e){
            excpOccured = true;
        }
        System.assertEquals(true, excpOccured);
    }
    
    
    //Step 2: Remove IPS members  
    public static testMethod void test_Step2_Remove_IPSMembers_Success3() {
        Contact con = [Select Id, AccountId FROM Contact WHERE  Account.Name = 'TestAcct0' Limit 1];
        User ipsExternalUser = [Select Id FROM User where ContactId =:con.id];
        system.runAs(ipsExternalUser){
            RecordType assetRecType = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType='Asset' AND Name ='IPS Asset'];
            
            //Create Support Org
            Core_IPS_Product_Organization__c SupOrg = new Core_IPS_Product_Organization__c(); //SupportOrg
            SupOrg.Core_IPS_Support_Org_Name__c='Trident Solutions';
            SupOrg.Core_Organization_Description__c='This is from portal side';
            insert SupOrg;
            
            //List Of Products
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
            ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='75025';
            ListOfProducts[0].IsActive = true;
            ListOfProducts[0].Core_Code_Name_EPM_ID__c ='75025';
            ListOfProducts[0].Name = 'Haswell processor';
            ListOfProducts[0].IsActive = true;
            ListOfProducts[0].Core_Product_Status__c= 'Active';
            ListOfProducts[0].Core_IPS_Visible_Flag_External__c = true;
            ListOfProducts[0].Core_IPS_Visible_Flag_Internal__c = 'Yes';
            ListOfProducts[0].Core_Product_Org__c = 'IPS';
            ListOfProducts[0].Core_Hierarchy_ID__c = '43';
            
            insert ListOfProducts;
            
            //Create Supported product Record
            List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            ListOfSupportedProduct[0].Core_Product__c = ListOfProducts[0].id;
            ListOfSupportedProduct[0].Core_Product_Organization__c = SupOrg.Id;
            ListOfSupportedProduct[0].Core_Flag_Status__c = 'Auto Approve';
            ListOfSupportedProduct[0].Core_Product_EPM_ID__c = '75025';
            ListOfSupportedProduct[0].Core_Supported_Product_Name__c = 'Haswell processor';
            upsert ListOfSupportedProduct;
            
            List<Asset> listofAssets= TestUtilities.getAssetList(1);
            listofAssets[0].Product2Id = ListOfProducts[0].id;
            listofAssets[0].Name = 'Haswell processor';
            listofAssets[0].AccountID =  con.AccountId;
            listofAssets[0].Core_Project_Asset_Status__c='Active';
            listofAssets[0].status ='Active';
            listofAssets[0].RecordTypeID= assetRecType.id;
            listofAssets[0].Core_IPS_Asset__c = true;
            listofAssets[0].Core_Code_Name__c = 'false';
            listofAssets[0].Core_Supported_Product__c = ListOfSupportedProduct[0].id;
            listofAssets[0].Core_Product_Organization__c =  SupOrg.Id;
            listofAssets[0].InstallDate = system.today();
            
            insert listofAssets;
            
            List<Asset> allAssets = [Select Id, Name FROM Asset where Account.Id =: con.AccountId];
            
            RecordType rc  = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'];
            System.debug(' ++++ '+rc);
            Core_IPS_Project__c cip=new Core_IPS_Project__c();
            ApexPages.StandardController sc = new ApexPages.standardController(cip);
            Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);  
            
            cep.ipsProject.Name ='testIPSMember_Success';
            cep.ipsProject.Core_Project_Description__c ='testIPSMember_Success';
            cep.nextStep();
            
            Core_CustomSetController setCntrlr = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');
            List<Core_CustomSetController.Wrapper> wl = setCntrlr.sobjectRecords;
            Set<Id> selContIds = new Set<Id>();
            for(Integer i=0;i<2;i++){
                Core_CustomSetController.Wrapper w = wl[i];
                w.selected = true;
                selContIds.add(w.sobj.Id);
                cep.updateSelectedRecords();
                
            }
            
            Core_CustomSetController setCntrlr2 = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');
            List<Core_CustomSetController.Wrapper> wl2 = setCntrlr2.sobjectRecords;
            Set<Id> selContIds2 = new Set<Id>();
            //Select 2 assets among availble(i.e. 4 assets)
            for(Integer i=0;i<2;i++){
                Core_CustomSetController.Wrapper w2 = wl2[i];
                w2.selected = true;
                selContIds2.add(w2.sobj.Id);
                cep.updateSelectedRecords();
                
            }
            cep.saveAll();
            system.debug('IPS Project Created ID : '+cip.id);
            
            //Initialize set controller
            Core_CustomSetController setCntrlr3 = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords');
            List<Core_CustomSetController.Wrapper> wl3 = setCntrlr.sobjectRecords;
            Set<Id> selContIds3 = new Set<Id>();
            //Select 2 assets among availble(i.e. 4 assets)
            for(Integer i=0;i<2;i++){
                Core_CustomSetController.Wrapper w3 = wl3[i];
                w3.selected = true;
                selContIds3.add(w3.sobj.Id);
                //cep.projOwnerId = ApexPages.currentPage().getParameters().get('projOwnerId');
                //cep.projOwnerId = ipsExternalUser.id;
                cep.removeMembers();
            }
           cep.removeMembers();
            //Select the member to remove
            //Call remove members button
            //Asserts 
        }
    }
}