/***************************************************************************************************
*Class Name:  Core_IPS_MAG_Questionnaire_Controller
*Version     : 1.0 
*Description:  Controller for MAG_Questionnaire VF Page
*Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                   17/08/2018              Created (US# US148915 I15)
****************************************************************************************************/ 

public class Core_IPS_MAG_Questionnaire_Controller {
    public List<Wrap_Question> lstQuestions  {get; set;}
    Public String selectedAnswerOrder {get; set;}
    Public Boolean isEditable {get; set;}
    public Case newCase {get;set;}
    public Boolean showError {get;set;}
    List<Core_IPS_Question__c> lstQuestion;
    Map<Id,Map<String,Id>> mapQues2AnswerStrMap;
    String caseId;    
    List<Core_IPS_Response__c> lstResponses {get; set;}
    Map<Id,Core_IPS_Answer__c> mapId2Answers;
    public String selectedTextVal {get;set;}
    
    public  Core_IPS_MAG_Questionnaire_Controller(ApexPages.StandardController controller){ 
        selectedTextVal = ''; 
        if(!Test.isRunningTest())
            controller.addFields(new List<String>{'Status','Core_Sub_Status__c'}); 
        
        caseId = ApexPages.currentPage().getParameters().get('Id');
        newCase = (Case)controller.getRecord();     
        isEditable = False;
        //To display Error message when caseid is null
        if(caseId == null){
            showError = True;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Core_IPS_Helper_Utility.getIPSLabel('Err_Msg_Mag_Questionnaire')));
            return;
        }       
        
        //All Questions should be in read only when case satus is not GEC Hold
        if(newCase.Core_Sub_Status__c == 'GEC Hold' && newCase.Status == 'On Hold'){
            isEditable = True;
        }
        
        showError = false;
        lstQuestions = new List<Wrap_Question>();
        lstResponses = new List<Core_IPS_Response__c>();       
        mapId2Answers = new Map<Id,Core_IPS_Answer__c>();
        mapQues2AnswerStrMap = new Map<Id,Map<String,Id>>();
        Map<Id,List<Core_IPS_Answer__c>> mapQuesId2Answers = new Map<Id,List<Core_IPS_Answer__c>>();
        
        //List of all the MAG Questions
        lstQuestion = new List<Core_IPS_Question__c>([SELECT Id,Name,Core_IPS_Datatype__c,Core_IPS_Environment_Detail_Answer__c,Core_IPS_Question__c,
                                                      Core_IPS_Required__c,Core_IPS_Order_No__c,Core_IPS_Environment_Detail_Answer__r.Core_IPS_Answer__c 
                                                      FROM Core_IPS_Question__c WHERE RecordType.DeveloperName='Core_IPS_MAG_Question' AND
                                                      Core_IPS_Status__c='Active' ORDER BY Core_IPS_Order_No__c]);
        //In case there are no MAG Questions, Show Error Message
        if(lstQuestion.size() == 0){
            showError = True;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Core_IPS_Helper_Utility.getIPSLabel('Err_Msg_Mag_Questionnaire_Empty')));
            return;
        }
        
        //Map of answers record wrt Question Id
        for(Core_IPS_Answer__c objAnswer : [SELECT Id,Core_IPS_Answer__c,Core_IPS_Question__c
                                            FROM Core_IPS_Answer__c WHERE Core_IPS_Question__c IN :lstQuestion AND Core_IPS_Status__c='Active' 
                                            ORDER BY Core_IPS_Order_No__c,Name ASC]) 
        {
            mapId2Answers.put(objAnswer.id,objAnswer);
            Id QuesId = objAnswer.Core_IPS_Question__c;
            if(!mapQuesId2Answers.containsKey(QuesId)) {
                mapQuesId2Answers.put(QuesId, new List<Core_IPS_Answer__c>());
                
            }
            mapQuesId2Answers.get(QuesId).add(objAnswer);
        }
        
        //List of Responses on Case
        lstResponses = [SELECT Id,Core_IPS_Answer_Master__c,Core_IPS_Question_Master__c,Core_IPS_Case__c,
                        Core_IPS_Answer_Master__r.Core_IPS_Answer__c, Core_IPS_Question_Master__r.Core_IPS_Datatype__c,
                        Core_IPS_Answer__c,Core_IPS_Question_Master__r.Core_IPS_Order_No__c,Core_IPS_Question_Master__r.Core_IPS_Environment_Detail_Answer__c
                        FROM Core_IPS_Response__c WHERE Core_IPS_Case__c = :caseId AND Core_IPS_Question_Master__r.RecordType.DeveloperName='Core_IPS_MAG_Question'];
        
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
            lstQuestions.add(new Wrap_Question(objMag, mapQuesId2Answers.get(objMag.Id),mapQues2AnswerStrMap,showDependentQues(Integer.ValueOf(objMag.Core_IPS_Order_No__c))));
        }
    }
    
    /*********************************************************
Version     : 1.0 
Created Date: 17/08/2018
Input Parameters: Question Order no.
Output Parameters: Boolean value.
Description: To display Dependent Question on VF screen on page load.
Used in     : Core_IPS_MAG_Questionnaire Page
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                    17/08/2018              Created 
*********************************************************/
    public Boolean showDependentQues(Integer order){
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
        system.debug('order'+showDependentQues);
        return showDependentQues;
    }
    
