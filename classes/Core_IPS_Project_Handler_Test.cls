/***************************************************************************************************
Class Name:  Core_IPS_Project_Handler_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 1 Feb 2016
Function    : This class contains test coverage for Core_IPS_Project_Handler class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_Project_Handler class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              01/02/2016                 Created
* Sugandha                  10/05/2018                 Modified(UserStory US104746 Iteration 11)
* Aayushi                   26/06/2018                 Modified US106361
****************************************************************************************************/
@isTest
public class Core_IPS_Project_Handler_Test { 
    
    //Instance variables that are commonly used in multiple test methods
    static List<User> listOfUser = new List<User> ();
    static Group grp = new Group();
    static Group queue = new Group();
    /***************************************************************************************************
Method Name:  getRecords()
Method Type: void
Version     : 1.0 
Created Date: 25 Jan 2016
Description:  Common Test data used for all test methods
Scenario Type:  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty       25/01/2016              Created
****************************************************************************************************/
    static void getRecords (){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('IPS Agent');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(2);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(1).ProfileID =  profiles.get('IPS Agent');
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
    }
    /***************************************************************************************************
Method Name:  ProjectNoDuplicateTest
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Project with no Duplicates
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/ 
    static testmethod void projectNoDuplicateTest(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        //Custom Setting - Trigger Executions added by Aayushi US79853
        List<Core_Trigger_Executions__c> listOftriggerExecutions = TestUtilities.getListOftriggerExecutions();
        insert ListOftriggerExecutions;
        // Create Ips Labels added by Aayushi US79852
        List<Core_IPS_Labels__c> iPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c iL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
            }
            if(IL.name=='CoreStatus_SPtoActive_Error'){
                IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';
            }
            if(IL.name=='Core_OneProjProdMem_Error'){
                IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';
            }
            if(IL.name=='CoreStatus_Draft'){
                IL.Value__c = 'Draft'; 
            }
            if(IL.name=='CoreStatus_Active'){
                IL.Value__c = 'Active' ;
            }
            if(IL.name=='CoreStatus_Inactive'){
                IL.Value__c = 'Inactive' ;
            }
            if(IL.name=='CoreStatus_SP'){
                IL.Value__c = 'Submitted Pending' ;
            }
        }
        System.runAs(ListOfUser.get(0)){
            Insert IPSLabels;
        }
        // Create Ips Project1
        List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
        }
        // Create Ips Project2
        List<Core_IPS_Project__c> listOfIpsProjectsTest = TestUtilities.getListOfIpsProjects(1);
        ListOfIpsProjectsTest.get(0).name='ipsProjectNameTest';
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjectsTest;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');        
        Test.stopTest();
    }    
    /***************************************************************************************************
Method Name:  ProjectNoDuplicateWithLongNameTest
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Project with long name (size >30) with no Duplicates
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/ 
    /*static testmethod void ProjectNoDuplicateWithLongNameTest(){
getrecords();
// Get intelSupportOwner Id (User Id)
Id intelSupportOwner = ListOfUser.get(0).id;
// Create Ips Labels
List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
for(Core_IPS_Labels__c IL: IPSLabels){
if(IL.name=='ProjectGroupPrefix'){
IL.Value__c = 'IPS_Proj_';
}
}
System.runAs(ListOfUser.get(0)){
Insert IPSLabels;
}
// Create Ips Project1
List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
System.runAs(ListOfUser.get(0)){
insert ListOfIpsProjects;
}
// Create Ips Project2
List<Core_IPS_Project__c> ListOfIpsProjectsTest = TestUtilities.getListOfIpsProjects(1);
ListOfIpsProjectsTest.get(0).name='ipsProjectNameTestipsProjectNameTestTest';
Test.startTest();
System.runAs(ListOfUser.get(0)){
insert ListOfIpsProjectsTest;
}
System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');        
Test.stopTest();
}
/***************************************************************************************************
Method Name:  ProjectDuplicateTest
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Project with Duplicates
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/ 
    /*Commented by Sugandha for US104746
    static testmethod void ProjectDuplicateTest(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        String ExceptionError;
        //Custom Setting - Trigger Executions added by Aayushi US79853
        List<Core_Trigger_Executions__c> ListOftriggerExecutions = TestUtilities.getListOftriggerExecutions();
        insert ListOftriggerExecutions;
        // Create Ips Labels added by Aayushi US79852
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c IL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
            }
            if(IL.name=='CoreStatus_SPtoActive_Error'){
                IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';
            }
            if(IL.name=='Core_OneProjProdMem_Error'){
                IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';
            }
            if(IL.name=='CoreStatus_Draft'){
                IL.Value__c = 'Draft'; 
            }
            if(IL.name=='CoreStatus_Active'){
                IL.Value__c = 'Active' ;
            }
            if(IL.name=='CoreStatus_Inactive'){
                IL.Value__c = 'Inactive' ;
            }
            if(IL.name=='CoreStatus_SP'){
                IL.Value__c = 'Submitted Pending' ;
            }
        }
        System.runAs(ListOfUser.get(0)){
            Insert IPSLabels;
        }
        // Create Ips Project1
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
        }
        // Create Ips Project2
        List<Core_IPS_Project__c> ListOfIpsProjectsTest = TestUtilities.getListOfIpsProjects(1);
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            try{
                insert ListOfIpsProjectsTest;
            } Catch(Exception e){
                ExceptionError = e.getMessage();
            }
        }
        System.assert(ExceptionError.contains('The Project Name is already in use. Please choose another'), 'Project Duplicate Error didnot occur');        
        Test.stopTest();
    }*/
    /***************************************************************************************************
Method Name:  ProjectAccessControlActiveUpdateTest
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Project with update fuctionality by updating Project record from New to Active
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/ 
    static testmethod void projectAccessControlActiveUpdateTest(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        String exceptionError;
        //Custom Setting - Trigger Executions added by Aayushi US79853
        List<Core_Trigger_Executions__c> listOftriggerExecutions = TestUtilities.getListOftriggerExecutions();
        insert ListOftriggerExecutions;
        // Create Ips Labels added by Aayushi US79852
        List<Core_IPS_Labels__c> iPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c iL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
            }
            if(IL.name=='CoreStatus_SPtoActive_Error'){
                IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';
            }
            if(IL.name=='Core_OneProjProdMem_Error'){
                IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';
            }
            if(IL.name=='CoreStatus_Draft'){
                IL.Value__c = 'Draft'; 
            }
            if(IL.name=='CoreStatus_Active'){
                IL.Value__c = 'Active' ;
            }
            if(IL.name=='CoreStatus_Inactive'){
                IL.Value__c = 'Inactive' ;
            }
            if(IL.name=='CoreStatus_SP'){
                IL.Value__c = 'Submitted Pending' ;
            }
            if(IL.name=='Core_IPS_PrivateProj_ActivateError'){
                IL.Value__c = 'This Premier Support Project is Private, please ask an IPS Support Org Admin on the Intel Support Team to set it to Active' ;
            }
            
        }
        System.runAs(ListOfUser.get(0)){
            Insert IPSLabels;
        }
        // Create Ips Project1
        List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
        }
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            TestUtilities.addAccMemProdToProject(ListOfIpsProjects); //added by Aayushi US79852
            
            for(Core_IPS_Project__c proj:ListOfIpsProjects){
                proj.Core_Status__c = 'Active';
            }
            Update ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects.get(0).Core_Status__c == 'Active', 'Record not Updated');        
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  ProjectAccessControlInactiveUpdateTest
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Project with update fuctionality by updating Project record from Active to Inactive
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/ 
    static testmethod void projectAccessControlInactiveUpdateTest(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        String exceptionError;
        //Custom Setting - Trigger Executions added by Aayushi US79853
        List<Core_Trigger_Executions__c> listOftriggerExecutions = TestUtilities.getListOftriggerExecutions();
        insert ListOftriggerExecutions;
        // Create Ips Labels added by Aayushi US79852
        List<Core_IPS_Labels__c> iPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c iL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
            }
            if(IL.name=='CoreStatus_SPtoActive_Error'){
                IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';
            }
            if(IL.name=='Core_OneProjProdMem_Error'){
                IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';
            }
            if(IL.name=='CoreStatus_Draft'){
                IL.Value__c = 'Draft'; 
            }
            if(IL.name=='CoreStatus_Active'){
                IL.Value__c = 'Active' ;
            }
            if(IL.name=='CoreStatus_Inactive'){
                IL.Value__c = 'Inactive' ;
            }
            if(IL.name=='CoreStatus_SP'){
                IL.Value__c = 'Submitted Pending' ;
            }
        }
        System.runAs(ListOfUser.get(0)){
            Insert IPSLabels;
        }
        // Create Ips Project1
        List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
        }
        Test.startTest();
        
        System.runAs(ListOfUser.get(0)){
            TestUtilities.addAccMemProdToProject(ListOfIpsProjects);  //added by Aayushi US79852
            for(Core_IPS_Project__c proj:ListOfIpsProjects){
                proj.Core_Status__c = 'Active';
            }
            Update ListOfIpsProjects;
            for(Core_IPS_Project__c proj:ListOfIpsProjects){
                proj.Core_Status__c = 'Inactive';
            }
            Update ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects.get(0).Core_Status__c == 'Inactive', 'Record not Updated');        
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  ProjectAccessControlActiveToNonInactiveUpdateTest
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Project with update fuctionality by updating Project record from Active to Non_Inactive(Submit)
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/ 
    static testmethod void projectAccessControlActiveToNonInactiveUpdateTest(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        String exceptionError;
        //Custom Setting - Trigger Executions added by Aayushi US79853
        List<Core_Trigger_Executions__c> listOftriggerExecutions = TestUtilities.getListOftriggerExecutions();
        insert ListOftriggerExecutions;
        // Create Ips Labels added by Aayushi US79852
        List<Core_IPS_Labels__c> iPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c iL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
            }
            if(IL.name=='CoreStatus_SPtoActive_Error'){ 
                IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';
            }
            if(IL.name=='Core_OneProjProdMem_Error'){
                IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';
            }
            if(IL.name=='CoreStatus_Draft'){
                IL.Value__c = 'Draft'; 
            }
            if(IL.name=='CoreStatus_Active'){
                IL.Value__c = 'Active' ;
            }
            if(IL.name=='CoreStatus_Inactive'){
                IL.Value__c = 'Inactive' ;
            }
            if(IL.name=='CoreStatus_SP'){
                IL.Value__c = 'Submitted Pending' ;
            }
            
            
        }
        System.runAs(ListOfUser.get(0)){
            Insert IPSLabels;
        }
        // Create Ips Project1
        List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
        }
        Test.startTest();
        
        System.runAs(ListOfUser.get(0)){
            TestUtilities.addAccMemProdToProject(ListOfIpsProjects); //added by Aayushi US79852
            for(Core_IPS_Project__c proj:ListOfIpsProjects){
                proj.Core_Status__c = 'Active';
            }
            System.debug('>>ListOfIpsProjects>>'+ListOfIpsProjects);
            Update ListOfIpsProjects;
            for(Core_IPS_Project__c proj:ListOfIpsProjects){
                proj.Core_Status__c = 'Submitted Pending';
            }
            Update ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects.get(0).Core_Status__c != 'Inactive', 'Record not Updated');        
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  ProjectPreventDeleteNewTest
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Project with update fuctionality by Deleting New Project record 
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/ 
    static testmethod void projectPreventDeleteNewTest(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        String exceptionError;
        //Custom Setting - Trigger Executions added by Aayushi US79853
        List<Core_Trigger_Executions__c> listOftriggerExecutions = TestUtilities.getListOftriggerExecutions();
        insert ListOftriggerExecutions;
        // Create Ips Labels added by Aayushi US79852
        List<Core_IPS_Labels__c> iPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c iL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
            }
            if(IL.name=='CoreStatus_SPtoActive_Error'){
                IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';
            }
            if(IL.name=='Core_OneProjProdMem_Error'){
                IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';
            }
            if(IL.name=='CoreStatus_Draft'){
                IL.Value__c = 'Draft'; 
            }
            if(IL.name=='CoreStatus_Active'){
                IL.Value__c = 'Active' ;
            }
            if(IL.name=='CoreStatus_Inactive'){
                IL.Value__c = 'Inactive' ;
            }
            if(IL.name=='CoreStatus_SP'){
                IL.Value__c = 'Submitted Pending' ;
            }
        }
        System.runAs(ListOfUser.get(0)){
            Insert IPSLabels;
        }
        // Create Ips Project1
        List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
        }
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            delete ListOfIpsProjects;
        }
        List<Core_IPS_Project__c> listOfProjectDelete = [select id from Core_IPS_Project__c where id IN: ListOfIpsProjects];
        System.assert(listOfProjectDelete.isEmpty(), 'Record not deleted');        
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  ProjectPreventDeleteActiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Project with update fuctionality by Deleting Active Project record 
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/ 
    static testmethod void projectPreventDeleteNonNewTest(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        String exceptionError;
        //Custom Setting - Trigger Executions added by Aayushi US79853
        List<Core_Trigger_Executions__c> listOftriggerExecutions = TestUtilities.getListOftriggerExecutions();
        insert ListOftriggerExecutions;
        // Create Ips Labels added by Aayushi US79852
        List<Core_IPS_Labels__c> iPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c iL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
            }
            if(IL.name=='CoreStatus_SPtoActive_Error'){
                IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';
            }
            if(IL.name=='Core_OneProjProdMem_Error'){
                IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';
            }
            if(IL.name=='CoreStatus_Draft'){
                IL.Value__c = 'Draft'; 
            }
            if(IL.name=='CoreStatus_Active'){
                IL.Value__c = 'Active' ;
            }
            if(IL.name=='CoreStatus_Inactive'){
                IL.Value__c = 'Inactive' ;
            }
            if(IL.name=='CoreStatus_SP'){
                IL.Value__c = 'Submitted Pending' ;
            }
        }
        System.runAs(ListOfUser.get(0)){
            Insert IPSLabels;
        }
        // Create Ips Project1
        List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
        }
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            TestUtilities.addAccMemProdToProject(ListOfIpsProjects); //added by Aayushi US79852
            
            for(Core_IPS_Project__c proj:ListOfIpsProjects){
                proj.Core_Status__c = 'Active';
            }
            Update ListOfIpsProjects;
            System.assert(ListOfIpsProjects.get(0).Core_Status__c == 'Active', 'Record not Updated');                    
            try{
                delete ListOfIpsProjects;
            }Catch (Exception E){
                ExceptionError = E.getMessage(); 
            }
        }
        System.assert(ExceptionError.contains('Cannot delete this when status is Submitted Pending or Active'), 'Record deleted Error not fired');        
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  ProjectPreventDeleteInactiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Project with update fuctionality by Deleting Inactive Project record 
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/ 
    static testmethod void projectPreventDeleteInactiveTest(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        String exceptionError;
        //Custom Setting - Trigger Executions added by Aayushi US79853
        List<Core_Trigger_Executions__c> listOftriggerExecutions = TestUtilities.getListOftriggerExecutions();
        insert ListOftriggerExecutions;
        // Create Ips Labels added by Aayushi US79852
        List<Core_IPS_Labels__c> iPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c iL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
            }
            if(IL.name=='CoreStatus_SPtoActive_Error'){
                IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';
            }
            if(IL.name=='Core_OneProjProdMem_Error'){
                IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';
            }
            if(IL.name=='CoreStatus_Draft'){
                IL.Value__c = 'Draft'; 
            }
            if(IL.name=='CoreStatus_Active'){
                IL.Value__c = 'Active' ;
            }
            if(IL.name=='CoreStatus_Inactive'){
                IL.Value__c = 'Inactive' ;
            }
            if(IL.name=='CoreStatus_SP'){
                IL.Value__c = 'Submitted Pending' ;
            }
        }
        System.runAs(ListOfUser.get(0)){
            Insert IPSLabels;
        }
        // Create Ips Project1
        List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
        }
        Test.startTest();
        
        System.runAs(ListOfUser.get(0)){
            TestUtilities.addAccMemProdToProject(ListOfIpsProjects); //added by Aayushi US79852
            for(Core_IPS_Project__c proj:ListOfIpsProjects){
                proj.Core_Status__c = 'Active';
            }
            Update ListOfIpsProjects;
            System.assert(ListOfIpsProjects.get(0).Core_Status__c == 'Active', 'Record not Updated');
            for(Core_IPS_Project__c proj:ListOfIpsProjects){
                proj.Core_Status__c = 'Inactive';
            }
            Update ListOfIpsProjects;
            System.assert(ListOfIpsProjects.get(0).Core_Status__c == 'Inactive', 'Record not Updated');
            try{
                delete ListOfIpsProjects;
            }Catch (Exception E){
                ExceptionError = E.getMessage(); 
            }
        }
        System.assert(ExceptionError.contains('Cannot delete this when status is Submitted Pending or Active'), 'Record deleted Error not fired');        
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  ProjectPreventDeleteSubmitTest
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Project with update fuctionality by Deleting Inactive Project record 
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/ 
    static testmethod void projectPreventDeleteSubmitTest(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        String exceptionError;
        //Custom Setting - Trigger Executions added by Aayushi US79853
        List<Core_Trigger_Executions__c> listOftriggerExecutions = TestUtilities.getListOftriggerExecutions();
        insert ListOftriggerExecutions;
        // Create Ips Labels added by Aayushi US79852
        List<Core_IPS_Labels__c> iPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c iL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
            }
            if(IL.name=='CoreStatus_SPtoActive_Error'){
                IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';
            }
            if(IL.name=='Core_OneProjProdMem_Error'){
                IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';
            }
            if(IL.name=='CoreStatus_Draft'){
                IL.Value__c = 'Draft'; 
            }
            if(IL.name=='CoreStatus_Active'){
                IL.Value__c = 'Active' ;
            }
            if(IL.name=='CoreStatus_Inactive'){
                IL.Value__c = 'Inactive' ;
            }
            if(IL.name=='CoreStatus_SP'){
                IL.Value__c = 'Submitted Pending' ;
            }
        }
        System.runAs(ListOfUser.get(0)){
            Insert IPSLabels;
        }
        // Create Ips Project1
        List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
        }
        Test.startTest();
        
        System.runAs(ListOfUser.get(0)){
            TestUtilities.addAccMemProdToProject(ListOfIpsProjects); //added by Aayushi US79852
            
            for(Core_IPS_Project__c proj:ListOfIpsProjects){
                proj.Core_Status__c = 'Active';
            }
            Update ListOfIpsProjects;
            System.assert(ListOfIpsProjects.get(0).Core_Status__c == 'Active', 'Record not Updated');
            for(Core_IPS_Project__c proj:ListOfIpsProjects){
                proj.Core_Status__c = 'Submitted Pending';
            }
            Update ListOfIpsProjects;
            System.assert(ListOfIpsProjects.get(0).Core_Status__c == 'Submitted Pending', 'Record not Updated');
            try{
                delete ListOfIpsProjects;
            }Catch (Exception E){
                ExceptionError = E.getMessage(); 
            }
        }
        System.assert(ExceptionError.contains('Cannot delete this when status is Submitted Pending or Active'), 'Record deleted Error not fired');        
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name         : activateProjectTest
Method Type         : Test Method
Version             : 1.0 
Created Date        : 03/01/2018
Description         : This method is used to change the status of the project to submitted pending 
Scenario Type       : Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Yogesh Sharma               03/01/2018             Created
****************************************************************************************************/ 
    
