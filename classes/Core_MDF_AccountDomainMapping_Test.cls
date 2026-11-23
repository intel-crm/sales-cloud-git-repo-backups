/****************************************************************************************************************************************
 * Class Name  : Core_MDF_AccountDomainMappingUtility
 * Version     : 1.0
 * Created Date: 29-Jan-2020
 * Modification Log :
 * Developer                 Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Accenture - vaishali              created to test account domain mapping functionality
 *****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private without sharing class Core_MDF_AccountDomainMapping_Test {

        /****************************************************************************************************************************************
Method Name:                                   
Description:                                   
Added By:                                      Accenture – VD  -  
Modified By:           Date:                    Changes: 
Accenture – vaishali                        Created.
*****************************************************************************************************************************************/   
    
    @TestSetup static void setUpData(){
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
        PermissionSet userAdminPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_External_User_Admin' LIMIT 1];
        
        List<Account> intAcctList = new List<Account>();
        
        //Creating Intel Account with utility class
        Account intAcct = Core_MDF_CCP_TestDataUtility.createAccount('Dell Corporation', null ,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        intAcct.BillingCity = 'Test City';         
        intAcct.BillingCountry= 'AUS';
        intAcct.BillingStreet= 'Test Street';
        intAcctList.add(intAcct);
		
        //Creating Intel Account with utility class
        Account intAcct2= Core_MDF_CCP_TestDataUtility.createAccount('Dell Corporation', null ,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        intAcct2.BillingCity = 'Test City';         
        intAcct2.BillingCountry= 'AUS';
        intAcct2.BillingStreet= 'Test Street';
        intAcctList.add(intAcct2);
        
        database.insert(intAcctList);
        //tAcct.IsPartner = true;
        //tabase.update(intAcct);
    }
}