/**************************************************************************************
Apex Class Name:  Core_Opp_SalesAssistController
Version     : 1.0 
Created Date: 30 Oct 2021
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan            10/30/2021             Original Version

*************************************************************************************/
public without sharing class Core_Opp_SalesAssistController { //TWC3123-5376: code scan fix
    
    /*
    * Method name  : Core_SA_getEOLData
    * Description  : method to open popup when clicked through the list view 
    * Return Type  : Core_SA_getEOLData
    * Parameter    : String OppId
    * Aura Comp    : Core_Opp_SalesAssist
    */  
    @AuraEnabled
    public static Core_SA_getEOLData getEOLData(String OppId){
        Core_SA_getEOLData eol = new Core_SA_getEOLData();
        Boolean showPopup= false;
        try{
            if(!String.isBlank(OppId)){
                List<Opportunity> opp = [select id,Core_Product_EOL_Count_Nm__c,Core_Sales_Assist_Pop_Up_Enabled__c from Opportunity where id =:OppId ];
                Integer EOLCount = Integer.valueof(opp[0].Core_Product_EOL_Count_Nm__c);
                Boolean SACheckBox = opp[0].Core_Sales_Assist_Pop_Up_Enabled__c;
                eol.EOLCount = EOLCount;
                if(EOLCount>0 && SACheckBox){
                    eol.showPopUp = true;
                    opp[0].Core_Sales_Assist_Pop_Up_Enabled__c = false;
                    update opp;                    
                }
            }
        }catch(Exception exp){
            PMP_Utility.logError(exp, 'Core_Opp_SalesAssistController.getEOLData');      
        }finally {
            Core_Opp_Bypass_Validation_Rule__c   cs = Core_Opp_Bypass_Validation_Rule__c.getInstance(UserInfo.getUserId());
            if(cs!=null && !Test.isRunningTest()){ //TWC3123-5376: code scan fix: Avoid Deeply Nested IF Statements
                delete cs;
            }      
        }  
        
        return eol;
    }
    
    /*
    * Method name  : getUserSessionData
    * Description  : method to create url
    * Return Type  : Core_SA_UserSessionDefination
    * Parameter    : 
    * Aura Comp    : Core_Opp_SalesAssist
    */  
    @AuraEnabled
    public static Core_SA_UserSessionDefination getUserSessionData(String OppId){ 
        String sessionId = '';
        Core_SA_UserSessionDefination userSession = new Core_SA_UserSessionDefination();
        //userSession.prodJSON = new List<opportunitylineitem>();
        List<opportunitylineitem> oplineList = new List<opportunitylineitem>();
        String sid = '';
        String prodList = '';
        String opp_name = '';
        String cimId = '';
        if(!String.isBlank(OppId)){
            List<opportunitylineitem> prList = [select product2id,TotalPrice,Quantity from opportunitylineitem where Core_Status__c in ('On Hold','Pending','Win Submitted') and opportunityid =: OppId and Core_Is_Product_EOL__c = true];
            if(prList.size()>0){
                //prodList = JSON.serialize(prList);
                oplineList.addall(prList);
                //userSession.opp_name = prList[0].opportunity.name;
                
            }
            List<opportunity> accCim = [select id, account.Core_Business_Party_Id__c from opportunity where id =: OppId limit 1];
            cimId = accCim[0].account.Core_Business_Party_Id__c;
        }
        
        if(!Test.isRunningTest()) {
          PageReference newPage = Page.GetSessionIdPage;
          String content = newPage.getContent().toString();
        
          //scrap the VF page content to retrieve sessionID
           sid = content.substringBetween('<SessionId>', '</SessionId>');
        }
        //Query User Object to get the user WWID based on the current user ID
        User u = [select Core_WWID__c from user where Id =: UserInfo.getUserId() LIMIT 1];
        
        //sessionId ='{"orgId":"'+ UserInfo.getOrganizationId() + '","SessionId":"' + sid + '","wwid":"' + u.Core_WWID__c + '","email":"' + UserInfo.getUserEmail() + '","prodJSON":"'+l+'"}';
        //sessionId ='{"orgId":"'+ UserInfo.getOrganizationId() + '","SessionId":"' + sid + '","wwid":"' + u.Core_WWID__c + '","email":"' + UserInfo.getUserEmail() + '"}';
        sessionId = sid;
        //userSession = Core_SA_UserSessionDefination.parse(sessionId);
        userSession.sessionId = sessionId;
        userSession.email =  UserInfo.getUserEmail();
        userSession.orgId = UserInfo.getOrganizationId();
        userSession.wwid = u.Core_WWID__c;
        userSession.cimId = cimId;
        Map<Id, opportunitylineitem> mapFromList  = new Map<Id, opportunitylineitem>(oplineList);
        userSession.prodJSON = mapFromList.values();
        return (userSession);
    }
    
    
    /*
    * Method name  : enableSalesAssistCheckBox
    * Description  : method to enable checkbox as an identifier to open the popup
    * Return Type  : void
    * Parameter    : String OppId
    * Aura Comp    : Core_Opp_SalesAssistRedirect
    */  
    @AuraEnabled
    public static String enableSalesAssistCheckBox(String OppId){
        String errmsg='';
        if(!String.isBlank(OppId)){
            List<Opportunity> opp = [select id,Core_Sales_Assist_Pop_Up_Enabled__c from Opportunity where id =:OppId];
            opp[0].Core_Sales_Assist_Pop_Up_Enabled__c = true;
            Savepoint sp = Database.setSavepoint();
            try{
                Core_Opp_Bypass_Validation_Rule__c   cs = new Core_Opp_Bypass_Validation_Rule__c();
                cs.Bypass__c = true;
                cs.SetupOwnerId = UserInfo.getUserId();
                insert cs;
                /*if(!cs.Bypass__c){
                    cs.Bypass__c = true;
                    upsert cs;
                }*/
                update opp;
            }
            catch(exception e){
                errmsg = e.getMessage();
                Database.rollback(sp);
            }
        }
        return errmsg;
    }
    
    public class Core_SA_getEOLData {
        // Used by SAServiceWrapper.getUserSessionId();
        // This class defines the User and the session properties
        @AuraEnabled
        public Integer EOLCount;
        
        @AuraEnabled
        public Boolean showPopUp;
        
    }
    
}