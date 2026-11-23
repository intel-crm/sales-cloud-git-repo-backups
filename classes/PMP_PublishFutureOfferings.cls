/*************************************************************************************************************************************************************************
* Class Name  : PMP_PublishFutureOfferings 
* Version     : 1.0 
* Created Date: 06/28/2019
* Modification Log :
*
* Developer         Modification Log                Date                               Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Manasa              M-01    : Original version     06/28/2019                    Batch class for all the future  published offerings
**************************************************************************************************************************************************************************/
global class PMP_PublishFutureOfferings implements Database.Batchable<sObject> {
    //Start - Method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Store today's date in a variable
        Date todayDate = Date.today();
                
        String query = PMP_Utility.queryAllFields('PMP_Partner_Offering__c',true);
        
        //WHERE clause - which retrieves the offerings having status = Approved & start date = today and with/without pre-release items 
        query = query + ' where PMP_Partner_Offering_Lifecycle_Status_Nm__c=\'Approved\' and PMP_Partner_Offering_Start_Dt__c =:todayDate'
            +' and PMP_Pre_Release_Item_Count_Num__c=0 and PMP_Is_Notified_Ind__c=false';
       
        System.debug('query--->'+Database.getQueryLocator(query));
              
        return Database.getQueryLocator(query);
    }
    //Exceute - Method
    global void execute(Database.BatchableContext BC,List<PMP_Partner_Offering__c> offObjList) {
        System.debug('offObjList-->'+offObjList);
        System.debug('offObjList-size->'+offObjList.size());
        //Initialise variables
        List<PMP_Partner_Offering__c> updateOfferingList = new List<PMP_Partner_Offering__c>();
        List<PMP_Partner_Offering__c> newOfferingList = new List<PMP_Partner_Offering__c>();
        //try - block
        try{
            //Iterating on the list of offerings - which we got from the SOQL
            for(PMP_Partner_Offering__c offObj : offObjList){ 
                //When is published = false, status = approved
                //New offering - create scenario
                if(offObj.PMP_Is_Published_Ind__c == false && offObj.PMP_Partner_Offering_Lifecycle_Status_Nm__c == PMP_StaticConstants_Offering.APPROVED){
                    //adding the new offerings in newOfferingList
                    newOfferingList.add(offObj);
                }
                //When is published = true, status = approved
                //Update offering - Edit scenario
                else if(offObj.PMP_Is_Published_Ind__c == true && offObj.PMP_Partner_Offering_Lifecycle_Status_Nm__c == PMP_StaticConstants_Offering.APPROVED){
                    //adding the edit offering in updateOfferingList
                    updateOfferingList.add(offObj);
                }      
            }
            System.debug('newOfferingList-->'+newOfferingList);
            System.debug('updateOfferingList-->'+updateOfferingList);
            //if the new offering list is not empty
            if(newOfferingList.size()>0){
                        //Call PMP_OfferingInsertUpdate.afterupdate() - method to create a new published version of the approved offering(Working copy)
                        PMP_OfferingTriggerHelper.createPublishedOfferings(newOfferingList);
                        //PMP_OfferingInsertUpdate.afterUpdate(newOfferingList);
                } 
            //if the update offering list is not empty 
            if(updateOfferingList.size()>0){
                        //Call PMP_OfferingInsertUpdate.afterupdate() - method to update already created published version of the approed offering(Working copy)
                        PMP_OfferingTriggerHelper.createPublishedOfferings(updateOfferingList);
                        //PMP_OfferingInsertUpdate.afterUpdate(updateOfferingList);
                }
                
            
        }
        //Catch - block
        catch(Exception e){
            System.debug('Error occured from batch class due to '+e.getMessage()+''+e.getlinenumber());
            //Throw exception if any
            throw e;
        }
    }
    //Finish - Method
     global void finish(Database.BatchableContext BC) {   
            //Get the job Id 
            Id job= bc.getJobId();
            System.debug(job);
        
    }    
}