/*********************************************************
Version     : 1.0 
Created Date: 17/08/2018
Input Parameters: NA.
Output Parameters: NA.
Description: To Rerender MSP Dependent Question on VF screen.
Used in     : Core_IPS_MAG_Questionnaire Page
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                    17/08/2018              Created 
*********************************************************/    
    public void renderMSPDepQues(){
        system.debug('selectedTextVal::'+selectedTextVal );
        String Query = 'SELECT id,Core_IPS_Answer__c, Core_IPS_Question__r.Core_IPS_Order_No__c FROM Core_IPS_Answer__c';
        if(selectedTextVal != '' && Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher(selectedTextVal ).matches()){
            Query = Query + ' WHERE id =:selectedTextVal LIMIT 1';
        }
        else
             Query = Query + ' WHERE Core_IPS_Answer__c =:selectedTextVal LIMIT 1';
        
        system.debug('query'+Query);
        
        List<Core_IPS_Answer__c> lstAns = Database.query(Query);
         String  ansId;
        if(lstAns != null && lstAns.size()>0 && selectedTextVal != ''){
            selectedAnswerOrder = String.valueOf(lstAns[0].Core_IPS_Question__r.Core_IPS_Order_No__c);
            system.debug('order::'+selectedAnswerOrder);
            
            for(SelectOption opt: lstQuestions[Integer.ValueOf(selectedAnswerOrder)-1].options){
                if(opt.getLabel().containsIgnoreCase(Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_MSP_None_Option'))){
                    ansId = opt.getValue(); 
                    break;
                }
            }
           
            if(lstAns[0].Core_IPS_Answer__c.containsIgnoreCase(Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_MSP_None_Option')) ){
                ansId = String.ValueOf(lstAns[0].id);
            } 
            
            if(ansId != null && lstQuestions[Integer.ValueOf(selectedAnswerOrder)-1].SelectedValues.contains(ansId)){
              lstQuestions[Integer.ValueOf(selectedAnswerOrder)-1].SelectedValues = new List<String>(); 
                 lstQuestions[Integer.ValueOf(selectedAnswerOrder)-1].SelectedValues.add(ansId);
            }
             renderDependentQuestions();
        }
        
    }
    
  
   
    
    /*********************************************************
Version     : 1.0 
Created Date: 17/08/2018
Input Parameters: NA.
Output Parameters: NA.
Description: To Rerender Dependent Question on VF screen.
Used in     : Core_IPS_MAG_Questionnaire Page
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                    17/08/2018              Created 
*********************************************************/
    public void renderDependentQuestions(){ 
       
        Integer quesOrder = Integer.ValueOf(selectedAnswerOrder);
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
                }
                else if(!selAnsMsp.contains(depQuesAnsText)){
                    lstQuestions[quesOrder].dependentQues = true;
                    lstQuestions[quesOrder].answer = '';
                }
            }
            else{
                if(selAns == depQuesAnsText){
                    lstQuestions[quesOrder].dependentQues = false;
                    lstQuestions[quesOrder].answer = '';
                }
                else if(selAns != depQuesAnsText){
                    lstQuestions[quesOrder].dependentQues = true;
                    lstQuestions[quesOrder].answer = '';
                }
            }
        }
        
    }
    
