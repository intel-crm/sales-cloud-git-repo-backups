/**************************************************************************************
Apex Class Name : Core_Mp_Public_Group_Creation_Batch
Version     : 1.0 
Created Date: 20th may, 2019
Description : Batch to create public group, Assignment of group members 
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Raushan                  20/05/2019               Original Version
*************************************************************************************/

global class PMP_Batch_Group_Management_Scheduler implements Database.Batchable<sObject>,Schedulable{
    
    global static Database.QueryLocator start(Database.BatchableContext context)
    {
        String Core_Entitlement_Id_Label = System.Label.PMP_External_Entitlement_Ids;
        List<Core_Entitlement__c> entitlementDetails = new List<Core_Entitlement__c>();
        List<String> lstEntitlementIds = Core_Entitlement_Id_Label.split(';');
       
        
        //When test is not running
        if(!Test.isRunningTest()){
            lstEntitlementIds = Core_Entitlement_Id_Label.split(';');
        }else{
            //Querying Entitlement Detail
            entitlementDetails = [Select Id, Name, Core_Display_Name__c from Core_Entitlement__c];
            for(Core_Entitlement__c coreEntitlement : entitlementDetails){
                lstEntitlementIds.add(coreEntitlement.Id);
            }
            System.debug('TestlstEntitlementIds ='+lstEntitlementIds);
        }
        
         List<Core_Contact_Entitlement__c> conEntList = [Select Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c, 
                                                        Core_Selected__c from Core_Contact_Entitlement__c
                                                        where Core_Status__c = 'Complete' AND Core_Selected__c = true 
                                                        AND Core_Entitlement_Id__c = :lstEntitlementIds];
        System.debug('conEntList ='+conEntList);
            
        
        
         return Database.getQueryLocator(
            'Select Core_Contact_Id__c, Core_Entitlement_Id__c '+
            ' FROM Core_Contact_Entitlement__c WHERE Core_Selected__c = true '+
            ' AND Core_Status__c = \'Complete\' '+
            ' AND Core_Entitlement_Id__c in :lstEntitlementIds');

    }
    global void execute(Database.BatchableContext context, List<Core_Contact_Entitlement__c> records){
        //System.debug('conEntList2 ='+conEntList);
        System.debug('records ='+records);
        PMP_Batch_Group_Management publicGroupCreationAndUserAssignment = new PMP_Batch_Group_Management();
        PMP_Batch_Group_Management.updatePublicGroupMembership();
        
              
    }
    global void finish(Database.BatchableContext context){
    List<Account> acc= [SELECT Id,Core_PMP_Membership_Change_Ind__c FROM Account WHERE  Core_PMP_Membership_Change_Ind__c=true]; 
        List<Account> accToUpdate = new List<Account>();
        for(Account a:acc)
        {
          if(a.Core_PMP_Membership_Change_Ind__c=true)
          {
           System.Debug('before update ='+a);
           a.Core_PMP_Membership_Change_Ind__c =false;
           System.Debug('after update ='+a);
           accToUpdate.add(a);
           }
           
         }
          update accToUpdate ; 
               
        
    }
    
    global void execute(SchedulableContext ctx) 
    {
         PMP_Batch_Group_Management_Scheduler schduleBatch = new PMP_Batch_Group_Management_Scheduler();
        database.executebatch(schduleBatch,100);
       
    }
    
}