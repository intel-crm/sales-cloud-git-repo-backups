/********************************************************************************************************************
    Class Name: Core_OpportunityLineItem_Daily
    Version     : 1.0 
    Created Date: 15 Sept 2020
    Function    : Class to recalculate opportunity line item BU Short name and this batch class runs Daily
    *******************************************************************************************************************/
global Class Core_OpportunityLineItem_Daily implements Database.Batchable<sObject> {
      public List<OpportunityLineItem> failedList= new List<OpportunityLineItem>();
      public Core_OppLineItem_Batch_Helper.WrapperHelper wrap;
    global Core_OpportunityLineItem_Daily(){
          wrap = Core_OppLineItem_Batch_Helper.prepareBuMappingTable();
    }
    
     /********************************************************************************************************************
        * Method name  : Start()- Batch class
        * Description  : Query the Open Opportunities and closed Opportunities which is having the pending products and updates the BU Short name
        * Return Type  : List of records.
        * Parameter    : Batch context
        *******************************************************************************************************************/   
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Core_product2_division__c,Core_BU_Product_Segment__c,Core_BU_ShortName__c,Core_BU_Short_Name__c,Core_Division__c,Core_Product_Application__c,Core_Product_Segment__c,Core_Product_Type__c,Id,OpportunityId FROM OpportunityLineItem where Opportunity.StageName IN (\'Design\', \'Develop\', \'Define\', \'Qualify\') OR ( Opportunity.StageName IN (\'Design Win\',\'Production Win\',\'Lost\',\'Cancelled\',\'Production Lost\',\'Production Cancelled\') AND Opportunity.Core_Pending_Products__c >0 )';
        //String prodId = '00k2i000004A4iYAAS';
        //String query = 'SELECT Core_product2_division__c,Core_BU_Product_Segment__c,Core_BU_ShortName__c,Core_BU_Short_Name__c,Core_Division__c,Core_Product_Application__c,Core_Product_Segment__c,Core_Product_Type__c,Id,OpportunityId FROM OpportunityLineItem where Id =: prodId';
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
                    Database.update(scope);
                }catch(Exception ex){
                   // System.debug('Exception occured:'+ex.getMessage()); //TWC3123-5359-Commented debug statement.
                    Core_OpportunityLineItemHandler.Insert_logexception(scope,ex.getmessage()); 
                }
            }
         
     }
    
     /********************************************************************************************************************
        Method Name  : finish
        Version      : 1.0 
        Created Date : 31/7/2017
        Function     : This Method used to create a BU Mapping  calculation failed records in Exception object
        *******************************************************************************************************************/
     global void finish(Database.BatchableContext BC){
          if(failedList.size() >0)
                Core_OpportunityLineItemHandler.Insert_logexception(failedList,label.Core_BU_ExceptionMsg);
     
     }
}