/*****************************************************************************
Version     : 1.0 
Created Date: 17/08/2018
Input Parameters: NA.
Output Parameters: NA.
Description: To Rerender Dependent Question on VF screen.
Used in     : Core_IPS_MAG_Questionnaire Page
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                    17/08/2018              Created 
* Sumukh                      08/05/2019              Modified for US340992
*******************************************************************************/
    public pagereference saveAnswer(){        
        List<Core_IPS_Response__c> lstRespToUpsert = new List<Core_IPS_Response__c>();       
        Boolean allRespEmpty = True;
        try{
            if(lstQuestions.size()>0)
            {
                for(Wrap_Question ques : lstQuestions){
                    //For Multiselect picklist questions responses records will be same as no of ans selected 1:n
                    system.debug('ques.dependentQues::'+ques.dependentQues+'ques.required::'+ques.required+'ques.selectedValues::'+ques.selectedValues);
                    if(ques.answerType == 'Multiselect Picklist'){
                        if(!ques.dependentQues && ques.required && (ques.selectedValues.isEmpty() || ques.selectedValues == null)){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_MAG_Required_Field_Err')));
                            return null;                            
                        }
                        //Iterate with no of selected values
                        for(String str : ques.selectedValues){
                            Core_IPS_Response__c res = new Core_IPS_Response__c();
                            res.Core_IPS_Case__c = caseId;
                            res.Core_IPS_Question_Master__c = ques.questionId;                        
                            res.Core_IPS_Answer_Master__c = str;
                            res.Core_IPS_Answer__c = mapId2Answers.get(str).Core_IPS_Answer__c;
                            lstRespToUpsert.add(res);
                            allRespEmpty = false;
                        }
                        if((ques.selectedValues.isEmpty() || ques.selectedValues == null))
                        {
                            Core_IPS_Response__c res = new Core_IPS_Response__c();
                            res.Core_IPS_Case__c = caseId;
                            res.Core_IPS_Question_Master__c = ques.questionId; 
                            lstRespToUpsert.add(res);
                        }
                    }
                    //For other question type respone will 1:1
                    else{
                        Core_IPS_Response__c res = new Core_IPS_Response__c();
                        res.Core_IPS_Case__c = caseId;
                        res.Core_IPS_Question_Master__c = ques.questionId;
                        if(!ques.dependentQues && ques.required && (ques.answer == '' || ques.answer == null)){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_MAG_Required_Field_Err')));
                            return null;                            
                        }
                        if((String.isEmpty(ques.answer) || String.isBlank(ques.answer)) ){
                            if(allRespEmpty)
                            allRespEmpty = True;
                        }
                        else{
                            if(ques.answerType == 'textarea' || ques.answerType == 'text'){                            
                                res.Core_IPS_Answer__c = ques.answer;
                                allRespEmpty = False;
                            }
                            else{
                                res.Core_IPS_Answer_Master__c = ques.answer;
                                res.Core_IPS_Answer__c = mapId2Answers.get(ques.answer).Core_IPS_Answer__c;
                                allRespEmpty = False;
                            }
                        }
                        lstRespToUpsert.add(res);                        
                    }                     
                    newCase.Core_IPS_GEC_Request_Status__c = Core_IPS_Labels__c.getValues('MINDS_Questionnaire_Completed').value__c; // Added by Sumukh for US340992             
                }
                if(allRespEmpty)
                {                                     
                   if(newCase!=null){
                    update newCase; // Added by Sumukh for US340992
                    }                    
                    return new PageReference('/' + caseId);
                }
                //usert responses           
                else if(lstRespToUpsert.size()>0)
                {
                    insert lstRespToUpsert;                   
                    if(newCase!=null){
                    update newCase;  // Added by Sumukh for US340992  
                     }
                                  
                    if(lstResponses.size()>0)
                        delete lstResponses;
                    //Redirect back to Case upon save
                    return new PageReference('/' + caseId);
                } 
                        
           }
            
        }
        catch(DMLException e){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getdmlMessage(0)));}
        catch(Exception ex){system.debug('Line No::'+ex.getLineNumber()+'Exception::'+ex.getMessage());ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Mag_Excep_Msg')));}                       
      
        return null;
    }
    
    public pagereference CancelOperation(){
        return new PageReference('/' + caseId);
    }
    
    public class Wrap_Question{
        public String question{get;set;}
        public String answer{get;set;}
        public String answerType{get;set;}
        public List<SelectOption> options{get;set;}
        public Boolean required{get;set;}
        public Boolean dependentQues{get;set;}
        public double orderNo {get;set;}
        Id questionId;
        Map<String,Id> mapAnswerId;
        public List<String> selectedValues{get; set;}
        
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
            
            options = new List<SelectOption>();
            if(answerType=='picklist' || answerType=='Multiselect Picklist' ) {
                options.add(new SelectOption('',''));
                
            }  
            
            mapAnswerId = new Map<String,Id>();
            for(Core_IPS_Answer__c objAns : lstEnvAns) {
                String answer = objAns.Core_IPS_Answer__c;
                answer = answer.trim();
                options.add(new SelectOption(objAns.Id,answer));
                mapAnswerId.put(answer, objAns.Id);
            }
        }
    }
}