/**************************************************************************************************
Apex Class Name:  Core_DDR_Accept_Approve_Reject_Test 
Version     : 1.0 
Created Date: 10 SEPT 2018
Function    :This is a test class for Core_DDR_Accept_Approve_Reject_Design
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------   
Sougata Sarkar         10/9/2018        Original Version
*****************************************************************************************************/

@isTest
public class Core_DDR_Accept_Approve_Reject_Test {
    
    public static List<Account> accountList; 
    
    @testSetup
    public static void prepareLogEntrySwitch(){
        List<Core_LogEntry_Switch__c> logEntSwitchList = new List<Core_LogEntry_Switch__c>();
        Core_LogEntry_Switch__c logEntSwitch = new Core_LogEntry_Switch__c();
        logEntSwitch.Name = 'Core_DDR_LogEntry_Check';
        logEntSwitch.Is_Selected__c = true;
        logEntSwitchList.add(logEntSwitch);
        logEntSwitch = new Core_LogEntry_Switch__c();
        logEntSwitch.Name = 'Core_LogEntry_Check';
        logEntSwitch.Is_Selected__c = true;
        logEntSwitchList.add(logEntSwitch);
        insert logEntSwitchList;
    }
    public static testmethod void DR_Product_test1() {
        //setupData();
        List<account> LstAcc = Core_Test_Utility.createAccount(6);
        for(Account acc : LstAcc){
            acc.Core_Sales_Groups__c = 'DCG Sales Group';
        }
        insert LstAcc;
        system.debug('########LstAcc '+LstAcc);
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();

        //List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();

        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;

        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;

        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);

        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(6);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;

        
        integer count=0;
        for(Core_Design_Registration__c Design: DDRLst){
            if(count==0){
                Design.Core_Design_Registration_Status_Nm__c='Approved';
            }
            if(count==3){
                Design.Core_Accepted_By_Id__c = Userinfo.getUserId(); 
                Design.Core_Partner_Account_Id__c=null;
            }else
            {
                
                Design.Core_Partner_Account_Id__c = LstAcc[1].id;
                
            }
            Design.Core_End_Customer_Account_Id__c = LstAcc[count].id;
            count++;  
        }
        update DDRLst;

