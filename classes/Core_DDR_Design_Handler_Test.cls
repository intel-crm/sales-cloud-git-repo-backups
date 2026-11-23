@isTest
public class Core_DDR_Design_Handler_Test{
       
     @future
    public static void insertUser() {
        Contact c=[Select id from Contact limit 1];
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Id DistiProid = [select id, name from profile where name LIKE '%portal%' limit 1].id;
       // Id IsrProid = [select id, name from profile where name='Sales Rep-BB'].id;
        User DistiUser = new User(alias = 'dis123', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='distestintel', languagelocalekey='en_US',
        localesidkey='en_US', profileid = DistiProid, IsActive =true,
        //contactId = c.Id,
        timezonesidkey='America/Los_Angeles', username='testerDistintel@Intelnoemail.com');
        insert DistiUser;
    }
    public static testmethod void DDR_Bulk(){
        
        Test.startTest();
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'GMP India Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'GMP India Sales Group';
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
            Design.Core_Design_Registration_Status_Nm__c = 'Approved';
        }        
        update DDRLst;
        
        Test.stopTest();
    }
    
    public static testMethod void DDR_OwnerChange(){
        Test.startTest();
                
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'GMP India Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'GMP India Sales Group';
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
       
        
        User IsrUser = new User(alias = 'test123', email='test1234@itp-intel.com',
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
        }*/
        
        List<Core_Design_Registration_Product__c> DRP_Update = [select id, Core_Design_Product_Status_Nm__c from Core_Design_Registration_Product__c limit 5000];
        
        for(Core_Design_Registration_Product__c pupdate: DRP_Update){
            pupdate.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRP_Update;
        
        List<Core_Design_Registration__c> TestDDRupdate = [select id from Core_Design_Registration__c limit 5000];
        
        for(Core_Design_Registration__c upDDR: TestDDRupdate){
            upDDR.Core_Design_Registration_Status_Nm__c = 'Approved';
            upDDR.Core_Approver_Grp_Nm__c = Label.Core_DDR_DSN_Group_Name;
            upDDR.Core_Product_Segment_Nm__c = 'Wireless & Connectivity';
            upDDR.Core_Product_Application_Nm__c = 'Automotive';
            upDDR.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            upDDR.Core_Intel_Technical_Owner_Id__c = UserInfo.getUserId();
        }
        
        update TestDDRupdate;
        
        
        
    }
    public static testmethod void DDR_BulkReject(){
        
        Test.startTest();
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'GMP India Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'GMP India Sales Group';
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
            DRP.Core_Design_Product_Status_Nm__c = 'Rejected';
        }
        update DRPLst;
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Rejected';
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
            Design.Core_Design_Registration_Status_Nm__c = 'Approved';
        }        
        update DDRLst;
        
        Test.stopTest();
    }
    public static testmethod void DDR_Handler_Export() {
        Test.startTest();
        List<account> LstAcc = Core_Test_Utility.createAccount(5);
        LstAcc[0].Core_Sales_Groups__c = 'GMP India Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'GMP India Sales Group';
        insert LstAcc;
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5);
        insert TestDDRlst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, TestDDRlst, ProdLst);
        insert DRPLst;
        
        List <Account> UpdateAccLst = Core_Test_Utility.Core_Account(5);
        for(account Acc: UpdateAccLst){
          //  acc.Core_Export_Compliance_Block__c = true;
        }
        insert UpdateAccLst;
        
        for(Core_Design_Registration__c DDR_hand: TestDDRlst){
            DDR_hand.Core_End_Customer_Account_Id__c = UpdateAccLst[0].id;
        }
        update TestDDRlst;
        
        for(Core_Design_Registration__c DDR_hand: TestDDRlst){
            DDR_hand.Core_End_Customer_Account_Id__c = LstAcc[0].id;
        }
        update TestDDRlst;
        
        Test.stopTest();
    }
}