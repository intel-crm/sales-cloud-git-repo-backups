/***************************************************************************************************
Class Name:  Core_IPS_Account_Trigger_Test
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
Public class Core_IPS_Account_Trigger_Test
{    
    public static List<Account> lstAccount{get;set;}
    public static list<Core_IPS_Labels__c> ipsLables{get;set;}
    //public static List<Core_IPS_Assigned_Environment_Variables__c> CAEVList{get;set;}
    
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
        lstAccount = Core_Test_utility.createAccount(1);  
         ipsLables = TestUtilities.getIPSLabel();
        insert ipsLables;
        insert lstAccount;
        
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
    static testMethod void testEntitlementCreation()
    {
        init();        
        for(Account acc:lstAccount){
            acc.Core_IPS_Active__c=true;
        }
        update lstAccount;
            
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
               
    }
}