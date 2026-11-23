/********************************************************************************************************************
    Class Name: Core_OpportunityLineBUShortName_Weekly 
    Version     : 1.0 
    Created Date: 15 Sept 2020
    Function    : Class to recalculate opportunity line item BU Short name and this batch class runs weekly
    *******************************************************************************************************************/
    
    global Class Core_OpportunityLineBUShortName_Weekly implements Database.Batchable<sObject>, Database.Stateful{
        public List<OpportunityLineItem> failedList= new List<OpportunityLineItem>();
        public Core_OppLineItem_Batch_Helper.WrapperHelper wrap;
        
        global Core_OpportunityLineBUShortName_Weekly(){
            wrap = Core_OppLineItem_Batch_Helper.prepareBuMappingTable();
        }
        
        /********************************************************************************************************************
        * Method name  : Start()- Batch class
        * Description  : Queries the all closed Opportunities and closed date before 2019 , update BU short name for those Opp line items
        * Return Type  : List of records.
        * Parameter    : Batch context
        *******************************************************************************************************************/     
        
        global Database.QueryLocator start(Database.BatchableContext BC){
            //Integer year = Date.today().year() - 1;
            //String PreviousYear =year+'-01-01';
			String StartDate= Date.today().year() - 3+'-01-01';
            String EndDate= Date.today().year() - 2+'-12-31';
			//TWC4767-465
            String query = 'SELECT Core_product2_division__c,Core_BU_Product_Segment__c,Core_BU_ShortName__c,Core_BU_Short_Name__c,Core_Division__c,Core_Product_Application__c,Core_Product_Segment__c,Core_Product_Type__c,Id,OpportunityId FROM OpportunityLineItem where  (Core_Product_Application__c != null OR Core_Product_Segment__c != null) AND Opportunity.StageName IN (\'Design Win\',\'Production Win\',\'Lost\',\'Cancelled\',\'Production Lost\',\'Production Cancelled\') AND Opportunity.CloseDate <='+EndDate+'AND Opportunity.CloseDate >='+StartDate; 
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
                    if(finalBuMap == null ){
                        failedList.add(oppLineItem);
                    }else{
                        oppLineItem.Core_BU_Mapping_record__c = finalBuMap.Id;
                    }
                }
                
                try{
                    Database.update(scope);
                }catch(Exception ex){
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
            if(failedList.size() >0 || Test.isRunningTest())
                Core_OpportunityLineItemHandler.Insert_logexception(failedList,label.Core_BU_ExceptionMsg);
        }
    }