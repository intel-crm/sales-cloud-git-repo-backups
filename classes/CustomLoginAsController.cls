public class CustomLoginAsController {
    public final Contact con{get;set;}
    public Core_User_Emulation_Log__c em_log{get;set;}
    public String community{get;set;}
    public Boolean errorFlag{get;set;}
    public Id NetworkUserId{get;set;}
    public String NetworkUserEmail{get;set;}
    public List<SelectOption> communityList {get;set;}
    private ApexPages.StandardController controller;
    
 // Constructor
    public CustomLoginAsController(ApexPages.StandardController stdController){
        this.con = (Contact)stdController.getRecord();
        em_log = new Core_User_Emulation_Log__c(); 
        NetworkUserId = [SELECT Id from User where Contactid=:con.Id ][0].Id;
        NetworkUserEmail = [SELECT Email from User where id=:NetworkUserId][0].email;
        errorFlag = false;
        
        //get the list of communities user has access to
        communityList = new List<SelectOption>();
        for (NetworkMember nr : [SELECT NetworkId,Network.Name FROM NetworkMember where MemberId=:NetworkUserId and Network.Status ='Live']) {
            communityList.add(new SelectOption(nr.NetworkId,nr.Network.Name));
        } 
        //----------------------------------------------- 
    }
 
    public pageReference save(){
       
        if(community == '' || community == null)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please select a Community'));
            errorFlag = true;
            
        }
         else if(em_log.T_C__c == false)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please except the Terms and Conditions'));
            errorFlag = true;
            
        }
        else if(em_log.Justification_Text__c == '' || em_log.Justification_Text__c == null)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please Enter Detailed Explanation Why You Are Emulating This User'));
            em_log.Justification_Text__c.addError('Please Enter Detailed Explanation Why You Are Emulating This User');
            errorFlag = true;
            
        }
       else if(em_log.Consent_To_Emulate__c == '' || em_log.Consent_To_Emulate__c == null|| em_log.Consent_To_Emulate__c.equals('No'))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'You Cannot Proceed If You Do Not Have Explicit Consent From This User To Emulate Them'));
            errorFlag = true;
            
        }
       else if(em_log.Emulating_On_Behalf_Of__c == '' || em_log.Emulating_On_Behalf_Of__c == null)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please Select If You Are Emulating On Behalf Of Someone Else'));
            errorFlag = true;
            
        }
      else if(em_log.Emulating_On_Behalf_Of__c.equals('Yes') && ( em_log.On_Whose_Behalf_WWID__c == '' || em_log.On_Whose_Behalf_WWID__c == null ) )
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please Enter WWID of User You Are Emulating'));
            errorFlag = true;
            
        }
        else{
            errorFlag = false;
        }
  
        if(errorFlag==false){
            // Do the redirect to emulate the user once all the 
            String orgId = UserInfo.getOrganizationId();
            //String URLRedirect ='https://intel--crmdevsls3.lightning.force.com/';
            String URLRedirect = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
                   URLRedirect = URLRedirect.removeEnd('--c');
                   URLRedirect = 'https://' + URLRedirect.toLowerCase() + '.lightning.force.com/';
            
            URLRedirect=URLRedirect+'servlet/servlet.su?oid='+orgId+'&retURL=%2F'+con.id+'&sunetworkid='+community+'&sunetworkuserid='+NetworkUserId;
            System.debug('URL:'+URLRedirect);
            System.debug('URL base:'+URL.getOrgDomainUrl().toExternalForm() );
            PageReference reference=new PageReference(URLRedirect);
            reference.setRedirect(true);
            //DML to save Log data
             createLogEntry();
            return reference;
        }    
        return null;
    }
    // method to create the Log Entry 
    public void createLogEntry(){
        em_log.Emulation_Target_User__c = NetworkUserId;
        em_log.Emulator_User__c = UserInfo.getUserId();
        em_log.Contact__c = con.Id;
        em_log.Emulation_Start_Date_Time__c =  DateTime.now();
        insert em_log;
        
    }


}