    static testmethod void activateProjectTest(){
        Test.startTest();
        getrecords();
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('IPS Support Org Admin');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        
        //Create Role
        UserRole r = [SELECT Id, Name FROM UserRole WHERE DeveloperName = 'IPS_Product_Org_Admin' LIMIT 1];
        
        User userRecord = new User(
            Alias = 'StdUser', 
            Email = 'newuser211@intel.com', 
            EmailEncodingKey ='UTF-8',
            LastName = 'Testing',
            FirstName = 'FName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'nnnnewuser12300000@intel.com',
            isActive = true,
            UserRoleId = r.Id
            
        );
        
        
        List<User> listOfUser1 = new List<User>{userRecord}; //TestUtilities.getListOfUser(1);
            ListOfUser1.get(0).ProfileID =  profiles.get('IPS Support Org Admin');
        //ListOfUser1.get(1).ProfileID =  profiles.get('IPS Support Org Admin');
        
        insert ListOfUser1;  
        
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser1.get(0).id; 
        String exceptionError;
        
        
        
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Core_IPS_Product_Organization__c');
        insert q1;
        
        //Create Custom Setting - Trigger Executions
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name = 'activateProject';
        triggerExecution.Core_Active__c = true;
        triggerExecution.Core_Class_Name__c ='Core_IPS_Project_Handler';
        triggerExecution.Core_Description__c = 'Activate the Project based on status update';
        triggerExecution.Core_Object__c = 'Core_IPS_Project__c';
        triggerExecution.Core_Trigger_Events__c = 'before update,after update';
        
        // Create Support Org
        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        ListOfSupportOrg.get(0).ownerId = ListOfUser1.get(0).Id;
        
        System.runAs(ListOfUser.get(0)){
            insert triggerExecution; 
            //insert IPSLabels;
            insert ListOfSupportOrg.get(0);
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        
        integer counter = 0;
        // Create Product
        List<Product2> listOfProducts = TestUtilities.getListOfProduct(2);
        for(Product2 product : ListOfProducts){
            if(counter==0){
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';
            }else{
                Product.Core_Hierarchy_ID__c = '59';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                Product.Core_Unique_ID__c = 'Product59';
                Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                
            }
            counter++;
        }
        System.runAs(ListOfUser1.get(0)){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        
        counter = 0;
        // Create Supported product
        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
        for(Core_IPS_Supported_Product__c supportedProduct : ListOfSupportedProduct){
            if(counter==0){
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                SupportedProduct.Core_Flag_Status__c = 'Par Hidden';
            }else{
                SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                SupportedProduct.Core_Flag_Status__c = 'Approval Required';
            }
            counter++;
        }
        System.runAs(ListOfUser1.get(0)){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        
        //Get Record Type
        Id projectRecordTypeId = Schema.SObjectType.Core_IPS_Project__c.getRecordTypeInfosByName().get('Active').getRecordTypeId();
        
        counter = 0;
        //Create Ips Project
        Core_IPS_Project__c ipsProjectRecord = new Core_IPS_Project__c(
            Name = 'projIPSTestProject12310000001111111110122322222333000000test123',
            Core_Status__c = 'Draft',
            Core_MPNDA__c='12345',
            recordTypeId = projectRecordTypeId
        );
        List<Core_IPS_Project__c> listOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
            System.runAs(ListOfUser1.get(0)){
                insert ListOfIpsProjects; 
                ListOfIpsProjects.get(0).Core_Status__c = 'Submitted Pending';
                update ListOfIpsProjects;
                
                //Add Member And Account to Project 
                TestUtilities.addAccMemProdToProject(ListOfIpsProjects);
            } 
        // Create IPS Product
        List<Core_IPS_Product__c> listOfIpsProductsOne = TestUtilities.getListOfIpsProducts(4);
        for(Core_IPS_Product__c ipsProduct:listOfIpsProductsOne){
            if(counter<2){
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                ipsProduct.Status__c = 'Active';
            }else{
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(1).id;
                ipsProduct.Status__c = 'Active';
            }   
        } 
        System.runAs(ListOfUser1.get(0)){
            insert listOfIpsProductsOne;
        }
        System.assert(listOfIpsProductsOne[0].Id != null, 'Record not created');
        
        //Create IPS Product
        List<Core_IPS_Product__c> listOfIpsProductsTwo = TestUtilities.getListOfIpsProducts(4);
        for(Core_IPS_Product__c ipsProduct:listOfIpsProductsTwo){
            if(counter<2){
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(1).id;
                ipsProduct.Status__c = 'Not Approved';
            }else{
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                ipsProduct.Status__c = 'Not Approved';
            }   
        }
        
        System.runAs(ListOfUser1.get(0)){
            insert listOfIpsProductsTwo;
        }
        System.assert(listOfIpsProductsTwo[0].Id != null, 'Record not created'); 
        
        Test.stopTest();
    }  
    
    
    
    
    
    
    //method for Interested Party checkbox
    static testmethod void enableProjectMemberAsInterestedParty(){
        
        getrecords();
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('IPS Support Org Admin');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        
        //Create Role
        UserRole r = [SELECT Id, Name FROM UserRole WHERE DeveloperName = 'IPS_Product_Org_Admin' LIMIT 1];
        
        User userRecord = new User(
            Alias = 'StdUser', 
            Email = 'newuser211@intel.com', 
            EmailEncodingKey ='UTF-8',
            LastName = 'Testing',
            FirstName = 'FName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'nnnnewuser12300000@intel.com',
            isActive = true,
            UserRoleId = r.Id
            
        );
        
        
        List<User> listOfUser1 = new List<User>{userRecord}; //TestUtilities.getListOfUser(1);
            ListOfUser1.get(0).ProfileID =  profiles.get('IPS Support Org Admin');
        //ListOfUser1.get(1).ProfileID =  profiles.get('IPS Support Org Admin');
        
        insert ListOfUser1;  
        
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser1.get(0).id; 
        String exceptionError;
        
        
        
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Core_IPS_Product_Organization__c');
        insert q1;
        
        System.runAs(ListOfUser[0]) {
        //Create Custom Setting - Trigger Executions
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name = 'insertRecord_InterestedParties';
        triggerExecution.Core_Active__c = true;
        triggerExecution.Core_Class_Name__c ='Core_IPS_Project_Handler';
        triggerExecution.Core_Description__c = 'Activate the Project based on status update';
        triggerExecution.Core_Object__c = 'Core_IPS_Project__c';
        triggerExecution.Core_Trigger_Events__c = 'before update,after update';
        insert triggerExecution;
        }
        
        //Get Record Type
        Id projectRecordTypeId = Schema.SObjectType.Core_IPS_Project__c.getRecordTypeInfosByName().get('Active').getRecordTypeId();
        
        Integer counter = 0;
        //Create Ips Project
        Core_IPS_Project__c ipsProjectRecord = new Core_IPS_Project__c(
            Name = 'projIPSTestProject12310000001111111110122322222333000000test123',
            Core_Status__c = 'Draft',
            Core_MPNDA__c='12345',
            recordTypeId = projectRecordTypeId
        );
        List<Core_IPS_Project__c> listOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
            System.runAs(ListOfUser1.get(0)){
                insert ListOfIpsProjects; 
                ListOfIpsProjects.get(0).Core_Status__c = 'Submitted Pending';
                update ListOfIpsProjects;
                
                //Add Member And Account to Project 
                TestUtilities.addAccMemProdToProject(ListOfIpsProjects);
            } 
        
        // Create Accounts
        List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
        for(Contact contactRec : listOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
            ContactRec.Core_IPS_Active__c = true;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        // Create Ips Account
        List<Core_IPS_Account__c> listOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
        for(Core_IPS_Account__c ipsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        Id externalUserProfileId = [select id, name from Profile where name='IPS External Customer'].Id;
        User customerUser = TestUtilities.getListOfUser(1).get(0);
        customerUser.ProfileId = ExternalUserProfileId;
        customerUser.UserName = 'testips.contact999@intel.com.crm';
        customerUser.FirstName = 'TestExt';
        customerUser.LastName = 'User192';
        customerUser.Alias = 'eusr192'; 
        customerUser.CommunityNickname = 'IPSExtUser192';
        customerUser.ContactId = ListOfContacts[0].Id;
        insert customerUser;
        System.assert(customerUser.Id != null, 'Record not created');
        
        // Create Project Member
        List<Core_IPS_Project_Member__c> listOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
        for(Core_IPS_Project_Member__c projMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = customerUser.Id;                             
            ProjMem.Core_Status__c = 'Active';
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProjectMembers;
        }
        
        //Create IST
        Core_IPS_Intel_Support_Team__c ist=new Core_IPS_Intel_Support_Team__c();
        ist.Core_IPS_Project__c=ListOfIpsProjects[0].Id;
        ist.Core_IPS_User__c=ListOfUser.get(0).Id;
        ist.Status__c='Active';
        System.runAs(ListOfUser.get(0)){
            insert ist;
        }
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            ipsProjectRecord.Core_IPS_Enable_ISTasInterested_Parties__c = true;
            ipsProjectRecord.Core_IPS_EnableMemberasInterestedParties__c = true;
            update ipsProjectRecord;
            
            ipsProjectRecord.Core_IPS_Enable_ISTasInterested_Parties__c = false;
            ipsProjectRecord.Core_IPS_EnableMemberasInterestedParties__c = false;
            update ipsProjectRecord;
        }
        Test.stopTest();
    } 
   /***************************************************************************************************
Method Name         : activateProjectTest
Method Type         : Test Method
Version             : 1.0 
Created Date        : 03/01/2018
Description         : This method is used to change the Private field of the Project 
Scenario Type       : Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi                     27/06/2018               Created
****************************************************************************************************/   
    static testmethod void privateProjectTest(){
        getrecords();
        
        //Create Custom Setting - Trigger Executions
        List<Core_Trigger_Executions__c> triggerExecutionList=new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name = 'updatePrivateProjectSharing';
        triggerExecution.Core_Active__c = true;
        triggerExecution.Core_Class_Name__c ='Core_IPS_Project_Handler';
        triggerExecution.Core_Description__c = 'This method is used to update Project sharing for Private projects.';
        triggerExecution.Core_Object__c = 'Core_IPS_Project__c';
        triggerExecution.Core_Trigger_Events__c = 'after update';
        triggerExecutionList.add(triggerExecution);
        
        Core_Trigger_Executions__c  triggerExecution1 = new Core_Trigger_Executions__c();
        triggerExecution1.Name = 'internalProjectGroup';
        triggerExecution1.Core_Active__c = true;
        triggerExecution1.Core_Class_Name__c ='Core_IPS_Project_Handler';
        triggerExecution1.Core_Description__c = 'This method is used to update Project Group on Projects.';
        triggerExecution1.Core_Object__c = 'Core_IPS_Project__c';
        triggerExecution1.Core_Trigger_Events__c = 'after insert';
        triggerExecutionList.add(triggerExecution1);
        
        Core_Trigger_Executions__c  triggerExecution2 = new Core_Trigger_Executions__c();
        triggerExecution2.Name = 'addDefaultCaseOwnerToIST';
        triggerExecution2.Core_Active__c = true;
        triggerExecution2.Core_Class_Name__c ='Core_IPS_Project_Handler';
        triggerExecution2.Core_Description__c = 'This method is used to update Project Group on Projects.';
        triggerExecution2.Core_Object__c = 'Core_IPS_Project__c';
        triggerExecution2.Core_Trigger_Events__c = 'after insert';
        triggerExecutionList.add(triggerExecution2);
        //Create Ips Project
        Core_IPS_Project__c ipsProjectRecord = new Core_IPS_Project__c(
            Name = 'Test Project',
            Core_Status__c = 'Draft',
            Core_MPNDA__c='12345',
            Core_IPS_Private__c=true,
            OwnerId=ListOfUser.get(1).Id
        );
        List<Core_IPS_Project__c> listOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
            
            System.runAs(ListOfUser.get(0)){
                insert triggerExecutionList;
                insert ListOfIpsProjects;
            }
        for(Core_IPS_Project__c proj: ListOfIpsProjects){
                proj.Core_IPS_Private__c=false;
            }
            
            update ListOfIpsProjects; 
        for(Core_IPS_Project__c proj: ListOfIpsProjects){
                proj.Core_IPS_Private__c=true;
            }
            
            update ListOfIpsProjects; 
        //Add Account, Project Member and Product to Project 
        TestUtilities.addAccMemProdToProject(ListOfIpsProjects);
        System.runAs(ListOfUser.get(0)){   
            for(Core_IPS_Project__c proj: ListOfIpsProjects){
                proj.Core_Status__c='Active';
            }
            
            update ListOfIpsProjects;
            //Create Asset
            Asset ast=new Asset();
            ast.Name='Test Asset';
            ast.Core_IPS_Project__c=ListOfIpsProjects[0].Id;
            ast.Status='Active';
            System.runAs(ListOfUser.get(0)){
                insert ast;
            }
            
			 system.assertnotEquals(ast.id, null);
            
        }   
    }

   /***************************************************************************************************
Method Name         : addInternalProjOwnerToIST
Method Type         : Test Method
Version             : 1.0 
Created Date        : 15/11/2018
Description         : This method is used to change the Private field of the Project 
Scenario Type       : Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gourav                     15/11/2018               Created
****************************************************************************************************/   
    static testmethod void addInternalProjOwnerToISTTest1(){
        getrecords();
        
        //Create Custom Setting - Trigger Executions
        List<Core_Trigger_Executions__c> triggerExecutionList=new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name = 'addInternalProjOwnerToIST';
        triggerExecution.Core_Active__c = true;
        triggerExecution.Core_Class_Name__c ='Core_IPS_Project_Handler';
        triggerExecution.Core_Description__c = 'This method is used to addInternalProjOwnerToIST';
        triggerExecution.Core_Object__c = 'Core_IPS_Project__c';
        triggerExecution.Core_Trigger_Events__c = 'afterinsert,after update';
        triggerExecutionList.add(triggerExecution);
        
        
        //Create Ips Project
        Core_IPS_Project__c ipsProjectRecord = new Core_IPS_Project__c(
            Name = 'Test Project',
            Core_Status__c = 'Draft',
            Core_MPNDA__c='',
            Core_IPS_Private__c=true
        );
    	            	
                	  
        List<Core_IPS_Project__c> listOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
            
            System.runAs(ListOfUser.get(0)){
                insert triggerExecutionList;
                insert ListOfIpsProjects;
            }
            system.assertnotEquals(listOfIpsProjects[0].id, null);
        
    }
    
    static testmethod void addInternalProjOwnerToISTTest2(){
        getrecords();
        
        //Create Custom Setting - Trigger Executions
        List<Core_Trigger_Executions__c> triggerExecutionList=new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name = 'addInternalProjOwnerToIST';
        triggerExecution.Core_Active__c = true;
        triggerExecution.Core_Class_Name__c ='Core_IPS_Project_Handler';
        triggerExecution.Core_Description__c = 'This method is used to addInternalProjOwnerToIST';
        triggerExecution.Core_Object__c = 'Core_IPS_Project__c';
        triggerExecution.Core_Trigger_Events__c = 'afterinsert,after update';
        triggerExecutionList.add(triggerExecution);
        
        
        //Create Ips Project
        Core_IPS_Project__c ipsProjectRecord = new Core_IPS_Project__c(
            Name = 'Test Project',
            Core_Status__c = 'Draft',
            Core_MPNDA__c='',
            Core_IPS_Private__c=false,
            OwnerId=ListOfUser.get(0).Id
        );
    	            	
                	  
        List<Core_IPS_Project__c> listOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
            
            System.runAs(ListOfUser.get(0)){
                insert triggerExecutionList;
                insert ListOfIpsProjects;
            }
        System.debug('-------------------->**Project owner:'+ListOfIpsProjects.get(0).OwnerId);
        Core_IPS_Intel_Support_Team__c istInsertRec = new Core_IPS_Intel_Support_Team__c();
        for(Core_IPS_Project__c proj:ListOfIpsProjects){
            System.debug('-------------------->Project owner:'+proj.OwnerId);
                  		istInsertRec.Core_IPS_Project__c  = proj.id;
                    	istInsertRec.Core_IPS_User__c = proj.OwnerId;
                    	istInsertRec.Status__c = 'Inactive';
        }    
        System.runAs(ListOfUser.get(0)){
                insert istInsertRec;
            }
        System.debug('-------------------->IST Rec:'+istInsertRec.Id+istInsertRec.Status__c);
        List<Core_IPS_Project__c> listOfIpsProjects1 = new List<Core_IPS_Project__c>();
        //Update Ips Project
        for(Core_IPS_Project__c proj: ListOfIpsProjects){
                proj.Core_IPS_Private__c=true;
            	ListOfIpsProjects1.add(proj);
            }
         System.runAs(ListOfUser.get(0)){
                update ListOfIpsProjects1;
                system.assertnotEquals(ListOfIpsProjects1.size(),0);   
            }
        
        
    }
    
}