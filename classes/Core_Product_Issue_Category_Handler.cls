/***************************************************************************************************
    Class Name : Core_Product_Issue_Category_Handler
    Version     : 1.0 
    Created Date: 24 Nov 2015
    Function    : This Class is a Handler class for trigger Core_Product_Issue_Category on Core_IPS_Product_Issue_Category__c object
    Input Parameters: NA
    Output Parameters: NA
    Description:   NA
    Used in     : User in trigger Dispatcher class Core_Product_Issue_Category_Dispatcher
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Vaibhav Dubey              11/11/2015              Created
    ****************************************************************************************************/       

public class Core_Product_Issue_Category_Handler
{    
    /***************************************************************************************************
    Method Name:  Core_Product_Issue_CategoryUpdate
    Method Type: Handler Method for Trigger Dispatcher of Object Core_IPS_Product_Issue_Category__c 
    Version     : 1.0 
    Created Date: 24 Nov 2015
    Function    : This method is used Update the child object Core_Product_Issue_Category__c subcategory record on Update parent case category record
    Input Parameters: trigger.new records in a List and Trigger.oldMap records in a Map
    Output Parameters: NA
    Description:   This method takes a list of Core_Product_Issue_Category__c records whose status field is changed and Update the child object Core_IPS_Assigned_Environment_Variables__c and Core_Product_Issue_Category__c  subcategory
    record status field value accordingly as per parent object status value.
    Used in     : User in trigger Dispatcher class Core_Product_Issue_Category_Dispatcher
    Number of Queries Within this Method: 1
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Vaibhav Dubey              24/11/2015              Created
    ****************************************************************************************************/       

    
    public static void Core_Product_Issue_CategoryUpdate(Map<Id,Core_IPS_Product_Issue_Category__c> oldMap,List<Core_IPS_Product_Issue_Category__c> newList)
    {
        Map<ID,String> CPIC_IDMap = new Map<ID,String>();
        for(Core_IPS_Product_Issue_Category__c nw : newList)
        {           
            if(nw.Core_Status__c != oldMap.get(nw.id).Core_Status__c && nw.Core_Status__c == 'Inactive')
            {
                CPIC_IDMap.put(nw.id,nw.Core_Status__c);                
            }
        }
        
        Map<ID,Core_IPS_Product_Issue_Category__c> CPICMap = new Map<ID,Core_IPS_Product_Issue_Category__c>([select id,Core_Status__c,Core_Product_Issue_Category__c from Core_IPS_Product_Issue_Category__c where Core_Product_Issue_Category__c in :CPIC_IDMap.keyset() order by Core_Product_Issue_Category__c]);
        Map<ID,Core_IPS_Assigned_Environment_Variables__c> CAEVMap = new Map<ID,Core_IPS_Assigned_Environment_Variables__c>([select id,Core_Status__c,Core_Product_Issue_Sub_Category__c from Core_IPS_Assigned_Environment_Variables__c where Core_Product_Issue_Sub_Category__c in :CPICMap.keyset() order by Core_Product_Issue_Sub_Category__c]);
        
        if(CPICMap.size() > 0)
        {
            for(ID CPIC_ID : CPICMap.keyset())
            {                
                CPICMap.get(CPIC_ID).Core_Status__c = CPIC_IDMap.get(CPICMap.get(CPIC_ID).Core_Product_Issue_Category__c);                
            }
            update CPICMap.values();
        }        
        if(CAEVMap.size() > 0)
        {
            for(ID CAEV_ID : CAEVMap.keyset())
            {
                CAEVMap.get(CAEV_ID).Core_Status__c = 'Inactive';
            }
            update CAEVMap.values();
        }
    }
}