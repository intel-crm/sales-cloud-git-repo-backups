public with sharing class Core_Case_CloseController {
    private ApexPages.StandardController controller;
    public String retURL {get; set;}
    public String ErrorMsg {get; set;}
    public String rType {get; set;}     
    public Case caseEdit{get;set;}
    public List<StandardActionRedirection__c> sCaseActionList{get;set;}
    
    public Core_Case_CloseController(ApexPages.StandardController controller) {
        this.controller = controller;
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        caseEdit = [select id,Casenumber,status,RecordtypeId,RecordType.developerName from case where id =:this.controller.getID()];
        if(retURL == null || retURL == '')
        {
            retURL = '/' + caseEdit.id ;
        }
        
        rType = caseEdit.RecordtypeId;
        
    }
    public pagereference redirect(){
        User u = [select Id, username,userType,profile.name from User where Id = :UserInfo.getUserId()];
        
        system.debug('>>>>>>>>>>>>>>>>>>my' + u.userType + caseedit.recordtype.developerName);
        
        if((u.userType=='PowerCustomerSuccess' || u.userType =='PowerPartner' ) && caseedit.recordtype.developerName=='IPS_Case_Create')
        {
            Pagereference Pg = new pagereference('/IPS/'+caseedit.id);
            
            return Pg ;
            
        }      
        else if((u.userType=='PowerCustomerSuccess' || u.userType =='PowerPartner' ) && caseedit.recordtype.developerName=='IPS_GEC_ReadOnly')
        {
            ErrorMsg = errormessage('close102');
            return null;
        }
        else if((u.userType=='PowerCustomerSuccess' || u.userType =='PowerPartner') && caseedit.status == 'Closed')
        {
            ErrorMsg = errormessage('close101');//defaultmessage'This case is already closed.please click back button for going back';                          
            return null;
        }
        // Added by sumukh for US277503 - Iteration 26 - 11/02/2019
        else if((u.userType=='Standard') && (caseedit.recordtype.developerName=='IPS_Case_Create' || caseedit.recordtype.developerName=='IPS_GEC_ReadOnly' || caseedit.recordtype.developerName=='IPS_Closed_Case' || caseedit.recordtype.developerName=='Core_IPS_Case_Create_Self_Assigned' ))
        {
            ErrorMsg = errormessage('Close-103');
            return null;
        } // end by sumukh
        else
        {
            pagereference Pg = new pagereference('/' + caseedit.id + '/s?retURL=' + retURL+'&nooverride=1'); 
            return Pg ;
        }
        
    }
    
    /***************************************************************************************************
Method Name:  errormessage
Method Type: Helper Method 
Version     : 1.0 
Created Date: 01 Jul 2015
Function    : This method Gets the error message from Core_IPS_Error_Code custom setting.
Input Parameters: Error code
Output Parameters: Returns error message
Description: All the error messages are added in Custom setting and this method gets the error message from error code.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              07/01/2015              Created
****************************************************************************************************/    
    public string errormessage(string errorCode){
        string defaultmessage ='Case cannot be closed.';
        if(Core_IPS_Error_Code__c.getinstance(errorCode)!=null){
            if(Core_IPS_Error_Code__c.getinstance(errorCode).Core_Error_Message__c!=null){
                defaultmessage = Core_IPS_Error_Code__c.getinstance(errorCode).Core_Error_Message__c; 
            }
        }
        return defaultmessage;
    }
    
    
    public pageReference Back()
    {
        pagereference Pg = new pagereference('/' + caseedit.id + '&nooverride=1'); 
        return Pg ;
    }
}