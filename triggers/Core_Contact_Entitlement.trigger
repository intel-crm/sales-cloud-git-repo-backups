/******************************************************************************************************************************************
Trigger Name: Core_Contact_Entitlement
Version     : 1.0 
Created Date: 03 NOV 2016
Function    : Trigger for the object Core_Contact_Entitlement__c.
NOTE: this is using the new trigger framework agreed upon in the technical governance meetings,
which is why it may look a little different than other triggers.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Zay Montalbo              11/03/2016              Original version
* Saif Alam                 9/20/2018            Added trigger handler for new framework
* Sankarshana               11/08/2021           Added trigger handler for new framework
* Gaurav Kurwade            11/11/2021           Added Trigger Handler for New framework
*****************************************************************************************************************************************/
trigger Core_Contact_Entitlement on Core_Contact_Entitlement__c (before insert,after update,after insert, before update, before delete) {
    
    //Added by Draco
     new Core_Contact_Entitlement_Handler().run(); 
    if(Trigger.isBefore)
    {
       //updateCEStatusChangeDateTime();
    }
     public static void updateCEStatusChangeDateTime()
    {
            for(Core_Contact_Entitlement__c ConEnt : Trigger.new){

            if(ConEnt.Core_Status__c != Trigger.OldMap.Get(ConEnt.Id).Core_Status__c){

                 ConEnt.Core_Status_Change_Date_Time__c = system.now();

            }

          }
    }
    
    
    // Added by Saif to incorporate new Trigger framework
    
    //Needed for US- TWC722-50 Added By Gaurav to updating related Contact Buisness Type on basis of Contact_Entitlement  
    new Core_Contact_EntitlementTriggerHandler().run();    

}