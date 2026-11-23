/*********************************************
* Name : Core_IPS_New_Backend_System_Handler 
* Author : Sai Krishna 
* Description : This class handles the Core_IPS_New_Backend_System trigger to prevent from  infinite loop
* Test Class : Core_IPS_BES_IPassDataSync_Test
*   
************************************************/


public class Core_IPS_BES_IPASSTriggerHandler {
  private static boolean run = true;
  public static Core_IPS_Backend_Field_Map__c fmap;  
  public static Boolean show{get;set;}
    public Core_IPS_BES_IPASSTriggerHandler(ApexPages.StandardController controller){
        List<Core_IPS_Backend_Value_Map__c> vmap;
        if(Core_IPS_Backend_Value_Map__c.SObjectType.getDescribe().isAccessible()){
        vmap = [Select Id, Backend_Field_Mapping_HSD__c, Core_IPS_Source_Value__c, Core_IPS_Target_Value__c From Core_IPS_Backend_Value_Map__c Where Id =: ApexPages.currentPage().getParameters().get('id') LIMIT 1 ];
        }
        if(vmap.size()>0){ 
         fmap = [Select Id, Core_IPS_New_Backend_System__r.isDataSync__c,Core_IPS_Source_Field__c, Core_IPS_Target_Field__c, Core_IPS_Deactivated__c From Core_IPS_Backend_Field_Map__c Where Id =: vmap[0].Backend_Field_Mapping_HSD__c ];
        if(fmap.Core_IPS_New_Backend_System__r.isDataSync__c == true){
            show = true;
        }
        else{
            show = false;
        }
        }
    }
    
    public Core_IPS_BES_IPASSTriggerHandler(){
     // TWC745-7109  - Avoid Using DML in Visual Force Pages Fix - START - SHIPRA
        updateNewBackEndSystem();
      // TWC745-7109  - Avoid Using DML in Visual Force Pages Fix - START - SHIPRA

        // Core_IPS_Backend_Field_Map__c fmap;
        // if(Core_IPS_Backend_Field_Map__c.SObjectType.getDescribe().isAccessible()){
        // fmap = [Select Id, Core_IPS_New_Backend_System__r.isDataSync__c,Core_IPS_Source_Field__c, Core_IPS_Target_Field__c, Core_IPS_Deactivated__c From Core_IPS_Backend_Field_Map__c WHERE Core_IPS_Source_Field__c ='subject'  LIMIT 1];
        // }
        // if(fmap.Core_IPS_New_Backend_System__r.isDataSync__c == true){
        //     show = true;
        // }
        // else{
        //     show = false;
        // }
        //  if (Schema.sObjectType.Core_IPS_Backend_Field_Map__c.fields.Core_IPS_Source_Field__c.isUpdateable()) {
        // 	fmap.Core_IPS_Source_Field__c = 'subject';
        //  }
        // if (Schema.sObjectType.Core_IPS_Backend_Field_Map__c.fields.Core_IPS_Target_Field__c.isUpdateable()) {
        // 	fmap.Core_IPS_Target_Field__c = 'title';
        // }
        // update fmap;
    }
    // TWC745-7109  - Avoid Using DML in Visual Force Pages Fix - START - SHIPRA
    public static void updateNewBackEndSystem () {
        Core_IPS_Backend_Field_Map__c fmap;
        if(Core_IPS_Backend_Field_Map__c.SObjectType.getDescribe().isAccessible()){
        fmap = [Select Id, Core_IPS_New_Backend_System__r.isDataSync__c,Core_IPS_Source_Field__c, Core_IPS_Target_Field__c, Core_IPS_Deactivated__c From Core_IPS_Backend_Field_Map__c WHERE Core_IPS_Source_Field__c ='subject'  LIMIT 1];
        }
        if(fmap.Core_IPS_New_Backend_System__r.isDataSync__c == true){
            show = true;
        }
        else{
            show = false;
        }
         if (Schema.sObjectType.Core_IPS_Backend_Field_Map__c.fields.Core_IPS_Source_Field__c.isUpdateable()) {
        	fmap.Core_IPS_Source_Field__c = 'subject';
         }
        if (Schema.sObjectType.Core_IPS_Backend_Field_Map__c.fields.Core_IPS_Target_Field__c.isUpdateable()) {
        	fmap.Core_IPS_Target_Field__c = 'title';
        }
        update fmap;
    }
        // TWC745-7109  - Avoid Using DML in Visual Force Pages Fix - END - SHIPRA

    public static boolean runOnce() {
        if(run) {
            run=false;
            return true;
        }
        else {
            return run;
        }
    }
}