        Test.startTest();
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id); 
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[3].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[3].Id); 
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[1].Id);
        Core_DDR_Accept_Approve_Reject_Design.updateDesignRegistration(DDRLst[0]);
        
        String ddrId = String.valueOf(DDRLst[0].Id);
        String ObjType = 'Core_Design_Registration__c';
        String fieldName = 'Core_Design_Registration_Status_Nm__c';
        System.runAs(Core_Test_Utility.systemAdminUser){
            Core_DDR_Accept_Approve_Reject_Design.getPicklistValues(ddrId,ObjType, fieldName);
        }
        Test.stopTest();     
    }
    
    public static testmethod void DR_Product_test2() {
         String IntelRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        List<account> LstAcc = Core_Test_Utility.createAccount(6);
        for(Account acc : LstAcc){
            acc.Core_Sales_Groups__c = 'DCG Sales Group';
            acc.RecordTypeId=IntelRecTypeId;
           // acc.Core_Covered_Account__c=true;
        }
        insert LstAcc;
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();

        //List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();

        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;

        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;

        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);

        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(6);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        DDRLst[1].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
                
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;

        integer count=0;

        for(Core_Design_Registration__c Design: DDRLst){
            if(count==0){
            Design.Core_Design_Registration_Status_Nm__c='Approved';
            }
            if(count==3){
             Design.Core_Partner_Account_Id__c=null;
            }else
            {
               
               Design.Core_Partner_Account_Id__c = LstAcc[1].id;
            
            }
            Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
          count++;  
        }        
        update DDRLst;
        
        String ddrId = String.valueOf(DDRLst[0].Id);
        String ObjType = 'Core_Design_Registration__c';
        String fieldName = 'Core_Design_Registration_Status_Nm__c';

        Test.startTest();
        System.runAs(Core_Test_Utility.systemAdminUser){
            Core_DDR_Accept_Approve_Reject_Design.getPicklistValues(ddrId,ObjType, fieldName);
        }
        
        DDRLst[0].Core_Design_Registration_Status_Nm__c = 'Rejected';
        update DDRLst[0];
        System.runAs(Core_Test_Utility.systemAdminUser){
            Core_DDR_Accept_Approve_Reject_Design.getPicklistValues(ddrId,ObjType, fieldName);
        }
                
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
            DRP.Core_Locked_Ind__c = False;
        }
        update DRPLst;
        
        DDRLst[0].Core_Design_Registration_Status_Nm__c = 'Approved';
        update DDRLst[0];
        System.runAs(Core_Test_Utility.systemAdminUser){
            Core_DDR_Accept_Approve_Reject_Design.getPicklistValues(ddrId,ObjType, fieldName);
        }
        List<Opportunity> listOppty  = new List<Opportunity>();
        listOppty = Core_Test_Utility.createOpportunity(2);
        listOppty[0].accountId = LstAcc[0].Id;
        listOppty[1].accountId = LstAcc[0].Id;
        insert listOppty;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
            DRP.Core_Locked_Ind__c = True;
        }
        update DRPLst;
        
        DDRLst[0].Core_Design_Registration_Status_Nm__c = 'Approved';
        DDRLst[0].Core_Opportunity_Id__c=listOppty[0].Id;
        update DDRLst[0];
        System.runAs(Core_Test_Utility.systemAdminUser){
            Core_DDR_Accept_Approve_Reject_Design.getPicklistValues(ddrId,ObjType, fieldName);
        }
        
        
        Test.stopTest();     
    }
    
    public static testmethod void DR_Product_test3() {
        //setupData();
        List<account> LstAcc = Core_Test_Utility.createAccount(5);
        for(Account acc : LstAcc){
            acc.Core_Sales_Groups__c = 'DCG Sales Group';
        }
        insert LstAcc;
        
        //Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true,Name='Partner Price Book');
        //update standardPricebook;
        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = 'Partner Price Book';
        pb2.IsActive = true;
        insert pb2;
        
        Core_Location_To_Approver_Group_Mapping__c locationToApproverGrp = new Core_Location_To_Approver_Group_Mapping__c(name = 'USA-OR', Core_Active_Ind__c = true, Core_Country_Cd__c = 'USA', Core_Approver_Group_Nm__c = 'Core_Design_Approver_USA_Oregon', Core_State_Cd__c = 'OR');
        insert locationToApproverGrp;
        
        List<Product2> products2 = Core_DDR_Utility.CreateProduct(5);
        insert products2;
        
        List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(1);
        insert TestDDRlst;
        
        List<Core_Design_Registration_Product__c> TestDDRProd = Core_DDR_Utility.CreateDRProduct(1, TestDDRlst, products2);
        
        List<Core_Design_Registration_Product__c> DRP_Update = new List<Core_Design_Registration_Product__c>();
        
        for(Core_Design_Registration_Product__c pupdate: TestDDRProd){
            pupdate.Core_Design_Product_Status_Nm__c = 'Approved';
            DRP_Update.add(pupdate);
        }
        insert DRP_Update;
        
        List<Core_Design_Registration__c> TestDDRupdate = new List<Core_Design_Registration__c>();
        
        for(Core_Design_Registration__c upDDR: TestDDRlst){
            upDDR.Core_Design_Registration_Status_Nm__c = 'Approved';
            upDDR.Core_Approver_Grp_Nm__c = Label.Core_DDR_DSN_Group_Name;
            upDDR.Core_Product_Segment_Nm__c = 'Embedded / IOT';
            upDDR.Core_Product_Application_Nm__c = 'Automotive';
            upDDR.Core_Partner_Account_Id__c = LstAcc[0].id;
            TestDDRupdate.add(upDDR);
        }
        update TestDDRupdate;
        
        List<Core_Design_Registration_Product__c> TestDDRProdReSubmit = Core_DDR_Utility.CreateDRProduct(1, TestDDRlst, products2);
        insert TestDDRProdReSubmit;
        Test.startTest();
        
        String ddrId = String.valueOf(TestDDRupdate[0].Id);
        String ObjType = 'Core_Design_Registration__c';
        String fieldName = 'Core_Design_Registration_Status_Nm__c';
        System.runAs(Core_Test_Utility.systemAdminUser){
            Core_DDR_Accept_Approve_Reject_Design.getPicklistValues(ddrId,ObjType, fieldName);
        }
        Test.stopTest();
    }
   
    public static testmethod void DR_Product_test4() {
        //setupData();
        List<account> LstAcc = Core_Test_Utility.createAccount(6);
        for(Account acc : LstAcc){
            acc.Core_Sales_Groups__c = 'DCG Sales Group';
        }
       // Id uncoveredUserId=[select id from user where name='Uncovered Account' limit 1].Id;
      //  lstAcc[2].OwnerId =uncoveredUserId;
        lstAcc[3].Core_Export_Compliance_Block__c =false;
        insert LstAcc;
        system.debug('LstAcc======>'+LstAcc[2]);
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();

        //List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();

        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;

        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;

        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);

        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(8);
        DDRLst[0].Core_Design_Registration_Status_Nm__c = 'Approved';
        DDRLst[0].Core_Approver_Grp_Nm__c = Label.Core_DDR_DSN_Group_Name;
        DDRLst[1].Core_Partner_Account_Id__c=null;
        DDRLst[2].Core_End_Customer_Account_Id__c=LstAcc[0].Id;
        DDRLst[3].Core_End_Customer_Account_Id__c=LstAcc[2].Id;
        DDRLst[4].Core_End_Customer_Account_Id__c=LstAcc[3].Id;
        DDRLst[5].Core_End_Customer_Account_Id__c=LstAcc[4].Id;
        DDRLst[6].Core_Partner_Account_Id__c=LstAcc[1].Id;
        insert DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst; 
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id); 
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[1].Id); 
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[2].Id); 
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[3].Id); 
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[4].Id);
         for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Rejected';
        }
        update DRPLst;        
        Test.startTest();
            Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id); 
            Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[1].Id); 
            Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[2].Id); 
            Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[3].Id); 
            Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[4].Id); 
            Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[5].Id); 
            Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[6].Id); 
        Test.stopTest();     
                
       } 
       
       
    public static testmethod void DR_Product_test5() {
        //setupData();
     Test.startTest();
        List<account> LstAcc = Core_Test_Utility.createAccount(6);
        for(Account acc : LstAcc){
            acc.Core_Sales_Groups__c = 'DCG Sales Group';
        }
       // Id uncoveredUserId=[select id from user where name='Uncovered Account' limit 1].Id;
       // LstAcc[0].OwnerId=uncoveredUserId;
        insert LstAcc;
        system.debug('LstAcc======>'+LstAcc[2]);
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();

        //List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();

        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(2);          
        insert DDRLST;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(2, DDRLst, ProdLst);
        DRPLst[0].Core_Locked_Ind__c=false;
        DRPLST[0].Core_Design_Product_Status_Nm__c='Pending';
        insert DRPLst;
        Id  DDRrollupId =[select id from Core_Design_Registration__c where id=:DDRLST[0].Id].Id;
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRrollupId); 

         Test.stopTest();      
        
    }
    
    public static testmethod void DR_Product_test6() {
        //setupData();
     Test.startTest();
        List<account> LstAcc = Core_Test_Utility.createAccount(3);
        for(Account acc : LstAcc){
            acc.Core_Sales_Groups__c = 'DCG Sales Group';
        }
        LstAcc[0].Core_Export_Compliance_Block__c=true; 
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        //List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
       
      
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Submitted';
           // Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
        }        
        update DDRLst;
        
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id);
        
        DDRLst[0].Core_End_Customer_Account_Id__c = LstAcc[2].id;
        update DDRLst;
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        for(Core_Design_Registration_Product__c drp : DRPLst){
            drp.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id);

         Test.stopTest();      
        
    } 
    
       public static testmethod void DR_Product_test7() {
        //setupData();
     Test.startTest();
        List<account> LstAcc = Core_Test_Utility.createAccount(3);
        for(Account acc : LstAcc){
            acc.Core_Sales_Groups__c = 'Undefined';
        }
        LstAcc[0].Core_Export_Compliance_Block__c=true; 
        // LstAcc[0].Core_Export_Compliance_Block__c=true;
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        //List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
           //ProdLst[0].IsActive=false;
           //update ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
         //DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
      
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Submitted';
           // Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
        }        
        update DDRLst;
        
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id);
        
       // DDRLst[0].Core_End_Customer_Account_Id__c = LstAcc[2].id;
        update DDRLst;
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        for(Core_Design_Registration_Product__c drp : DRPLst){
            drp.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id);

         Test.stopTest();      
        
    } 
    
    
    public static testmethod void DR_Product_test8() {
        //setupData();
     Test.startTest();
        List<account> LstAcc = Core_Test_Utility.createAccount(3);
        for(Account acc : LstAcc){
            acc.Core_Sales_Groups__c = 'Undefined';
            //acc.Core_Export_Compliance_Block__c=true;
        }
        LstAcc[0].Core_Export_Compliance_Block__c=true; 
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        //List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
      
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Submitted';
            //Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
        }        
        update DDRLst;
        
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id);
        
        DDRLst[0].Core_End_Customer_Account_Id__c = LstAcc[2].id;
        update DDRLst;
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        for(Core_Design_Registration_Product__c drp : DRPLst){
            drp.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);
        
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id);
        
         for(Account acc : LstAcc){
            //acc.Core_Sales_Groups__c = 'DCG Sales Group';
            acc.Core_Export_Compliance_Block__c=true;
        }
        update LstAcc;
                Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id);

         Test.stopTest();      
        
    } 
        
    public static testmethod void DR_Product_test9() {
        //setupData();
     Test.startTest();
        List<account> LstAcc = Core_Test_Utility.createAccount(3);
        for(Account acc : LstAcc){
            acc.Core_Sales_Groups__c = 'DCG Sales Group';
        }
        LstAcc[0].Core_Export_Compliance_Block__c=true; 
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        //List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
       
      
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Submitted';
           // Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
        }        
        update DDRLst;
        
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id);
        
        DDRLst[0].Core_End_Customer_Account_Id__c = LstAcc[2].id;
        update DDRLst;
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        for(Core_Design_Registration_Product__c drp : DRPLst){
            drp.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
         ProdLst[0].isActive=false;
        update ProdLst[0];
     
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id);

         Test.stopTest();      
        
    } 
        public static testmethod void DR_Product_test10() {
        //setupData();
     Test.startTest();
        List<account> LstAcc = Core_Test_Utility.createAccount(3);
        for(Account acc : LstAcc){
            acc.Core_Sales_Groups__c = 'DCG Sales Group';
        }
        LstAcc[0].Core_Export_Compliance_Block__c=true; 
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        //List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
       
      
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Submitted';
           // Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
        }        
        update DDRLst;
        
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id);
        
        DDRLst[0].Core_End_Customer_Account_Id__c = LstAcc[2].id;
        // DDRLst[0].Core_Vertical_Market_Nm__c = 'Test Inactive';
        update DDRLst;
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        for(Core_Design_Registration_Product__c drp : DRPLst){
            drp.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        //LstAcc[0].OwnerId=Label.Core_Uncovered_Account_ID;
        LstAcc[1].Core_Deactivated__c=true;
        LstAcc[1].Core_Deactivation_Reason__c='Duplicate Account';
      //  update LstAcc[0];
         update LstAcc[1];
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id);

         Test.stopTest();      
        
    }
    
    public static testmethod void DR_Product_test11() {
        //setupData();
     Test.startTest();
        List<account> LstAcc = Core_Test_Utility.createAccount(3);
        for(Account acc : LstAcc){
            acc.Core_Sales_Groups__c = 'DCG Sales Group';
        }
        LstAcc[0].Core_Export_Compliance_Block__c=true; 
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        //List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
       
      
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Submitted';
           // Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
        }        
        update DDRLst;
        
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id);
        
        DDRLst[0].Core_End_Customer_Account_Id__c = LstAcc[2].id;
        // DDRLst[0].Core_Vertical_Market_Nm__c = 'Test Inactive';
        update DDRLst;
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        for(Core_Design_Registration_Product__c drp : DRPLst){
            drp.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        //LstAcc[0].OwnerId=Label.Core_Uncovered_Account_ID;
        LstAcc[1].Core_Deactivated__c=true;
        LstAcc[1].Core_Deactivation_Reason__c='Duplicate Account';
      //  update LstAcc[0];
         update LstAcc[1];
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id);
        DDRLst[0].Core_Intel_Platform_Nm__c='Test12';
         DDRLst[0].Core_Vertical_Market_Nm__c='Test12';
         DDRLst[0].Core_Product_Segment_Nm__c='Test12';
         DDRLst[0].Core_Product_Application_Nm__c='Test12';
         Core_DDR_Accept_Approve_Reject_Design.ValidateInactiveLOVS(DDRLst[0]);

         Test.stopTest();      
        
    }
    
    // Test class to validate the Industry/Sub-Industry values
    public static testmethod void DR_Product_test12() {

        Test.startTest();
        
        List<account> LstAcc = Core_Test_Utility.createAccount(3);
        LstAcc[0].Core_Sales_Groups__c = 'DCG Sales Group';
        LstAcc[0].Industry = 'Education';
        LstAcc[0].Core_Sub_Industry__c = 'Student';
        
        LstAcc[1].Core_Sales_Groups__c = 'DCG Sales Group';
        LstAcc[1].Industry = 'To Be Defined';
        LstAcc[1].Core_Sub_Industry__c = 'To Be Defined';
        
        LstAcc[2].Core_Sales_Groups__c = 'DCG Sales Group';
        LstAcc[2].Industry = 'Education';
        LstAcc[2].Core_Sub_Industry__c = '';

        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
              
        DDRLst[0].Core_Partner_Account_Id__c = LstAcc[0].id;
        DDRLst[0].Core_End_Customer_Account_Id__c = LstAcc[1].id; 
        
        DDRLst[1].Core_Partner_Account_Id__c = LstAcc[0].id;
        DDRLst[1].Core_End_Customer_Account_Id__c = LstAcc[1].id; 

        DDRLst[2].Core_Partner_Account_Id__c = LstAcc[0].id;
        DDRLst[2].Core_End_Customer_Account_Id__c = LstAcc[2].id;               
        
        update DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c drp : DRPLst){
            drp.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[0].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[0].Id);
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[1].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[1].Id);
        Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign(DDRLst[2].Id);
        Core_DDR_Accept_Approve_Reject_Design.ApproveDesign(DDRLst[2].Id);

        Test.stopTest();             
    } 
}