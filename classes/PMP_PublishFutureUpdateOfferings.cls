/*************************************************************************************************************************************************************************
* Class Name  : PMP_PublishFutureUpdateOfferings 
* Version     : 1.0 
* Created Date: 09/14/2020 
* Modification Log :
*
* Developer         Modification Log                Date                               Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Gireesh              M-01    : Original version                       Batch class for all the future published offerings on update 
https://intel--crmdevipa.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
  Yashasvi Aggarwal                                 14/10/2021          Batch class to publish and republish offerings
**************************************************************************************************************************************************************************/
//IPA2.0 - As part of TWC729-7977 commented the entire class & added dummy syntax to override error
global with sharing class PMP_PublishFutureUpdateOfferings{
	public static Boolean isWorking() {
        return true;
    }

 /*implements Database.Batchable<sObject>,Database.AllowsCallouts {
    
    //Start - Method
   /* global Database.QueryLocator start(Database.BatchableContext BC) {
        //Store today's date in a variable
        Date todayDate = Date.today();
                
        String query = PMP_Utility.queryAllFields('PMP_Partner_Offering__c',true);
        
        //WHERE clause - which retrieves the offerings having status = Approved & start date = today and with/without pre-release items 
        query = query + ' where PMP_Partner_Offering_Lifecycle_Status_Nm__c=\'Approved\' and PMP_Partner_Offering_Start_Dt__c =:todayDate'
            +' and PMP_Pre_Release_Item_Count_Num__c=0 and PMP_Is_Notified_Ind__c=false';
       
        //System.debug('query--->'+Database.getQueryLocator(query));
              
        return Database.getQueryLocator(query);
    }
    //Exceute - Method
    global void execute(Database.BatchableContext BC,List<PMP_Partner_Offering__c> offObjList) {
        // System.debug('offObjList-->'+offObjList);
        // System.debug('offObjList-size->'+offObjList.size());
        //Initialise variables
        List<PMP_Partner_Offering__c> updateOfferingList = new List<PMP_Partner_Offering__c>();
        //try - block
        try{
            //Iterating on the list of offerings - which we got from the SOQL
            for(PMP_Partner_Offering__c offObj : offObjList){ 
                    //adding the offering in updateOfferingList
                    updateOfferingList.add(offObj);
            }
           
             //System.debug('updateOfferingList-->'+updateOfferingList);
     
             //if the update offering list is not empty 
            if(updateOfferingList.size()>0){
                        PMP_OfferingTriggerHelper.updateOfferings(updateOfferingList);
                }       
        }
        //Catch - block
        catch(Exception e){
            //System.debug('Error occured from batch class due to '+e.getMessage()+''+e.getlinenumber());
            //Throw exception if any
            throw e;
        }
    }
    //Finish - Method
     global void finish(Database.BatchableContext BC) {   
            //Get the job Id 
            //Id job= bc.getJobId();
            // System.debug(job);
        
    }  */  
}