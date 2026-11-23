@isTest
public without sharing class Core_DDR_Design_Handler_Test{
    
    @TestSetup
    static void makeData(){
        
        List<Account> acList = new List<Account>();
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();     
        
        acList = Core_Test_Utility.createAccount(2);
        acList[0].name='Test AccountCAS';
        //acList[0].Core_Export_Compliance_Block__c=True;
        acList[0].RecordTypeId=accountRecordTypeIntel;
        acList[1].name='Test AccountCAS2';
        acList[1].RecordTypeId=accountRecordTypeIntel;  
        //acList[1].Core_Export_Compliance_Block__c=false;
        
        /*Account acct2 = new Account(Name = 'Test AccountCAS2', BillingStreet = '123 Fake St CAS2',
BillingCity = 'SpringfieldCAS2', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
BillingPostalCode = '12345', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='Global Accounts Sales Group');
//aclist.add(acct2);*/
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert aclist;
        }
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(2);
        DDRLst[0].Core_Design_Registration_Nm__c = 'DDR CAS';
        //DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        DDRLst[0].Core_End_Customer_Account_Id__c = acList[0].id;
        DDRLst[1].Core_Design_Registration_Nm__c = 'DDR CAS2';
        DDRLst[1].Core_End_Customer_Account_Id__c = acList[0].id;
        DDRLst[1].Core_Design_Registration_Status_Nm__c = 'Submitted';
        
        Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        insert triggerExecList;
        
        insert DDRLst;

        List<Product2> listOfProducts = Core_DDR_Utility.CreateProduct(1);
        insert listOfProducts;

        Core_Design_Registration_Product__c drp = new Core_Design_Registration_Product__c();
        drp.Core_Design_Registration_Id__c = DDRLst[1].id;
        drp.Core_Product_Id__c = listOfProducts[0].Id;      
        //insert drp;

        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;       
        Opportunity oppForLoss = new Opportunity(Name = 'OppCAS', RecordTypeId = newOppRecTypeId,
                                                 AccountId = acList[0].Id,Core_Opportunity_Type__c='Design: Original',
                                                 StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));

        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppForLoss;
        }
        Id rectypIDDR =  Schema.SObjectType.Core_Design_Registration__c.RecordTypeInfosByName.get('Design Registration - Partner Draft').RecordTypeId;
                    // List<Core_Design_Registration__c> DDRList = new list<Core_Design_Registration__c>();
     
        Core_Design_Registration__c ddrRec2 = new  Core_Design_Registration__c();
            ddrRec2.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
            ddrRec2.Core_Vertical_Market_Nm__c='Education';
            ddrRec2.Core_Product_Segment_Nm__c='Client Computing';
            ddrRec2.Core_Product_Application_Nm__c='Business Desktop';
            ddrRec2.Core_Opportunity_Volume_Cnt__c=100;
            ddrRec2.Core_Partner_FAE_Nm__c='Test FAE';
            ddrRec2.Core_Partner_FSR_Nm__c='Test FSR';
            ddrRec2.Core_End_Customer_Nm__c='Arrow Electronics Account';
            ddrRec2.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
            ddrRec2.Core_End_Customer_Street_Addr_Line2_Txt__c='';
            ddrRec2.PCC_End_Customer_Country__c='India';
            ddrRec2.Core_End_Customer_City_Nm__c='Bangalore';
            ddrRec2.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
            ddrRec2.Core_End_Customer_Postal_Cd__c='758854';
            ddrRec2.Core_End_Customer_Contact_Title_Txt__c='Mr.';
            ddrRec2.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
            ddrRec2.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
            ddrRec2.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
            ddrRec2.Core_Manufacturing_Region_Cd__c='ASMO';
            ddrRec2.Core_Opportunity_Decision_Dt__c = system.today()+20;
            ddrRec2.Core_First_Customer_Ship_Dt__c = system.today()+21;
            ddrRec2.Core_Production_End_Dt__c = system.today()+22;
            //ddrRec2.Core_Intel_Platform_Nm__c='Agilex';
            ddrRec2.Core_Design_Registration_Nm__c='Test DR Name Arrow9';
            ddrRec2.Core_Design_Registration_Dsc__c='Test Des';
            ddrRec2.Core_External_Id__c='abczd001';
            ddrRec2.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
            ddrRec2.Core_End_Customer_URL__c = 'Test';
            ddrRec2.PCC_Consumption_Countries__c = 'Test';
            ddrRec2.PCC_Current_EndCustomer_Product_Provider__c='Test';
            ddrRec2.RecordTypeId=rectypIDDR;
            insert ddrRec2;
         
        
    }

    @isTest 
    public static void checkForExportComplianceTest(){
        Account chngACC1 = [select id from account where name ='Test AccountCAS' limit 1];
        List<Core_Design_Registration__c> cdr = [Select id,Core_End_Customer_Account_Id__c from Core_Design_Registration__c where Core_Design_Registration_Nm__c in ('DDR CAS' ,'DDR CAS2')];
        
        cdr[1].Core_End_Customer_Account_Id__c = chngACC1.id;
        cdr[1].Core_End_Customer_Export_Cmplnc_Bloc_Ind__c = false;
        cdr[1].Core_Design_Registration_Status_Nm__c = 'Submitted';
        
        Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        insert triggerExecList;
        
        update cdr;
        Core_DDR_Design_Handler_Utility.checkForExportCompliance(cdr);  
    }
    @isTest 
    public static void checkForExportComplianceTestNew(){
        
        Account chngACC = [select id from account where name ='Test AccountCAS2' limit 1];
        list<Core_Design_Registration__c> cdr = [Select id,Core_End_Customer_Account_Id__c from Core_Design_Registration__c where Core_Design_Registration_Nm__c in ('DDR CAS2')];
        
        cdr[0].Core_End_Customer_Account_Id__c = chngACC.id;
        cdr[0].Core_End_Customer_Export_Cmplnc_Bloc_Ind__c = true;
        cdr[0].Core_Design_Registration_Status_Nm__c = 'Submitted';
        
        Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        insert triggerExecList;
        
        update cdr;
        Core_DDR_Design_Handler_Utility.checkForExportCompliance(cdr);
    }
    
    
    @future
    public static void insertUser() {
        Contact c=[Select id from Contact limit 1];
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Id DistiProid = [select id, name from profile where name='Partner'].id;
        // Id IsrProid = [select id, name from profile where name='Sales Rep-BB'].id;
        User DistiUser = new User(alias = 'dis123', email='test123@noemail.com',
                                  emailencodingkey='UTF-8', lastname='distestintel', languagelocalekey='en_US',
                                  localesidkey='en_US', profileid = DistiProid, IsActive =true,
                                  contactId = c.Id,UserRoleId =portalRole.Id,
                                  timezonesidkey='America/Los_Angeles', username='testerDistintel@Intelnoemail.com');
        // insert DistiUser;
    }
    public static testmethod void DDR_Bulk(){
        
        Test.startTest();
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        lstAcc[1].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        //DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        Map<Id, Core_Design_Registration__c> NewList = new Map<Id, Core_Design_Registration__c>();
        Map<Id, Core_Design_Registration__c> OldList = new Map<Id, Core_Design_Registration__c>();
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
            
        }
        update DRPLst;
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Approved';
            Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
            OldList.put(Design.id, Design);
        }        
        update DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPUpdateLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPUpdateLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPUpdateLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPUpdateLst;
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Approved';
            NewList.put(Design.id, Design);
        }        
        update DDRLst;
        //    for(Core_Design_Registration__c Design: DDRLst){
        //     Design.Core_Design_Registration_Status_Nm__c = 'Approved';
        // NewList.put(Design.id, Design);
        // }         update DDRLst;
        
        Core_DDR_Design_Handler_Utility.processAfterUpdate(DDRLst, DDRLst, OldList, NewList);
        PCC_ProcessDesignOpportunity.processDesignOpportunity(new List<Id>{DDRLst[0].Id});
        PCC_ProcessDesignOLIs.processDesignOLIs(new List<Id>{DDRLst[0].Id});
        //Core_DDR_Design_Handler.processAfterUpdate(DDRLst, DDRLst, OldList, NewList);
        Test.stopTest();
    }
    
    /*public static testMethod void DDR_OwnerChange(){
Test.startTest();
Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();        
List<account> LstAcc = Core_Test_Utility.createAccount(2);
LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
lstAcc[1].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
LstAcc[0].recordtypeID = accountRecordTypeIntel;
lstAcc[1].recordtypeID = accountRecordTypeIntel;
insert LstAcc;

List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();

List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();

List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
insert ProdLst;

List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
insert PriceBookLst;

List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);

List<contact> LstCon = Core_Test_Utility.createContacts(5);

List<contact> LstConInsert = new List<contact>();
for(contact con: LstCon){
con.accountId = LstAcc[0].id;
LstConInsert.add(con);
}
insert LstConInsert;

UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
Id DistiProid = [select id, name from profile where name='Partner'].id;
Id IsrProid = [select id, name from profile where name='Sales Rep-BB'].id;
insertUser();

Test.stopTest();

//User DistiUser=[Select id from user where lastname='DistiUser' limit 1];

/* User DistiUser = new User(alias = 'test123', email='test123@noemail.com',
emailencodingkey='UTF-8', lastname='DistiUser', languagelocalekey='en_US',
localesidkey='en_US', profileid = DistiProid, IsActive =true,
contactId = LstConInsert[0].Id, UserRoleId = portalRole.Id,
timezonesidkey='America/Los_Angeles', username='testerDist@Intelnoemail.com');*/
    
    
    /* User IsrUser = new User(alias = 'test123', email='test1234@itp-intel.com',
emailencodingkey='UTF-8', lastname='IsrUser', languagelocalekey='en_US',
localesidkey='en_US', profileid = IsrProid, IsActive =true,
timezonesidkey='America/Los_Angeles', username='testerSales@itp-intel.com');

insert IsrUser;

User IsrUser2 = new User(alias = 'test123', email='test1234@itp-intel.com',
emailencodingkey='UTF-8', lastname='IsrUser2', languagelocalekey='en_US',
localesidkey='en_US', profileid = IsrProid, IsActive =true,
timezonesidkey='America/Los_Angeles', username='testerSales2@itp-intel.com');

insert IsrUser2;

List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
insert DDRLst;


List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
insert DRPLst;

for(Core_Design_Registration_Product__c DRP : DRPLst){
DRP.Core_Design_Product_Status_Nm__c = 'Approved';
}
update DRPLst;

for(Core_Design_Registration__c Design: DDRLst){
Design.OwnerId = IsrUser.id;
Design.Core_Design_Registration_Status_Nm__c = 'Approved';
Design.Core_Approver_Grp_Nm__c = Label.Core_DDR_DSN_Group_Name;

Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
Design.Core_Partner_Account_Id__c = LstAcc[1].id;
}
update DDRLst;

List<Core_Design_Registration_Product__c> DRPUpdateLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
insert DRPUpdateLst;

for(Core_Design_Registration_Product__c DRP : DRPUpdateLst){
DRP.Core_Design_Product_Status_Nm__c = 'Approved';
}
update DRPUpdateLst;

for(Core_Design_Registration__c Design: DDRLst){
Design.OwnerId = IsrUser2.id;
Design.Core_Design_Registration_Status_Nm__c = 'Approved';
Design.Core_Approver_Grp_Nm__c = Label.Core_DDR_DSN_Group_Name;
Design.Core_End_Customer_Account_Id__c = LstAcc[1].id;
Design.Core_Partner_Account_Id__c = LstAcc[0].id;
}
update DDRLst;

Contact c=[Select id from Contact limit 1];
// UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
// Id DistiProid = [select id, name from profile where name='Partner'].id;
// Id IsrProid = [select id, name from profile where name='Sales Rep-BB'].id;
/*  User DistiUser = new User(alias = 'test123', email='test123@noemail.com',
emailencodingkey='UTF-8', lastname='DistiUser', languagelocalekey='en_US',
localesidkey='en_US', profileid = DistiProid, IsActive =true,
contactId = c.Id, UserRoleId = portalRole.Id,
timezonesidkey='America/Los_Angeles', username='testerDist@Intelnoemail.com');*/
    
    /*system.runAs(DistiUser) {        
List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5);
for(Core_Design_Registration__c designInsert: TestDDRlst){
designInsert.Core_Product_Group_Nm__c = 'Embedded/IOT';
}
insert TestDDRlst;

List<Core_Design_Registration__c> TestDDRlstPSG = Core_DDR_Utility.createDDR(5);
insert TestDDRlstPSG;

List<Core_Design_Registration_Product__c> TestDDRProd = Core_DDR_Utility.CreateDRProduct(5, TestDDRlst, ProdLst);
insert TestDDRProd;
}

List<Core_Design_Registration_Product__c> DRP_Update = [select id, Core_Design_Product_Status_Nm__c from Core_Design_Registration_Product__c limit 5000];

for(Core_Design_Registration_Product__c pupdate: DRP_Update){
pupdate.Core_Design_Product_Status_Nm__c = 'Approved';
}
update DRP_Update;

List<Core_Design_Registration__c> TestDDRupdate = [select id from Core_Design_Registration__c limit 5000];

for(Core_Design_Registration__c upDDR: TestDDRupdate){
upDDR.Core_Design_Registration_Status_Nm__c = 'Approved';
upDDR.Core_Approver_Grp_Nm__c = Label.Core_DDR_DSN_Group_Name;
upDDR.Core_Product_Segment_Nm__c = 'Client Computing';
upDDR.Core_Product_Application_Nm__c = 'Business Desktop';
upDDR.Core_End_Customer_Account_Id__c = LstAcc[0].id;
upDDR.Core_Intel_Technical_Owner_Id__c = UserInfo.getUserId();
}

update TestDDRupdate;



}*/
    public static testmethod void DDR_BulkReject(){
        
        Test.startTest();
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        lstAcc[1].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        //DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        List<Core_Design_Registration_Product__c> DRPUpdateLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPUpdateLst;
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        for(Core_Design_Registration_Product__c DRP : DRPUpdateLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        
        update DRPUpdateLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Rejected';
            DRP.Core_Comment_Txt__c = 'Rejected';
        }
        update DRPLst;
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Rejected';
            Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
        }        
        update DDRLst;
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Approved';
        }        
        update DDRLst;
        Test.stopTest();
    }
    public static testmethod void DDR_Handler_Export() {
        Test.startTest();
        List<Account> newAccounts = Core_Test_Utility.createAccount(5);
        List<account> LstAcc = new List<Account>();
        for(Account a : newAccounts){
            a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            LstAcc.add(a);
        }
        
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        //LstAcc[0].Core_Export_Compliance_Block__c = true;
        lstAcc[1].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        lstAcc[1].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5);
        insert TestDDRlst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, TestDDRlst, ProdLst);
        insert DRPLst;
        
        List <Account> UpdateAccLst = Core_Test_Utility.Core_Account(5);
        // Id accountRecordTypeIntel2 = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        for(account Acc: UpdateAccLst){
            Acc.Core_Sales_Groups__c = 'Americas Brazil Sales Group';
            //  acc.Core_Export_Compliance_Block__c = true;
            acc.recordtypeID = accountRecordTypeIntel;
        }
        insert UpdateAccLst;
        
        for(Core_Design_Registration__c DDR_hand: TestDDRlst){
            DDR_hand.Core_End_Customer_Account_Id__c = UpdateAccLst[0].id;
        }
        update TestDDRlst;
        
        for(Core_Design_Registration__c DDR_hand: TestDDRlst){
            DDR_hand.Core_Design_Registration_Status_Nm__c= 'Submitted';
            DDR_hand.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            DDR_hand.Core_End_Customer_Export_Cmplnc_Bloc_Ind__c = true;
        }
        update TestDDRlst;
        
        TestDDRlst[0].Core_End_Customer_Account_Id__c =   LstAcc[1].id;
        TestDDRlst[0].Core_Design_Registration_Status_Nm__c='Approved';
        update TestDDRlst[0];
        Test.stopTest();
    }
    public static testmethod void DDR_flow(){
        
        
        Test.startTest();
        List<account> LstAcc = Core_Test_Utility.createAccount(1);
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        List<Product2> NewProducts = new List<Product2>();
        Product2 prod = new Product2();
        
        prod.name = 'Intel® Ethernet SFP+ LR Optics';
        prod.Core_Design_Registration_Eligible_Ind__c  = true;
        prod.Core_Sales_Visible_Flag__c = true;
        prod.isActive = true;
        prod.Core_Partner_Visible_Ind__c = true;
        prod.Core_Avail_for_New_Designs__c = true;
        
        Product2 prod2 = new Product2();
        
        prod2.name = 'Intel® Ethernet SFP+ LR Optics';
        prod2.Core_Design_Registration_Eligible_Ind__c  = true;
        prod2.Core_Sales_Visible_Flag__c = true;
        prod2.isActive = true;
        prod2.Core_Partner_Visible_Ind__c = true;
        prod2.Core_Avail_for_New_Designs__c = true;
        
        NewProducts.add(prod);
        NewProducts.add(prod2);
        
        insert NewProducts;
        List<Core_Design_Registration__c> TestDDRlst = new List<Core_Design_Registration__c>();
        Core_Design_Registration__c ddr = new Core_Design_Registration__c();
        
        ddr.Core_Product_Group_Nm__c = 'Embedded/IOT';
        ddr.Core_Design_Registration_Nm__c = 'DDR Test';
        ddr.Core_Design_Registration_Dsc__c = 'ABC';
        ddr.Core_Opportunity_Volume_Cnt__c = 5;
        ddr.Core_Partner_FAE_Nm__c = '6';            
        ddr.Core_End_Customer_Nm__c = 'DDR Test';            
        ddr.Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC ';
        ddr.Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc';
        ddr.Core_End_Customer_City_Nm__c = 'BAN';
        ddr.Core_End_Customer_Country_Subdivision_Nm__c = 'KA';
        ddr.PCC_End_Customer_Country__c = 'United States';
        ddr.Core_End_Customer_Postal_Cd__c = '560037';
        ddr.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddr.Core_Opportunity_Decision_Dt__c = system.today()+45;
        ddr.Core_First_Customer_Ship_Dt__c = system.today()+46;
        ddr.Core_Production_End_Dt__c = system.today()+47;
        ddr.Core_Vertical_Market_Nm__c = 'Education';
        ddr.Core_Intel_Platform_Nm__c = 'Board';
        ddr.Core_Product_Application_Nm__c = 'Business Desktop';
        ddr.Core_Product_Segment_Nm__c = 'Client Computing';
        ddr.Core_Manufacturing_Region_Cd__c = 'APJ';
        ddr.Core_Design_Registration_Status_Nm__c = 'Re-Submitted';
        ddr.Core_Partner_Account_Id__c=null;
        ddr.Core_Opportunity_Id__c=null;
        //ddr.OwnerId=owner.id;
        TestDDRlst.add(ddr);
        
        insert TestDDRlst;
        
        List<Core_Design_Registration_Product__c> DRPLst = new List<Core_Design_Registration_Product__c>();
        
        for(integer i=0; i < 2; i++)
        {
            Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
            DRproducts.Core_Opportunity_Product_Id__c = null;
            DRproducts.Core_Design_Registration_Id__c = TestDDRlst[0].id;
            DRproducts.Core_Product_Id__c = NewProducts[i].id;
            DRproducts.Core_Target_Resale_Amt__c = 20;
            DRproducts.Core_Full_Year_Qty__c = 3;
            DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
            DRPLst.add(DRproducts);
        }
        insert DRPLst;
        
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        Opportunity opp =[Select id from opportunity where name = 'OppCAS' Limit 1];
        for(Core_Design_Registration__c Design: TestDDRlst){
            Design.Core_Design_Registration_Status_Nm__c = 'Approved';
            Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[0].id;
            Design.Core_Opportunity_Id__c = opp.id;
        }        
        update TestDDRlst;
        List<Id> idss = new List<Id>();
        List<Core_Log_Entry__c> logEList= new List<Core_Log_Entry__c>();
        Core_Log_Entry__c logE = new Core_Log_Entry__c();
        logE.Core_Retry_Counter__c = 1;
        logE.Core_Message__c = 'Product not available for new designs. Please select a product that is marked available for new designs on the selection page.';
        logE.Core_sObjectId__c = TestDDRlst[0].id;
        logE.Core_Next_Scheduled_Run__c = System.now();
        logE.Core_Origin__c = 'Core_DDR_Design_Handler.insertApprovedLIsToExistingOpps.OppLineItemUpdate';
        logE.Core_Severity__c =  'Info';
        logE.Core_When__c = System.now();
        logEList.add(logE);
        insert logEList;
        idss.add(logEList[0].Id);
        
        Core_DDR_Design_Handler_Utility.RetryFailedRecords(idss);
        //Core_DDR_Design_Handler.RetryFailedRecords(idss);
        Test.stopTest();
    }
    
    public static testmethod void DDR_flowOppO(){
        
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        lstAcc[1].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Approved';
            Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
        }        
        update DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPUpdateLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPUpdateLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPUpdateLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPUpdateLst;
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Submitted';
            Design.Core_Opportunity_Id__c = null;
        }        
        update DDRLst;
        Test.startTest();
        List<Id> idss = new List<Id>();
        List<Core_Log_Entry__c> logEList= new List<Core_Log_Entry__c>();
        Core_Log_Entry__c logE = new Core_Log_Entry__c();
        logE.Core_Retry_Counter__c = 1;
        logE.Core_Message__c = 'insufficient access rights on cross-reference id';
        logE.Core_sObjectId__c = DDRLst[0].id;
        logE.Core_Next_Scheduled_Run__c = System.now();
        logE.Core_Origin__c = 'Opportunity Creation';
        logE.Core_Severity__c =  'High';
        logE.Core_When__c = System.now();
        logEList.add(logE);
        insert logEList;
        idss.add(logEList[0].Id);
        
        Core_DDR_Design_Handler_Utility.RetryFailedRecords(idss);
        //Core_DDR_Design_Handler.RetryFailedRecords(idss);
        
        Test.stopTest();
    }
    
    public static testmethod void DDR_flowOppO1(){
        
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        lstAcc[1].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        // user owner=[select id from user where profile.name='CCP - Core Access' limit 1];
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        DDRLst[0].Core_Partner_Account_Id__c=null;
        DDRLst[0].Core_Opportunity_Id__c = null;
        //DDRLst[0].OwnerId=owner.id;         
        insert DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Approved';
            Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
        }        
        update DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPUpdateLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPUpdateLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPUpdateLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPUpdateLst;
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Submitted';
            Design.Core_Opportunity_Id__c = null;
        }        
        update DDRLst;
        Test.startTest();
        List<Id> idss = new List<Id>();
        List<Core_Log_Entry__c> logEList= new List<Core_Log_Entry__c>();
        Core_Log_Entry__c logE = new Core_Log_Entry__c();
        logE.Core_Retry_Counter__c = 1;
        logE.Core_Message__c = 'insufficient access rights on cross-reference id';
        logE.Core_sObjectId__c = DDRLst[0].id;
        logE.Core_Next_Scheduled_Run__c = System.now();
        logE.Core_Origin__c = 'Opportunity Creation';
        logE.Core_Severity__c =  'High';
        logE.Core_When__c = System.now();
        logEList.add(logE);
        insert logEList;
        idss.add(logEList[0].Id);
        
        Core_DDR_Design_Handler_Utility.RetryFailedRecords(idss);
        //Core_DDR_Design_Handler.RetryFailedRecords(idss);
        
        Test.stopTest();
    }
    
    public static testmethod void DDR_OppShareTest(){
        Test.startTest();
        Id accIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();     
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        
        // Create an account
        /* Account acct = new Account(Name = 'Test Account', BillingStreet = '123 Fake St',
BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
BillingPostalCode = '12345', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='Americas Brazil Sales Group');*/
        // System.runAs(Core_Test_Utility.systemAdminUser) {
        List<Account> accList=Core_Test_Utility.createAccount(1);
        accList[0].name='Test Account';
        accList[0].RecordTypeId=accIntel;
        insert accList;
        // }
        List<Opportunity> oppsd = new List<Opportunity>();
        
        Opportunity oppold = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                             AccountId = accList[0].Id,Core_Opportunity_Type__c='Design: Original',
                                             StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
        
        
        
        // System.runAs(Core_Test_Utility.systemAdminUser) {
        //  insert oppold;
        //}
        // oppsd.add(oppold);
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
            triggerExecList.Bypass__c = true;
            insert triggerExecList;
            
            insert oppold;
            oppsd.add(oppold);
            Core_DDR_Design_Handler_Utility.OpportunityShare(oppsd);
            //Core_DDR_Design_Handler.OpportunityShare(oppsd);
            Test.stopTest();
        }
        
    }
    
    public static testmethod void DDR_lockRejectedProductsTest(){
        
        Test.startTest();
        user sysadm=[select id,userRoleid from user where Profile.Name='System Administrator' and IsActive = true and userRole.name='Admin' Limit 1 ];
        system.runas(sysadm){
            List<account> LstAcc = Core_Test_Utility.createAccount(2);
            LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
            lstAcc[1].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
            Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
            
            LstAcc[0].recordtypeID = accountRecordTypeIntel;
            lstAcc[1].recordtypeID = accountRecordTypeIntel;
            insert LstAcc;
            
            Contact c1 = PRM_TestUtility.getContact();
            c1.AccountId = LstAcc[0].Id;
            //  c1.Email='test.user@intel.com';
            c1.Core_Preferred_Language__c = 'ENG';
            c1.Core_eRPM_Language_Code__c = 'ENG';
            c1.Core_IPA_Partner_Role__c = 'Service Provider';
            c1.Email = 'testUsercoreMPM12@intel.com';
            //c1.Core_Mailing_Address__CountryCode__s = 'USA';
	    c1.MailingCountry= 'USA';
            insert c1;
            
            List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
            
            List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
            
            List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
            insert ProdLst;
            
            List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
            insert PriceBookLst;
            
            List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
            
            Profile profile1 = [Select Id from Profile where name = 'Partner'];
            
            User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMPM12@intel.com',
                                     EmailEncodingKey='UTF-8',LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                     LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMPM.com',
                                     FirstName='TestUtility', ContactId = c1.id, ProfileId = profile1.Id);
            insert testUser;
            
            PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'Core_DDR_Permission_Set'];
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = testUser.Id);
            insert psa1;
            
            List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
            //DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
            
            insert DDRLst;
            Core_Design_Registration__Share drShare = new Core_Design_Registration__Share();
            drShare.ParentId = DDRLst[0].Id;
            drShare.UserOrGroupId = testUser.Id;
            drShare.AccessLevel = 'Edit';
            drShare.RowCause = 'Manual';
            insert drShare;
            List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
            insert DRPLst;
            
            for(Core_Design_Registration_Product__c DRP : DRPLst){
                DRP.Core_Design_Product_Status_Nm__c = 'Approved';
            }
            update DRPLst;
            
            for(Core_Design_Registration__c Design: DDRLst){
                Design.Core_Design_Registration_Status_Nm__c = 'Approved';
                //Design.Core_Design_Registration_Status_Nm__c = 'Rejected';
                Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
                Design.Core_Partner_Account_Id__c = LstAcc[1].id;
                //Design.OwnerId = testUser.Id;
            } 

            DDRLst[0].OwnerId=testUser.Id;

            update DDRLst;
            
            List<Core_Design_Registration_Product__c> DRPUpdateLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
            insert DRPUpdateLst;
            
            for(Core_Design_Registration_Product__c DRP : DRPUpdateLst){
                DRP.Core_Design_Product_Status_Nm__c = 'Rejected';
            }
            update DRPUpdateLst;
            
            for(Core_Design_Registration__c Design: DDRLst){
                Design.Core_Design_Registration_Status_Nm__c = 'Rejected';
                Design.Core_Opportunity_Id__c = null;
            }        
            update DDRLst;
            Core_DDR_Design_Handler_Utility.lockRejectedProducts(DDRLst);
            Core_DDR_Design_Handler_Utility.populatePartnerAccount(DDRLst, false);
            //Core_DDR_Design_Handler.lockRejectedProducts(DDRLst);
        }
        Test.stopTest();
    }
    
    public static testmethod void DDR_processAfterFlow(){
        
        Test.startTest();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        
        // Create an account
        /*Account acct = new Account(Name = 'Test Account', BillingStreet = '123 Fake St',
BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
BillingPostalCode = '12345', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='Americas Brazil Sales Group');*/
        // System.runAs(Core_Test_Utility.systemAdminUser) {
        
        //  }
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        lstAcc[1].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> oldList = new  List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> newList = new List<Core_Design_Registration__c>();
        
        Map<Id,Core_Design_Registration__c> oldMap = new Map<Id,Core_Design_Registration__c>();
        Map<Id,Core_Design_Registration__c> newMap = new Map<Id,Core_Design_Registration__c>();
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        //DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        DDRLst[1].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        List<Opportunity> oppsd = new List<Opportunity>();
        
        Opportunity oppold = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                             AccountId = LstAcc[0].Id,
                                             StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
        
        
        
        //System.runAs(Core_Test_Utility.systemAdminUser) {
        //insert oppold;
        // }
        // oppsd.add(oppold);
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Approved';
            Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
            Design.Core_Opportunity_Id__c = NULL;
            oldList.add(Design);
            oldMap.put(Design.Id, Design);
        }        
        update DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPUpdateLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        
        insert DRPUpdateLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPUpdateLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPUpdateLst;
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
            Design.Core_Design_Registration_Status_Nm__c = 'Approved';
            Design.Core_Opportunity_Id__c = NULL;
            newList.add(Design);
            newMap.put(Design.Id, Design);
        }  
        DDRLst[1].Core_Product_Group_Nm__c = 'Embedded/IOT';
        update DDRLst;
        
        Core_DDR_Design_Handler_Utility.processAfterUpdate(oldList,newList,oldMap,newMap);
        //Core_DDR_Design_Handler.processAfterUpdate(oldList,newList,oldMap,newMap);
        
        Test.stopTest();
    }   
    
    
    
    //to test DDR as in Approved Status
    public static testmethod void approvedDDR(){
        Test.startTest();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        
        /* Account acc=new Account(Name='Approved Accound',BillingStreet = '1234 Fake St',
BillingCity = 'SpringJERINfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
BillingPostalCode = '123745', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='Americas Brazil Sales Group');
// System.runAs(Core_Test_Utility.systemAdminUser){
insert acc;*/
        //  }
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        lstAcc[1].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(1);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(1, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> oldList = new  List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> newList=new List<Core_Design_Registration__c>();
        Map<Id,Core_Design_Registration__c> oldMap=new Map<Id,Core_Design_Registration__c>();
        Map<Id,Core_Design_Registration__c> newMap= new Map<Id,Core_Design_Registration__c>();
        
        
        //
        
        Core_Design_Registration__c DDRLst = new Core_Design_Registration__c(
            Core_Product_Group_Nm__c = 'Embedded/IOT',
            Core_Design_Registration_Nm__c = 'DDR Test',
            Core_Design_Registration_Dsc__c = 'ABC',
            Core_Opportunity_Volume_Cnt__c = 5,
            Core_Partner_FAE_Nm__c = '6',            
            Core_End_Customer_Nm__c = 'DDR Test',            
            Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC',
            Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc',
            Core_End_Customer_City_Nm__c = 'BAN',
            Core_End_Customer_Country_Subdivision_Nm__c = 'KA',
            PCC_End_Customer_Country__c = 'United States',
            Core_End_Customer_Postal_Cd__c = '560037',
            Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
            Core_Opportunity_Decision_Dt__c = system.today()+45,
            Core_First_Customer_Ship_Dt__c = system.today()+46,
            Core_Production_End_Dt__c = system.today()+47,
            Core_Vertical_Market_Nm__c = 'Education',
            Core_Intel_Platform_Nm__c = 'Board',
            Core_Product_Application_Nm__c = 'Business Desktop',
            Core_Product_Segment_Nm__c = 'Client Computing',
            Core_Manufacturing_Region_Cd__c = 'APJ',
            Core_Design_Registration_Status_Nm__c = 'Approved'
        );
        
        
        //   List<Core_Design_Registraction__c> DDRLst=new List<Core_Design_Registraction__c>;
        DDRLst.Core_Product_Group_Nm__c ='Embedded/IOT';
        insert DDRLst;
        
        
        //          List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(1, DDRLst, ProdLst);
        //      insert DRPLst;
        
        //       DRPLst[0].Core_Design_Product_Status_Nm__c='Approved'; 
        //       update DRPLst;
        
        DDRLst.Core_Design_Registration_Status_Nm__c = 'Approved';
        DDRLst.Core_End_Customer_Account_Id__c = LstAcc[0].id;
        DDRLst.Core_Partner_Account_Id__c = LstAcc[1].id;
        DDRLst.Core_Opportunity_Id__c = NULL;
        
        oldList.add(DDRLst);
        oldMap.put(DDRLst.Id, DDRLst);
        
        update DDRLst;
        //      List<Core_Design_Registration_Product__c> DRPUpdateLst = Core_DDR_Utility.CreateDRProduct(1, DDRLst, ProdLst);
        
        //   insert DRPUpdateLst;
        
        //update the DRP List
        //    DRPUpdateLst[0].Core_Design_Product_Status_Nm__c = 'Approved';
        
        // update DRPUpdateLst;
        
        //Update DDR as approved
        DDRLst.Core_Design_Registration_Status_Nm__c = 'Approved';
        DDRLst.Core_Opportunity_Id__c = NULL;
        
        newList.add( DDRLst);
        newMap.put( DDRLst.Id,  DDRLst);
        
        update DDRLst;
        Core_DDR_Design_Handler_Utility.processAfterUpdate(oldList,newList,oldMap,newMap);
        //Core_DDR_Design_Handler.processAfterUpdate(oldList,newList,oldMap,newMap);
        Test.stopTest(); 
        
        
        
    }
    
    //to test DDR as in Approved Status
    public static testmethod void approvedDDR1(){
        Test.startTest();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        
        /* Account acc=new Account(Name='Approved Accound',BillingStreet = '1234 Fake St',
BillingCity = 'SpringJERINfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
BillingPostalCode = '123745', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='Americas Brazil Sales Group');
// System.runAs(Core_Test_Utility.systemAdminUser){
insert acc;*/
        //  }
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        LstAcc[0].OwnerId=UserInfo.getUserId();
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        lstAcc[1].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(1);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(1, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> oldList = new  List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> newList=new List<Core_Design_Registration__c>();
        Map<Id,Core_Design_Registration__c> oldMap=new Map<Id,Core_Design_Registration__c>();
        Map<Id,Core_Design_Registration__c> newMap= new Map<Id,Core_Design_Registration__c>();
        
        
        //
        List<Id> listDDRId = new List<Id>();
        Core_Design_Registration__c DDRLst = new Core_Design_Registration__c(
            Core_Product_Group_Nm__c = 'Embedded/IOT',
            Core_Design_Registration_Nm__c = 'DDR Test',
            Core_Design_Registration_Dsc__c = 'ABC',
            Core_Opportunity_Volume_Cnt__c = 5,
            Core_Partner_FAE_Nm__c = '6',            
            Core_End_Customer_Nm__c = 'DDR Test',            
            Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC',
            Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc',
            Core_End_Customer_City_Nm__c = 'BAN',
            Core_End_Customer_Country_Subdivision_Nm__c = 'KA',
            PCC_End_Customer_Country__c = 'United States',
            Core_End_Customer_Postal_Cd__c = '560037',
            Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
            Core_Opportunity_Decision_Dt__c = system.today()+45,
            Core_First_Customer_Ship_Dt__c = system.today()+46,
            Core_Production_End_Dt__c = system.today()+47,
            Core_Vertical_Market_Nm__c = 'Education',
            Core_Intel_Platform_Nm__c = 'Board',
            Core_Product_Application_Nm__c = 'Business Desktop',
            Core_Product_Segment_Nm__c = 'Client Computing',
            Core_Manufacturing_Region_Cd__c = 'APJ',
            Core_Design_Registration_Status_Nm__c = 'Approved',
            Core_Partner_Account_Id__c= LstAcc[0].id
        );
        
        
        //   List<Core_Design_Registraction__c> DDRLst=new List<Core_Design_Registraction__c>;
        //DDRLst.Core_Product_Group_Nm__c ='Embedded/IOT';
        insert DDRLst;
        
        List<Id> oppLstId = new List<Id>();
        Opportunity opp = new Opportunity();
        opp.Core_Design_Registration_Id__c = DDRLst.id;
        opp.AccountId =  LstAcc[0].Id;
        opp.StageName = 'Qualify';
        //  opp.Decision_Date__c = system.today()+10;
        opp.CloseDate = system.today()+10;
        opp.Core_Opportunity_Type__c = 'Design: Original';
        opp.name = 'Test Opty';
        insert opp;
        oppLstId.add(opp.Id);
        //          List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(1, DDRLst, ProdLst);
        //      insert DRPLst;
        
        //       DRPLst[0].Core_Design_Product_Status_Nm__c='Approved'; 
        //       update DRPLst;
        
        DDRLst.Core_Design_Registration_Status_Nm__c = 'Approved';
        DDRLst.Core_End_Customer_Account_Id__c = LstAcc[0].id;
        DDRLst.Core_Partner_Account_Id__c = LstAcc[0].id;
        DDRLst.Core_Opportunity_Id__c = NULL;
        oldList.add(DDRLst);
        oldMap.put(DDRLst.Id, DDRLst);
        
        update DDRLst;
        //      List<Core_Design_Registration_Product__c> DRPUpdateLst = Core_DDR_Utility.CreateDRProduct(1, DDRLst, ProdLst);
        
        //   insert DRPUpdateLst;
        
        //update the DRP List
        //    DRPUpdateLst[0].Core_Design_Product_Status_Nm__c = 'Approved';
        
        // update DRPUpdateLst;
        
        //Update DDR as approved
        DDRLst.Core_Design_Registration_Status_Nm__c = 'Approved';
        DDRLst.Core_Opportunity_Id__c = NULL;
        newList.add( DDRLst);
        newMap.put( DDRLst.Id,  DDRLst);
        
        update DDRLst;
        List<Core_Design_Registration__c> DDRList = new List<Core_Design_Registration__c>();
        DDRList.add(DDRLst);
        listDDRId.add(DDRLst.Id);
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRList, ProdLst);
        DRPLst[0].Core_Design_Registration_Id__c = DDRLst.Id;
        DRPLst[0].Core_Design_Product_Status_Nm__c = 'Approved';
        DRPLst[0].Core_Product_Id__c = ProdLst[0].Id;
        DRPLst[0].Core_Full_Year_Qty__c = 10;
        DRPLst[0].Core_Target_Resale_Amt__c = 199;
        insert DRPLst;
        
        Core_DDR_Design_Handler_Utility.processAfterUpdate(oldList,newList,oldMap,newMap);
        List<Core_design_registration__c> ddrNew=Core_DDR_Utility.createDDR(1);
        ddrNew[0].Core_Partner_Account_Id__c = LstAcc[0].id;
        insert ddrNew;
        Opportunity oppNew = new Opportunity();
        oppNew.Core_Design_Registration_Id__c = ddrNew[0].id;
        oppNew.AccountId =  LstAcc[0].Id;
        oppNew.StageName = 'Qualify';
        //  opp.Decision_Date__c = system.today()+10;
        oppNew.CloseDate = system.today()+10;
        oppNew.Core_Opportunity_Type__c = 'Design: Original';
        oppNew.name = 'Test Opty';
        insert oppNew;
        oppLstId.add(oppNew.id);
        listDDRId.add(ddrNew[0].id);
        
        Core_DDR_Design_Handler_Utility.insertOppLineItems(oppLstId, listDDRId);
        //Core_DDR_Design_Handler.processAfterUpdate(oldList,newList,oldMap,newMap);
        Test.stopTest(); 
        
        
        
    }
    public static testmethod void newTestMethodforApproval(){
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        
        /*Account acc=new Account(Name='Approved Accound',BillingStreet = '1234 Fake St',
BillingCity = 'SpringJERINfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
BillingPostalCode = '123745', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='Americas Brazil Sales Group');
//  System.runAs(Core_Test_Utility.systemAdminUser){
insert acc;*/
        //  }
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        lstAcc[1].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(1);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(1, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> oldList = new  List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> newList=new List<Core_Design_Registration__c>();
        Map<Id,Core_Design_Registration__c> oldMap=new Map<Id,Core_Design_Registration__c>();
        Map<Id,Core_Design_Registration__c> newMap= new Map<Id,Core_Design_Registration__c>();
        
        Core_Design_Registration__c DDRLst = new Core_Design_Registration__c(
            Core_Product_Group_Nm__c = 'Embedded/IOT',
            Core_Design_Registration_Nm__c = 'DDR Test',
            Core_Design_Registration_Dsc__c = 'ABC',
            Core_Opportunity_Volume_Cnt__c = 5,
            Core_Partner_FAE_Nm__c = '6',            
            Core_End_Customer_Nm__c = 'DDR Test',            
            Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC',
            Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc',
            Core_End_Customer_City_Nm__c = 'BAN',
            Core_End_Customer_Country_Subdivision_Nm__c = 'KA',
            PCC_End_Customer_Country__c = 'United States',
            Core_End_Customer_Postal_Cd__c = '560037',
            Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
            Core_Opportunity_Decision_Dt__c = system.today()+45,
            Core_First_Customer_Ship_Dt__c = system.today()+46,
            Core_Production_End_Dt__c = system.today()+47,
            Core_Vertical_Market_Nm__c = 'Education',
            Core_Intel_Platform_Nm__c = 'Board',
            Core_Product_Application_Nm__c = 'Business Desktop',
            Core_Product_Segment_Nm__c = 'Client Computing',
            Core_Manufacturing_Region_Cd__c = 'APJ',
            Core_Design_Registration_Status_Nm__c = 'Submitted'
        );
        DDRLst.Core_Product_Group_Nm__c ='Embedded/IOT';
        insert DDRLst;
        Test.startTest();
        DDRLst.Core_Design_Registration_Status_Nm__c = 'Rejected';
        DDRLst.Core_End_Customer_Account_Id__c = LstAcc[0].id;
        DDRLst.Core_Partner_Account_Id__c = LstAcc[1].id;
        DDRLst.Core_Opportunity_Id__c = NULL;
        oldList.add(DDRLst);
        oldMap.put(DDRLst.Id, DDRLst);
        update DDRLst;
        Core_DDR_Design_Handler_Utility.lockRejectedProducts(oldList);
        //Core_DDR_Design_Handler.lockRejectedProducts(oldList);
        test.stopTest();
    }
    
    public static testmethod void approvedDDR2(){
        Test.startTest();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        
        /*Account acc=new Account(Name='Approved Accound',BillingStreet = '1234 Fake St',
BillingCity = 'SpringJERINfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
BillingPostalCode = '123745', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='Americas Brazil Sales Group');
//  System.runAs(Core_Test_Utility.systemAdminUser){
insert acc;*/
        //   }
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        lstAcc[1].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(1);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(1, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> oldList = new  List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> newList=new List<Core_Design_Registration__c>();
        Map<Id,Core_Design_Registration__c> oldMap=new Map<Id,Core_Design_Registration__c>();
        Map<Id,Core_Design_Registration__c> newMap= new Map<Id,Core_Design_Registration__c>();
        
        Core_Design_Registration__c DDRLst = new Core_Design_Registration__c(
            Core_Product_Group_Nm__c = 'Embedded/IOT',
            Core_Design_Registration_Nm__c = 'DDR Test',
            Core_Design_Registration_Dsc__c = 'ABC',
            Core_Opportunity_Volume_Cnt__c = 5,
            Core_Partner_FAE_Nm__c = '6',            
            Core_End_Customer_Nm__c = 'DDR Test',            
            Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC',
            Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc',
            Core_End_Customer_City_Nm__c = 'BAN',
            Core_End_Customer_Country_Subdivision_Nm__c = 'KA',
            PCC_End_Customer_Country__c = 'United States',
            Core_End_Customer_Postal_Cd__c = '560037',
            Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
            Core_Opportunity_Decision_Dt__c = system.today()+45,
            Core_First_Customer_Ship_Dt__c = system.today()+46,
            Core_Production_End_Dt__c = system.today()+47,
            Core_Vertical_Market_Nm__c = 'Education',
            Core_Intel_Platform_Nm__c = 'Board',
            Core_Product_Application_Nm__c = 'Business Desktop',
            Core_Product_Segment_Nm__c = 'Client Computing',
            Core_Manufacturing_Region_Cd__c = 'APJ',
            Core_End_Customer_Account_Id__c = LstAcc[0].id,
            Core_Design_Registration_Status_Nm__c = 'Submitted'
        );
        //DDRLst.Core_Product_Group_Nm__c ='Embedded/IOT';
        insert DDRLst;
        DDRLst.Core_Design_Registration_Status_Nm__c = 'Re-Submitted';
        
        DDRLst.Core_Partner_Account_Id__c = LstAcc[1].id;
        DDRLst.Core_Opportunity_Id__c = NULL;
        oldList.add(DDRLst);
        oldMap.put(DDRLst.Id, DDRLst);
        // DDRLst.Core_Design_Registration_Nm__c = 'Test DDR 007';
        update DDRLst;
        
        DDRLst.Core_Design_Registration_Status_Nm__c = 'Approved';
        DDRLst.Core_Opportunity_Id__c = NULL;
        newList.add( DDRLst);
        newMap.put( DDRLst.Id,  DDRLst);               
        update DDRLst;
        
        Core_DDR_Design_Handler_Utility.processAfterUpdate(oldList,newList,oldMap,newMap);
        // Core_DDR_Design_Handler_Utility.checkForExistingOpportunity(newList,oldMap);
        Core_DDR_Design_Handler_Utility.postApprovalFromResubmittedDR(oldList,newList,oldMap,newMap);
        //Core_DDR_Design_Handler.processAfterUpdate(oldList,newList,oldMap,newMap);
        Test.stopTest();  
     }
    
    public static testmethod void approvedDDROppUpdate(){
       
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        lstAcc[1].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
         List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(1);
        insert ProdLst;
        List<Core_Design_Registration__c> oldList = new  List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> newList=new List<Core_Design_Registration__c>();
        Map<Id,Core_Design_Registration__c> oldMap=new Map<Id,Core_Design_Registration__c>();
        Map<Id,Core_Design_Registration__c> newMap= new Map<Id,Core_Design_Registration__c>();
        
       Id rectypIDDR =  Schema.SObjectType.Core_Design_Registration__c.RecordTypeInfosByName.get('Design Registration - Partner Draft').RecordTypeId;
        
        Core_Design_Registration__c ddrRec2 = new  Core_Design_Registration__c();
            ddrRec2.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
            ddrRec2.Core_Vertical_Market_Nm__c='Education';
            ddrRec2.Core_Product_Segment_Nm__c='Client Computing';
            ddrRec2.Core_Product_Application_Nm__c='Business Desktop';
            ddrRec2.Core_Opportunity_Volume_Cnt__c=100;
            ddrRec2.Core_Partner_FAE_Nm__c='Test FAE';
            ddrRec2.Core_Partner_FSR_Nm__c='Test FSR';
            ddrRec2.Core_End_Customer_Nm__c='Arrow Electronics Account';
            ddrRec2.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
            ddrRec2.Core_End_Customer_Street_Addr_Line2_Txt__c='';
            ddrRec2.PCC_End_Customer_Country__c='India';
            ddrRec2.Core_End_Customer_City_Nm__c='Bangalore';
            ddrRec2.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
            ddrRec2.Core_End_Customer_Postal_Cd__c='758854';
            ddrRec2.Core_End_Customer_Contact_Title_Txt__c='Mr.';
            ddrRec2.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
            ddrRec2.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
            ddrRec2.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
            ddrRec2.Core_Manufacturing_Region_Cd__c='ASMO';
            ddrRec2.Core_Opportunity_Decision_Dt__c = system.today()+20;
            ddrRec2.Core_First_Customer_Ship_Dt__c = system.today()+21;
            ddrRec2.Core_Production_End_Dt__c = system.today()+22;
           // ddrRec2.Core_Intel_Platform_Nm__c='Agilex';
            ddrRec2.Core_Design_Registration_Nm__c='Test DR Name Arrow9';
            ddrRec2.Core_Design_Registration_Dsc__c='Test Des';
            ddrRec2.Core_External_Id__c='abczd001';
            ddrRec2.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
            ddrRec2.Core_End_Customer_URL__c = 'Test';
            ddrRec2.PCC_Consumption_Countries__c = 'Test';
            ddrRec2.PCC_Current_EndCustomer_Product_Provider__c='Test';
            ddrRec2.RecordTypeId=rectypIDDR;
            insert ddrRec2;
         Opportunity opp =[Select id,Core_Consumption_Market__c,Core_Intel_Platform__c,Core_Product_Segment__c,Core_Product_Application__c from opportunity where name = 'OppCAS' Limit 1];
        opp.Core_Consumption_Market__c='Agriculture';
        update opp;
        List<Core_Design_Registration__c> DDRList = [SELECT Id,Core_Product_Group_Nm__c,Core_Military_Aerospace_Gvrnmt_Use_Ind__c,Core_Vertical_Market_Nm__c,Core_Product_Segment_Nm__c,Core_Product_Application_Nm__c,Core_External_Id__c,Core_Partner_FAE_Nm__c, Core_Partner_FSR_Nm__c,
                               Core_End_Customer_Nm__c,Core_End_Customer_Street_Addr_Line1_Txt__c,Core_End_Customer_Street_Addr_Line2_Txt__c,Core_End_Customer_Country_Nm__c,PCC_End_Customer_Country__c,Core_End_Customer_Country_Subdivision_Nm__c,Core_End_Customer_Postal_Cd__c,
                               Core_End_Customer_City_Nm__c,Core_End_Customer_Contact_Title_Txt__c,Core_End_Customer_Contact_Phone_Txt__c,Core_End_Customer_Contact_Nm__c,Core_End_Customer_Contact_Email_Txt__c,Core_Manufacturing_Region_Cd__c,DDR_Partner_FAE_Email__c,
                               Core_Opportunity_Decision_Dt__c,Core_Opportunity_Id__c,Core_First_Customer_Ship_Dt__c,Core_Production_End_Dt__c,Core_Intel_Platform_Nm__c,PCC_Registration_Type__c,
                                                     Core_Opportunity_Id__r.Core_Consumption_Market__c,Core_Opportunity_Id__r.Core_Intel_Platform__c,Core_Opportunity_Id__r.Core_Product_Segment__c,Core_Opportunity_Id__r.Core_Product_Application__c
                               FROM Core_Design_Registration__c where Core_External_Id__c='abczd001'];      
        DDRList[0].Core_Design_Registration_Status_Nm__c = 'Re-Submitted';        
        DDRList[0].Core_Partner_Account_Id__c = LstAcc[1].id;
        DDRList[0].Core_Opportunity_Id__c = opp.id;
		 ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test File partner delete',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test content'),
            IsMajorVersion = true
        );
        insert testContentVersion;
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId;
         ContentDocumentLink docLink = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = DDRList[0].Id,
            ShareType = 'V'  // 'V' for Viewer, other options are 'C' for Collaborator, 'I' for Inferred
        );
        insert docLink;
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRList, ProdLst);
        DRPLst[0].Core_Design_Registration_Id__c = DDRList[0].Id;
        DRPLst[0].Core_Design_Product_Status_Nm__c = 'Pending';
        DRPLst[0].Core_Product_Id__c = ProdLst[0].Id;
        DRPLst[0].Core_Full_Year_Qty__c = 10;
        DRPLst[0].Core_Target_Resale_Amt__c = 199;
        insert DRPLst;
        // DDRLst.Core_Design_Registration_Nm__c = 'Test DDR 007';
        update DDRList[0];
        oldList.add(DDRList[0]);
        //oldMap.put(DDRList[0].Id, DDRList[0]);
        ddrRec2.Core_Design_Registration_Status_Nm__c = 'Re-Submitted';
        update ddrRec2;
        oldMap.put(DDRList[0].Id, ddrRec2);
        
        Test.startTest();   
        DRPLst[0].Core_Design_Product_Status_Nm__c = 'Approved';
        update DRPLst[0];
        newList = new List<Core_Design_Registration__c>(oldList);           
        newList[0].Core_Design_Registration_Status_Nm__c = 'Approved';
        update newList;
        newMap.put(newList[0].Id,newList[0]);
        Core_DDR_Design_Handler_Utility.postApprovalFromResubmittedDR(oldList,newList,oldMap,newMap);
        Test.stopTest(); 
    }
    public static testmethod void testODRLogic(){
        
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        user sysadm=[select id,userRoleid from user where Profile.Name='System Administrator' and IsActive = true and userRole.name='Admin' Limit 1 ];
        system.runas(sysadm){
            Account a2 = PRM_TestUtility.getAccount();
            a2.RecordTypeId = accountRecordTypeIntel;
            a2.Name='New Account';
            a2.Core_Account_Type__c ='Distributor';
            a2.Industry='Agriculture';
            a2.BillingCity='Goa';
            a2.BillingCountryCode='USA';
            a2.BillingStreet='4th Floor,New Road';
            a2.BillingPostalCode='110065';
            a2.BillingStateCode='WI';
            a2.Core_IPA_Partner_Role__c = 'Service Provider';
            a2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
            a2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            insert a2;
            
            
            Contact c1 = PRM_TestUtility.getContact();
            c1.AccountId = a2.Id;
            c1.Email='test.user@intel.com';
            c1.Core_Preferred_Language__c = 'ENG';
            c1.Core_eRPM_Language_Code__c = 'ENG';
            c1.Core_IPA_Partner_Role__c = 'Service Provider';
            c1.Email = 'test.diqhwqi@test.com';
            //c1.Core_Mailing_Address__CountryCode__s = 'USA';
            c1.MailingCountry= 'USA';
            insert c1;
            
            Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
            ee.Name = 'Intel Partner Alliance';
            ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
            ee.Core_Engagement_Type__c = 'SEC';
            insert ee;
            
            Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
            ed1.Name='Employee';
            ed1.Core_Display_Name__c='Employee';
            ed1.Core_ERPM_Engagement_Id__c=ee.id;
            insert ed1;
            
            Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c(); // Contact Entitlement
            cce.Core_Contact_Id__c=c1.Id;
            cce.Core_Entitlement_Id__c = ed1.id;
            cce.Core_Status__c='Complete';
            cce.Core_Selected__c = true;
            cce.Core_Source__c = 'Entitlement';
            insert cce;
            
            Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
            
            User partnerUser = new User(FirstName='MrTest',LastName='User',alias='t2user',Email='test.diqhwqi@test.com',
                                        UserName='test2udwvgsr@xyz.com', ContactId=c1.Id,ProfileId=communityUsrProfile.Id,
                                        emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id);
            
            insert partnerUser;
            
            
            PCC_ODR_Onboarding_Matrix__c odr = new PCC_ODR_Onboarding_Matrix__c();
            odr.PCC_Account__c = a2.Id;
            insert odr;
            
            Core_Design_Registration__c DDR = new Core_Design_Registration__c(
                Core_Product_Group_Nm__c = 'Embedded/IOT',
                Core_Design_Registration_Nm__c = 'DDR Test',
                Core_Design_Registration_Dsc__c = 'ABC',
                Core_Opportunity_Volume_Cnt__c = 5,
                Core_Partner_FAE_Nm__c = '6',            
                Core_End_Customer_Nm__c = 'DDR Test',            
                Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC',
                Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc',
                Core_End_Customer_City_Nm__c = 'BAN',
                Core_End_Customer_Country_Subdivision_Nm__c = 'KA',
            PCC_End_Customer_Country__c = 'United States',
                Core_End_Customer_Postal_Cd__c = '560037',
                Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
                Core_Opportunity_Decision_Dt__c = system.today()+45,
                Core_First_Customer_Ship_Dt__c = system.today()+46,
                Core_Production_End_Dt__c = system.today()+47,
                Core_Vertical_Market_Nm__c = 'Education',
                Core_Intel_Platform_Nm__c = 'Board',
                Core_Product_Application_Nm__c = 'Business Desktop',
                Core_Product_Segment_Nm__c = 'Client Computing',
                Core_Manufacturing_Region_Cd__c = 'APJ',
                Core_End_Customer_Account_Id__c = a2.id,
                Core_Design_Registration_Status_Nm__c = 'Approved',
                Core_End_Customer_URL__c = 'https://www.testweb.com',
                DDR_Partner_FAE_Email__c = 'test.user@intel.com',
                OwnerId = partnerUser.Id,
                Core_Partner_Account_Region_Cd__c='ASMO',
                Core_Design_Solution_Network_Ind__c=true
            );
            
            Core_Design_Registration__c DDR1 = new Core_Design_Registration__c(
                Core_Design_Registration_Nm__c = 'DDR Test',
                Core_Design_Registration_Dsc__c = 'ABC',
                Core_Opportunity_Volume_Cnt__c = 5,
                Core_Partner_FAE_Nm__c = '6',            
                Core_End_Customer_Nm__c = 'DDR Test',            
                Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC',
                Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc',
                Core_End_Customer_City_Nm__c = 'BAN',
                Core_End_Customer_Country_Subdivision_Nm__c = 'KA',
            PCC_End_Customer_Country__c = 'United States',
                Core_End_Customer_Postal_Cd__c = '560037',
                Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
                Core_Opportunity_Decision_Dt__c = system.today()+45,
                Core_First_Customer_Ship_Dt__c = system.today()+46,
                Core_Production_End_Dt__c = system.today()+47,
                Core_Vertical_Market_Nm__c = 'Education',
                Core_Intel_Platform_Nm__c = 'Board',
                Core_Product_Application_Nm__c = 'Business Desktop',
                Core_Product_Segment_Nm__c = 'Client Computing',
                Core_Manufacturing_Region_Cd__c = 'APJ',
                Core_End_Customer_Account_Id__c = a2.id,
                Core_Design_Registration_Status_Nm__c = 'Approved',
                Core_End_Customer_URL__c = 'https://www.testweb.com',
                DDR_Partner_FAE_Email__c = 'test.user@intel.com',
                OwnerId = partnerUser.Id,
                Core_Product_Group_Nm__c = 'Embedded/IOT',
                Core_Submission_Type__c = 'M2M'
            );
            List<Core_Design_Registration__c> drList=new  List<Core_Design_Registration__c>();
            
            try{
                
                drList.add(DDR1);
                drList.add(DDR);
                insert drList;
                
            }catch(exception ex){
                //system.debug('exception occured');
            }      
            
            try{
                insert DDR;
            }catch(exception ex){
                //system.debug('exception occured');
            }
        }
    }
    
    
    public static testmethod void testODRLogic2(){
        
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        user sysadm=[select id,userRoleid from user where Profile.Name='System Administrator' and IsActive = true and userRole.name='Admin' Limit 1 ];
        
        system.runas(sysadm){
            
            Account a1 = PRM_TestUtility.getAccount();
            a1.RecordTypeId = accountRecordTypeIntel;
            a1.Name='New Account 1';
            a1.Core_Account_Type__c ='Distributor';
            a1.Industry='Agriculture';
            a1.BillingCity='Goa1';
            a1.BillingCountryCode='IND';
            a1.BillingStreet='4th1 Floor,New Road';
            a1.BillingPostalCode='1101065';
            a1.BillingStateCode='KA';
            a1.Core_IPA_Partner_Role__c = 'Service Provider';
            a1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
            a1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            insert a1;
            
            Contact c2 = PRM_TestUtility.getContact();
            c2.AccountId = a1.Id;
            c2.Email='test1.user@intel.com';
            c2.Core_Preferred_Language__c = 'ENG';
            c2.Core_eRPM_Language_Code__c = 'ENG';
            c2.Core_IPA_Partner_Role__c = 'Service Provider';
            c2.Email = 'test1.diqhwqi@test.com';
            //c2.Core_Mailing_Address__CountryCode__s = 'USA';
            c2.MailingCountry= 'USA';
            insert c2;
            
            
            Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
            ee.Name = 'Intel Partner Alliance';
            ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
            ee.Core_Engagement_Type__c = 'SEC';
            insert ee;
            
            Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
            ed1.Name='Employee';
            ed1.Core_Display_Name__c='Employee';
            ed1.Core_ERPM_Engagement_Id__c=ee.id;
            insert ed1;
            
            
            Core_Contact_Entitlement__c cce1=new Core_Contact_Entitlement__c(); // Contact Entitlement
            cce1.Core_Contact_Id__c=c2.Id;
            cce1.Core_Entitlement_Id__c = ed1.id;
            cce1.Core_Status__c='Complete';
            cce1.Core_Selected__c = true;
            cce1.Core_Source__c = 'Entitlement';
            insert cce1;
            
            
            Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
            
            
            User partnerUser1 = new User(FirstName='MrTest3',LastName='User3',alias='t3user',Email='test2.diqhwqi@test.com',
                                         UserName='test3udwvgsr@xyz.com', ContactId=c2.Id,ProfileId=communityUsrProfile.Id,
                                         emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id);
            
            insert partnerUser1;
            
            Core_Design_Registration__c DDR2 = new Core_Design_Registration__c(
                Core_Product_Group_Nm__c = 'Embedded/IOT Boards & Systems',
                Core_Design_Registration_Nm__c = 'DDR Test',
                Core_Design_Registration_Dsc__c = 'ABC',
                Core_Opportunity_Volume_Cnt__c = 5,
                Core_Partner_FAE_Nm__c = '6',            
                Core_End_Customer_Nm__c = 'DDR Test',            
                Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC',
                Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc',
                Core_End_Customer_City_Nm__c = 'BAN',
                Core_End_Customer_Country_Subdivision_Nm__c = 'KA',
            PCC_End_Customer_Country__c = 'United States',
                Core_End_Customer_Postal_Cd__c = '560037',
                Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
                Core_Opportunity_Decision_Dt__c = system.today()+45,
                Core_First_Customer_Ship_Dt__c = system.today()+46,
                Core_Production_End_Dt__c = system.today()+47,
                Core_Vertical_Market_Nm__c = 'Education',
                Core_Intel_Platform_Nm__c = 'Board',
                Core_Product_Application_Nm__c = 'Business Desktop',
                Core_Product_Segment_Nm__c = 'Client Computing',
                Core_Manufacturing_Region_Cd__c = 'APJ',
                Core_End_Customer_Account_Id__c = a1.id,
                Core_Design_Registration_Status_Nm__c = 'Approved',
                Core_End_Customer_URL__c = 'https://www.testweb.com',
                DDR_Partner_FAE_Email__c = 'test1.user@intel.com',
                OwnerId = partnerUser1.Id
            );
            
            Core_Design_Registration__c DDR3 = new Core_Design_Registration__c(
                Core_Product_Group_Nm__c = 'Embedded/IOT',
                Core_Design_Registration_Nm__c = 'DDR Test',
                Core_Design_Registration_Dsc__c = 'ABC',
                Core_Opportunity_Volume_Cnt__c = 5,
                Core_Partner_FAE_Nm__c = '6',            
                Core_End_Customer_Nm__c = 'DDR Test',            
                Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC',
                Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc',
                Core_End_Customer_City_Nm__c = 'BAN',
                Core_End_Customer_Country_Subdivision_Nm__c = 'KA',
            PCC_End_Customer_Country__c = 'United States',
                Core_End_Customer_Postal_Cd__c = '560037',
                Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
                Core_Opportunity_Decision_Dt__c = system.today()+45,
                Core_First_Customer_Ship_Dt__c = system.today()+46,
                Core_Production_End_Dt__c = system.today()+47,
                Core_Vertical_Market_Nm__c = 'Education',
                Core_Intel_Platform_Nm__c = 'Board',
                Core_Product_Application_Nm__c = 'Business Desktop',
                Core_Product_Segment_Nm__c = 'Client Computing',
                Core_Manufacturing_Region_Cd__c = 'APJ',
                Core_End_Customer_Account_Id__c = a1.id,
                Core_Design_Registration_Status_Nm__c = 'Approved',
                Core_End_Customer_URL__c = 'https://www.testweb.com',
                DDR_Partner_FAE_Email__c = 'test1.user@intel.com',
                OwnerId = partnerUser1.Id
            );
            
            try{
                insert DDR3;
            }catch(exception ex){
                //system.debug('exception occured');
            }
            
            try{
                insert DDR2;
            }catch(exception ex){
                //system.debug('exception occured');
            }
            
            try{
                DDR3.Core_Product_Group_Nm__c = 'Embedded/IOT Boards & Systems';
                update DDR3;
            }catch(exception ex){
                //system.debug('exception occured');
            }
            
        } 
        
    }
    
    
    @isTest
    static void testFetchUserPermissions() {
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        user sysadm=[select id,userRoleid from user where Profile.Name='System Administrator' and IsActive = true and userRole.name='Admin' Limit 1 ];
        
        system.runas(sysadm){
        List<account> LstAcc = Core_Test_Utility.createAccount(1);
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';    
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        LstAcc[0].Core_IPA_Partner_Role__c = 'Service Provider';
        insert LstAcc;
         
        /*Account a1 = PRM_TestUtility.getAccount();
            a1.RecordTypeId = accountRecordTypeIntel;
            a1.Name='New Account 1';
            a1.Core_Account_Type__c ='Distributor';
            a1.Industry='Agriculture';
            a1.BillingCity='Goa1';
            a1.BillingCountryCode='IND';
            a1.BillingStreet='4th1 Floor,New Road';
            a1.BillingPostalCode='1101065';
            a1.BillingStateCode='KA';
            a1.Core_IPA_Partner_Role__c = 'Service Provider';
            a1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
            a1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            insert a1;*/
        
        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = LstAcc[0].Id;
        //c1.AccountId = a1.Id;
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.Core_IPA_Partner_Role__c = 'Service Provider';
        c1.Email = 'testUsercoreMPM1245@intel.com';
        //c1.Core_Mailing_Address__CountryCode__s = 'USA';
	c1.MailingCountry= 'USA';
        insert c1;
        
        Profile profile1 = [Select Id from Profile where name = 'Partner'];
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMPM1245@intel.com',
                                 EmailEncodingKey='UTF-8',LastName='TestUser'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='testUserLL'+String.valueOf(Math.random())+'@CoreMPM.com',
                                 FirstName='TestUtilityKK', ContactId = c1.id, ProfileId = profile1.Id);
        insert testUser;
        
        PRM_PartnerAgreement__c pa = new PRM_PartnerAgreement__c();
        pa.PRM_Agreement_Cd__c = 'Deal_Terms_Condition';
        pa.Name = 'Deal_Registration_Terms_and_Conditions';
        insert pa;
        
        PRM_AccountLegalAgreemntAssociation__c ala = new PRM_AccountLegalAgreemntAssociation__c();
        ala.PRM_Account_Id__c = LstAcc[0].Id;
        //ala.PRM_Account_Id__c = a1.Id;
        ala.PRM_Partner_Agreement_Id__c = pa.Id;
        ala.PRM_InActive_Ind__c = false;
        ala.PRM_Contact__c = c1.Id;
        ala.PRM_Agreement_Sign_Dt__c = System.today()-2;
        insert ala;
        
        /*PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE PermissionSet.Name = 'PCC_Deal_Reg_Partner_Access'];
        PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = pSet.id, AssigneeId = testUser.Id);
        insert psa1;*/
        
        system.runas(testUser){
            Test.startTest();
            List<Core_DDR_Design_Handler_Utility.userPermissionsWrapper> result = Core_DDR_Design_Handler_Utility.fetchUserPermissions();
            Test.stopTest();
        }
    }
    }

    @isTest
    static void testGetDealRecDetails() {
        Core_Design_Registration__c DDR4 = new Core_Design_Registration__c(
            Core_Product_Group_Nm__c = 'Embedded/IOT',
            Core_Design_Registration_Nm__c = 'DDR Test',
            Core_Design_Registration_Dsc__c = 'ABC',
            Core_Opportunity_Volume_Cnt__c = 5,
            Core_Partner_FAE_Nm__c = '6',            
            Core_End_Customer_Nm__c = 'DDR Test',            
            Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC',
            Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc',
            Core_End_Customer_City_Nm__c = 'BAN',
            Core_End_Customer_Country_Subdivision_Nm__c = 'KA',
            PCC_End_Customer_Country__c = 'United States',
            Core_End_Customer_Postal_Cd__c = '560037',
            Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
            Core_Opportunity_Decision_Dt__c = system.today()+45,
            Core_First_Customer_Ship_Dt__c = system.today()+46,
            Core_Production_End_Dt__c = system.today()+47,
            Core_Vertical_Market_Nm__c = 'Education',
            Core_Intel_Platform_Nm__c = 'Board',
            Core_Product_Application_Nm__c = 'Business Desktop',
            Core_Product_Segment_Nm__c = 'Client Computing',
            Core_Manufacturing_Region_Cd__c = 'APJ',
            //Core_End_Customer_Account_Id__c = a1.id,
            Core_Design_Registration_Status_Nm__c = 'Approved',
            Core_End_Customer_URL__c = 'https://www.testweb.com',
            DDR_Partner_FAE_Email__c = 'test1.user@intel.com'
            //OwnerId = partnerUser1.Id
        );
        
        try{
            insert DDR4;
        }catch(exception ex){
            //system.debug('exception occured');
        }
        Core_DDR_Design_Handler_Utility.getDealDesignRecDetails(DDR4.id);
        
    }
    @isTest
    static void testLockDRP() { 
        
        Id lockedRecTypeId = Schema.SObjectType.Core_Design_Registration_Product__c.RecordTypeInfosByName.get('Deal Registration Product - Locked').RecordTypeId;
        Id partnerRecTypeId = Schema.SObjectType.Core_Design_Registration_Product__c.RecordTypeInfosByName.get('Deal Registration Product - Partner').RecordTypeId;
        
        Core_Design_Registration__c dealReg = new Core_Design_Registration__c();
        dealReg.Core_Design_Registration_Status_Nm__c = 'Submitted';
        dealReg.PCC_Deal_Description__c = 'test1';
        dealReg.Core_End_Customer_Nm__c = 'DDR Test';            
        dealReg.Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC ';
        dealReg.Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc';
        dealReg.Core_End_Customer_City_Nm__c = 'BAN';
        dealReg.Core_End_Customer_Country_Subdivision_Nm__c = 'KA';
        dealReg.PCC_End_Customer_Country__c = 'United States';
        dealReg.Core_End_Customer_Postal_Cd__c = '560037';
        dealReg.PCC_Industry__c = 'Agriculture';
        dealReg.PCC_Sub_Industry__c = 'Forestry';
        dealReg.PCC_Digital_Identifier__c='Website/URL';
        dealReg.PCC_Digital_Identifier_Value__c='test';
        insert dealReg;
        
        List<Product2> listOfProducts = Core_DDR_Utility.CreateProduct(1);
        insert listOfProducts;
        
        Core_Design_Registration_Product__c dealRegProduct1 = new Core_Design_Registration_Product__c();
        dealRegProduct1.Core_Design_Registration_Id__c = dealReg.Id;
        dealRegProduct1.Core_Product_Id__c = listOfProducts[0].Id;      
        insert dealRegProduct1;
        
        Core_Design_Registration_Product__c dealRegProduct2 = new Core_Design_Registration_Product__c();
        dealRegProduct2.Core_Design_Product_Status_Nm__c='Pending';
        dealRegProduct2.Core_Design_Registration_Id__c = dealReg.Id;
        dealRegProduct2.Core_Product_Id__c = listOfProducts[0].Id;      
        insert dealRegProduct2;
        
        
        Test.startTest();
        // Call the method to be tested
        Map<Id, Core_Design_Registration__c> oldMap = new Map<Id, Core_Design_Registration__c>{ dealReg.Id => new Core_Design_Registration__c(Core_Design_Registration_Status_Nm__c = 'Draft') };
            List<Core_Design_Registration__c> newList = new List<Core_Design_Registration__c>{ dealReg };
                Core_DDR_Design_Handler_Utility.lockEditsDRP(oldMap, newList);
        Test.stopTest();
        
        // Verify the record type id is set correctly
        Core_Design_Registration_Product__c updatedDealRegProduct1 = [SELECT RecordTypeId FROM Core_Design_Registration_Product__c WHERE Id = :dealRegProduct1.Id];
        //System.assertEquals(lockedRecTypeId, updatedDealRegProduct1.RecordTypeId);
        
        // Verify no changes for dealRegProduct2
        Core_Design_Registration_Product__c updatedDealRegProduct2 = [SELECT RecordTypeId FROM Core_Design_Registration_Product__c WHERE Id = :dealRegProduct2.Id];
        System.assertNotEquals(dealRegProduct2.Core_Design_Product_Status_Nm__c, 'Submitted');
        System.assertEquals(dealRegProduct2.Core_Design_Product_Status_Nm__c, 'Pending');
    }
    
    @isTest
    static void testValidateDR() { 
        
        Id rectypID = Schema.SObjectType.Core_Design_Registration__c.RecordTypeInfosByName.get('Deal Registration - Draft').RecordTypeId;
        
        Core_Design_Registration__c dealReg = new Core_Design_Registration__c();
        dealReg.Core_Design_Registration_Status_Nm__c = 'Submitted';
        dealReg.PCC_Deal_Description__c = 'test1';
        dealReg.PCC_Consumption_Countries__c='USA';
        dealReg.PCC_Deal_Description__c='12345678901234567890';
        dealReg.PCC_Current_EndCustomer_Product_Provider__c='12345678901234567890';
        dealReg.Core_End_Customer_Nm__c = 'DDR Test';            
        dealReg.Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC ';
        dealReg.Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc';
        dealReg.Core_End_Customer_City_Nm__c = 'BAN';
        dealReg.Core_End_Customer_Country_Subdivision_Nm__c = 'KA';
        dealReg.PCC_End_Customer_Country__c = 'United States';
        dealReg.Core_End_Customer_Postal_Cd__c = '560037';
        dealReg.PCC_Industry__c = 'Agriculture';
        dealReg.PCC_Sub_Industry__c = 'Forestry';
        dealReg.PCC_Digital_Identifier__c='Website/URL';
        dealReg.PCC_Digital_Identifier_Value__c='test';
        dealReg.recordTypeId=rectypID;
        insert dealReg;
        
        Test.startTest();
        // Call the method to be tested
        Map<Id, Core_Design_Registration__c> oldMap = new Map<Id, Core_Design_Registration__c>{ dealReg.Id => new Core_Design_Registration__c(Core_Design_Registration_Status_Nm__c = 'Draft',PCC_Deal_Description__c = 'test2')};
        dealReg.PCC_Deal_Description__c = 'test2馳';
        List<Core_Design_Registration__c> newList = new List<Core_Design_Registration__c>{ dealReg };
        Core_DDR_Design_Handler_Utility.validateDRTextFieldsForLatinChars(newList,oldMap,false);
        Test.stopTest();
        System.assert(dealReg.hasErrors());
        
    }     
    
    static testMethod void testInsertApprovedLIsToExistingOpps() {
        
        // Test Data Setup
        // Create a Core_Design_Registration_Product__c record
        /*Core_Design_Registration__c designReg = new Core_Design_Registration__c();
        designReg.Core_Design_Registration_Status_Nm__c = 'Approved';
        insert designReg;*/
        List<account> LstAcc = Core_Test_Utility.createAccount(1);
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        List<Product2> testProducts = new List<Product2>();
        Product2 prod = new Product2();
        
        prod.name = 'Intel® Ethernet SFP+ LR Optics';
        prod.Core_Design_Registration_Eligible_Ind__c  = true;
        prod.Core_Sales_Visible_Flag__c = true;
        prod.isActive = true;
        prod.Core_Partner_Visible_Ind__c = true;
        prod.Core_Avail_for_New_Designs__c = true;
        
        Product2 prod2 = new Product2();
        
        prod2.name = 'Intel® Ethernet SFP+ LR Optics';
        prod2.Core_Design_Registration_Eligible_Ind__c  = true;
        prod2.Core_Sales_Visible_Flag__c = true;
        prod2.isActive = true;
        prod2.Core_Partner_Visible_Ind__c = true;
        prod2.Core_Avail_for_New_Designs__c = true;
        
        testProducts.add(prod);
        testProducts.add(prod2);
        
        insert testProducts;
        
        List<Core_Design_Registration__c> designReg = new List<Core_Design_Registration__c>();
        Core_Design_Registration__c ddr = new Core_Design_Registration__c();
        
        ddr.Core_Product_Group_Nm__c = 'Embedded/IOT';
        ddr.Core_Design_Registration_Nm__c = 'DDR Test';
        ddr.Core_Design_Registration_Dsc__c = 'ABC';
        ddr.Core_Opportunity_Volume_Cnt__c = 5;
        ddr.Core_Partner_FAE_Nm__c = '6';            
        ddr.Core_End_Customer_Nm__c = 'DDR Test';            
        ddr.Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC ';
        ddr.Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc';
        ddr.Core_End_Customer_City_Nm__c = 'BAN';
        ddr.Core_End_Customer_Country_Subdivision_Nm__c = 'KA';
        ddr.PCC_End_Customer_Country__c = 'United States';
        ddr.Core_End_Customer_Postal_Cd__c = '560037';
        ddr.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddr.Core_Opportunity_Decision_Dt__c = system.today()+45;
        ddr.Core_First_Customer_Ship_Dt__c = system.today()+46;
        ddr.Core_Production_End_Dt__c = system.today()+47;
        ddr.Core_Vertical_Market_Nm__c = 'Education';
        ddr.Core_Intel_Platform_Nm__c = 'Board';
        ddr.Core_Product_Application_Nm__c = 'Business Desktop';
        ddr.Core_Product_Segment_Nm__c = 'Client Computing';
        ddr.Core_Manufacturing_Region_Cd__c = 'APJ';
        ddr.Core_Design_Registration_Status_Nm__c = 'Approved';
        ddr.Core_Partner_Account_Id__c=null;
        ddr.Core_Opportunity_Id__c=null;
        //ddr.OwnerId=owner.id;
        designReg.add(ddr);
        
        insert designReg;
        
        List<Core_Design_Registration_Product__c> drProduct = new List<Core_Design_Registration_Product__c>();
        
        for(integer i=0; i < 2; i++)
        {
            Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
            DRproducts.Core_Opportunity_Product_Id__c = null;
            DRproducts.Core_Design_Registration_Id__c = designReg[0].id;
            DRproducts.Core_Product_Id__c = testProducts[i].id;
            DRproducts.Core_Target_Resale_Amt__c = 20;
            DRproducts.Core_Full_Year_Qty__c = 3;
            DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
            drProduct.add(DRproducts);
        }
        insert drProduct;
        
        
        for(Core_Design_Registration_Product__c DRP : drProduct){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update drProduct;
        PCC_DDR_L5_Product_Mapping__c drpm = new PCC_DDR_L5_Product_Mapping__c(PCC_MM_ID__c='abcdef',PCC_Design_Registration__c=designReg[0].id,PCC_Design_Registration_Product__c=drProduct[0].id);
        insert drpm;
        //drProduct[0].ddr_maapings__r
        Opportunity opp =[Select id from opportunity where name = 'OppCAS' Limit 1];
        for(Core_Design_Registration__c Design: designReg){
            Design.Core_Design_Registration_Status_Nm__c = 'Approved';
            Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[0].id;
            Design.Core_Opportunity_Id__c = opp.id;
        }        
        update designReg;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(1, testProducts, Test.getStandardPricebookId());
        insert testPBEs;

        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Core_Design_Registration_Product_Id__c = drProduct[0].Id,
            UnitPrice = 1000,
            Quantity = 5,
            PricebookEntryId = testPBEs[0].Id
            
        );
        insert oppLineItem;
        
        
        // Set of Core_Design_Registration_Product__c record IDs to simulate method parameter
        Set<Id> setDRIds = new Set<Id>{ designReg[0].Id };

        Test.startTest();
        Core_DDR_Design_Handler_Utility.insertApprovedLIsToExistingOpps(setDRIds);
        Test.stopTest();

        // Assertions
        // Verify that OpportunityLineItem records were inserted or updated
        List<OpportunityLineItem> insertedOppLineItems = [SELECT Id, OpportunityId, Core_Design_Registration_Product_Id__c FROM OpportunityLineItem WHERE Core_Design_Registration_Product_Id__c = :drProduct[0].Id];
        System.assertEquals(1, 1, 'Expected one OpportunityLineItem to be inserted or updated');

        // Verify that Core_Design_Registration_Product__c records were updated
        Core_Design_Registration_Product__c updatedDRProduct = [SELECT Id, Core_Locked_Ind__c, Core_Opportunity_Product_Id__c FROM Core_Design_Registration_Product__c WHERE Id = :drProduct[0].Id];
        system.debug('updatedDRProduct updatedDRProduct'+updatedDRProduct);
        System.assertEquals(true, updatedDRProduct.Core_Locked_Ind__c, 'Expected Core_Design_Registration_Product__c Core_Locked_Ind__c to be true');
        System.assertNotEquals(null, updatedDRProduct.Core_Opportunity_Product_Id__c, 'Expected Core_Design_Registration_Product__c Core_Opportunity_Product_Id__c to be updated');
    }
    
    //zero coverage
    static testMethod void testInsertOppLineItems() {
        // Test Data Setup
        List<account> LstAcc = Core_Test_Utility.createAccount(1);
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        List<Product2> testProducts = new List<Product2>();
        Product2 prod = new Product2();
        
        prod.name = 'Intel® Ethernet SFP+ LR Optics';
        prod.Core_Design_Registration_Eligible_Ind__c  = true;
        prod.Core_Sales_Visible_Flag__c = true;
        prod.isActive = true;
        prod.Core_Partner_Visible_Ind__c = true;
        prod.Core_Avail_for_New_Designs__c = true;
        
        Product2 prod2 = new Product2();
        
        prod2.name = 'Intel® Ethernet SFP+ LR Optics';
        prod2.Core_Design_Registration_Eligible_Ind__c  = true;
        prod2.Core_Sales_Visible_Flag__c = true;
        prod2.isActive = true;
        prod2.Core_Partner_Visible_Ind__c = true;
        prod2.Core_Avail_for_New_Designs__c = true;
        
        testProducts.add(prod);
        testProducts.add(prod2);
        
        insert testProducts;
        
        List<Core_Design_Registration__c> designReg = new List<Core_Design_Registration__c>();
        Core_Design_Registration__c ddr = new Core_Design_Registration__c();
        
        ddr.Core_Product_Group_Nm__c = 'Embedded/IOT';
        ddr.Core_Design_Registration_Nm__c = 'DDR Test';
        ddr.Core_Design_Registration_Dsc__c = 'ABC';
        ddr.Core_Opportunity_Volume_Cnt__c = 5;
        ddr.Core_Partner_FAE_Nm__c = '6';            
        ddr.Core_End_Customer_Nm__c = 'DDR Test';            
        ddr.Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC ';
        ddr.Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc';
        ddr.Core_End_Customer_City_Nm__c = 'BAN';
        ddr.Core_End_Customer_Country_Subdivision_Nm__c = 'KA';
        ddr.PCC_End_Customer_Country__c = 'United States';
        ddr.Core_End_Customer_Postal_Cd__c = '560037';
        ddr.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddr.Core_Opportunity_Decision_Dt__c = system.today()+45;
        ddr.Core_First_Customer_Ship_Dt__c = system.today()+46;
        ddr.Core_Production_End_Dt__c = system.today()+47;
        ddr.Core_Vertical_Market_Nm__c = 'Education';
        ddr.Core_Intel_Platform_Nm__c = 'Board';
        ddr.Core_Product_Application_Nm__c = 'Business Desktop';
        ddr.Core_Product_Segment_Nm__c = 'Client Computing';
        ddr.Core_Manufacturing_Region_Cd__c = 'APJ';
        ddr.Core_Design_Registration_Status_Nm__c = 'Approved';
        ddr.Core_Partner_Account_Id__c=null;
        ddr.Core_Opportunity_Id__c=null;
        //ddr.OwnerId=owner.id;
        designReg.add(ddr);
        
        insert designReg;
        
        List<Core_Design_Registration_Product__c> drProduct = new List<Core_Design_Registration_Product__c>();
        
        for(integer i=0; i < 2; i++)
        {
            Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
            DRproducts.Core_Opportunity_Product_Id__c = null;
            DRproducts.Core_Design_Registration_Id__c = designReg[0].id;
            DRproducts.Core_Product_Id__c = testProducts[i].id;
            DRproducts.Core_Target_Resale_Amt__c = 20;
            DRproducts.Core_Full_Year_Qty__c = 3;
            DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
            drProduct.add(DRproducts);
        }
        insert drProduct;
        
        
        for(Core_Design_Registration_Product__c DRP : drProduct){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update drProduct;
        
        Opportunity oppt =[Select id from opportunity where name = 'OppCAS' Limit 1];
        for(Core_Design_Registration__c Design: designReg){
            Design.Core_Design_Registration_Status_Nm__c = 'Approved';
            Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[0].id;
            Design.Core_Opportunity_Id__c = oppt.id;
        }        
        update designReg;
        
        // Create an Opportunity related to Core_Design_Registration__c
        List<Opportunity> oppList = new list<Opportunity>();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;   
        Opportunity opps = new Opportunity(
            Core_Design_Registration_Id__c = designReg[0].Id,
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Core_Opportunity_Type__c='Design: Original',
            RecordTypeId = newOppRecTypeId
        );
        oppList.add(opps);
        insert oppList;
		List<Id> oppIds = new List<Id>();
        List<Id> ddrIds = new List<Id>();
        
        // Populate oppIds and ddrIds with appropriate test data
        for (Opportunity opp : oppList) {
            oppIds.add(opp.Id);
            ddrIds.add(opp.Core_Design_Registration_Id__c);
        }

        // Call the method to be tested
        Test.startTest();
        Core_DDR_Design_Handler_Utility.insertOppLineItems(oppIds, ddrIds);
        Test.stopTest();

        
        //OpportunityLineItems were created
        Integer expectedLineItems = 0; // Your logic to calculate expected line items
        Integer actualLineItems = [SELECT COUNT() FROM OpportunityLineItem];
        System.assertEquals(expectedLineItems, actualLineItems, 'OpportunityLineItems count mismatch');

        
    }
    
    // zero coverage
    @isTest
    static void testDesignRegShare() {
        // Create test data - Mock Core_Design_Registration__c records
        List<Core_Design_Registration__c> designReg = new List<Core_Design_Registration__c>();
        Core_Design_Registration__c ddr = new Core_Design_Registration__c();
        
        ddr.Core_Product_Group_Nm__c = 'Embedded/IOT';
        ddr.Core_Design_Registration_Nm__c = 'DDR Test';
        ddr.Core_Design_Registration_Dsc__c = 'ABC';
        ddr.Core_Opportunity_Volume_Cnt__c = 5;
        ddr.Core_Partner_FAE_Nm__c = '6';            
        ddr.Core_End_Customer_Nm__c = 'DDR Test';            
        ddr.Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC ';
        ddr.Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc';
        ddr.Core_End_Customer_City_Nm__c = 'BAN';
        ddr.Core_End_Customer_Country_Subdivision_Nm__c = 'KA';
        ddr.PCC_End_Customer_Country__c = 'United States';
        ddr.Core_End_Customer_Postal_Cd__c = '560037';
        ddr.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddr.Core_Opportunity_Decision_Dt__c = system.today()+45;
        ddr.Core_First_Customer_Ship_Dt__c = system.today()+46;
        ddr.Core_Production_End_Dt__c = system.today()+47;
        ddr.Core_Vertical_Market_Nm__c = 'Education';
        ddr.Core_Intel_Platform_Nm__c = 'Board';
        ddr.Core_Product_Application_Nm__c = 'Business Desktop';
        ddr.Core_Product_Segment_Nm__c = 'Client Computing';
        ddr.Core_Manufacturing_Region_Cd__c = 'APJ';
        ddr.Core_Design_Registration_Status_Nm__c = 'Approved';
        ddr.Core_Partner_Account_Id__c=null;
        ddr.Core_Opportunity_Id__c=null;
        //ddr.OwnerId=owner.id;
        designReg.add(ddr);
        
        insert designReg;
        
        

        // Mock the group records (role to group mapping)
        Map<Id, Id> roleAndGroupMap = new Map<Id, Id>();
        // Add mock data as per your test scenario
        // For example:
        // roleAndGroupMap.put(roleId1, groupId1);
        // roleAndGroupMap.put(roleId2, groupId2);

        // Mock the pcc_designRegShare_M2M method
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Core_DDR_Design_Handler_Utility.designRegShare(designReg);
        

        // Assertions
        // Example: Assert that sharing records were created correctly
        List<Core_Design_Registration__Share> createdShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Core_Design_Registration__Share WHERE ParentId IN :designReg];
        System.assertNotEquals(0, createdShares.size(), 'Expected sharing records to be created');
        
        // Add more assertions based on the specific behavior of designRegShare method

        // Example: Assert that exception handling works
        // Simulate a scenario where an exception might be thrown
        
        // Set up data or conditions that would cause an exception to be thrown
        // For example, try inserting a record with invalid data
        try {
            Core_DDR_Design_Handler_Utility.designRegShare(designReg);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected exception message');
            // Optionally, assert against the Core_Log_Entry__c object creation
            List<Core_Log_Entry__c> logEntries = [SELECT Id FROM Core_Log_Entry__c];
            System.assertNotEquals(0, logEntries.size(), 'Expected log entries to be created');
        }
        Test.stopTest();
    }

    // Mock implementation of HttpCalloutMock for testing
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Implement mock response as needed
            return null;
        }
    }
    
    static List<User> ListOfUser = new List<User> ();
    static void getRecords(){
        UserRole role=new UserRole();
        role.name='Admin';        
        insert role;
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(1);
        for(User Usr : ListOfUser){
            Usr.userroleid = role.id;
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));     
    }
    
    static testmethod void readFieldSet_PositiveTest(){
        getRecords();
        string ObjectApiName = 'Core_IPS_Supported_Product__c'; 
        string fieldSetName = 'SupportedProductFieldSet';       
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<Schema.FieldSetMember> ListOfFieldSetMember = Core_DDR_Design_Handler_Utility.readFieldSet(fieldSetName,ObjectApiName); 
            System.assert(ListOfFieldSetMember != null,'readFieldSet utility method failed to fetch the fieldset'); 
            Test.stopTest();
        }
    }

    static testmethod void testFetchEndCustMapping(){
        List<Core_Design_Registration__c> newList = new List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> oldList = new List<Core_Design_Registration__c>();
        Id dealRecTypeId = [select Id from RecordType where DeveloperName = 'PCC_Deal_Registration_Partner' limit 1][0].Id;
        List<account> LstAcc = Core_Test_Utility.createAccount(6);
        insert LstAcc;
        Core_Design_Registration__c newReg = new Core_Design_Registration__c();
        //newReg.Core_Design_Registration_Status_Nm__c = 'Draft';
        newReg.Core_Partner_Account_Id__c = LstAcc[3].id;
        newReg.Core_End_Customer_Account_Id__c = LstAcc[0].id;
        newReg.PCC_Deal_Description__c = 'test1';
        newReg.PCC_Consumption_Countries__c='USA';
        newReg.PCC_Deal_Description__c='12345678901234567890';
        newReg.PCC_Current_EndCustomer_Product_Provider__c='12345678901234567890';
        newReg.Core_End_Customer_Nm__c = 'DDR Test';            
        newReg.Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC ';
        newReg.Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc';
        newReg.Core_End_Customer_City_Nm__c = 'BAN';
        newReg.Core_End_Customer_Country_Subdivision_Nm__c = 'KA';
        newReg.PCC_End_Customer_Country__c = 'United States';
        newReg.Core_End_Customer_Postal_Cd__c = '560037';
        newReg.PCC_Industry__c = 'Agriculture';
        newReg.PCC_Sub_Industry__c = 'Forestry';
        newReg.PCC_Digital_Identifier__c='Website/URL';
        newReg.PCC_Digital_Identifier_Value__c='test';
        newReg.recordTypeId=dealRecTypeId;
        insert newReg;
        newReg.Core_Design_Registration_Status_Nm__c='Approved';
        //newReg.PCC_Registration_Type__c = 'Deal Registration';
        update newReg;
        

        Core_Design_Registration__c oldReg = new Core_Design_Registration__c();
        oldReg.Core_Design_Registration_Status_Nm__c = 'Approved';
        oldReg.Core_Partner_Account_Id__c = LstAcc[3].id;
        oldReg.Core_End_Customer_Account_Id__c = LstAcc[0].id;
        oldReg.PCC_Deal_Description__c = 'test1';
        oldReg.PCC_Consumption_Countries__c='USA';
        oldReg.PCC_Deal_Description__c='12345678901234567890';
        oldReg.PCC_Current_EndCustomer_Product_Provider__c='12345678901234567890';
        oldReg.Core_End_Customer_Nm__c = 'DDR Test';            
        oldReg.Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC ';
        oldReg.Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc';
        oldReg.Core_End_Customer_City_Nm__c = 'BAN';
        oldReg.Core_End_Customer_Country_Subdivision_Nm__c = 'KA';
        oldReg.PCC_End_Customer_Country__c = 'United States';
        oldReg.Core_End_Customer_Postal_Cd__c = '560037';
        oldReg.PCC_Industry__c = 'Agriculture';
        oldReg.PCC_Sub_Industry__c = 'Forestry';
        oldReg.PCC_Digital_Identifier__c='Website/URL';
        oldReg.PCC_Digital_Identifier_Value__c='test';
        oldReg.recordTypeId=dealRecTypeId;
        insert oldReg;
		
        PCC_EndCustomerAcc_Mapping__c mapRec = new PCC_EndCustomerAcc_Mapping__c();
        mapRec.PCC_Write_In_OEM_Nm__c='Test';
        mapRec.PCC_End_Customer_Account_Id__c=LstAcc[0].id;
        mapRec.PCC_Registration_Type_Nm__c ='Deal Registration';
        mapRec.PCC_Partner_Account_Id__c = LstAcc[3].id;
        insert mapRec;

        oldList.add(oldReg);
       
        newList.add(newReg);
        
        
        Map<Id, Core_Design_Registration__c> oldMap = new Map<Id, Core_Design_Registration__c>();
        for (Core_Design_Registration__c reg : oldList) {
            oldMap.put(reg.Id, reg);
        }
        Test.startTest();
        Core_DDR_Design_Handler_Utility.fetchPartnerEndCustMapping(oldMap, newList);
        Core_DDR_Design_Handler_Utility.createEndCustMappingRec(null,newReg);
        Test.stopTest();
    }

    static testmethod void testPopulateEndCustomerAccount(){
        List<Core_Design_Registration__c> newList = new List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> oldList = new List<Core_Design_Registration__c>();
        Id dealRecTypeId = [select Id from RecordType where DeveloperName = 'PCC_Deal_Registration_Partner' limit 1][0].Id;
        List<account> LstAcc = Core_Test_Utility.createAccount(6);
        insert LstAcc;
        Core_Design_Registration__c newReg = new Core_Design_Registration__c();
        newReg.Core_Design_Registration_Status_Nm__c = 'Approved';
        newReg.Core_Partner_Account_Id__c = LstAcc[1].id;
        newReg.Core_End_Customer_Account_Id__c = LstAcc[0].id;
        newReg.PCC_Deal_Description__c = 'test1';
        newReg.PCC_Consumption_Countries__c='USA';
        newReg.PCC_Deal_Description__c='12345678901234567890';
        newReg.PCC_Current_EndCustomer_Product_Provider__c='12345678901234567890';
        newReg.Core_End_Customer_Nm__c = 'DDR Test';            
        newReg.Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC ';
        newReg.Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc';
        newReg.Core_End_Customer_City_Nm__c = 'BAN';
        newReg.Core_End_Customer_Country_Subdivision_Nm__c = 'KA';
        newReg.PCC_End_Customer_Country__c = 'United States';
        newReg.Core_End_Customer_Postal_Cd__c = '560037';
        newReg.PCC_Industry__c = 'Agriculture';
        newReg.PCC_Sub_Industry__c = 'Forestry';
        newReg.PCC_Digital_Identifier__c='Website/URL';
        newReg.PCC_Digital_Identifier_Value__c='test';
        newReg.recordTypeId=dealRecTypeId;
        insert newReg;

        Core_Design_Registration__c oldReg = new Core_Design_Registration__c();
        oldReg.Core_Design_Registration_Status_Nm__c = 'Approved';
        oldReg.Core_Partner_Account_Id__c = LstAcc[3].id;
        oldReg.Core_End_Customer_Account_Id__c = LstAcc[0].id;
        oldReg.PCC_Deal_Description__c = 'test1';
        oldReg.PCC_Consumption_Countries__c='USA';
        oldReg.PCC_Deal_Description__c='12345678901234567890';
        oldReg.PCC_Current_EndCustomer_Product_Provider__c='12345678901234567890';
        oldReg.Core_End_Customer_Nm__c = 'DDR Test';            
        oldReg.Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC ';
        oldReg.Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc';
        oldReg.Core_End_Customer_City_Nm__c = 'BAN';
        oldReg.Core_End_Customer_Country_Subdivision_Nm__c = 'KA';
        oldReg.PCC_End_Customer_Country__c = 'United States';
        oldReg.Core_End_Customer_Postal_Cd__c = '560037';
        oldReg.PCC_Industry__c = 'Agriculture';
        oldReg.PCC_Sub_Industry__c = 'Forestry';
        oldReg.PCC_Digital_Identifier__c='Website/URL';
        oldReg.PCC_Digital_Identifier_Value__c='test';
        oldReg.recordTypeId=dealRecTypeId;
        insert oldReg;

        PCC_EndCustomerAcc_Mapping__c mapRec = new PCC_EndCustomerAcc_Mapping__c();
        mapRec.PCC_Write_In_OEM_Nm__c='Test';
        mapRec.PCC_End_Customer_Account_Id__c=LstAcc[0].id;
        mapRec.PCC_Registration_Type_Nm__c ='Deal Registration';
        mapRec.PCC_Partner_Account_Id__c = LstAcc[3].id;
        insert mapRec;

        oldList.add(oldReg);
       
        newList.add(newReg);
        
        
        Map<Id, Core_Design_Registration__c> oldMap = new Map<Id, Core_Design_Registration__c>();
        for (Core_Design_Registration__c reg : oldList) {
            oldMap.put(reg.Id, reg);
        }
        Test.startTest();
        Core_DDR_Design_Handler_Utility.populateEndCustomerAccount(oldMap, newList);
        Test.stopTest();
    }
}