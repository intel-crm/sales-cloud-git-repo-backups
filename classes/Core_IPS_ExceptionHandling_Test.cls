/***************************************************************************************************
Class Name:  Core_IPS_ExceptionHandling_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 22/05/2017
Function    : This class contains test coverage for Core_IPS_ExceptionHandling class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_ExceptionHandling class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Rajput              22/05/2017                 Created
****************************************************************************************************/
@isTest
public class Core_IPS_ExceptionHandling_Test {
    
/***************************************************************************************************
Method Name:  logEntryWithException_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 22/05/2017
Description:  Test method for logEntryWithException method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Rajput        22/05/2017    Created
****************************************************************************************************/ 

    static testmethod void logEntryWithException_Test() {
        try {
            Account acc = new Account();
            insert acc;
        }
        Catch(exception ex) {
            Core_IPS_ExceptionHandling.logEntryWithException(ex, 'Core_IPS_Account_Handler', 'Project Account');
        }

    }
/***************************************************************************************************
Method Name:  dmlExceptionHandlingLogs_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 22/05/2017
Description:  Test method for dmlExceptionHandlingLogs method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Rajput        22/05/2017    Created
****************************************************************************************************/ 

    static testmethod void dmlExceptionHandlingLogs_Test() {
        Account acc = new Account(name = 'Test1');
        List < Account > lstAccount = new List < Account > ();
        lstAccount.add(acc);
        map < string, Database.Error[] > errorsMap = new map < string, Database.Error[] > ();
        Database.saveResult[] srlist = database.insert(lstAccount, false);
        for (integer i = 0; i < srlist.size(); i++) {

            database.saveResult sr = srlist.get(i);

            if (!sr.isSuccess()) {

                // inserting Exception error records 

                errorsMap.put(lstAccount[i].name, sr.getErrors());
                Core_IPS_ExceptionHandling.dmlExceptionHandlingLogs(errorsMap, 'Account', 'Core_IPS_Project_Handler');

            }

        }
    }


}