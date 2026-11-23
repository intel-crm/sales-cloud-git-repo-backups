/****************************************************************************************************************************************
* Class Name  : Core_ExternalUser_IPS_Project_Ctrl_Test
* Version     : 1.0 
* Created Date: 5 Oct 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         10/5/2017             test Class for Core_ExternalUser_IPS_Project_Controller  Main Controller to create Premier Support Projects As IPS EXternal Customer 
*****************************************************************************************************************************************/
@isTest
public class Core_ExternalUser_IPS_Test_RK {
    
    @testSetup static void setup() {
        
        RecordType accRecType = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType='Account' AND Name ='Intel Account'];
        RecordType conRecType = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType='Contact' AND Name ='Intel Contact'];
        RecordType assetRecType = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType='Asset' AND Name ='IPS Asset'];
        User adminUser = [Select Id, Name FROm User where Profile.Name = 'System Administrator' Limit 1];
        Profile powerUserProfile = [select id From profile Where usertype = 'PowerCustomerSuccess' limit 1];
        
        Test.startTest();
        
        List <Account> accts = TestUtilities.getAccountsList(4);
        for(Integer i=0; i<accts.size();i++){
            accts[i].Name = 'Test Account'+String.ValueOf(i);
            accts[0].RecordTypeId = accRecType.Id;
        }
        insert accts;
        
        
        List<Contact> conts = TestUtilities.getListOfContact(8);
        conts[0].FirstName = 'Test Contact0';
        conts[1].FirstName = 'Test Contact1';
        
        conts[0].RecordTypeId = conRecType.Id;
        conts[0].Core_IPS_Intel_Support_Owner__c = adminUser.Id;
        conts[1].Core_IPS_Intel_Support_Owner__c = adminUser.Id;
        
        conts[2].FirstName = 'Test Contact2';
        conts[3].FirstName = 'Test Contact3';
        conts[4].FirstName = 'Test Contact4';
        conts[5].FirstName = 'Test Contact5';
        conts[5].Core_IPS_Active__c = false;
        conts[6].FirstName = 'Test Contact6';
        conts[7].FirstName = 'Test Contact7';
        conts[7].Core_IPS_Active__c = false;
        
        
        conts[0].AccountID = accts[0].id;
        conts[1].AccountID = accts[0].id;
        conts[2].AccountID = accts[1].id;
        conts[3].AccountID = accts[1].id;
        conts[4].AccountID = accts[2].id;
        conts[5].AccountID = accts[2].id;
        conts[6].AccountID = accts[3].id;
        conts[7].AccountID = accts[3].id;
        insert conts;
        
        
        List<User> users = TestUtilities.getListOfUser(4);
        Profile profileIPS = [SELECT Id FROM Profile WHERE Name = 'IPS External Customer' LIMIT 1];
        System.debug('Test users are '+users);
        
        //Create a community User
        Profile p = [Select Id, Name from Profile where Name ='IPS External Customer' ];
        System.debug('SK  '+ [Select Id, Name from UserRole where Name Like '%Test Account%' ]);
        //UserRole ur = [Select Id, Name from UserRole where Name Like '%Test Account0%'];
        UserLicense ul = [SELECT Id, Name FROM UserLicense where Name = 'Customer Community Plus'];
        
        Integer i=0;
        for(Contact c: [Select Id, Email, FirstName FROM Contact where FirstName = 'Test Contact0' OR FirstName = 'Test Contact1']){
            User u = new User();
            u.FirstName = 'Daze'+c.FirstName;
            u.LastName = 'CommUser';
            u.ContactId = c.Id;
           // U.AccountID = accts[0].id;
            u.Username = 'u'+String.valueOf(i)+c.Email;
            u.Email = String.valueOf(i)+c.Email;
            u.CommunityNickname = String.valueOf(i)+'unitTest';
            u.Alias = 'utest';
            u.TimeZoneSidKey = 'America/Phoenix'; // Required
            u.LocaleSidKey = 'en_US'; // Required
            u.EmailEncodingKey = 'ISO-8859-1'; // Required
            u.LanguageLocaleKey = 'en_US'; // Required
            u.ProfileId = p.Id;
            //u.UserRoleId = ur.Id;
            u.Alias = 'utest';
            System.debug('SK Portal User '+u);
            insert u;
            i=i+1;
        }
        
        
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
        ListOfSupportedProduct[0].Core_IPS_Is_Show_Variant__c = true;
        ListOfSupportedProduct[0].Core_Flag_Status__c = 'Auto Approve';
        ListOfSupportedProduct[0].Core_Product_EPM_ID__c = '75025';
        ListOfSupportedProduct[0].Core_Supported_Product_Name__c = 'Haswell processor';
        upsert ListOfSupportedProduct;
        
        
        List<Asset> listofAssets= TestUtilities.getAssetList(1);
        listofAssets[0].Product2Id = ListOfProducts[0].id;
        listofAssets[0].Name = 'Haswell processor';
        listofAssets[0].AccountID =  accts[0].id;
        listofAssets[0].Core_Project_Asset_Status__c='Active';
        listofAssets[0].status ='Active';
        listofAssets[0].RecordTypeID= assetRecType.id;
        listofAssets[0].Core_IPS_Asset__c = true;
        listofAssets[0].Core_Code_Name__c = 'false';
        listofAssets[0].Core_Supported_Product__c = ListOfSupportedProduct[0].id;
        listofAssets[0].Core_Product_Organization__c =  SupOrg.Id;
        listofAssets[0].InstallDate = system.today();
       
        System.debug('RAST'+listofAssets[0].AccountID);
        
        insert listofAssets;
        system.debug('List of Assets'+listofAssets);
        
        System.debug('SK SETUP  Contacts Total '+[Select Id, Core_IPS_Active__c FROM Contact ]);
        System.debug('SK SETUP  Accounts Total '+[Select Id, RecordTypeId, RecordType.Name,  Core_IPS_Active__c FROM Account ]);
        Test.stopTest();
        
        System.debug('SK '+[Select Id, Name from UserRole where Name Like '%Test Account0%']);
    }
    
    public static testMethod void testDataSetup(){
        List<Account> accts = [Select Id FROM Account];
        //TODO contacts, assets, User
        System.assertEquals(4, accts.size());
        List<User> users = [Select Id, Name, Profile.Name FROM USER];
        System.debug('  testDataSetup '+users);
    }
    
    //Create a IPS Project 
    public static testMethod void testIPSProjectCreation_Success() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IPS External Customer' LIMIT 1];
        Contact con = [Select Id FROM Contact Limit 1];
        User ipsExternalUser = [Select Id FROM User where ContactId =:con.id];
        
        List<Contact> contList2 = [Select Id, FirstName,LastName,Email,AccountID from contact];
        system.debug('RAX Contacts'+contList2);
        
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
            System.debug('RAX >>>> '+newIpsProj);
            System.assertNotEquals(null, newIpsProj);
            System.assertEquals('testIPSProjectCreation', newIpsProj.Name);
            //Assertion
            
            //Assert group id is created
            
        }   
    }
    
    //Create a IPS Project Error
    public static testMethod void testIPSProjectCreation_Error() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IPS External Customer' LIMIT 1];
        Contact con = [Select Id FROM Contact Limit 1];
        User ipsExternalUser = [Select Id FROM User where ContactId =: con.id];
        system.runAs(ipsExternalUser){
            
            
            RecordType rc  = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'];
            System.debug(' ++++ '+rc);
            Core_IPS_Project__c cip=new Core_IPS_Project__c();
            ApexPages.StandardController sc = new ApexPages.standardController(cip);
            Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);  
            
            cep.ipsProject.Name ='error message';
            cep.ipsProject.Core_Project_Description__c ='testIPSProjectCreation';
            cep.nextStep();//Call Action
            
            //validation 1: Record should not create
            //Step 2:Page should throw error message
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            System.debug('  error message  '+msgs);
            //TODO
            List<Core_CustomSetController.Wrapper> availRecords = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords').sobjectRecords;
            System.debug(' >>>>>>>>> availRecords '+availRecords);
            
            //Assert on for 2 records    
            
        }
    }
    
    public static testMethod void testCreateIPSMember_Success() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IPS External Customer' LIMIT 1];
        Contact con = [Select Id, Core_IPS_Active__c  FROM Contact Limit 1];
        
        //Contact ConAcc = [Select AccountID from Contact where Id =:con.id];
        User ipsExternalUser = [Select Id, Name, Profile.Name,AccountID,  UserRole.Name FROM User where Contact.FirstName = 'Test Contact0'];
        System.debug('SK '+ipsExternalUser);
        System.debug('SK TM  Contacts Total '+[Select Id, Core_IPS_Active__c FROM Contact ]);
        System.debug('SK TM  Accounts Total '+[Select Id, Core_IPS_Active__c FROM Account ]);
        
        List <Asset> asset7472 = [Select Name,id,RecordTypeID,AccountID,Product2ID,Core_Supported_Product__R.Id,Core_Product_EPM_ID__c,Core_Project_Asset_Status__c,Core_Support_Org_Name__c,Core_IPS_Asset__c,Core_Product_Organization__c  from Asset];
        System.debug('asset7472'+asset7472 );
        
        system.runAs(ipsExternalUser){
            Core_IPS_Project__c cip=new Core_IPS_Project__c();
            
          List <Asset> asset747 = [Select Name,id,Core_Project_Asset_Status__c,status,RecordTypeID,Core_IPS_Asset__c,Core_Supported_Product__c,Product2ID  from Asset];
            System.debug('asset747'+asset747 );
            
            Contact conQuery = [Select AccountID from Contact where id=:con.id ];
            
            List<Contact> contList = [Select Id, FirstName,LastName,Email from contact where AccountID=:conQuery.AccountID ];
            
            RecordType rc  = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'];
            System.debug(' ++++ '+rc);
                        
            ApexPages.StandardController sc = new ApexPages.standardController(cip);
            
            Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);
            system.debug('cep.IPSProductBasicRecordType==='+cep.IPSProductBasicRecordType);
            cep.ipsProject.Name ='testIPSProjectCreation';
            cep.ipsProject.Core_Project_Description__c ='testIPSProjectCreation';
            
            cep.ipsProject = cip;
            cep.nextStep();   
            cep.nextStep(); 
            List<Core_CustomSetController.Wrapper> availRecords = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords').sobjectRecords;
            System.debug(' >>>>>>>>> availRecords '+availRecords); 
            if(availRecords.size()>0) {
                
                System.debug('Prods Not empty RAD');
                for(Core_CustomSetController.Wrapper w : availRecords){
                    w.selected = true;
                    cep.updateSelectedRecords();
                    upsert cip;
                }     
            }   
            
            cep.nextStep();
            cep.saveAll();
            
            List<Core_CustomSetController.Wrapper> availRecords2 = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords').sobjectRecords;
            System.debug(' >>>>>>>>> availRecords2 '+availRecords2); 
            if(availRecords2.size()>0) {
                for(Core_CustomSetController.Wrapper w2 :availRecords2 ){
                    w2.selected = true;//
                    cep.updateSelectedRecords();
                }     
            } 
            
            
            PageReference pageRef = Page.Core_ExternalUser_IPS_Project;
            PageReference resPg = cep.previousStep();
            
            //cep.getLoggerInUser();
            //cep.createIPSProject();
            cep.nextStep();
            cep.btnActionSource='AvailableRecords';
            cep.firstPage();
            cep.previousPage();
            cep.nextPage();
            cep.lastPage();
            cep.reset();
            //cep.updateExisting();
            cep.saveAll();
            //cep.upsertAsserts();
           // cep.upsertProjectMembers();
           // cep.upsertIPSProducts();
             
        }  
        
    }
    
    public static testMethod void loggerInUser() {
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Core_IPS_Product__c' and DeveloperName = 'Core_IPS_Project_Product'].Id;
        
        Account acc = TestUtilities.getAccount();
        acc.Core_IPS_Active__c=True;
        insert acc;
        
        Core_IPS_Project__c cip=new Core_IPS_Project__c();
        //cip.RecordTypeId=strRecordTypeId;
        cip.Name = 'Test 1';
        insert cip;
        
        User usr = new User(LastName = 'LIVESTON',
                            FirstName='JASON',
                            Alias = 'jliv',
                            Email = 'jason.liveston@asdf.com',
                            Username = 'jason.liveston@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        
        ApexPages.StandardController sc = new ApexPages.standardController(cip);
        Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);
        system.debug(cep.IPSProductBasicRecordType);
        cep.ipsProject.Name ='value';
        cep.ipsProject.Core_MPNDA__c=''; 
        cep.stepIndex = 1;
        cep.nextStep();
    }
    
    public static testMethod void testCreateIPSMember_Success1() { 
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IPS External Customer' LIMIT 1];
        Contact con = [Select Id, Core_IPS_Active__c  FROM Contact Limit 1];
        
        //Contact ConAcc = [Select AccountID from Contact where Id =:con.id];
        User ipsExternalUser = [Select Id, Name, Profile.Name,  UserRole.Name,AccountId,  Contact.AccountId FROM User where Contact.FirstName = 'Test Contact0'];
        System.debug('\n\n SK '+ipsExternalUser);
        System.debug('SK TM  Contacts Total '+[Select Id, Core_IPS_Active__c FROM Contact ]);
        System.debug('SK TM  Accounts Total '+[Select Id, Core_IPS_Active__c FROM Account ]);
        
        List <Asset> asset7472 = [Select Name,id,RecordTypeID,AccountID,Product2ID,Core_Supported_Product__R.Id,Core_Product_EPM_ID__c,Core_Project_Asset_Status__c,Core_Support_Org_Name__c  
                                  from Asset where AccountId = : ipsExternalUser.Contact.AccountId];
        System.debug('asset7472'+asset7472 );
        
        String userType=Label.Core_IPS_CustCommPlus_UserType;
        List<User> customerUsersbyAccount = [select id,ContactId,AccountId,userroleid from User 
                                             where AccountId  =:ipsExternalUser.AccountId and UserType=:userType and contact.core_ips_Active__c=true];
        
        
        //ipsExternalUser = customerUsersbyAccount[0];
        system.runAs(ipsExternalUser){
            Core_IPS_Project__c cip=new Core_IPS_Project__c();
            
            List <Asset> asset747 = [Select Name,id  from Asset];
            System.debug('asset747'+asset747 );
            
            Contact conQuery = [Select AccountID from Contact where id=:con.id ];
            System.debug('RAX Account'+conQuery);
            
            System.debug('SK TM Internal Contacts Total '+[Select Id, Core_IPS_Active__c FROM Contact ]);
            System.debug('SK TM Internal Accounts Total '+[Select Id, Core_IPS_Active__c FROM Account ]);
            
            List<Contact> contList = [Select Id, FirstName,LastName,Email from contact where AccountID=:conQuery.AccountID ];
            System.debug('RAX Contacts'+contList);
            
            RecordType rc  = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'];
            System.debug(' ++++ '+rc);
            
            Core_IPS_Project__c cip2=new Core_IPS_Project__c();
            
            ApexPages.StandardController sc = new ApexPages.standardController(cip); 
            
            Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);
            system.debug('cep.IPSProductBasicRecordType==='+cep.IPSProductBasicRecordType);
            cep.ipsProject.Name ='testIPSProjectCreation';
            cep.ipsProject.Core_Project_Description__c ='testIPSProjectCreation';
            
            cep.ipsProject = cip;
            cep.nextStep();   
            
            List<Core_CustomSetController.Wrapper> availRecords = cep.mStep_SetCntlr.get(cep.steps[cep.stepIndex]).get('AvailableRecords').sobjectRecords;
            System.debug(' >>>>>>>>> availRecords '+availRecords); 
            if(availRecords.size()>0) {
                
                System.debug('Prods Not empty RAD');
                for(Core_CustomSetController.Wrapper w : availRecords){
                    w.selected = false;
                    cep.updateRecords();
                    upsert cip;
                   // w.selected = isExisting;
                }  
                
            } 
        }
        
    }
}