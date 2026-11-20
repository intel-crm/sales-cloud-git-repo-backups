/***************************************************************************************************
Class Name:  Core_IPS_EnvironmentDetailQuestion_Test
Class Type: Test Class 
Description:   This class contains unit test scenarios for Core_IPS_EnvironmentDetailQuestion Apex Class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh                  01/19/2018                Created
****************************************************************************************************/ 
@isTest
private class Core_IPS_EnvironmentDetailQuestion_Test {
    
    static List<Core_IPS_Supported_Product__c> ListOfSupportedProduct;
    static Id ControllingQuesId;
    
    static void getRecords() {
        Profile ps = [select id, name from Profile where  name = 'System Administrator' limit 1];        
        User sysAdimUser = TestUtilities.getUser();
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
            
            List<Core_IPS_Question__c> lstCoreQuestion = TestUtilities.getlstCoreQuestion(5);    
            for(Core_IPS_Question__c objQues : lstCoreQuestion) {
                objQues.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).id;
            }
            lstCoreQuestion[1].Core_IPS_Datatype__c = 'Text Area';
            //lstCoreQuestion[6].Core_IPS_Datatype__c = 'Text Area';
            lstCoreQuestion[2].Core_IPS_Datatype__c = 'Picklist';
            lstCoreQuestion[4].Core_IPS_Datatype__c = 'Picklist';
            //lstCoreQuestion[7].Core_IPS_Datatype__c = 'Picklist';
            lstCoreQuestion[3].Core_IPS_Datatype__c = 'Multiselect Picklist';
            //lstCoreQuestion[8].Core_IPS_Datatype__c = 'Multiselect Picklist';
            
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
            }     
            insert EnvironmentalDetailsList;
            System.assert(EnvironmentalDetailsList[0].Id != null, 'Record not created');
            
        }
    }
    
    static testmethod void Core_IPS_EnvironmentDetailQuestion() {
        getRecords();
        Core_IPS_EnvironmentDetailQuestion wrapEDQ = new Core_IPS_EnvironmentDetailQuestion();
        wrapEDQ.selectedMValue = new List<string>();
        wrapEDQ.selectedParentAnswer = null;
        List<Core_IPS_EnvironmentDetailQuestion> lstEDQ = constructWrapper(Core_IPS_Questions_Utility.getEnvDetailQuestions(ListOfSupportedProduct.get(0).Id,null,true));
        System.assert(lstEDQ.size()>0, 'EDQ Process unsuccessful');
        for(Core_IPS_EnvironmentDetailQuestion objEDQ : lstEDQ) {
            if(objEDQ.questionId==ControllingQuesId) {
                objEDQ.renderDependentQuestions();
                objEDQ.selectedValue = objEDQ.pplaceholder.get(1).getValue();
                objEDQ.renderDependentQuestions();
            }
        }
    }
    
    static List<Core_IPS_EnvironmentDetailQuestion> constructWrapper(List<Core_IPS_Assigned_Environment_Variables__c> envVars){
        Map<Id,Core_IPS_Assigned_Environment_Variables__c> MapAssigned_EnvironmentVariables = new Map<Id,Core_IPS_Assigned_Environment_Variables__c>();
        Map<Id,Set<Id>> mapQuesParentId2DependentId = new Map<Id,Set<Id>>();
        boolean IsOptionsChanges =  false;
        for(Core_IPS_Assigned_Environment_Variables__c Ev : envVars)
        {
            if(Ev.Core_IPS_Question__c!=null && String.isNotBlank(Ev.Core_IPS_Question__r.Core_IPS_Question__c)) 
            {
                MapAssigned_EnvironmentVariables.put(Ev.Core_IPS_Question__c, ev); 
                // define the questions dependency
                if(Ev.Core_IPS_Question__r.Core_IPS_Parent_Question__c!=null) {
                    if(!mapQuesParentId2DependentId.containsKey(Ev.Core_IPS_Question__r.Core_IPS_Parent_Question__c)) {
                        mapQuesParentId2DependentId.put(Ev.Core_IPS_Question__r.Core_IPS_Parent_Question__c, new Set<Id>());
                    }                    
                    mapQuesParentId2DependentId.get(Ev.Core_IPS_Question__r.Core_IPS_Parent_Question__c).add(Ev.Core_IPS_Question__c);
                }                
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
                det.splaceHolder = '';
                if(mapQues2AnswerMap.containsKey(en.Core_IPS_Question__c)) {
                    Map<Id,String> mapAns = mapQues2AnswerMap.get(en.Core_IPS_Question__c);
                    if(mapAns.values().size()>0) {
                        det.splaceHolder = mapAns.values().get(0);
                    }
                } 
                
            }else if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim()== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim() || en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c.trim()){
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
                det.selectedValue=selectOptionsList.get(0).getValue();                
            } else if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c.trim()){   // added  by amritesh 12/18/2017 - US85344          
                det.type=Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c.trim();
                det.tplaceHolder= '';
                if(mapQues2AnswerMap.containsKey(en.Core_IPS_Question__c)) {
                    Map<Id,String> mapAns = mapQues2AnswerMap.get(en.Core_IPS_Question__c);
                    det.tplaceHolder = String.join(mapAns.values(), '\r\n');
                } 
            }
            if(mapQuesParentId2DependentId.containsKey(en.Core_IPS_Question__c)) {
                det.hasChildQuestions = true;
            }
            if(en.Core_IPS_Question__r.Core_IPS_Parent_Question__c!=null) {
                det.hasParentQuestion = true;
                det.isVisible = false;
            }
            mapEnvDetail.put(en.Core_IPS_Question__c, det);            
        }
        
        List<Core_IPS_EnvironmentDetailQuestion> lstEnvDetail = new List<Core_IPS_EnvironmentDetailQuestion>();
        for(Id quesId : mapEnvDetail.keySet()) { 
            if(!mapEnvDetail.get(quesId).hasParentQuestion) {
                createQuestionHierachy(quesId, mapEnvDetail, mapQuesParentId2DependentId);
            }
        }
        for(Id quesId : mapEnvDetail.keySet()) {
            if(!mapEnvDetail.get(quesId).hasParentQuestion) {
                lstEnvDetail.add(mapEnvDetail.get(quesId));
            }
        }        
        return lstEnvDetail;
    }
    
    private static void createQuestionHierachy(Id quesId, Map<Id,Core_IPS_EnvironmentDetailQuestion> mapEnvDetail, Map<Id,Set<Id>> mapQuesParentId2DependentId) {        
        if(mapQuesParentId2DependentId.containsKey(quesId)) {
            for(Id childQuesId : mapQuesParentId2DependentId.get(quesId)) {
                if(mapEnvDetail.containsKey(childQuesId)) {
                    createQuestionHierachy(childQuesId, mapEnvDetail, mapQuesParentId2DependentId);                       
                    mapEnvDetail.get(quesId).childQuestions.add(mapEnvDetail.get(childQuesId));
                }
            }
        }        
    }
    
}