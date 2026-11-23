/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_CaseComments_Test
* Version     : 1.0 
* Created Date: 15 Dec 2017 
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         12/15/2017              This class is for testing the business use Case Comments.This single will take care of tesing all the versions of Case Comments API
*****************************************************************************************************************************************/
@isTest public class Core_RestAPI_CaseComments_Test{

    private static final String v1_0 = 'v1.0';
    private static User adminUser  = null;
    private static User commUser  = null;
    private static Case objCase = null;
    
    @testSetup 
    public static void setupData(){
        Core_RestAPI_TestUtilities.setupCustomSetting();
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        Test.startTest();
        System.runAs(adminUser){
            Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
            commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact)];
            List<Case> lstCase = Core_RestAPI_TestUtilities.getListOfCases(10);
            for(Integer i =0;i<lstCase.size()/2;i++){
                Case c = lstCase[i];
                c.OwnerId = commUser.Id;
            }
            for(Integer i =lstCase.size()/2;i<lstCase.size();i++){
                Case c = lstCase[i];
                c.OwnerId = adminUser.Id;
            }
            insert lstCase;
            /*Core_IPS_Labels__c ipsLabel = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS');

            if(ipsLabel == null) {
            ipsLabel = new Core_IPS_Labels__c(Name= 'PUBLIC_TO_CUSTOMERS');
            ipsLabel.Value__c = 'Public to Customers';
            insert ipsLabel;
            } */ //Already inserting in testutil
            List<Core_IPS_Case_Comments__c> lstCaseComments = Core_RestAPI_TestUtilities.getCaseComments(10);
            System.debug('lstCaseComments --->'+lstCaseComments);
            for(Integer i=0 ;i< lstCaseComments.size();i++){
                Core_IPS_Case_Comments__c objComments = lstCaseComments[i];
                objComments.Core_IPS_Case__c = lstCase[i].id;
            }
            insert lstCaseComments;
            System.debug('lstCaseComments --->'+lstCaseComments);
        }
       
       Test.StopTest();
    }
    //Pass the version, the method returns the request based on the version number 
    private static RestRequest doGet_getCaseComments_VersionRequest(String version){
        RestRequest request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'GET';
        if(v1_0.equals(version)){
            objCase = [Select CaseNumber FROM Case where OwnerId =: commUser.Id Limit 1];
            System.debug('objCase-->'+objCase);
            request.requestURI ='/v1.0/cases/'+objCase.CaseNumber+'/comments/'; 
            request.resourcePath ='/services/apexrest/v1.0/cases/'+objCase.CaseNumber+'/comments/';
        }
        return request;
    }
     // Asserts for the responses of Case Comments list
      private static void getCaseComments_Asserts(Core_RestAPI_Response apiResponse, RestResponse objResponse, String strVersion) {
        
        //Consolidate asserts so that each test method does not have to copy/paste the logic
        //expand if statement when multiple versions share the same asserts
        If(strVersion == v1_0){ 
            System.assertEquals('200' ,apiResponse.Code,'RestAPIResponse Success code 200');
            System.assertNotEquals(null, apiResponse);
            System.assertEquals(true, apiResponse.isSuccess);
            System.assertNotEquals(null, apiResponse.successContent);
            //check for all sharing Case  are retrieved
            System.assertEquals(1,apiResponse.successContent.size(), 'All Admin user Case Comments retrieved ');
        }
        //Common Asserts for all versions
        //Verify the transaction log is created
        if(LABEL.Core_RestAPI_Transaction_Switch == 'ON'){
            try{
                Core_RestAPI_Transaction_Entry__c log = [Select Id FROM Core_RestAPI_Transaction_Entry__c Limit 1];    
                System.assertNotEquals(null, log);
            }catch(Exception e){
                //Fail if log entry is not found when 
                System.assert(null);
            }
        }
    }
     //Our Test Class Starts from here 
    //Here Test doGet method in Core_RestAPI_CaseCommentsV1
    @isTest public static void test_doGet_getCaseComments_V1(){
        commUser  = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        RestContext.request = doGet_getCaseComments_VersionRequest(v1_0);//v1_0 is the parameter (String) of doGet_getCaseComments_VersionRequestRequest
        System.runAs(commUser){
            Core_RestAPI_Response apiResponse = Core_RestAPI_CaseCommentsV1.doGet();
            System.assertEquals('200' ,apiResponse.code);
            getCaseComments_Asserts(apiResponse,null,v1_0);
            
            
        } 
    }
 }