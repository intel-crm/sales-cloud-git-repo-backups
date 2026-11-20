@isTest
public class Core_IPS_MAG_Questionnaire_Lex_Test {
    
    @testSetup 
    static void TestData() {
        String sysAdminProfileID = [select id, name from Profile where name = 'System Administrator' Limit 1].Id;
        
        User sysadmin = TestUtilities.getUser();
        sysadmin.ProfileID =  sysAdminProfileID;  
        sysadmin.username='intel.com.crm@intel.com';  
        //sysadmin.Core_User_Country_Code__c ='DEU';     
        insert sysadmin;
        
        System.runAs(sysadmin) {
            Case objCase = TestUtilities.getCase();
            objCase.RecordTypeId = schema.sobjecttype.Case.getrecordtypeinfosbyname().get('IPS Case Create').getRecordTypeId();
            insert objCase;
            
            Id magRecordTypeId = schema.sobjecttype.Core_IPS_Question__c.getrecordtypeinfosbyname().get('MAG Question').getRecordTypeId();
            List<Core_IPS_Question__c> lstQues = new List<Core_IPS_Question__c>();
            lstQues.add(new Core_IPS_Question__c( RecordTypeId=magRecordTypeId, Core_IPS_Order_No__c=1, Core_IPS_Question__c='Question 1', Core_IPS_DataType__c='Picklist', Core_IPS_Status__c = 'Active'));
            lstQues.add(new Core_IPS_Question__c( RecordTypeId=magRecordTypeId, Core_IPS_Order_No__c=2, Core_IPS_Question__c='Question 2', Core_IPS_DataType__c='Multiselect Picklist', Core_IPS_Status__c = 'Active'));
            lstQues.add(new Core_IPS_Question__c( RecordTypeId=magRecordTypeId, Core_IPS_Order_No__c=3, Core_IPS_Question__c='Question 3', Core_IPS_DataType__c='Text Area', Core_IPS_Status__c = 'Active',Core_IPS_Required__c=True));
            insert lstQues;
            
            List<Core_IPS_Answer__c> lstAns = new List<Core_IPS_Answer__c>();
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[0].Id, Core_IPS_Order_No__c=1, Core_IPS_Answer__c='Yes'));
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[0].Id, Core_IPS_Order_No__c=2, Core_IPS_Answer__c='No'));
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[1].Id, Core_IPS_Order_No__c=3, Core_IPS_Answer__c='None'));
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[1].Id, Core_IPS_Order_No__c=4, Core_IPS_Answer__c='MSP1'));
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[1].Id, Core_IPS_Order_No__c=4, Core_IPS_Answer__c='MSP2'));
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[2].Id, Core_IPS_Order_No__c=4, Core_IPS_Answer__c='MSP3'));
            insert lstAns;
            
            lstQues[0].Core_IPS_Environment_Detail_Answer__c = lstAns[0].id;
            lstQues[1].Core_IPS_Environment_Detail_Answer__c = lstAns[2].id;
            lstQues[2].Core_IPS_Environment_Detail_Answer__c = lstAns[5].id;
            update lstQues;
            
            List<Core_IPS_Response__c> lstResponse = new List<Core_IPS_Response__c>();
            lstResponse.add(new Core_IPS_Response__c(Core_IPS_Case__c=objCase.id,Core_IPS_Question_Master__c=lstQues[0].id,Core_IPS_Answer_Master__c=lstAns[0].id));
            lstResponse.add(new Core_IPS_Response__c(Core_IPS_Case__c=objCase.id,Core_IPS_Question_Master__c=lstQues[1].id,Core_IPS_Answer_Master__c=lstAns[1].id));
            lstResponse.add(new Core_IPS_Response__c(Core_IPS_Case__c=objCase.id,Core_IPS_Question_Master__c=lstQues[1].id,Core_IPS_Answer_Master__c=lstAns[2].id));
            insert lstResponse;
            
            Core_IPS_Labels__c objLabel = new Core_IPS_Labels__c(Name='Core_IPS_MSP_Order', Value__c='2');
            insert objLabel;
            Core_IPS_Labels__c objLabel2 = new Core_IPS_Labels__c(Name='MINDS_Questionnaire_Completed', Value__c='MAG Questionnaire Completed');
            insert objLabel2 ;
        }
    }  
    
    static testmethod void MAG_Questionnaire_ConTest1(){                 
        Case ca = [SELECT Id,Core_Sub_Status__c,Status,Core_IPS_GEC_Request_Status__c FROM Case LIMIT 1];
        Test.startTest();
        List<Core_IPS_MAG_Questionnaire_Lex.Wrap_Question> wrap = Core_IPS_MAG_Questionnaire_Lex.getMINDSQuestions(ca.Id);
        List<Core_IPS_MAG_Questionnaire_Lex.Wrap_Question> rend = Core_IPS_MAG_Questionnaire_Lex.renderDependentQuestions('1',ca.Id);
        Boolean check = Core_IPS_MAG_Questionnaire_Lex.getCaseStatus(ca.Id);
        List<Core_IPS_Question__c> lstQues = [SELECT Id FROM Core_IPS_Question__c];
        List<Core_IPS_Answer__c> lstAns = [SELECT Id FROM Core_IPS_Answer__c];
        string mndData = '[{"edq":[{"question":"'+ lstQues[1].Id  +'","selectedValues":"'+ lstAns[2].Id  +'","required":false,"answerType":"Multiselect Picklist","val":true}]},{"edq":[{"question":"'+ lstQues[0].Id +'","selectedValues":"'+ lstAns[0].Id  +'","required":false,"answerType":"Picklist","val":true}]},{"edq":[{"question":"'+ lstQues[2].Id +'","selectedValues":"Test Value","required":true,"answerType":"text area","val":true}]}]';
        Core_IPS_MAG_Questionnaire_Lex.saveAnswer(mndData,ca.Id);
        Test.stopTest();     
    }
}