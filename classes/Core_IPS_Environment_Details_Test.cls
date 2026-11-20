/***************************************************************************************************
* Apex Class Name: Core_IPS_Environment_Details_Test
* Version     : 1.0 
* Created Date: 19th Dec 2015
* Function    : Test class for Core_IPS_Environment_Details_Handler
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T             12/19/2015                Created
****************************************************************************************************/
@isTest 
public class Core_IPS_Environment_Details_Test{
    
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
    * Method Name: testEnvHTMLTableCreated
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
    private static testMethod void testEnvHTMLTableCreated() {
        getRecords();
        System.runAs(SystUserRunAs){
            Case cs=TestUtilities.getCase();
            insert cs;
            List<Core_IPS_Environment_Details__c> envResponses=TestUtilities.getEnvironmentDetailResponses(10);
            for(Core_IPS_Environment_Details__c envResp:envResponses){
                envResp.Core_Case__c = cs.id;
            }
            insert envResponses;
        }
    }
    
    /***************************************************************************************************
    * Method Name: testEnvJSONCreated
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
    private static testMethod void testEnvJSONCreated() {
        getRecords();
    }  
    
    /***************************************************************************************************
    * Method Name: testEnvMultiSelectPicklistWithBreak
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
    private static testMethod void testEnvMultiSelectPicklistWithBreak() {
        getRecords();
    }       
    
}