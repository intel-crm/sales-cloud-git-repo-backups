/****************************************************************************************************
Apex Class Name : Core_Batch_DDR_PriceBook_Add_Test
Version         : 1.0 
Created Date    : 01/19/2018
Function        : This Scheduler class is used to schedule the batch apex 'Core_Batch_DDR_PriceBook_Add'
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajadinakaran             01/19/2018             Created
*****************************************************************************************************/
@isTest(seeAllData = false)
public class Core_Batch_DDR_PriceBook_Add_Test
{
    public static testmethod void PartnerPriceBook_Test1() 
    {
        List<Pricebook2> lstPriceBook = new List<Pricebook2>();
        
        
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
        product1.Core_Design_Registration_Eligible_Ind__c = TRUE;
        product1.Core_Sales_Visible_Flag__c = TRUE;
        product1.Core_Partner_Visible_Ind__c  = TRUE;
        lstProduct.add(product1);
        
        //Product2 price book entry create scenario
        Product2 product2 = new Product2();
        product2.Name = 'Intel® Core™ i3-4020M Processor (3M Cache, 2.60 GHz)';
        product2.IsActive = TRUE;
        product2.Core_Design_Registration_Eligible_Ind__c = TRUE;
        product2.Core_Sales_Visible_Flag__c = TRUE;
        product2.Core_Partner_Visible_Ind__c  = TRUE;
        lstProduct.add(product2);

        insert lstProduct;
        
        List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry>();
        
        /*******Partner price book entry update scenario ********/
        PricebookEntry PriceBookEntry1 = new PricebookEntry();
        PriceBookEntry1.Pricebook2Id =  Test.getStandardPricebookId();
        PriceBookEntry1.Product2Id = lstProduct[0].id;
        PriceBookEntry1.IsActive = true;
        PriceBookEntry1.UnitPrice = 100;
        
        lstPriceBookEntry.add(PriceBookEntry1);
        
        PricebookEntry PriceBookEntry2 = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
        {
            if(iPB.Name == 'Standard Price Book')
            {
                PriceBookEntry2.Pricebook2Id =  iPB.Id;
            }
        }
        PriceBookEntry2.Product2Id = lstProduct[0].id;
        PriceBookEntry2.IsActive = true;
        PriceBookEntry2.UnitPrice = 100;
        PriceBookEntry2.UseStandardPrice = true;    
            
        lstPriceBookEntry.add(PriceBookEntry2);
        
        PricebookEntry PriceBookEntry3 = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
        {
            if(iPB.Name == 'Partner Price Book')
            {
                PriceBookEntry3.Pricebook2Id =  iPB.ID;
            }
        }
        PriceBookEntry3.Product2Id = lstProduct[0].id;
        PriceBookEntry3.IsActive = false;
        PriceBookEntry3.UnitPrice = 100;
        
        lstPriceBookEntry.add(PriceBookEntry3);      

        /*******Partner price book entry update scenario - Close ********/
        
        /*******Partner price book entry create scenario ********/

        PricebookEntry PriceBookEntry4 = new PricebookEntry();
        PriceBookEntry4.Pricebook2Id =  Test.getStandardPricebookId();
        PriceBookEntry4.Product2Id = lstProduct[1].id;
        PriceBookEntry4.IsActive = true;
        PriceBookEntry4.UnitPrice = 100;
            
        lstPriceBookEntry.add(PriceBookEntry4);         
        
        PricebookEntry PriceBookEntry5 = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
        {
            if(iPB.Name == 'Standard Price Book')
            {
                PriceBookEntry5.Pricebook2Id =  iPB.Id;
            }
        }
        PriceBookEntry5.Product2Id = lstProduct[1].id;
        PriceBookEntry5.IsActive = true;
        PriceBookEntry5.UnitPrice = 100;
        PriceBookEntry5.UseStandardPrice = true;    
            
        lstPriceBookEntry.add(PriceBookEntry5);          
        
        /*******Partner price book entry create scenario - Close ********/
        
        /*******Partner price book entry deactivate scenario - Close********/
      
                
        insert lstPriceBookEntry;
        
        Core_Design_Registration_Product_List__c DRPL = new Core_Design_Registration_Product_List__c(Core_Active_Ind__c = true, Core_Design_Product_Id__c = lstProduct[0].id);
        insert DRPL;
        
        Test.StartTest();
        Core_Batch_DDR_PriceBook_Add objPartnerPB1 = new Core_Batch_DDR_PriceBook_Add();  
        Database.executeBatch(objPartnerPB1); 
        
        Core_Batch_DDR_PriceBook_Add_Scheduler.SchedulerMethod();  
        Test.StopTest();
    }     
   
}