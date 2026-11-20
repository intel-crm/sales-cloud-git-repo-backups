/***************************************************************************************************
    Class Name : Core_Environment_Variables_Handler
    Version     : 1.0 
    Created Date: 11 Nov 2015
    Function    : This Class is a Handler class for trigger Core_Environment_Variables on Core_Environment_Variables__c object
    Input Parameters: NA
    Output Parameters: NA
    Description:   NA
    Used in     : User in trigger Dispatcher class Core_Environment_Variables_Dispatcher
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Vaibhav Dubey              11/11/2015              Created
    ****************************************************************************************************/       

public class Core_Environment_Variables_Handler
{    
    /***************************************************************************************************
    Method Name:  Core_Environment_VariableUpdate
    Method Type: Handler Method for Trigger Dispatcher of Object Core_Environment_Variables__c
    Version     : 1.0 
    Created Date: 11 Nov 2015
    Function    : This method is used Update the child object Core_Assigned_Environment_Variables__c record on Update parent object Core_Environment_Variables__c record
    Input Parameters: trigger.new records in a List and Trigger.oldMap records in a Map
    Output Parameters: NA
    Description:   This method takes a list of Core_Environment_Variables__c records whose status field is changed and Update the child object Core_Assigned_Environment_Variables__c 
    record status field value accordingly as per parent object status value.
    Used in     : User in trigger Dispatcher class Core_Environment_Variables_Dispatcher
    Number of Queries Within this Method: 1
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Vaibhav Dubey              11/11/2015              Created
    ****************************************************************************************************/       

    
    public static void Core_Environment_VariableUpdate(Map<Id,Core_IPS_Environment_Variables__c> oldMap,List<Core_IPS_Environment_Variables__c> newList)
    {
        Map<ID,String> CEV_IDMap = new Map<ID,String>();
        for(Core_IPS_Environment_Variables__c nw : newList)
        {           
            if(nw.Core_Status__c != oldMap.get(nw.id).Core_Status__c && nw.Core_Status__c == 'Inactive')
            {
                CEV_IDMap.put(nw.id,nw.Core_Status__c);                
            }
        }
        
        Map<ID,Core_IPS_Assigned_Environment_Variables__c> CAEVMap = new Map<ID,Core_IPS_Assigned_Environment_Variables__c>([select id,Core_Status__c,Core_Environment_Variable__c from Core_IPS_Assigned_Environment_Variables__c where Core_Environment_Variable__c in :CEV_IDMap.keyset() order by Core_Environment_Variable__c]);
        if(CAEVMap.size() > 0)
        {
            for(ID CAEV_ID : CAEVMap.keyset())
            {                
                CAEVMap.get(CAEV_ID).Core_Status__c = CEV_IDMap.get(CAEVMap.get(CAEV_ID).Core_Environment_Variable__c);                
            }
            update CAEVMap.values();
        }        
    }
}