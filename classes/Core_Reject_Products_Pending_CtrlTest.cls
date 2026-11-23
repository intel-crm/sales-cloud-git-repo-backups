/*-------------------------------------------------------------------------------------------
Apex Class  : Core_Reject_Products_Pending_CtrlTest
Version     : 1.0 
Created Date: 19 JUNE 2018
Function    : Test class for Core_Reject_Products_Pending_Ctrl apex class.
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            11/06/2018              Original Version
-------------------------------------------------------------------------------------------*/

@isTest
public class Core_Reject_Products_Pending_CtrlTest {
    public static List<Core_Design_Registration__c> DDRLst = new List<Core_Design_Registration__c>();
    public static List<Core_Design_Registration_Product__c> DRPLst = new List<Core_Design_Registration_Product__c>();
    public static List<Product2> ProdLst = new List<Product2>();
    
    static void setup(){
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'GMP India Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'GMP India Sales Group';
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        DDRLst = Core_DDR_Utility.createDDR(1);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        DRPLst = Core_DDR_Utility.CreateDRProduct(4, DDRLst, ProdLst);
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
    }

    static testMethod void rejectProductsPendingTest(){
        setup();
        Test.startTest();
        List<Core_Design_Registration_Product__c> DRPLst1 = Core_DDR_Utility.CreateDRProduct(2, DDRLst, ProdLst);
        insert DRPLst1;
        PageReference pageRef = Page.Core_Reject_Products_Pending;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DDRLst);
        pageRef.getParameters().put('id',DDRLst[0].Id);
        Core_Reject_Products_Pending_Ctrl ext = new Core_Reject_Products_Pending_Ctrl(stdSetController);
        ext.rejectProductsPending();
        Test.stopTest();
    }
}