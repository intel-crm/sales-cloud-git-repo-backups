public with sharing class Core_IPS_AddDependentAnswersExt {
    
    public Id parentAnsId{get;set;}   
    public Boolean isError{get;set;}
    public Core_IPS_Answer__c parentAnswer{get;set;}
    public List<SelectOption> lstSelAnswers{get;set;}
    private ApexPages.StandardController stdcon;
    
    //Wrapper class list variable to render the questions and answers table.
    public List<questionAnsWrapper> wrapperQusAnsList {get;set;}
    
    public Boolean showBackButton{
        get{
            return (parentAnsId!=null || getParam('retURL')!=null);
        }
    }
       
    //Constructor
    public Core_IPS_AddDependentAnswersExt(ApexPages.StandardController controller) {
        /*if(!Test.isRunningTest()) {
            controller.addFields(new List<String>{'Core_IPS_Question__r.Core_IPS_Question__c','Core_IPS_Answer__c'});
        }*/
        stdcon = controller;
        //init();
    }
    
    public Pagereference init() {
        wrapperQusAnsList = new List<questionAnsWrapper>();
        lstSelAnswers = new List<SelectOption>();
        parentAnsId = stdcon.getId();
        isError = false;
        String quesId;
        if(parentAnsId != null) {                        
            
            //Get Question Id of current answer.
            for(Core_IPS_Answer__c objAns : [select Id,Core_IPS_Answer__c,Core_IPS_Question__c,Core_IPS_Question__r.Core_IPS_Question__c from Core_IPS_Answer__c where id=: parentAnsId])           
            {
                parentAnswer = objAns;
            }
            //parentAnswer = (Core_IPS_Answer__c) stdcon.getRecord();
            if(parentAnswer==null) {
                addErrorMsg('Invalid URL !!');
                return null;
            }
            quesId = parentAnswer.Core_IPS_Question__c;
            
            //Retrive all the child questions and answers.
            List<Core_IPS_Question__c> childQuestionList = [select id,Name,Core_IPS_Question__c,(select Id,Name,Core_IPS_Answer__c,Core_IPS_Parent_Answer__c from Core_Answers__r ORDER BY Core_IPS_Order_No__c,Core_IPS_Answer__c) from Core_IPS_Question__c where (Core_IPS_Parent_Question__c =:quesId OR Id=:quesId) AND (Core_IPS_Datatype__c=:Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Picklist') OR
Core_IPS_Datatype__c=:Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Multi_Select'))];            
            Integer countDependentQuestions = 0;
            Integer countDependentAnswers = 0;
            if(childQuestionList != NULL && childQuestionList.size() > 0) {                
                for(Core_IPS_Question__c qA : childQuestionList) {                    
                    if(qA.Id==parentAnswer.Core_IPS_Question__c) {
                        for(Core_IPS_Answer__c objAns : qA.Core_Answers__r) {
                            lstSelAnswers.add(new SelectOption(objAns.Id, objAns.Core_IPS_Answer__c));
                        }
                    } else {
                        countDependentQuestions++;
                        if(qA.Core_Answers__r!=null && qA.Core_Answers__r.size()>0) {
                            wrapperQusAnsList.add(new questionAnsWrapper(qA, qA.Core_Answers__r, this));
                            countDependentAnswers += qA.Core_Answers__r.size(); 
                        }
                    }
                }                
            } 
            if(countDependentQuestions==0){
                addErrorMsg('No dependent Questions found !!');
            } else if(countDependentAnswers==0) {
                addErrorMsg('No child Answers found !!');
            }
            
        } else if(String.isNotBlank(getParam('qid'))) {
            
            quesId = getParam('qid');
            
            for(Core_IPS_Answer__c objAns : [select Id,Name,Core_IPS_Answer__c,Core_IPS_Parent_Answer__c from Core_IPS_Answer__c WHERE Core_IPS_Question__c=:quesId ORDER BY Core_IPS_Order_No__c,Core_IPS_Answer__c LIMIT 1]) {
                parentAnsId = objAns.Id;
            }
            if(parentAnsId != null) {   
                ApexPages.currentPage().getParameters().put('retURL','/'+quesId);             
                return redirectToSelectedParentAnswer();
            } else {
                addErrorMsg('No Answers found !!');
                if(String.isBlank(getParam('retURL'))) {
                    Pagereference pgref = ApexPages.currentPage();
                    pgref.getParameters().put('retURL','/'+quesId);
                    pgref.setRedirect(true);
                    return pgref;
                }
            }
            
        } else {
            addErrorMsg('Invalid URL !!');
        }
            
        return null;
    }
    
    private void addErrorMsg(String msg) {
        isError = true;
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, msg));
    }
    
    private String getParam(String strP) {
        String returnParam = null;
        if(String.isNotBlank(strP)) {
            returnParam = ApexPages.currentPage().getParameters().get(strP);
        }
        return returnParam;
    }
    
    //Have to create a wrpper class to render in page.
    
    public class questionAnsWrapper{
        
        public Core_IPS_Question__c question {get;set;}
        public List<answerWrapper> answerList {get;set;}
        public questionAnsWrapper(Core_IPS_Question__c qA, List<Core_IPS_Answer__c > answers, Core_IPS_AddDependentAnswersExt inst_Ext){
            question = qA;
            answerList =  new List<answerWrapper>();
            if(answers !=null && answers.size()>0){
                
                for(Core_IPS_Answer__c answer : answers){
                    answerList.add(new answerWrapper(answer, inst_Ext));
                }
            }
            else {
                answerList = null;
            }
        }
    }
    
    public class answerWrapper {
        public Core_IPS_Answer__c answer {get;set;}
        public Boolean selected {get;set;}
        public Boolean disabled {get;set;}
        
        public answerWrapper(Core_IPS_Answer__c ans, Core_IPS_AddDependentAnswersExt inst_Ext){
            answer = ans;
            disabled = false;
            selected = false;
            if(answer.Core_IPS_Parent_Answer__c!=null) {
                selected = true;
                if(String.valueOf(inst_Ext.parentAnsId).left(15)!=String.valueOf(ans.Core_IPS_Parent_Answer__c).left(15)) {
                    disabled = true;
                } 
            }
        }
    }
    
    private void updateDependency() {
        List<Core_IPS_Answer__c> answersList = new List<Core_IPS_Answer__c>();
        for(questionAnsWrapper qusAnsWrap : wrapperQusAnsList){
            
            for(answerWrapper ansWrap : qusAnsWrap.answerList) {
                if(ansWrap.disabled) continue;
                if(ansWrap.selected == true ) {
                    answersList.add(new Core_IPS_Answer__c(Id=ansWrap.answer.Id, Core_IPS_Parent_Answer__c=parentAnsId));
                    //answerIdSet_selected.add(ansWrap.answer.id);
                } else {
                    answersList.add(new Core_IPS_Answer__c(Id=ansWrap.answer.Id, Core_IPS_Parent_Answer__c=null));
                }
            }             
        }
        if(answersList.size()>0) {
            update answersList; 
        }     
    }
    
    public pageReference SaveDetails() {  
        try { 
            updateDependency();
            return redirectToSelectedParentAnswer();
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
            System.debug('-------Error :'+e.getMessage());            
        } 
        return null;
    }
    
    public pageReference SaveandReturn() {
        try{
            updateDependency();
            return stdcon.cancel();
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
            System.debug('-------Error :'+e.getMessage());            
        } 
        return null;
    }
    
    public pageReference redirectToSelectedParentAnswer() {
        //if(parentAnsId!=null && parentAnsId!=parentAnswer.Id) {
        Pagereference pgref = Page.Core_IPS_AddDependentAnswers;
        pgref.getParameters().put('id', parentAnsId);
        if(String.isNotBlank(getParam('retURL')))
            pgref.getParameters().put('retURL', getParam('retURL'));
        pgref.setRedirect(true);
        return pgref;
        //}
        //return null;
    }
    
    /*public pageReference returnBack() {
        Pagereference pgref = null;
        if(String.isNotBlank(getParam('retURL')))
            pgref = new pageReference(getParam('retURL'));
        else
            pgref = new pageReference('/' + parentAnsId);
        pgref.setRedirect(true);
        return pgref;
    }*/

}