@isTest
public class PRM_CDB_CompanyValidation_APICalloutTest {
    @testSetup
    public static void setup(){
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert cprogram;
        
        List<PRM_Registration_Request__c> regReqInsertList = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c regReq = new PRM_Registration_Request__c();
        
        regReq.PRM_First_Name__c = 'Test Request';
        regReq.PRM_Last_Name__c = 'New';
        regReq.PRM_Email_ID__c='testrequest@mailinator.com';
        regReq.PRM_Account_Name__c='Dell US';
        regReq.PRM_Account_URL__c='www.rdc.com';
        regReq.PRM_Address_Line_1__c='4th Floor,ITPL,Brookfield';
        regReq.PRM_City__c='Bengaluru';
        regReq.PRM_State_Province__c='Karnataka';
        regReq.PRM_Channel_Program__c = cprogram.Id;
        regReq.PRM_Status__c='New';
        regReq.PRM_Salesforce_ID__c=null;
        regReq.PRM_Country__c='India';
        
        regReqInsertList.add(regReq);
        
        Database.SaveResult[] results = Database.insert(regReqInsertList);
        system.debug('RegInsertResult>>'+results);
        
    }
    @isTest
    public static void publishAndSubscribeEvent(){
        List<PRM_Registration_Request__c> newRegList = [Select id from PRM_Registration_Request__c where PRM_Email_ID__c='testrequest@mailinator.com'];
        List<PRM_CDB_Platform_Event__e> events = new List<PRM_CDB_Platform_Event__e>();
        if (!newRegList.isEmpty()){
            for(PRM_Registration_Request__c newReg : newRegList){
                events.add(new PRM_CDB_Platform_Event__e(
                    Core_Record_Id__c = newReg.Id
                    
                ));
            }
            Test.startTest();
            if (!events.isEmpty()) {
                Database.SaveResult[] results = EventBus.publish(events);
                Test.getEventBus().deliver();
            }
            Test.stopTest();
            
        }
    }
    @isTest
    public static void reValidateCompanyDetails(){
        List<PRM_Registration_Request__c> newRegList = [Select id from PRM_Registration_Request__c where PRM_Email_ID__c='testrequest@mailinator.com'];
        List<PRM_CDB_CompanyValidation_APICallout.FlowInputs> regList = new List<PRM_CDB_CompanyValidation_APICallout.FlowInputs>();
        PRM_CDB_CompanyValidation_APICallout.FlowInputs regReq = new PRM_CDB_CompanyValidation_APICallout.FlowInputs();
        regReq.reValidateNewReg = newRegList;
        regList.add(regReq);
        PRM_CDB_CompanyValidation_APICallout.reValidateCompanyDetails(regList);
    }
    
    @IsTest
    static void testStringifyErrors() {
        
        PRM_Registration_Request__c newReg = new PRM_Registration_Request__c(); // Missing required Name field
        Database.SaveResult[] results = Database.insert(
            new List<PRM_Registration_Request__c>{ newReg }, false
        );
        
        List<Database.Error> errs = results[0].getErrors();
        
        String result = PRM_CDB_CompanyValidation_APICallout.stringifyErrors(errs);
        
        System.assert(result.contains('REQUIRED_FIELD_MISSING'),
                      'Expected REQUIRED_FIELD_MISSING error in result');
    }
    
}