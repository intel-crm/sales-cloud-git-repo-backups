/**************************************************************************************
Apex Class Name:  Core_Role_Upload_Temp_Table_Test
Version     : 1.0 
Created Date: 5/13/15
Function    : Test Class for the Core_Role_Upload_Temp_Table
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              5/13/15                Original Version
*************************************************************************************/
@isTest
public class Core_Role_Upload_Temp_Table_Test{
     
    static Core_Role_Upload_Temp_Table roleUploadTempTable = new Core_Role_Upload_Temp_Table();
     
    static void setupTest()
    {
        Core_Role_Upload_Temp_Table_2__c tempTable2 = new Core_Role_Upload_Temp_Table_2__c();
        tempTable2.Core_Update_Managers_Start__c = 0;
        insert tempTable2;
    
        Core_Role_Upload_Temp_Table_3__c tempTable3 = new Core_Role_Upload_Temp_Table_3__c();
        tempTable3.Core_Update_Subordinates_Start__c = 0;
        insert tempTable3;           
    }     
     
    /*
    * Method name  : Core_Role_Upload_Temp_Table_Test
    * Description  : Constructor
    */ 
    static TestMethod void Core_Role_Upload_Temp_Table_Test()
    {
        System.runAs(Core_Test_Utility.systemAdminUser) {
            setupTest();
        }
    
        // Start testing the functionality
        Test.startTest();    
    
        String mgrCount = roleUploadTempTable.mgrCounts;
        String subCount = roleUploadTempTable.subCounts;
        Boolean reloadDisbaled = roleUploadTempTable.reloadDisabled;
        
        roleUploadTempTable.deleteRoleUpdateTempTable();

        List<Core_Role_Upload_Temp_Table__c> tmpList = new List<Core_Role_Upload_Temp_Table__c>();

        Core_Role_Upload_Temp_Table__c tmpRec = new Core_Role_Upload_Temp_Table__c();
        tmpRec.Core_Account_Manager_WWID__c   = '12345678';
        tmpRec.Core_Subordinate_WWID__c       = '11223344';
        tmpList.add(tmpRec);
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert tmpList;                        
        }
        
        //roleUploadTempTable.clearUsers();

        // Can't delete user roles if user have been assigned to them.
        // roleUploadTempTable.deleteUserRoles();

        System.runAs(Core_Test_Utility.systemAdminUser) {
            roleUploadTempTable.topLevel();
            roleUploadTempTable.assignRolesToTopLevel();
            roleUploadTempTable.loadManagerIds();
            roleUploadTempTable.assignRolesToManagers();
            roleUploadTempTable.loadSubordinateIds();
            roleUploadTempTable.topUpdateRolesToMidLevel();
        }
    
        roleUploadTempTable.updateManagers();        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            roleUploadTempTable.updateManagersCounters();
        }
        
        roleUploadTempTable.updateSubordinates();
        System.runAs(Core_Test_Utility.systemAdminUser) {
            roleUploadTempTable.updateSubsCounters();
        }

        roleUploadTempTable.updateRoleHierarchyAccess();
        
        Test.stopTest();
    }    
}