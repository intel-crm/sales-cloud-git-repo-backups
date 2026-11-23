/****************************************************************************************************
Apex Class Name : PSG_ManagePriceBookController_Test
Version         : 1.0 
Created Date    : 26/02/2021
Function        : Test class for PSG_ManagePriceBookController.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijay                    26/02/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_ManagePriceBookController_Test {
    
    @testSetup
    public static void setUpData(){
        List<User> adminUserlst = PSG_Test_Utility.createAdminUser();
        Test.startTest();
        System.runAs(adminUserlst[0]){            
            PSG_Test_Utility.createPriceBook('APJTest');
            List<Product2> pdt =PSG_Test_Utility.createProduct(3);
            System.assertEquals(pdt[0].Name,'Test Product0');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testgetPriceList(){
        List<User> bmUserLst = PSG_Test_Utility.createBMUser();
        Test.StartTest();
        System.runAs(bmUserLst[0]){                
            PSG_ManagePricebookController.getPriceList();
            System.assert( PSG_ManagePricebookController.getPriceList()!=null,'Sucessfull getPriceList');
        }
        Test.StopTest();   
    }
    
    @isTest
    public static void testloadDataScenario(){
        List<User> bmUserLst = PSG_Test_Utility.createBMUser();
        list<Pricebook2> strPriceBookId = [SELECT Id from Pricebook2 limit 1];
        list<pricebookentry> strPriceBookEntryId = [SELECT Id FROM Pricebookentry limit 1];
        list<core_cpq_list_price__c> listPricelst = PSG_Test_Utility.createlistprice(3,strPriceBookEntryId[0].Id);
        Test.StartTest();
        System.runAs(bmUserLst[0]){
            PSG_ManagePricebookController.getPriceList();
            PSG_ManagePricebookController.getPriceBookEntries(strPriceBookId[0].Id,null);
            PSG_ManagePricebookController.getPriceBookEntries(strPriceBookId[0].Id,'1SG00');
            System.assert(PSG_ManagePricebookController.getPriceBookEntries(strPriceBookId[0].Id,'1SG00')!=null,'Successfull getPriceBookEntries');
            PSG_ManagePricebookController.getListPrice(strPriceBookId[0].Id,'1SG00',strPriceBookEntryId[0].Id);
        }
        Test.StopTest();  
    }
    @isTest
    public static void testUpdateScenario(){
        List<User> bmUserLst = PSG_Test_Utility.createBMUser();
        list<pricebookentry> strPriceBookEntryId = [SELECT Id FROM Pricebookentry limit 1];
        list<core_cpq_list_price__c> listPricelst = PSG_Test_Utility.createlistprice(3,strPriceBookEntryId[0].Id);
        Test.StartTest();
        System.runAs(bmUserLst[0]){   
            list<PSG_ManagePricebookController.pricebookEntriesWrapper> pbelst = new list<PSG_ManagePricebookController.pricebookEntriesWrapper>();
            PSG_ManagePricebookController.pricebookEntriesWrapper data = new PSG_ManagePricebookController.pricebookEntriesWrapper();
            data.Id = strPriceBookEntryId[0].Id;
            data.distyCost = 100;
            data.UnitPrice = 100;
            data.Speed = 100;
            data.minimumQty = 100;
            data.multipleQty = 100;
            pbelst.add(data);
            PSG_ManagePricebookController.updatePricebookentries(pbelst);
            System.assertEquals( data.distyCost,100);
            list<PSG_ManagePricebookController.listPriceWrapper> lplst = new list<PSG_ManagePricebookController.listPriceWrapper>();
            PSG_ManagePricebookController.listPriceWrapper lpData = new PSG_ManagePricebookController.listPriceWrapper();
            lpData.Id = listPricelst[0].id;
            lpData.Ubound = 100;
            lpData.Lbound = 100;
            lpData.UnitPrice = 100;
            lplst.add(lpData);
            PSG_ManagePricebookController.updateListPrices(lplst);
            System.assert(lpData!=null,'Successfully added'); 
        }
        Test.StopTest();   
    }
    
}