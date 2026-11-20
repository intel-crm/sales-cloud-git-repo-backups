/***************************************************************************************************
* Apex Class Name: Core_Product_Issue_Category_Handler
* Version     : 1.0 
* Created Date: 19th Dec 2015
* Function    : Test class for Core_Product_Issue_Category_Handler
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T             12/19/2015                Created
****************************************************************************************************/
@isTest 
public class Core_Product_Issue_Category_Handler_Test{
    
    private static User SystUserRunAs; 
    private static EmailTemplate EmailTempl;
    private static OrgWideEmailAddress OrgWideEmailObj;
    
    
    private static void getRecords(){
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
        List<User> userList = new List<user>();
        userList = TestUtilities.getListOfUser(1);
        userList[0].profileId=prof.id;
        insert userlist;
        SystUserRunAs = new User();
        SystUserRunAs = userList[0];
    }
    
/***************************************************************************************************
* Method Name: Core_Product_Issue_CategoryUpdate_test
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 19th Dec 2015
* Description:  Product issue category update 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T             11/18/2015                 Created
****************************************************************************************************/         
    private static testMethod void Core_Product_Issue_CategoryUpdate_test() {
        getRecords();
        System.runAs(SystUserRunAs){
            
            //List<Core_IPS_Product_Issue_Category__c> prodCaseCatList = new List<Core_IPS_Product_Issue_Category__c>();
            //for(Integer i=0;i<5;i++){
                 Core_IPS_Product_Issue_Category__c caseCat = new Core_IPS_Product_Issue_Category__c();
                caseCat = TestUtilities.getCaseCategories();
                //prodCaseCatList.add(caseCat);
            //}
            insert caseCat;
            
            Core_IPS_Product_Issue_Category__c caseSubCat = new Core_IPS_Product_Issue_Category__c();
            caseSubCat = TestUtilities.getCaseCategories();
            caseSubCat.Core_Product_Issue_Category__c=caseCat.id;
            insert caseSubCat;   
            List<Core_IPS_Environment_Variables__c> envDetails = TestUtilities.getEnvironmentVariables(1);
            insert envDetails;
            List<Core_IPS_Assigned_Environment_Variables__c> catEnvOperationalList= new List<Core_IPS_Assigned_Environment_Variables__c>();
            catEnvOperationalList= TestUtilities.getListOfEnvDetailsOperational(5);
            for(Core_IPS_Assigned_Environment_Variables__c envOper:catEnvOperationalList){
                envOper.Core_Product_Issue_Sub_Category__c = caseSubCat.id;
                envOper.Core_Environment_Variable__c = envDetails[0].id;
            }
            
            insert catEnvOperationalList;
            caseCat.core_status__c='Inactive';
            update caseCat;
            /*for(Core_IPS_Assigned_Environment_Variables__c envOper:catEnvOperationalList){
                system.assertEquals('Inactive',envOper.core_status__c);
            }*/
        }
    }
}