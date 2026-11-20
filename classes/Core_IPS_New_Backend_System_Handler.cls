/*********************************************
* Name : Core_IPS_New_Backend_System_Handler 
* Author : Sai Krishna 
* Description : Handler class for BackendFieldMapTrigger, BackendValueMapTrigger, Core_IPS_New_Backend_System
* Test Class : Core_IPS_BES_IPassDataSync_Test
*   
************************************************/
public without sharing class Core_IPS_New_Backend_System_Handler {
    public static List<Core_IPS_Backend_Field_Map__c> fmap;
    public static Boolean show{get;set;}
    public Core_IPS_New_Backend_System_Handler(ApexPages.StandardController controller){
        if(Core_IPS_Backend_Field_Map__c.SObjectType.getDescribe().isAccessible()){
          fmap = [Select Id, Core_IPS_New_Backend_System__r.isDataSync__c,Core_IPS_Source_Field__c, Core_IPS_Target_Field__c, Core_IPS_Deactivated__c From Core_IPS_Backend_Field_Map__c Where Id =: ApexPages.currentPage().getParameters().get('id') LIMIT 1];
        }
            if(fmap.size()>0)  {
        if(fmap[0].Core_IPS_New_Backend_System__r.isDataSync__c == true){
            show = true;
        }
        else{
            show = false;
        }
        }
    }
/*************************************************
* Description : To update isDataSync__c field as true whenever update opertaion is performed on Core_IPS_Backend_System2__c object
* Author : Sai Krishna Emani
**************************************************/
  	public static Core_IPS_Backend_System2__c sys;
    public static void afterUpdate(List<Core_IPS_Backend_System2__c> bsys, Map<Id,Core_IPS_Backend_System2__c> oldmap){
        String dt;
        Core_IPS_Backend_System2__c bksys = bsys[0];
        if(Core_IPS_Backend_System2__c.SObjectType.getDescribe().isAccessible()){
            sys = [SELECT Id,Last_Sync__c, isDataSync__c, Core_IPS_Deactivated__c FROM Core_IPS_Backend_System2__c where Id =: bksys.Id ];
        }
            for(Core_IPS_Backend_System2__c o : oldmap.values()){
           dt = o.Last_Sync__c;
        }  
        if(dt == sys.Last_Sync__c){
            if (Schema.sObjectType.Core_IPS_Backend_System2__c.fields.isDataSync__c.isUpdateable()){
            	sys.isDataSync__c = true;
            }
        }
        else{
            sys.isDataSync__c = false;
        }    
        update sys;
    }
/*************************************************
* Description : To update isDataSync__c field as true whenever update opertaion is performed on Core_IPS_Backend_Field_Map__c object
* Author : Sai Krishna Emani
**************************************************/
    
    public static void afterFmapinsertupdatedelete(List<Core_IPS_Backend_Field_Map__c> fieldmap){
        Core_IPS_Backend_Field_Map__c feilds =  fieldmap[0];
        Core_IPS_Backend_System2__c fmap = [SELECT Id,Last_Sync__c, isDataSync__c, Core_IPS_Deactivated__c FROM Core_IPS_Backend_System2__c where Id =: feilds.Core_IPS_New_Backend_System__c ];
        if (Schema.sObjectType.Core_IPS_Backend_System2__c.fields.isDataSync__c.isUpdateable()){
        	fmap.isDataSync__c = true;
        }
        update fmap;
    }
/*************************************************
* Description : To update isDataSync__c field as true whenever update opertaion is performed on Core_IPS_Backend_Value_Map__c object
* Author : Sai Krishna Emani
**************************************************/
    public static Core_IPS_Backend_Field_Map__c vmap;
    public static void afterVmapinsertupdatedelete(List<Core_IPS_Backend_Value_Map__c> valuemap){
        Core_IPS_Backend_Value_Map__c values = valuemap[0];
        if(Core_IPS_Backend_Field_Map__c.SObjectType.getDescribe().isAccessible()){
             vmap = [SELECT Id,  Core_IPS_New_Backend_System__r.Id FROM Core_IPS_Backend_Field_Map__c where Id =: values.Backend_Field_Mapping_HSD__c  ];
        }
        Core_IPS_Backend_System2__c bksys = [SELECT Id,Last_Sync__c, isDataSync__c, Core_IPS_Deactivated__c FROM Core_IPS_Backend_System2__c where Id =: vmap.Core_IPS_New_Backend_System__c];
        if (Schema.sObjectType.Core_IPS_Backend_System2__c.fields.isDataSync__c.isUpdateable()){
        	bksys.isDataSync__c = true;
        }
        update bksys;
    }
}