/***************************************************************************************************
Class Name:  Core_IPS_Questions_Utility_Test
Class Type: Test Class 
Description:   This class contains unit test scenarios for Core_IPS_Questions_Utility Apex Class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh                  01/19/2018                Created
****************************************************************************************************/ 
@isTest
private class Core_IPS_Questions_Utility_Test {
    
    static List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = new List<Core_IPS_Supported_Product__c>();
    static List<Id> lstQuesId = new List<Id>();
    static Id ControllingQuesId;
    static Id ControllingAnsId;
    static Case CaseRecord = new Case();
    static User sysAdimUser;
    
    static void getRecords() {
        Profile ps = [select id, name from Profile where  name = 'System Administrator' limit 1];        
        sysAdimUser = TestUtilities.getUser();
        sysAdimUser.ProfileId = ps.id;
        insert sysAdimUser;
        System.runAs(sysAdimUser) {     
            List<Core_IPS_Labels__c>  LstLabels = TestUtilities.getIPSLabel();
            insert LstLabels;
            
            // Create Support Org Record
            List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
            insert ListOfSupportOrg;
            System.assert(ListOfSupportOrg != null, 'Support Org Record not created');
            
            // Create Product2 Record
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
            insert ListOfProducts;
            System.assert(ListOfProducts[0].id != null,'Product2 Record not created');
            
            // Create Supported product Record
            ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
            ListOfSupportedProduct.get(0).Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            insert ListOfSupportedProduct;
            System.assert(ListOfSupportedProduct[0].id != null,'Supported product Record not created');
            
            CaseRecord = new Case ();
            //CaseRecord.AccountId=ListOfAccounts.get(0).Id;
            //CaseRecord.AssetId=ListOfAssets.get(0).Id;
            CaseRecord.Core_IPS_Supported_Product__c=ListOfSupportedProduct.get(0).id;
            //CaseRecord.ContactId=ListOfContacts.get(0).id;        
            CaseRecord.Core_IPS_Product_Org1__c=ListOfSupportOrg.get(0).id;
            //CaseRecord.Core_Case_Issue_Category__c = caseCat.id;
            //CaseRecord.Core_case_issue_sub_category__c = subCategory.id;
            CaseRecord.Core_Issue_Description__c = 'test';
            CaseRecord.Subject='TestSubject';
            CaseRecord.Core_CaseType__c='Issue';
            //CaseRecord.core_ips_project_case__c=projectcase.id;
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
            CaseRecord.recordTypeId = RT.Id;
            insert CaseRecord;
            
            List<Core_IPS_Question__c> lstCoreQuestion = TestUtilities.getlstCoreQuestion(5);    
            for(Core_IPS_Question__c objQues : lstCoreQuestion) {
                objQues.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).id;
            }
            lstCoreQuestion[1].Core_IPS_Datatype__c = 'Text Area';
            lstCoreQuestion[2].Core_IPS_Datatype__c = 'Picklist';
            lstCoreQuestion[4].Core_IPS_Datatype__c = 'Picklist';
            lstCoreQuestion[3].Core_IPS_Datatype__c = 'Multiselect Picklist';
            
            insert lstCoreQuestion;
            System.assert(lstCoreQuestion[0].Id != null, 'Record not created');
            
            lstCoreQuestion[4].Core_IPS_Parent_Question__c = lstCoreQuestion[2].Id;
            update lstCoreQuestion[4];
            
            ControllingQuesId = lstCoreQuestion[2].Id;
            
            List<Core_IPS_Answer__c> lstAnswer = new List<Core_IPS_Answer__c>();
            Map<Id,List<Core_IPS_Answer__c>> mapQuesId2Ans = new Map<Id,List<Core_IPS_Answer__c>>();
            for(Core_IPS_Question__c objQues : lstCoreQuestion) {
                mapQuesId2Ans.put(objQues.Id,new List<Core_IPS_Answer__c>());
                for(Core_IPS_Answer__c objAns : TestUtilities.getCoreAnswers(2)) {
                    objAns.Core_IPS_Question__c = objQues.Id;
                    lstAnswer.add(objAns);
                    mapQuesId2Ans.get(objQues.Id).add(objAns);
                }        
            }
            
            insert lstAnswer;
            System.assert(lstAnswer[0].Id != null, 'Record not created');
            
            ControllingAnsId = mapQuesId2Ans.get(lstCoreQuestion[2].Id)[0].Id;
            mapQuesId2Ans.get(lstCoreQuestion[4].Id)[0].Core_IPS_Parent_Answer__c = mapQuesId2Ans.get(lstCoreQuestion[2].Id)[0].Id;
            mapQuesId2Ans.get(lstCoreQuestion[4].Id)[1].Core_IPS_Parent_Answer__c = mapQuesId2Ans.get(lstCoreQuestion[2].Id)[1].Id;
            lstAnswer = new List<Core_IPS_Answer__c>{mapQuesId2Ans.get(lstCoreQuestion[4].Id)[0], mapQuesId2Ans.get(lstCoreQuestion[4].Id)[1]};
                update lstAnswer;
            
            //Creating Environmental Details Operational
            List<Core_IPS_Assigned_Environment_Variables__c> EnvironmentalDetailsList = new List<Core_IPS_Assigned_Environment_Variables__c>();
            for(integer i=0;i<5;i++){
                Core_IPS_Assigned_Environment_Variables__c EnvironmentalDetails = TestUtilities.getEnvironmentalDetailsOperational();
                EnvironmentalDetails.Core_IPS_Question__c = lstCoreQuestion[i].id;
                EnvironmentalDetails.Core_Required__c=true;
                EnvironmentalDetails.Core_supported_product__c = ListOfSupportedProduct[0].id;
                EnvironmentalDetailsList.add(EnvironmentalDetails);
                lstQuesId.add(lstCoreQuestion[i].Id);
            }     
            insert EnvironmentalDetailsList;
            System.assert(EnvironmentalDetailsList[0].Id != null, 'Record not created');
            
            List<Core_IPS_Response__c> lstResponse = new List<Core_IPS_Response__c>();
            for(Core_IPS_Question__c objQues : [SELECT Id,Core_IPS_Datatype__c,(SELECT Id, Core_IPS_Answer__c FROM Core_Answers__r LIMIT 1) FROM Core_IPS_Question__c]) {
                for(Core_IPS_Answer__c objAns : objQues.Core_Answers__r) {
                    Core_IPS_Response__c objResponse = new Core_IPS_Response__c();
                    objResponse.Core_IPS_Case__c = CaseRecord.Id;
                    if(String.isNotBlank(objQues.Core_IPS_Datatype__c) && String.valueOf(objQues.Core_IPS_Datatype__c).contains('Picklist')){
                        objResponse.Core_IPS_Answer_Master__c = objAns.Id;
                    }
                    objResponse.Core_IPS_Question_Master__c = objQues.Id;
                    objResponse.Core_IPS_Answer__c = objAns.Core_IPS_Answer__c;
                    lstResponse.add(objResponse);
                }
            }
            insert lstResponse;
        }
    }
    
    static testmethod void Core_IPS_EnvironmentDetailQuestion() {
        getRecords();
        String allFields = Core_IPS_Questions_Utility.getAllFieldsSObjectQuery(Core_IPS_Answer__c.SobjectType.getDescribe());
        List<Core_IPS_Answer__c> lstAnswer = Core_IPS_Questions_Utility.getCoreAnswers(lstQuesId);
        lstAnswer = Core_IPS_Questions_Utility.getCoreAnswersByParentAnswer(ControllingAnsId);
        lstAnswer = Core_IPS_Questions_Utility.getCoreAnswersByParentAnswer(new List<Id> { ControllingAnsId });
        List<Core_IPS_Assigned_Environment_Variables__c> lstEDO = Core_IPS_Questions_Utility.getEnvDetailQuestions(ListOfSupportedProduct[0].Id, null, true);
        List<Core_IPS_Response__c> lstResp = Core_IPS_Questions_Utility.getEnvDetailCoreResponse(CaseRecord.Id);
        Map<Id,Map<Id,String>> mapQues2Ans = Core_IPS_Questions_Utility.getQues2AnswerMapId(lstQuesId);
        List<SelectOption> lstOptions = Core_IPS_Questions_Utility.constructSelectOptionList(new Map<Id,String>{lstQuesId[0]=>'Ques1'}); 
        List<Core_IPS_EnvironmentDetailQuestion> lstEDQ = constructWrapper(lstEDO);
        for(Core_IPS_EnvironmentDetailQuestion objEDQ : lstEDQ) {
            lstResp.addAll(Core_IPS_Questions_Utility.constructResponse(objEDQ, CaseRecord));
        }
        //Core_IPS_Questions_Utility.makeIPSResponse(Id CaseId, Id QuestionId, Id AnswerId, Boolean isAgentOnly)
        List<Core_IPS_EnvironmentDetailQuestion> lstEDO2 = Core_IPS_Questions_Utility.getAllWithChildEnvDetails(lstEDQ);
        Map<Id,Boolean> mapAccess = Core_IPS_Questions_Utility.recordEditAccessMap(new Set<Id>{ControllingAnsId}, sysAdimUser.Id);
    }
    
    static List<Core_IPS_EnvironmentDetailQuestion> constructWrapper(List<Core_IPS_Assigned_Environment_Variables__c> envVars){
        Map<Id,Core_IPS_Assigned_Environment_Variables__c> MapAssigned_EnvironmentVariables = new Map<Id,Core_IPS_Assigned_Environment_Variables__c>();
              
        for(Core_IPS_Assigned_Environment_Variables__c Ev : envVars)
        {
            if(Ev.Core_IPS_Question__c!=null && String.isNotBlank(Ev.Core_IPS_Question__r.Core_IPS_Question__c)) 
            {
                MapAssigned_EnvironmentVariables.put(Ev.Core_IPS_Question__c, ev);                              
            }            
        }
        
        Map<Id,Map<Id,String>> mapQues2AnswerMap = new Map<Id,Map<Id,String>>();
        mapQues2AnswerMap = Core_IPS_Questions_Utility.getQues2AnswerMapId(new List<Id>(MapAssigned_EnvironmentVariables.keySet()));
        
        Map<Id,Core_IPS_EnvironmentDetailQuestion> mapEnvDetail = new Map<Id,Core_IPS_EnvironmentDetailQuestion>(); 
        
        for(Core_IPS_Assigned_Environment_Variables__c en : envVars){
            Core_IPS_EnvironmentDetailQuestion det = new Core_IPS_EnvironmentDetailQuestion();                     
            det.label = en.Core_IPS_Question__r.Core_IPS_Question__c; 
            det.questionId = en.Core_IPS_Question__c; 
            det.required = en.Core_required__c;
            det.IsAgentOnly = en.Core_Agent_Only__c;
            if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c.trim()) {                 
                det.type=Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c;
                det.splaceHolder = 'Text Value';                
            } else if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim()== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim() || en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c.trim()){
                List<SelectOption> selectOptionsList = new List<SelectOption>();
                SelectOptionsList.add(new SelectOption('','Select Option'));
                if(mapQues2AnswerMap.containsKey(en.Core_IPS_Question__c)) {
                    Map<Id,String> mapAns = mapQues2AnswerMap.get(en.Core_IPS_Question__c);
                    for(Id ansId : mapAns.keySet()) {
                        selectOptionsList.add(new SelectOption(ansId, mapAns.get(ansId)));
                    }
                }                 
                if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim()== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim()){ 
                    det.type=Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim();
                } else{
                    det.type=Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c.trim();
                }
                det.pplaceholder=selectOptionsList;
                det.selectedValue=selectOptionsList.get(1).getValue();   
                det.selectedMValue= new List<String>{selectOptionsList.get(1).getValue()};   
            } else if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c.trim()){   
                det.type=Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c.trim();
                det.tplaceHolder= 'Text Area Test';
            }
            mapEnvDetail.put(en.Core_IPS_Question__c, det);            
        }       
        return mapEnvDetail.values();
    }

}