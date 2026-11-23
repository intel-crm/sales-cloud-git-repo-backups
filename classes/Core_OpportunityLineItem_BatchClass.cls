/**************************************************************************************
Apex Class Name:  Core_OpportunityLineItem_BatchClass
Version     : 1.0 
Created Date: 22 June 2017
Function    : Class to recalculate opportunity line item BU Short name and this batch class runs at every 8 hours
Modification Log :
* Developer           Date                    Description
* ---------------------------------------------------------------------------- 
* Rajesh Kumar        04/04/2018              US102413-Removed Filter Condition 'Write In product' in the Query.
* Rajesh Kumar        07/02/2018              US93858-Added logic for Update BU mapping logic to enter and continue to update the BU data on opportunities and products that are lost and cancelled).                                                     
* Rajesh kumar        01/08/2017              Insert BU calculation failed record in exception object.             
* Ajay DS             22/06/2017              Original Version 
*/
global class Core_OpportunityLineItem_BatchClass implements Database.Batchable<sObject>, Database.Stateful{   
    public List<OpportunityLineItem> failedList= new List<OpportunityLineItem>();
    public Core_OppLineItem_Batch_Helper.WrapperHelper wrap;
    
    global Core_OpportunityLineItem_BatchClass(){
        wrap = Core_OppLineItem_Batch_Helper.prepareBuMappingTable();
    }
    
    /*
	* Method name  : Start()- Batch class
	* Description  : Queries the values from BU Mapping table and Opty line item to process
	* Return Type  : List of records.
	* Parameter    : Batch context
	*/    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Core_BU_Mapping_record__c,Core_product2_division__c,Core_BU_Product_Segment__c,Core_BU_ShortName__c,Core_BU_Short_Name__c,Core_Division__c,Core_Product_Application__c,Core_Product_Segment__c,Core_Product_Type__c,Id,OpportunityId FROM OpportunityLineItem where Core_Status__c IN (\'Pending\', \'Design Win\', \'Deleted\', \'On Hold\', \'Production Win\', \'Approved\', \'Win Submitted\', \'Win Approved\')';
        return Database.getQueryLocator(query);
    }    
    /*
	* Method name  : execute()- Batch class
	* Description  : Process the records to update BU Shortname Opty line items
	* Return Type  : VOID
	* Parameter    : Batch context and Scope
	*/  
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
                //System.debug('Exception occured:'+ex.getMessage());
                PMP_Utility.logError(ex, 'Core_OpportunityLineItem_BatchClass.execute');
                Core_OpportunityLineItemHandler.Insert_logexception(scope,ex.getmessage()); 
            }
        }
    }  
    
    /********************************************************************************************************************
	Method Name  :  Insert_logexception
	Version      : 1.0 
	Created Date : 31/7/2017
	Function     : This Method used to create a BU Mapping  calculation failed records in Exception object
	* Developer                   Date                   Description
	* ----------------------------------------------------------------------------
	* Rajesh                     06/27/2017            Added for code BU information has not been calculated since crietria has not match with BU mapping table.

	*******************************************************************************************************************/   
    global void finish(Database.BatchableContext BC){   
        if(failedList.size() >0)
            Core_OpportunityLineItemHandler.Insert_logexception(failedList,label.Core_BU_ExceptionMsg);
    }
}