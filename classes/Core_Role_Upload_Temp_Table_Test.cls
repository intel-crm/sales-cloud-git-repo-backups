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
        userrole usr=new userrole();
        usr.name='Te234abc';
        usr.OpportunityAccessForAccountOwner ='read';
        insert usr;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'st654t', Email='Sy0976@intel.com', 
            EmailEncodingKey='UTF-8', LastName='T0p897', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles',Core_WWID__c='11223344',Core_Employee_Type_Code__c='EMP', UserName='Sy0976@@intel.com',UserRoleId=usr.id );
        insert u;
    
        String mgrCount = roleUploadTempTable.mgrCounts;
        String subCount = roleUploadTempTable.subCounts;
        Boolean reloadDisbaled = roleUploadTempTable.reloadDisabled;
        
        roleUploadTempTable.deleteRoleUpdateTempTable();
        
       List<Core_Role_Upload_Temp_Table__c> tmpList = new List<Core_Role_Upload_Temp_Table__c>();

        Core_Role_Upload_Temp_Table__c tmpRec = new Core_Role_Upload_Temp_Table__c();
        tmpRec.Core_Account_Manager_WWID__c   = u.Core_WWID__c;
        tmpRec.Core_Subordinate_WWID__c       = '';
        tmpRec.Core_Subordinate_Leaf_Node__c=true;
        tmpRec.Core_Top_Level__c=true;
        tmpRec.Core_Account_Manager_Role_Name__c ='Te234abc';
        tmpList.add(tmpRec);
        
        Core_Role_Upload_Temp_Table__c tmpRec1 = new Core_Role_Upload_Temp_Table__c();
        tmpRec1.Core_Account_Manager_WWID__c   = u.Core_WWID__c;
        tmpRec1.Core_Account_Manager_Role_Id__c =usr.id;
        tmpRec1.Core_Subordinate_WWID__c       =  '';
        tmpRec1.Core_Subordinate_Leaf_Node__c=true;
        tmpRec1.Core_Subordinate_Role_Name__c ='Te234abc';
        tmpList.add(tmpRec1);
        
        Core_Role_Upload_Temp_Table__c tmpRec2 = new Core_Role_Upload_Temp_Table__c();
        tmpRec2.Core_Account_Manager_WWID__c   = '';
        tmpRec2.Core_Account_Manager_Role_Id__c =usr.id;
        tmpRec2.Core_Subordinate_WWID__c       = u.Core_WWID__c;
        tmpRec2.Core_Subordinate_Leaf_Node__c=true;
        tmpRec2.Core_Subordinate_Role_Name__c ='Te234abc';
        tmpRec2.Core_Subordinate_Role_Id__c=usr.id;
        tmpList.add(tmpRec2);
        
        System.runAs(u) {
            insert tmpList;                        
        }
        
        

        System.runAs(u) {
            roleUploadTempTable.topLevel();
            roleUploadTempTable.assignRolesToTopLevel();
            roleUploadTempTable.loadManagerIds();
            roleUploadTempTable.assignRolesToManagers();
            roleUploadTempTable.loadSubordinateIds();
            roleUploadTempTable.topUpdateRolesToMidLevel();
            roleUploadTempTable.clearUsers();
            
        }
        
    
        System.runAs(u) {
        roleUploadTempTable.updateManagers();
            roleUploadTempTable.updateManagersCounters();
        }
        
        roleUploadTempTable.updateSubordinates();
        System.runAs(u) {
            roleUploadTempTable.updateSubsCounters();
        }

        roleUploadTempTable.updateRoleHierarchyAccess();
        
        Test.stopTest();
    }
    
     /*
    * Method name  : Core_Role_Upload_Temp_Table_Test
    * Description  : Constructor
    */ 
    static TestMethod void Core_Role_Upload_Temp_Table_Test1()
    {
        System.runAs(Core_Test_Utility.systemAdminUser) {
            setupTest();
        }
    
        // Start testing the functionality
        Test.startTest(); 
        userrole usr1=new userrole();
        usr1.name='TestRole1new';
        insert usr1;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='System@intel.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles',Core_WWID__c='11223344',Core_Employee_Type_Code__c='EMP', UserName='System@@intel.com',UserRoleId=usr1.id );
        insert u;
    Core_Role_Upload_Temp_Table roleUpload=new Core_Role_Upload_Temp_Table();
        String mgrCount = roleUpload.mgrCounts;
        String subCount = roleUpload.subCounts;
        Boolean reloadDisbaled = roleUpload.reloadDisabled;
     

        List<Core_Role_Upload_Temp_Table__c> tmpList = new List<Core_Role_Upload_Temp_Table__c>();

        Core_Role_Upload_Temp_Table__c tmpRec = new Core_Role_Upload_Temp_Table__c();
        tmpRec.Core_Account_Manager_WWID__c   = u.Core_WWID__c;
        tmpRec.Core_Subordinate_WWID__c       = '';
        tmpRec.Core_Account_Manager_Role_Id__c ='';
        tmpRec.Core_Subordinate_Leaf_Node__c=true;
        tmpRec.Core_Top_Level__c=true;
        tmpRec.Core_Account_Manager_Role_Name__c ='TestRole12345abc';
        tmpList.add(tmpRec);
       
        
        System.runAs(u) {
            insert tmpList;                        
        }
        System.runAs(u) {
                       roleUpload.assignRolesToManagers();
                       roleUploadTempTable.assignRolesToTopLevel();
               }
        Test.stopTest();
    }

}