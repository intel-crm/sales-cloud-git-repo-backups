/***************************************************************************************************
Class Name:  Core_Environment_Variables_Test
Class Type:  Test Class
Version     : 1.0 
Created Date: 22 Jan 2016
Function    : This class does Test Coverage for Core_Environment_Variables_Handler,Core_Environment_Variables_Dispatcher 
              classes and Core_Environment_Variables Trigger.
Description :   This class does Test Coverage for Core_Environment_Variables_Handler,Core_Environment_Variables_Dispatcher 
               classes and Core_Environment_Variables Trigger.
Positive    : Case Creation
Negative    :
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              01/22/2015              Created
****************************************************************************************************/   
@isTest()
Public class Core_Environment_Variables_Test
{    
    public static List<Core_IPS_Environment_Variables__c> CEVList{get;set;}
    public static List<Core_IPS_Assigned_Environment_Variables__c> CAEVList{get;set;}
    
    /***************************************************************************************************
    Method Name  :  init()
    Method Type  :  Data Initiatialization
    Version      :  1.0 
    Description  :  Common Test data used for all test methods
    Scenario Type:  None
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T            01/22/2016                 Created
    ****************************************************************************************************/
    static public void init()
    {
        integer count=0,j=0;
        Core_IPS_Product_Organization__c cpo = TestUtilities.getSupportOrg();
        insert cpo;
        
        CEVList = TestUtilities.getListOfEnDetailMaster(5);
        for(Core_IPS_Environment_Variables__c cev : CEVList)
        {
            cev.Core_Product_Organization__c = cpo.id;        
            if(count<3)cev.Core_Status__c = 'Active';    
            count++;        
        }
        if(CEVList.size() > 0) insert CEVList;
        
        count = 0;
        
        CAEVList = TestUtilities.getListOfEnvDetailsOperational(15);
        for(integer i=0;i < CAEVList.size();i++)
        {            
            CAEVList[i].Core_Environment_Variable__c = CEVList[j].id;
            CAEVList[i].Core_Status__c = CEVList[j].Core_Status__c;   
            count++;          
            if(count>2)
            {
                j++;
                count=0;
            }              
        }
        if(CAEVList.size() > 0) insert CAEVList;     
    }        
    
    /***************************************************************************************************
    Method Name:  checkIfAssignedEnvInactivated
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 22 Jan 2016
    Description:  This method checks 
                    When Environmental Detail Master is made inactive, the associated Environment Detail Operational is also made inactive.
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash       12/27/2015                Created
    ****************************************************************************************************/
    static testMethod void checkIfAssignedEnvInactivated()
    {
        init();        
        for(Core_IPS_Environment_Variables__c cev:cevlist){
            cev.Core_Status__c = 'Inactive';
        }
        update cevlist;
        //CAEVList[0].Core_Status__c = 'Active';
        
        List<Core_IPS_Assigned_Environment_Variables__c> aevList = [select id, core_status__c from Core_IPS_Assigned_Environment_Variables__c where Core_Environment_Variable__c in :cevList];
        Test.startTest();
        for(Core_IPS_Assigned_Environment_Variables__c caev : aevList)
        {
            System.assertEquals(caev.core_status__c,'Inactive');           
        }
        Test.stopTest();
        //Update CEVList;        
    }
    
    /***************************************************************************************************
    Method Name:  checkIfAssignedEnvNotInactivated
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 22 Jan 2016
    Description:  This method checks 
                    When Environmental Detail Master is not made inactive, the associated Environment Detail Operational is also not made inactive.
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash       12/27/2015                Created
    ****************************************************************************************************/
    static testMethod void checkIfAssignedEnvNotInactivated()
    {
        init();        
        //CAEVList[0].Core_Status__c = 'Active';
        
        List<Core_IPS_Assigned_Environment_Variables__c> aevList = [select id, core_status__c from Core_IPS_Assigned_Environment_Variables__c where Core_Environment_Variable__c in :cevList];
        Test.startTest();
        for(Core_IPS_Assigned_Environment_Variables__c caev : aevList)
        {
            System.assertEquals(caev.core_status__c,'Active');           
        }
        Test.stopTest();
        //Update CEVList;        
    }
}