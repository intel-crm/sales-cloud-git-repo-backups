/****************************************************************************************************
Apex Class Name : Core_Batch_DDR_PriceBook_Del
Version         : 1.0 
Created Date    : 01/10/2018
Function        : This batch apex is used update the partner price entries with the recent price of products
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajadinakaran              01/10/2018            Created
*****************************************************************************************************/
global Class Core_Batch_DDR_PriceBook_Del implements Database.Batchable<sObject>
{
    //To get the log switch details 
    public static Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
    public static String PARTNER_PRICE_BOOK_NAME = 'Partner Price Book';
    public static String STANDARD_PRICE_BOOK_NAME = 'Standard Price Book';
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id, Name, Core_Product_Series__c, Core_Design_Registration_Eligible_Ind__c, Core_Partner_Visible_Ind__c FROM Product2 '+
                        'WHERE IsActive = true AND Core_Sales_Visible_Flag__c = true '+
                        'AND (Core_Design_Registration_Eligible_Ind__c = FALSE AND Core_Partner_Visible_Ind__c = FALSE) '+
                        'AND Id IN (SELECT Product2Id FROM PricebookEntry WHERE IsActive = true AND Pricebook2.Name = \''+STANDARD_PRICE_BOOK_NAME+'\')'+
                        'AND Id IN (SELECT Product2Id FROM PricebookEntry WHERE IsActive = true AND Pricebook2.Name = \''+PARTNER_PRICE_BOOK_NAME+'\')';
    
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Product2> lstProduct2)
    {
        try
        {
            Set<Id> setPricebookId = new Set<Id>();
            Set<Id> setProductId = new Set<Id>();

            List<Pricebook2> lstPriceBook2 = new List<Pricebook2>();
            List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
            List<Core_Design_Registration_Product_List__c> lstDesignProdList = new List<Core_Design_Registration_Product_List__c>();
            
            List<PricebookEntry> lstUpdatePricebookEntry = new List<PricebookEntry>();
            List<Core_Design_Registration_Product_List__c> lstUpdateDesignProdList = new List<Core_Design_Registration_Product_List__c>();
            
            lstPriceBook2 = [SELECT Id, Name FROM Pricebook2];
            
            for(Product2 iProduct2 : lstProduct2)
            {
                setProductId.add(iProduct2.Id);
            }
            
            for(Pricebook2 iPriceBook2 : lstPriceBook2)
            {
                if(iPriceBook2.Name == 'Partner Price Book')
                {
                    setPricebookId.add(iPriceBook2.Id);
                }
            }
            
            //Query all standard & partner price book entries
            lstPricebookEntry = [SELECT Id, Product2Id, Pricebook2Id, UnitPrice, isActive FROM PricebookEntry WHERE Product2.Id IN: setProductId AND Pricebook2Id IN: setPricebookId];
            lstDesignProdList = [SELECT Id, Name, Core_Active_Ind__c,Core_Design_Product_Id__c FROM Core_Design_Registration_Product_List__c WHERE Core_Design_Product_Id__c IN: setProductId];           
            for(PricebookEntry iPBE : lstPricebookEntry)
            {
                //Inactive the existing partner price book entry when the product doesnt available for partner
                PricebookEntry tempPriceBookEntry = new PricebookEntry();
                tempPriceBookEntry.isActive = FALSE;
                tempPriceBookEntry.Id = iPBE.Id;
                
                lstUpdatePricebookEntry.add(tempPriceBookEntry);
            }
             
            //Inactivate design product list 
            for(Core_Design_Registration_Product_List__c  iDesignProdList : lstDesignProdList)
            {
                Core_Design_Registration_Product_List__c tempDesignProdList = new Core_Design_Registration_Product_List__c();
            
                tempDesignProdList.Id = iDesignProdList.Id;
                tempDesignProdList.Core_Active_Ind__c = FALSE;
                lstUpdateDesignProdList.add(tempDesignProdList);   
            }
            
            if(lstUpdatePricebookEntry.size() > 0)
            {
                update lstUpdatePricebookEntry;   
            }
            
            if(lstUpdateDesignProdList.size() > 0)
            {
                update lstUpdateDesignProdList;
            }
        }
        catch(Exception err)
        {
            //System.debug('NotifyPatnerPriceBookBatchApex::'+err.getMessage());
            
            if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
            {   
                Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = 'Error:'+err.getMessage(),Core_Details__c = 'Line number: ' + err.getLineNumber()+', Stack trace: ' + err.getStackTraceString(), Core_Origin__c='Core_Batch_DDR_PriceBook_Del', Core_Severity__c='High', Core_When__c = System.Now(), Core_Project__c = 'DDR', Core_sObjectId__c = '');
                insert ExcepLog;
            }              
        }
        
    }   
     
    global void finish(Database.BatchableContext BC)
    {
        
    }
}