/**************************************************************************************
Apex Class Name:  Core_AMBRelatedObjs
Version     : 1.0 
Created Date: 04 July 2018
Function    : class for Creating related objects of Account Meeting Briefs
Modification Log :
* Developer                       Date                    Description
* ----------------------------------------------------------------------------                 
* Ragamalika Mohanraj             04/07/2018              Original Version
*************************************************************************************/

public class Core_AMBRelatedObjs{

public Account_Meeting_Brief__c amb{get;set;} 
public string ambId{get;set;}
private ApexPages.StandardSetController standardSetController;

    public Core_AMBRelatedObjs(ApexPages.StandardSetController standardSetController){
         this.standardSetController = standardSetController;
         ambId = ApexPages.CurrentPage().getparameters().get('id');
         amb = [Select id,Name from Account_Meeting_Brief__c where id=: ambId];
    
    }
     
    // Getter method for the URL for the "New meeting Attendee" button
    public String getNewMeetingAttendeeUrl() {
              
            return '/a1b/e?CF00No000000CobFE='+amb.Name+'&CF00No000000CobFE_lkid='+ambId+'&retURL=%2F'+ambId+'&saveURL=%2F'+ambId;
       
    }
    
    // Getter method for the URL for the "New meeting Objective" button
    public String getNewMeetingObjectivesUrl() {
              
            return '/a1c/e?CF00No000000CobFF='+amb.Name+'&CF00No000000CobFF_lkid='+ambId+'&retURL=%2F'+ambId+'&saveURL=%2F'+ambId;
            
    }
    
    // Getter method for the URL for the "New meeting Agenda Item" button
    public String getNewMeetingAgendaItemUrl() {
              
            return '/a1a/e?CF00No000000CobFD='+amb.Name+'&CF00No000000CobFD_lkid='+ambId+'&retURL=%2F'+ambId+'&saveURL=%2F'+ambId;
            
    }
    // Getter method for the URL for the "New Customer/Other Attendee" button
    public String getNewCustomerAttendeeUrl() {
              
        return '/a13/e?CF00N2D000006LjFA='+amb.Name+'&CF00N2D000006LjFA_lkid='+ambId+'&retURL=%2F'+ambId+'&saveURL=%2F'+ambId;    
        //return null;
    }
  
}