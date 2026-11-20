public without sharing class Core_IPS_MAG_Questionnaire_Lex {

    @AuraEnabled(cacheable = true)
    public static Boolean getCaseStatus(Id recordId) {
        Boolean isEditable = false;
        Case cs = [SELECT Id,Core_Sub_Status__c,Status FROM Case WHERE Id = :recordId WITH SECURITY_ENFORCED];
        if(cs.Core_Sub_Status__c == 'GEC Hold' && cs.Status == 'On Hold'){
            isEditable = True;
        }
        return isEditable;
    }    
   
    @AuraEnabled(cacheable = true)
    public static List<Wrap_Question> getMINDSQuestions(Id recordId) {
        //showError = false;
        List<Core_IPS_Question__c> lstQuestion;
        List<Wrap_Question> lstQuestions = new List<Wrap_Question>();
        List<Core_IPS_Response__c> lstResponses = new List<Core_IPS_Response__c>();       
        Map<Id,Core_IPS_Answer__c> mapId2Answers = new Map<Id,Core_IPS_Answer__c>();
        Map<Id,Map<String,Id>> mapQues2AnswerStrMap = new Map<Id,Map<String,Id>>();
        Map<Id,List<Core_IPS_Answer__c>> mapQuesId2Answers = new Map<Id,List<Core_IPS_Answer__c>>();
        //return lstQuestions;

        if(Core_IPS_Question__c.SObjectType.getDescribe().isAccessible()){
            lstQuestion = new List<Core_IPS_Question__c>([SELECT Id,Name,Core_IPS_Datatype__c,Core_IPS_Environment_Detail_Answer__c,Core_IPS_Question__c,
                                                          Core_IPS_Required__c,Core_IPS_Order_No__c,Core_IPS_Environment_Detail_Answer__r.Core_IPS_Answer__c 
                                                          FROM Core_IPS_Question__c WHERE RecordType.DeveloperName='Core_IPS_MAG_Question' AND
                                                          Core_IPS_Status__c='Active' ORDER BY Core_IPS_Order_No__c ]);
        }

        if(Core_IPS_Answer__c.SObjectType.getDescribe().isAccessible()){
            for(Core_IPS_Answer__c objAnswer : [SELECT Id,Core_IPS_Answer__c,Core_IPS_Question__c
                                                FROM Core_IPS_Answer__c WHERE Core_IPS_Question__c IN :lstQuestion AND Core_IPS_Status__c='Active' 
                                                ORDER BY Core_IPS_Order_No__c,Name ASC]) 
            {
                mapId2Answers.put(objAnswer.id,objAnswer);
                Id quesId = objAnswer.Core_IPS_Question__c;
                if(!mapQuesId2Answers.containsKey(quesId)) {
                    mapQuesId2Answers.put(quesId, new List<Core_IPS_Answer__c>());
                    
                }
                mapQuesId2Answers.get(quesId).add(objAnswer);
            }
        }
        
        //List of Responses on Case
        //FLS Check Added - Yasasvi
        if(Core_IPS_Response__c.SObjectType.getDescribe().isAccessible()) {
               lstResponses = [SELECT Id,Core_IPS_Answer_Master__c,Core_IPS_Question_Master__c,Core_IPS_Case__c,
                               Core_IPS_Answer_Master__r.Core_IPS_Answer__c, Core_IPS_Question_Master__r.Core_IPS_Datatype__c,
                               Core_IPS_Answer__c,Core_IPS_Question_Master__r.Core_IPS_Order_No__c,Core_IPS_Question_Master__r.Core_IPS_Environment_Detail_Answer__c
                               FROM Core_IPS_Response__c WHERE Core_IPS_Case__c = :recordId AND Core_IPS_Question_Master__r.RecordType.DeveloperName='Core_IPS_MAG_Question'];
           }
        //adding all Responses in a list of String wrt questions
        for(Core_IPS_Response__c response:lstResponses){ 
            if(!mapQues2AnswerStrMap.containsKey(response.Core_IPS_Question_Master__c)) {
                mapQues2AnswerStrMap.put(response.Core_IPS_Question_Master__c, new Map<String,Id>());
            }
            mapQues2AnswerStrMap.get(response.Core_IPS_Question_Master__c).put(response.Core_IPS_Answer__c,response.Core_IPS_Answer_Master__c);            
        }
        //Initializing Question & Answers
        for(Core_IPS_Question__c objMag : lstQuestion) { 
            if(!mapQuesId2Answers.containsKey(objMag.Id)) {
                mapQuesId2Answers.put(objMag.Id, new List<Core_IPS_Answer__c>());
            }             
            lstQuestions.add(new Wrap_Question(objMag, mapQuesId2Answers.get(objMag.Id),mapQues2AnswerStrMap,showDependentQues(Integer.ValueOf(objMag.Core_IPS_Order_No__c),lstQuestion,lstResponses)));
        }
        return lstQuestions;
    }

    public static Boolean showDependentQues(Integer order, List<Core_IPS_Question__c> lstQuestion, List<Core_IPS_Response__c> lstResponses){
        Map<Integer,set<String>> mapQuesOrderToAnswer = new  Map<Integer,set<String>>();//Map created from responses
        Map<Integer,String> mapOrderToquestion = new Map<Integer,String>();// map created from  Questions
        Boolean showDependentQues = True; 
        //initializing map of dependent Ans id wrt question order no from All Questions.
        for(Core_IPS_Question__c ques: lstQuestion){
            if(ques.Core_IPS_Environment_Detail_Answer__c != null ){   
                mapOrderToquestion.put(Integer.ValueOf(ques.Core_IPS_Order_No__c), ques.Core_IPS_Environment_Detail_Answer__c);
            }
        } 
        //initializing map of ans ids wrt question order no from All responses.
        for(Core_IPS_Response__c resp: lstResponses){
            if(mapQuesOrderToAnswer.get(order) == null){
                set<string> setStr = new set<String>();
                setStr.add(resp.Core_IPS_Answer_Master__c);
                mapQuesOrderToAnswer.put(Integer.valueOf(resp.Core_IPS_Question_Master__r.Core_IPS_Order_No__c),setStr);
            }
            else{
                Set<string> setStr = mapQuesOrderToAnswer.get(order);      
                setStr.add(resp.Core_IPS_Answer_Master__c);
                mapQuesOrderToAnswer.put(Integer.valueOf(resp.Core_IPS_Question_Master__r.Core_IPS_Order_No__c),setStr);
            }           
        }
        //Checking if Response map conatins same as Question map asns
        if(mapQuesOrderToAnswer.get(order-1)!= null && mapOrderToquestion.get(order)!= null &&
           mapQuesOrderToAnswer.get(order-1).Contains(mapOrderToquestion.get(order))){
               showDependentQues = False;
           }
        return showDependentQues;
    }
    
    @AuraEnabled
    public static List<Wrap_Question> renderDependentQuestions(String orderNumber, Id recordId){ 
       
        Integer quesOrder = Integer.ValueOf(orderNumber);
        List<Core_IPS_Question__c> lstQuestion;
        if(Core_IPS_Question__c.SObjectType.getDescribe().isAccessible()){
            lstQuestion = new List<Core_IPS_Question__c>([SELECT Id,Name,Core_IPS_Datatype__c,Core_IPS_Environment_Detail_Answer__c,Core_IPS_Question__c,
                                                          Core_IPS_Required__c,Core_IPS_Order_No__c,Core_IPS_Environment_Detail_Answer__r.Core_IPS_Answer__c 
                                                          FROM Core_IPS_Question__c WHERE RecordType.DeveloperName='Core_IPS_MAG_Question' AND
                                                          Core_IPS_Status__c='Active' ORDER BY Core_IPS_Order_No__c ]);
        }
        List<Wrap_Question> lstQuestions = getMINDSQuestions(recordId);
        if(lstQuestion[quesOrder].Core_IPS_Environment_Detail_Answer__c != null){
            String selAns = lstQuestions[quesOrder-1].answer;  // Ans provided by user of Dependent ans ques       
            String depQuesAnsText = lstQuestion[quesOrder].Core_IPS_Environment_Detail_Answer__c;   // Ans of Dependent Question at backend        
            if(lstQuestions[quesOrder-1].answerType == 'Multiselect Picklist'){
                set<String> selAnsMsp = new set<String>();
                if(lstQuestions[quesOrder-1].selectedValues != null){
                    for(String str: lstQuestions[quesOrder-1].selectedValues){
                        selAnsMsp.add(str);
                    }
                }
                if(selAnsMsp.contains(depQuesAnsText)){
                    lstQuestions[quesOrder].dependentQues = false;
                    lstQuestions[quesOrder].answer = '';
                    lstQuestions[quesOrder].parentQuestionId = depQuesAnsText;
                }
                else if(!selAnsMsp.contains(depQuesAnsText)){
                    lstQuestions[quesOrder].dependentQues = true;
                    lstQuestions[quesOrder].parentQuestionId = depQuesAnsText;
                }
            }
            else{
                if(selAns == depQuesAnsText){
                    lstQuestions[quesOrder].dependentQues = false;
                    //lstQuestions[quesOrder].answer = '';
                    lstQuestions[quesOrder].parentQuestionId = depQuesAnsText;
                }
                else if(selAns != depQuesAnsText){
                    lstQuestions[quesOrder].dependentQues = true;
                    lstQuestions[quesOrder].parentQuestionId = depQuesAnsText;
                }
            }
        }
        return lstQuestions;
    }
    
    @AuraEnabled
    public static void saveAnswer(String magEDQdata,Id recordId){   
        Case newCase = [SELECT Id,Core_IPS_GEC_Request_Status__c FROM Case WHERE Id = :recordId WITH SECURITY_ENFORCED];    
        List<Core_IPS_Response__c> getResponse = new List<Core_IPS_Response__c>();     
        Boolean allRespEmpty = True;
        //String lsListString = JSON.serialize(magEDQdata);
        List<MAGResponseEDQ>  classTwoWrap = MAGResponseEDQ.parse(magEDQdata);
        if(classTwoWrap.size() > 0) {
            for(MAGResponseEDQ c : classTwoWrap) {
                if(c.edq[0].answerType == 'Multiselect Picklist') {
                    if(String.isNotBlank(c.edq[0].selectedValues)) {
                    List<String> lstStringmul = c.edq[0].selectedValues.split(',');
                    for(String vb : lstStringmul) {
                        Core_IPS_Response__c newresaddmulti = new Core_IPS_Response__c();
                        newresaddmulti.Core_IPS_Question_Master__c = c.edq[0].question;
                        newresaddmulti.Core_IPS_Answer_Master__c = vb;
                        newresaddmulti.Core_IPS_Case__c = recordId;
                        getResponse.add(newresaddmulti);
                }
            }
                allRespEmpty = false;
            } else {
                Core_IPS_Response__c newres = new Core_IPS_Response__c();
                if(c.edq[0].answerType == 'picklist'){
                    if(String.isNotBlank(c.edq[0].selectedValues)) {
                newres.Core_IPS_Answer_Master__c = c.edq[0].selectedValues;
                newres.Core_IPS_Question_Master__c = c.edq[0].question;
                newres.Core_IPS_Case__c = recordId;
                getResponse.add(newres); 
                allRespEmpty = false;
                    }
                } else {
                    if(String.isNotBlank(c.edq[0].selectedValues)) {
                    newres.Core_IPS_Answer__c = c.edq[0].selectedValues;
                    newres.Core_IPS_Question_Master__c = c.edq[0].question;
                    newres.Core_IPS_Case__c = recordId;
                    getResponse.add(newres); 
                    allRespEmpty = false;
                }
                }
            }
        }
    }
    List<Core_IPS_Response__c> lstResponses = [SELECT Id,Core_IPS_Answer_Master__c,Core_IPS_Question_Master__c,Core_IPS_Case__c,
    Core_IPS_Answer_Master__r.Core_IPS_Answer__c, Core_IPS_Question_Master__r.Core_IPS_Datatype__c,
    Core_IPS_Answer__c,Core_IPS_Question_Master__r.Core_IPS_Order_No__c,Core_IPS_Question_Master__r.Core_IPS_Environment_Detail_Answer__c
    FROM Core_IPS_Response__c WHERE Core_IPS_Case__c = :recordId AND Core_IPS_Question_Master__r.RecordType.DeveloperName='Core_IPS_MAG_Question'];

    newCase.Core_IPS_GEC_Request_Status__c = Core_IPS_Labels__c.getValues('MINDS_Questionnaire_Completed').value__c;
    if(allRespEmpty) {
            update newCase;
    } else if(getResponse.size()>0) {
        insert getResponse;
        update newCase;
        delete lstResponses;
    }

}

    public class Wrap_Question{
        @AuraEnabled
        public String question;
        @AuraEnabled
        public String parentQuestionId;
        @AuraEnabled
        public String answer;
        @AuraEnabled
        public String answerType;
        @AuraEnabled 
        public  List<CustomSelectOptions> lovs;
        @AuraEnabled
        public Boolean required;
        @AuraEnabled
        public Boolean dependentQues;
        @AuraEnabled
        public double orderNo;
        @AuraEnabled
        public Id questionId;
        @AuraEnabled
        public Map<String,Id> mapAnswerId;
        @AuraEnabled
        public List<String> selectedValues;
        
        public Wrap_Question(Core_IPS_Question__c objQuestion, List<Core_IPS_Answer__c> lstEnvAns,Map<Id,map<string,id>> mapQToAns,Boolean showQues){
            answer = '';             
            questionId = objQuestion.Id;
            required= objQuestion.Core_IPS_Required__c;        
            question = objQuestion.Core_IPS_Question__c;
            dependentQues = false;
            List<String> strMulti = new List<String>(); 
            selectedValues = new List<String>();
            orderNo = objQuestion.Core_IPS_Order_No__c;
            
            if(mapQToAns.get(questionId)!= null && mapQToAns.get(questionId).size()>0  ){
                if(objQuestion.Core_IPS_Datatype__c != 'Text Area' &&  objQuestion.Core_IPS_Datatype__c != 'Text'){
                    for(Id ans: mapQToAns.get(questionId).Values()){
                        selectedValues.add(ans); 
                    }
                    answer = mapQToAns.get(questionId).Values()[0];
                }
                else{
                    answer = new List<String> (mapQToAns.get(questionId).keyset()).get(0);
                    dependentQues = showQues;
                }
                dependentQues = showQues;               
            }            
            else{
                dependentQues = true; 
            }
            
            if(objQuestion.Core_IPS_Environment_Detail_Answer__c == null){
                dependentQues = False;
            }
            
            if(objQuestion.Core_IPS_Datatype__c == 'Picklist') {
                answerType = 'picklist';
            }
            
            else if(objQuestion.Core_IPS_Datatype__c == 'Multiselect Picklist') {
                answerType = 'Multiselect Picklist';
            }
            else if(String.valueOf(objQuestion.Core_IPS_Datatype__c).startsWith('Text Area')) {
                answerType = 'textarea';
            } 
            else {
                answerType = 'text';
            }
            
           // options = new List<SelectOption>();
              lovs = new List<CustomSelectOptions>();
           /* if(answerType=='picklist' || answerType=='Multiselect Picklist' ) {
                lovs.add(new CustomSelectOptions('',''));
                
            }  */
            
            mapAnswerId = new Map<String,Id>();
            for(Core_IPS_Answer__c objAns : lstEnvAns) {
                String answer = objAns.Core_IPS_Answer__c;
                answer = answer.trim();
               lovs.add(new CustomSelectOptions(answer,objAns.Id));
                mapAnswerId.put(answer, objAns.Id);
            }
        }
    }
}