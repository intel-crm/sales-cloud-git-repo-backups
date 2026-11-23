/****************************************************************************************************
Apex Class Name : Core_Batch_DDR_PriceBook_Del_Test
Version         : 1.0 
Created Date    : 01/19/2018
Function        : This Scheduler class is used to schedule the batch apex 'Core_Batch_DDR_PriceBook_Del'
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajadinakaran             01/19/2018               Created
*****************************************************************************************************/
@isTest(seeAllData = false)
public class Core_Batch_DDR_PriceBook_Del_Test
{
    public static testmethod void PartnerPriceBook_Test1() 
    {
        List<Pricebook2> lstPriceBook = new List<Pricebook2>();
        //testing
        
        Pricebook2 pb1 = new Pricebook2();
        pb1.name = 'Standard Price Book';
        pb1.isActive = TRUE;
        
        lstPriceBook.add(pb1);
        
        Pricebook2 pb2 = new Pricebook2();
        pb2.name = 'Partner Price Book';
        pb2.isActive = TRUE;
        
        lstPriceBook.add(pb2); 
        
        insert lstPriceBook;  
        
        List<Product2> lstProduct = new List<Product2>();
        
        //Product1 price book entry update scenario
        Product2 product1 = new Product2();
        product1.Name = 'Intel Atom® CE4275 Media Processor';
        product1.IsActive = TRUE;
        product1.Core_Design_Registration_Eligible_Ind__c = FALSE;
        product1.Core_Sales_Visible_Flag__c = TRUE;
        product1.Core_Partner_Visible_Ind__c  = FALSE;
        lstProduct.add(product1);
        
        insert lstProduct;
        
        List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry>();
        
        /*******Partner price book entry deactivate scenario ********/
        
        PricebookEntry PriceBookEntry6 = new PricebookEntry();
        PriceBookEntry6.Pricebook2Id =  Test.getStandardPricebookId();
        PriceBookEntry6.Product2Id = lstProduct[0].id;
        PriceBookEntry6.IsActive = true;
        PriceBookEntry6.UnitPrice = 100;
            
        lstPriceBookEntry.add(PriceBookEntry6);         
        
        PricebookEntry PriceBookEntry7 = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
        {
            if(iPB.Name == 'Standard Price Book')
            {
                PriceBookEntry7.Pricebook2Id =  iPB.Id;
            }
        }
        PriceBookEntry7.Product2Id = lstProduct[0].id;
        PriceBookEntry7.IsActive = true;
        PriceBookEntry7.UnitPrice = 100;
        PriceBookEntry7.UseStandardPrice = true;    
            
        lstPriceBookEntry.add(PriceBookEntry7); 
        
        PricebookEntry PriceBookEntry8 = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
        {
            if(iPB.Name == 'Partner Price Book')
            {
                PriceBookEntry8.Pricebook2Id =  iPB.Id;
            }
        }
        PriceBookEntry8.Product2Id = lstProduct[0].id;
        PriceBookEntry8.IsActive = true;
        PriceBookEntry8.UnitPrice = 100;
        PriceBookEntry8.UseStandardPrice = true;    
            
        lstPriceBookEntry.add(PriceBookEntry8);        
        
        /*******Partner price book entry deactivate scenario - Close********/
        
                
        insert lstPriceBookEntry;
        Core_Design_Registration_Product_List__c DRPL = new Core_Design_Registration_Product_List__c(Core_Active_Ind__c = true, Core_Design_Product_Id__c = lstProduct[0].id);
        insert DRPL;
        
        Test.StartTest();
        Core_Batch_DDR_PriceBook_Del objPartnerPB1 = new Core_Batch_DDR_PriceBook_Del();  
        Database.executeBatch(objPartnerPB1); 
        
       // Core_Batch_DDR_PriceBook_Del_Scheduler.SchedulerMethod();  
        Test.StopTest();
    }     
   
}