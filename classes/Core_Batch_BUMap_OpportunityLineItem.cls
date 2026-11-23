/********************************************************************************************************************
    Class Name: Core_Batch_BUMap_OpportunityLineItem
    Version     : 1.0 
    Created Date: 10 May 2022
    Function    : Class to recalculate opportunity line item BU Short name 
    *******************************************************************************************************************/
global Class Core_Batch_BUMap_OpportunityLineItem implements Database.Batchable<sObject>,Database.Stateful {
    public List<OpportunityLineItem> failedList= new List<OpportunityLineItem>();
    public List<Core_BU_Mapping_Table__c> Bmt = new List<Core_BU_Mapping_Table__c>();   
    public Core_OppLineItem_Batch_Helper.WrapperHelper wrap;
    
    global Core_Batch_BUMap_OpportunityLineItem(){
          wrap = Core_OppLineItem_Batch_Helper.prepareBuMappingTable();
    }
    
    /********************************************************************************************************************
        * Method name  : Start()- Batch class
        * Description  : Query the Line Item with same combination of Product Segment,Division,Prod Type and Application as BU Mapping Table record.
        * Return Type  : List of records.
        * Parameter    : Batch context
    *******************************************************************************************************************/   
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        List<String> ProdSegment = new List<String>();
        List<String> ProdType = new List<String>();
        Bmt = [select id,Core_Product_Segment__c, Core_Product_Application__c, Core_LOB_Code__c, Core_Product_Type__c from Core_BU_Mapping_Table__c where Core_Processed__c = false];
        for(Core_BU_Mapping_Table__c bm: Bmt){
             
             ProdSegment.add(bm.Core_Product_Segment__c);
             ProdType.add(bm.Core_Product_Type__c);
        }
            //TWC4767-465 
       String query = 'select id,Core_Product_Segment__c, Core_Product2_LOB_Code__c, Core_Product_Type__c,  Core_Product_Application__c,Core_BU_Mapping_record__c from opportunitylineitem where Core_Product_Segment__c IN:ProdSegment AND Core_Product_Type__c IN:ProdType AND (Opportunity.StageName IN (\'Design\', \'Develop\', \'Define\', \'Qualify\') OR (Opportunity.StageName IN (\'Design Win\',\'Production Win\',\'Lost\',\'Cancelled\',\'Production Lost\',\'Production Cancelled\') AND Opportunity.Core_Pending_Products__c >0)) AND (Core_Product_Application__c != null OR Core_Product_Segment__c != null) ORDER BY Opportunity.AccountId';
       // String query = 'select id,Core_Product_Segment__c, Core_Product2_LOB_Code__c, Core_Product_Type__c,  Core_Product_Application__c,Core_BU_Mapping_record__c from opportunitylineitem where Opportunity.StageName IN (\'Design\', \'Develop\', \'Define\', \'Qualify\') OR ( Opportunity.StageName IN (\'Design Win\',\'Production Win\',\'Lost\',\'Cancelled\',\'Production Lost\',\'Production Cancelled\') AND Opportunity.Core_Pending_Products__c >0)  AND Core_Product_Segment__c IN:ProdSegment AND Core_Product_Type__c IN:ProdType ORDER BY Opportunity.AccountId';
        //System.debug('query:::'+query);
        return Database.getQueryLocator(query);
    }
    
    /********************************************************************************************************************
    * Method name  : execute()- Batch class
    * Description  : Process the records to update BU Shortname Opty line items
    * Return Type  : VOID
    * Parameter    : Batch context and Scope
    *******************************************************************************************************************/   
    
    global void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope){
        Core_BU_Mapping_Table__c finalBuMap;
        if(!wrap.extKeyWithBuMap.isEmpty()){
            for(OpportunityLineItem oppLineItem : scope){
                finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppLineItem, wrap);
                if(finalBuMap == null){
                    failedList.add(oppLineItem);
                }else{
                    oppLineItem.Core_BU_Mapping_record__c = finalBuMap.Id;
                }
            }
            
            try{
                Database.update(scope,false);
            }catch(Exception ex){
                //System.debug('Exception occured:'+ex.getMessage());
                Core_OpportunityLineItemHandler.Insert_logexception(scope,ex.getmessage()); 
            }
        }
        
     }
    
    /********************************************************************************************************************
    Method Name  : finish
    Version      : 1.0 
    Created Date : 31/7/2017
    Function     : This Method used to create a BU Mapping  calculation failed records in Exception object and updating the field on BU Table Field.
    *******************************************************************************************************************/
    
    global void finish(Database.BatchableContext BC){
        List<Core_BU_Mapping_Table__c> bmList = new List<Core_BU_Mapping_Table__c>();
        if(failedList.size() >0){
            Core_OpportunityLineItemHandler.Insert_logexception(failedList,label.Core_BU_ExceptionMsg);
        }
        for(Core_BU_Mapping_Table__c bm: Bmt){
            Core_BU_Mapping_Table__c bmObj = new Core_BU_Mapping_Table__c();
            bmObj.id = bm.id;
            bmObj.Core_Processed__c = true;
            bmList.add(bmObj);
        }
        Database.update(bmList,false);
     
     }
}