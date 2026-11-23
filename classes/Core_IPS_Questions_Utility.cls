/********************************************************************************
Class Name:  Core_IPS_Questions_Utility
Description:   used to return to the case tab
Used in     :  Case Creation, Case Clone
Modification Log :
* Developer              Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh               12/18/2017             Created - US8534
**********************************************************************************/    

public class Core_IPS_Questions_Utility {
    
    /********************************************************************************
    Method Name:  getAllFieldsSObjectQuery
    Description:   To get all fields query formation
    Used in     :  Case Creation, Case Clone
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh               12/18/2017             Created   -  US8534
    **********************************************************************************/    
    @TestVisible
    private static String getAllFieldsSObjectQuery(Schema.DescribeSObjectResult describeResult) {       
        //DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(SObjectApi);        
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );      
        String stQuery = 'SELECT ' + String.join(fieldNames, ',') + ' FROM ' + describeResult.getName();
        return stQuery;
    }
    
    /********************************************************************************
    Method Name:  getCoreAnswers
    Description:   Get all Core Answer Records related to list of Core Question Ids
    Used in     :  Case Creation, Case Clone
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh               12/18/2017             Created   -  US8534
    **********************************************************************************/    
    public static List<Core_IPS_Answer__c> getCoreAnswers(List<Id> lstQuestionId) {
        String strQuery = getAllFieldsSObjectQuery(Core_IPS_Answer__c.sObjectType.getDescribe());
        strQuery += ' WHERE Core_IPS_Status__c=\'Active\' AND Core_IPS_Question__c IN :lstQuestionId AND Core_IPS_Question__c!=null ORDER BY Core_IPS_Order_No__c,Core_IPS_Answer__c';
        return Database.query(strQuery);
    }
    
    /********************************************************************************
    Method Name:  getCoreAnswersByParentAnswer
    Description:   Get all Core Answer Records related to Parent Answer
    Used in     :  Case Creation, Case Clone
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh               12/18/2017             Created   -  US8534
    **********************************************************************************/
    public static List<Core_IPS_Answer__c> getCoreAnswersByParentAnswer(Id ParentAnswerId) {
        return getCoreAnswersByParentAnswer(new List<Id>{ParentAnswerId});
    }
    
    /********************************************************************************
    Method Name:  getCoreAnswersByParentAnswer
    Description:   Get all Core Answer Records related to list of Parent Answer Ids
    Used in     :  Case Creation, Case Clone
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh               12/18/2017             Created   -  US8534
    **********************************************************************************/
    public static List<Core_IPS_Answer__c> getCoreAnswersByParentAnswer(List<Id> lstParentAnswerId) {
        String strQuery = getAllFieldsSObjectQuery(Core_IPS_Answer__c.sObjectType.getDescribe());
        strQuery += ' WHERE Core_IPS_Status__c=\'Active\' AND Core_IPS_Parent_Answer__c IN :lstParentAnswerId AND Core_IPS_Parent_Answer__c!=null ORDER BY Core_IPS_Order_No__c,Core_IPS_Answer__c';
        return Database.query(strQuery);
    }
    
    /********************************************************************************
    Method Name:  getEnvDetailQuestions
    Description:   Get all Environment Details Operational related to product/subcategory
    Used in     :  Case Creation, Case Clone
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh               12/18/2017             Created   -  US8534
    * Modified               09/03/2018             Order by order number field US113683
    **********************************************************************************/
    public static List<Core_IPS_Assigned_Environment_Variables__c> getEnvDetailQuestions(String productId, String SubCatId,boolean isAgent){
        String strQuery = 'SELECT Id, Name, Core_IPS_Question__c,Core_IPS_Question__r.Name,Core_IPS_Question__r.Core_IPS_Question__c,'+ 
                          'Core_IPS_Question__r.Core_IPS_Datatype__c, Core_IPS_Question_Text__c,Core_Product_Issue_Sub_Category__c,Core_Required__c,'+
                          'Core_Agent_Only__c,Core_Environment_Variable__c,Core_IPS_Question__r.Core_IPS_Parent_Question__c'+ 
                          ' FROM Core_IPS_Assigned_Environment_Variables__c'+ 
                          ' WHERE Core_Status__c=\'Active\' AND Core_IPS_Question__c!=null '; // Added by Prem "Core_IPS_Question_Text__c" for US72555
         system.debug('>>>productId>>>: ' + productId+'..SubCatId'+SubCatId+'isAgent..'+isAgent);
        if(SubCatId!=null){
            strQuery += ' AND Core_Product_Issue_Sub_Category__c=:SubCatId AND Core_Product_Issue_Sub_Category__c!=null';
        }else{
            strQuery += ' AND Core_supported_product__c =:productId and Core_supported_product__c!=null';
        }
        if(isAgent!=null && !isAgent){    
            strQuery += ' AND Core_Agent_Only__c!=true';
        }
        System.debug('query..line97..'+strQuery);
        //Added Core_IPS_Order_No__c field by karthick as part of US113683
        strQuery += ' ORDER BY Core_IPS_Question__r.Core_IPS_Order_No__c ASC';
       // strQuery ='SELECT Id,Core_Product_Issue_Sub_Category__c,Name,Core_supported_product__c,Core_Status__c,Core_IPS_Question__c,Core_Agent_Only__c FROM Core_IPS_Assigned_Environment_Variables__c';// where Core_Status__c=\'Active\' AND Core_IPS_Question__c!=null';
        system.debug('>>>strQuery : ' + strQuery);
       
        
         List<Core_IPS_Assigned_Environment_Variables__c>  listCoreAttrbutr = Database.query(strQuery);
         system.debug('====listCoreAttrbutr '+listCoreAttrbutr+'Size...'+listCoreAttrbutr.size());
       // return Database.query(strQuery);
        return listCoreAttrbutr;
    }
    
    /********************************************************************************
    Method Name:  getEnvDetailCoreResponse
    Description:   Get all Core Response Related to Case
    Used in     :  Case Creation, Case Clone
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh               12/18/2017             Created   -  US8534
    **********************************************************************************/
    public static List<Core_IPS_Response__c> getEnvDetailCoreResponse(Id caseId) {
        return [SELECT Id,Core_IPS_Answer__c,Core_IPS_Question_Master__c,Core_IPS_Answer_Master__c,Core_IPS_Agent_Only__c FROM Core_IPS_Response__c WHERE Core_IPS_Case__c=:caseId AND Core_IPS_Question_Master__r.RecordType.DeveloperName='EDQ'];        
    }
    
    /********************************************************************************
    Method Name:  getQues2AnswerMapId
    Description:   Construct Map of Core Question Id and Map of Answer Id and String 
                   based on provided list of Questions
    Used in     :  Case Creation, Case Clone
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh               12/18/2017             Created   -  US8534
    **********************************************************************************/
    public static Map<Id,Map<Id,String>> getQues2AnswerMapId(List<Id> lstQuesId) {
        Map<Id,Map<Id,String>> mapQues2AnswerMap = new Map<Id,Map<Id,String>>();
        for(Core_IPS_Answer__c objAns : Core_IPS_Questions_Utility.getCoreAnswers(lstQuesId)) {
            if(!mapQues2AnswerMap.containsKey(objAns.Core_IPS_Question__c)) {
                mapQues2AnswerMap.put(objAns.Core_IPS_Question__c, new Map<Id,String>());
            }
            mapQues2AnswerMap.get(objAns.Core_IPS_Question__c).put(objAns.Id, objAns.Core_IPS_Answer__c);
        }
        return mapQues2AnswerMap;
    }
    
    /********************************************************************************
    Method Name:  constructSelectOptionList
    Description:   Construct selectOption list based on Map
    Used in     :  Case Creation, Case Clone
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh               12/18/2017             Created   -  US8534
    **********************************************************************************/
    public static List<SelectOption> constructSelectOptionList(Map<Id,String> mapOption) {
        List<SelectOption> lstSelectOption = new List<SelectOption>();
        lstSelectOption.add(new SelectOption('','--Select Option--'));
        if(mapOption!=null) {
            for(Id optionId : mapOption.keySet()) {
                lstSelectOption.add(new SelectOption(optionId, mapOption.get(optionId)));            
            }
        }
        return lstSelectOption;
    }
    
    /********************************************************************************
    Method Name:  constructResponse
    Description:  construct list of Core Response records
    Used in     :  Case Creation, Case Clone
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh               12/18/2017             Created   -  US8534
    **********************************************************************************/
    public static List<Core_IPS_Response__c> constructResponse(Core_IPS_EnvironmentDetailQuestion det, Case objCase) {
        List<Core_IPS_Response__c> lstEnvResponse = new List<Core_IPS_Response__c>();
        Core_IPS_Response__c envResponse = new Core_IPS_Response__c();
        envResponse.Core_IPS_Question_Master__c = det.questionId;
        envResponse.Core_IPS_Case__c = objCase.Id;
        envResponse.Core_IPS_Agent_Only__c = det.IsAgentOnly;
        
        if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c.trim()) {
            envResponse.Core_IPS_Answer__c = det.sPlaceHolder;                    
        } else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c) {
            envResponse.Core_IPS_Answer__c = det.tPlaceHolder;
        } else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c ) {
            if(String.isNotBlank(det.selectedValue))
                envResponse.Core_IPS_Answer_Master__c = det.selectedValue;
            else
                envResponse.Core_IPS_Answer_Master__c = null;
        }  
        if(det.type == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c) {
            if(det.selectedMValue!=null && det.selectedMValue.size()>0) {
                for(String strSelected : det.selectedMValue) { 
                    if(String.isNotBlank(strSelected)) {
                        lstEnvResponse.add(makeIPSResponse(objCase.Id, det.questionId, strSelected, det.IsAgentOnly));
                    } else if(det.selectedMValue.size()==1) {
                        lstEnvResponse.add(makeIPSResponse(objCase.Id, det.questionId, null, det.IsAgentOnly));
                    }                
                }
            } else {                
                lstEnvResponse.add(makeIPSResponse(objCase.Id, det.questionId, null, det.IsAgentOnly));
            }
            
        } else {
            lstEnvResponse.add(envResponse);
        }
        return lstEnvResponse;
    }
    
    /********************************************************************************
    Method Name:  makeIPSResponse
    Description:   construct a Core Response record
    Used in     :  Case Creation, Case Clone
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh               12/18/2017             Created   -  US8534
    **********************************************************************************/
    private static Core_IPS_Response__c makeIPSResponse(Id CaseId, Id QuestionId, Id AnswerId, Boolean isAgentOnly) {
        return new Core_IPS_Response__c(
            Core_IPS_Case__c = CaseId,
            Core_IPS_Question_Master__c = QuestionId,
            Core_IPS_Agent_Only__c = isAgentOnly,
            Core_IPS_Answer_Master__c = AnswerId
        );
    }
    
    /********************************************************************************
    Method Name:  getAllWithChildEnvDetails
    Description:   Get all Environment Details Data along with child questions
    Used in     :  Case Creation, Case Clone
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh               12/18/2017             Created   -  US8534
    **********************************************************************************/
    public static List<Core_IPS_EnvironmentDetailQuestion> getAllWithChildEnvDetails(List<Core_IPS_EnvironmentDetailQuestion> lstWEnvDet) {
        List<Core_IPS_EnvironmentDetailQuestion> lstAllWEnvDet = new List<Core_IPS_EnvironmentDetailQuestion>();
        for(Core_IPS_EnvironmentDetailQuestion wEnvDet : lstWEnvDet) {
            lstAllWEnvDet.add(wEnvDet);
            if(wEnvDet.childQuestions.size()>0) {
                lstAllWEnvDet.addAll(getAllWithChildEnvDetails(wEnvDet.childQuestions));
            }
        }
        return lstAllWEnvDet;
    }
    
    /********************************************************************************
    Method Name:  recordEditAccessMap
    Description:   Check if edit access to records
    Used in     :  Case Creation, Case Clone
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh               12/18/2017             Created   -  US8534
    **********************************************************************************/
    public static Map<Id,Boolean> recordEditAccessMap(Set<Id> lstRecordId, Id UserId) {
        Map<Id,Boolean> recordEditAccessMap = new Map<Id,Boolean>();
        for(UserRecordAccess objURA : [SELECT RecordId,HasEditAccess FROM UserRecordAccess WHERE UserId=:UserId AND RecordId IN :lstRecordId]) {
            recordEditAccessMap.put(objURA.RecordId, objURA.HasEditAccess);
        }
        return recordEditAccessMap; 
    }

}