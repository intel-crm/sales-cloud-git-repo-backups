public class Core_IPS_CommEmailOptController{
    public User Usr{get;set;}
    public Boolean EmailOptOut{get;set;}
    public Boolean EmailOptIn{get;set;}
    public Boolean Checkbox{get;set;}
    Contact ContactInContext = new Contact();
    public String statusMessage{get;set;}
    public List<String> SelectedChoice{get;set;}
    public List<SelectOption> options{get;set;}

    public Core_IPS_CommEmailOptController(){
        SelectedChoice = new List<String>();
        //statusMessage='Updated Successfully';
        Usr = [Select id, Name, ContactId,Contact.Name, TimeZoneSidKey from User where id=:UserInfo.getUserId()];
        ContactInContext = [Select id, Name,Core_IPS_Email_Opt_Out__c  from Contact where id=: Usr.Contactid];
        if(ContactInContext.Core_IPS_Email_Opt_Out__c == true)
            EmailOptOut = true;
        else
            EmailOptIn = true;        
        options = new List<SelectOption>();
        if(EmailOptOut == true)
        options.add(new SelectOption('OptIn', System.Label.Core_IPS_OptIn));
        if(EmailOptIn == true)
        options.add(new SelectOption('OptOut', System.Label.Core_IPS_OptOut));     
    }

    public PageReference SubmitChoice(){
        try{
                if(SelectedChoice <> null && SelectedChoice.size()>0){
                    if(SelectedChoice[0] <> null && SelectedChoice[0] == 'OptOut'){
                        ContactInContext.Core_IPS_Email_Opt_Out__c = true;
                        update ContactInContext; 
                    }
                    else if(SelectedChoice[0] <> null && SelectedChoice[0] == 'OptIn'){
                        ContactInContext.Core_IPS_Email_Opt_Out__c = false;
                        update ContactInContext;
                    }
                }
                update Usr;
                statusMessage='Updated Successfully';
            }catch(Exception e){
                  statusMessage='Fail To Update '+e;
            } 
            return null;   
      }

    public PageReference Cancel() {
        return new PageReference('/500/o');
    }
}