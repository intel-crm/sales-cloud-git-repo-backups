/****************************************************************************************************
Apex Class Name : Core_Batch_DDR_PriceBook_Test
Version         : 1.0 
Created Date    : 11/08/2017
Function        : This Scheduler class is used to schedule the batch apex 'Core_Batch_DDR_PriceBook'
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajadinakaran             11/08/2017             Created
*****************************************************************************************************/
@isTest(seeAllData = false)
public class Core_Batch_DDR_PriceBook_Test
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
        Set<Id> PricebookId1 = new Set<Id>();
        
        //Product1 price book entry update scenario
        Product2 product1 = new Product2();
        product1.Name = 'Intel Atom® CE4275 Media Processor';
        product1.IsActive = TRUE;
        product1.Core_Design_Registration_Eligible_Ind__c = TRUE;
        product1.Core_Sales_Visible_Flag__c = TRUE;
        product1.Core_Partner_Visible_Ind__c  = TRUE;
        lstProduct.add(product1);
        PricebookId1.add(product1.Id);
        
        //Product2 price book entry create scenario
        Product2 product2 = new Product2();
        product2.Name = 'Intel® Core™ i3-4020M Processor (3M Cache, 2.60 GHz)';
        product2.IsActive = TRUE;
        product2.Core_Design_Registration_Eligible_Ind__c = TRUE;
        product2.Core_Sales_Visible_Flag__c = TRUE;
        product2.Core_Partner_Visible_Ind__c  = TRUE;
        lstProduct.add(product2);
        PricebookId1.add(product2.Id);
        
        //Product 3 price book entry deactivate scenario
        Product2 product3 = new Product2();
        product3.Name = 'Intel® Core™ i3-6167U Processor (3M Cache, 2.70 GHz)';
        product2.IsActive = TRUE;
        product3.Core_Design_Registration_Eligible_Ind__c = TRUE;
        product3.Core_Sales_Visible_Flag__c = TRUE;
        product3.Core_Partner_Visible_Ind__c  = FALSE;
        lstProduct.add(product3);  
        PricebookId1.add(product3.Id);      
        
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
        PriceBookEntry3 = setPriceBookIdForPartnerPriceBook(lstPriceBook);
        PriceBookEntry3.Product2Id = lstProduct[0].id;
        PriceBookEntry3.IsActive = true;
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
        
        /*******Partner price book entry deactivate scenario ********/
        
        PricebookEntry PriceBookEntry6 = new PricebookEntry();
        PriceBookEntry6.Pricebook2Id =  Test.getStandardPricebookId();
        PriceBookEntry6.Product2Id = lstProduct[2].id;
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
        PriceBookEntry7.Product2Id = lstProduct[2].id;
        PriceBookEntry7.IsActive = true;
        PriceBookEntry7.UnitPrice = 100;
        PriceBookEntry7.UseStandardPrice = true;    
            
        lstPriceBookEntry.add(PriceBookEntry7); 
        
        PricebookEntry PriceBookEntry8 = new PricebookEntry();
        PriceBookEntry8 = setPriceBookIdForPartnerPriceBook(lstPriceBook);
        // for(Pricebook2 iPB : lstPriceBook)
        // {
        //     if(iPB.Name == 'Partner Price Book')
        //     {
        //         PriceBookEntry8.Pricebook2Id =  iPB.Id;
        //     }
        // }
        PriceBookEntry8.Product2Id = lstProduct[2].id;
        PriceBookEntry8.IsActive = true;
        PriceBookEntry8.UnitPrice = 100;
        PriceBookEntry8.UseStandardPrice = true;    
            
        lstPriceBookEntry.add(PriceBookEntry8);        
        
        /*******Partner price book entry deactivate scenario - Close********/
        
                
        insert lstPriceBookEntry;
        
        List<PricebookEntry> lstPricebookEntry1 = new List<PricebookEntry>();
        lstPricebookEntry1 = [SELECT Id, Product2Id, Pricebook2Id, UnitPrice, isActive FROM PricebookEntry WHERE Pricebook2Id IN: PricebookId1];
        //system.debug('ans:'+lstPricebookEntry1.size());
        system.assertequals(0,lstPricebookEntry1.size());
        
        
        Test.StartTest();
        Core_Batch_DDR_PriceBook objPartnerPB1 = new Core_Batch_DDR_PriceBook();  
        Database.executeBatch(objPartnerPB1); 
        
        Core_Batch_DDR_PriceBook_Scheduler.SchedulerMethod();  
        Test.StopTest();
    }
    
    public static PricebookEntry setPriceBookIdForPartnerPriceBook(List<Pricebook2> lstPriceBook){

        PricebookEntry PriceBookEntry = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
            {
            
                if(iPB.Name == 'Partner Price Book')
                {
                    PriceBookEntry.Pricebook2Id =  iPB.ID;
                }
            }

        return PriceBookEntry;
    }
   
}