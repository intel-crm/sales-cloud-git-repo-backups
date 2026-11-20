/********************************************************************************
Class Name:  Core_IPS_EnvironmentDetailQuestion
Description:   Wrapper Class to hold Core Question and Answer related data
Used in     :  Case Creation, Case Clone
Modification Log :
* Developer              Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh               12/18/2017             Created - US8534
**********************************************************************************/ 
public class Core_IPS_EnvironmentDetailQuestion {
  @AuraEnabled  public String type{get;set;}
  @AuraEnabled  public String label{get;set;}
  @AuraEnabled  public String splaceholder{get;set;}
    public List<SelectOption> pplaceholder{get;set;}
	@AuraEnabled public List<CustomSelectOptions> lwcplaceholder{get;set;}
   @AuraEnabled public String selectedValue{get;set;}
   @AuraEnabled public String old_selectedValue{get;set;}
   @AuraEnabled public boolean cplaceholder{get;set;}
   @AuraEnabled public String tplaceholder{get;set;}
  @AuraEnabled  public boolean required{get;set;}
  @AuraEnabled  public boolean IsAgentOnly{get;set;}
  @AuraEnabled  public List<string> selectedMValue{get;set;}
    
    // added by amritesh 12/18/2017 - US85344 
   @AuraEnabled public Id selectedParentAnswer{get;set;}
   @AuraEnabled public Id questionId; 
  @AuraEnabled public List<Core_IPS_EnvironmentDetailQuestion> childQuestions{get;set;}   
    @AuraEnabled public Boolean hasChildQuestions{get;set;}
    @AuraEnabled public Boolean hasParentQuestion{get;set;}
    //public Boolean showDependentSection{get;set;} 
  @AuraEnabled public Boolean isVisible{get;set;}
    @AuraEnabled public String parentQuestionID{get;set;}
    public Core_IPS_EnvironmentDetailQuestion() {
        required = false;
        hasChildQuestions = false;
        hasParentQuestion = false;
        //showDependentSection = false;
        isVisible = true;
        IsAgentOnly = false;
        cplaceholder = false;
        childQuestions = new List<Core_IPS_EnvironmentDetailQuestion>();
    }
    
    public void renderDependentQuestions() {
        if(childQuestions==null || childQuestions.size()==0) return;
        if(String.isBlank(selectedValue)) {
            //showDependentSection = false;
            for(Core_IPS_EnvironmentDetailQuestion objChildQues : childQuestions) {
                objChildQues.isVisible = false;
            }
        } else {
            //showDependentSection = true;            
            if(old_selectedValue!=selectedValue) {
                //List<Id> lstQuesId = new List<Id>();
                //for(Core_IPS_EnvironmentDetailQuestion objChildQues : childQuestions) {
                    //lstQuesId.add(objChildQues.questionId);
                //}
                
                Map<Id,Map<Id,Core_IPS_Answer__c>> mapQues2AnswerMap = new Map<Id,Map<Id,Core_IPS_Answer__c>>();
                for(Core_IPS_Answer__c objAns : Core_IPS_Questions_Utility.getCoreAnswersByParentAnswer(selectedValue)) {
                    if(!mapQues2AnswerMap.containsKey(objAns.Core_IPS_Question__c)) {
                        mapQues2AnswerMap.put(objAns.Core_IPS_Question__c, new Map<Id,Core_IPS_Answer__c>());
                    }
                    mapQues2AnswerMap.get(objAns.Core_IPS_Question__c).put(objAns.Id, objAns);
                }
                for(Core_IPS_EnvironmentDetailQuestion objChildQues : childQuestions) {
                    
                    if(objChildQues.type==Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Picklist') || objChildQues.type==Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Multi_Select'))
                    {
                        //Modified By Karthick - US101342 - R4.2
                        objChildQues.pplaceholder.clear();
                        objChildQues.pplaceholder.add(new SelectOption('','Select Option'));
                        if(mapQues2AnswerMap.containsKey(objChildQues.questionId)) {
                            Map<Id,Core_IPS_Answer__c> mapAns = mapQues2AnswerMap.get(objChildQues.questionId);
                            for(Id ansId : mapAns.keySet()) {
                                String strPAnsId = String.valueOf(mapAns.get(ansId).Core_IPS_Parent_Answer__c).left(15);
                                if(strPAnsId==selectedValue.left(15)) {
                                    objChildQues.pplaceholder.add(new SelectOption(ansId, mapAns.get(ansId).Core_IPS_Answer__c));
                                }
                            }
                        }
                        objChildQues.isVisible=true;
                        
                        if(objChildQues.pplaceholder==null) { objChildQues.isVisible=false; }
                        else if(objChildQues.pplaceholder.size()==1) { objChildQues.isVisible=false; }
                    } else{
                        objChildQues.isVisible=true;
                    }
                    
                }
            }
        }
        old_selectedValue = selectedValue;
        
    }

	
}