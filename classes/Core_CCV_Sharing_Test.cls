/****************************************************************************************************
Apex Class Name : Core_CCV_Sharing_Test
Version         : 1.0 
Created Date    : 2/9/15
Function        : Test class for CCV Sharing functions
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              2/9/15                 Original Version
*****************************************************************************************************/
@
isTest
private class Core_CCV_Sharing_Test {

    static List<Core_CCV_Sharing> ccvShareObjects = new List<Core_CCV_Sharing>();

    static void setupTest()
    {
        Core_CCV__c ccv = new Core_CCV__c();
        insert ccv;
        
        User ccvUser = Core_Test_Utility.Core_User(1)[0];
        insert ccvUser;
        
        Core_CCV_Sharing ccvSharing = new Core_CCV_Sharing();
        ccvSharing.userId = ccvUser.Id;
        ccvSharing.ccvId  = ccv.Id;
        
        ccvShareObjects = new List<Core_CCV_Sharing>(); 
        ccvShareObjects.add(ccvSharing);   
    }


    static testMethod void Core_CCVHandler_Test_1() 
    {    
        Test.startTest();

        setupTest();
                
        Core_CCV_Sharing.manualShareList(ccvShareObjects);
     
        Test.stopTest();
    }


    static testMethod void Core_CCVHandler_Test_2() 
    {    
        Test.startTest();

        setupTest();
        Core_CCV_Sharing ccvSharing = ccvShareObjects[0];
        
        // Create a database error condition
        ccvSharing.userId = null;
                
        Core_CCV_Sharing.manualShareList(ccvShareObjects);
     
        Test.stopTest();
    }       
}