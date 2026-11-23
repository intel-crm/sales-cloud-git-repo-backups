/***************************************************************************************************
Class Name          : Core_IPS_CaseUpdateQueueable
Version             : 1.0 
Created Date        : 3 Oct 2018
Function            : This Class is a Batch class mainly written for update of Case for EDQ Filtering Fields but can be used for othr Case Update as well.
Input Parameters    : List<Case> and String
Output Parameters   : NA
Description         : NA
Used in             : trigger Handler class Core_IPS_Response_Handler
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                    
* Aayushi Singhal             03/10/2018              Created US185674
* Gourav Anand                17/10/2018              Modified US195065 - to handle redundant questions being added to Case EDQ Filtering Question text 
****************************************************************************************************/       
global class Core_IPS_CaseUpdateQueueable implements Queueable{
    
    global List<Case> caseIdList = new List<Case>();
    global enum Mode {EDQ,GENERAL}
    Mode m;
    
    global Core_IPS_CaseUpdateQueueable(List<Case> caseList,Mode mode1){
        caseIdList= caseList;
        m= mode1;
    }
    
    
    global void execute(QueueableContext context){
        
        List<case> caseIdList1=new List<Case>();
        List<Case> caseList1=new List<Case>();
        List<Case> caseList2 = new List<Case>();
        Integer count=0;
        if(caseIdList!=null && caseIdList.size()>0){
             for(Integer i = caseIdList.size()-1 ; i >=0; i--){ 
                 caseIdList1.add(caseIdList.remove(i));
                 count++;
                     if(count==200)
                     break;
                    }
    }
      if(m==Mode.EDQ){
            if(caseIdList1!=null && caseIdList1.size()>0){
                caseList1=[Select Id,Core_IPS_EDQ_Filtering_Answer__c,Core_IPS_EDQ_Filtering_Question__c,(Select Id,Core_IPS_Case__c,Core_IPS_Answer__c,Core_IPS_Question_Master__r.Core_IPS_Add_to_Reporting__c,Core_IPS_Question_Master__r.Core_IPS_Reporting_Name__c from Core_IPS_Responses__r where Core_IPS_Question_Master__r.Core_IPS_Add_to_Reporting__c=true) from Case where Id In: caseIdList1 limit 50000];
            }
            if(caseList1!=null && caseList1.size()>0){
                for(Case cs: caseList1){
                    //US195065 - Gourav: Using Question & Answers SET collection
                    Set<String> unqQuestnSet = new Set<String>();
                    Set<String> unqAnswrSet = new Set<String>();
                    String ques='',ans='';
                    
                    if(cs.Core_IPS_Responses__r!=null && cs.Core_IPS_Responses__r.size()>0){
                        for(Core_IPS_Response__c resp: cs.Core_IPS_Responses__r){
                            if(cs.Id==resp.Core_IPS_Case__c && resp.Core_IPS_Question_Master__r.Core_IPS_Add_to_Reporting__c==true)  {
                            //US195065 - Gourav:To remove redundant questions from multiselect picklist responses by using Question & Answers SET collection
                                //ques=ques+ resp.Core_IPS_Question_Master__r.Core_IPS_Reporting_Name__c+'|';
                                unqQuestnSet.add(resp.Core_IPS_Question_Master__r.Core_IPS_Reporting_Name__c);
                                if(resp.Core_IPS_Answer__c!=null)
                                    //ans=ans+ resp.Core_IPS_Answer__c+'|';
                                    unqAnswrSet.add(resp.Core_IPS_Answer__c);
                            } 
                        }
                    }
                    //ques=ques.removeEnd('|');
                    ques = String.join(new List<String>(unqQuestnSet), '|');
                    //ans=ans.removeEnd('|');
                    ans  = String.join(new List<String>(unqAnswrSet) , '|');
                    caseList2.add(new Case(Id=cs.Id, Core_IPS_EDQ_Filtering_Answer__c=ans.left(255), Core_IPS_EDQ_Filtering_Question__c=ques.left(255))); 
                    ques='';
                    ans='';
                    unqQuestnSet.clear();
                    unqAnswrSet.clear();
                } 
            }
            Core_CaseTrigger_Dispatcher.recursivetrigger1=false;            //case trigger execution is not required
            
            try{ if(caseList2!=null && caseList2.size()>0){
                Database.update(caseList2) ;
            }
               }catch(Exception ex){ System.debug('Error message:'+ ex.getMessage()+ex.getLineNumber());   }
            
            
        }
        
        else{
            Core_CaseTrigger_Dispatcher.recursivetrigger1=false;            //case trigger execution is not required
            try{
                Database.update(caseIdList1);
            }
            catch(Exception ex){  System.debug('Error message:'+ ex.getMessage()+ex.getLineNumber());}
            
        }
        if(caseIdList!=null && caseIdList.size()>0)
        System.enqueueJob(new Core_IPS_CaseUpdateQueueable(caseIdList,m));
    }     
    
    
}