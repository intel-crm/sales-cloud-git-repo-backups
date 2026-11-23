public class Core_IPS_CommEmailOptController{
    public User Usr{get;set;}
    public Boolean EmailOptOut{get;set;}
    public Boolean EmailOptIn{get;set;}
    public Boolean Checkbox{get;set;}
    Contact contactInContext = new Contact();
    public String statusMessage{get;set;}
    public List<String> SelectedChoice{get;set;}
    public List<SelectOption> options{get;set;}
    /*Start--US254983--Trade Compliance Settings under My Settings tab*/
    public List<SelectOption> countryOptions = new List<SelectOption>();
    public String selectedCountry{get;set;}
    public Boolean radioCheckbox{get;set;}
    /*End--US254983--Trade Compliance Settings under My Settings tab*/
    public Core_IPS_CommEmailOptController(){
        EmailOptOut = false;
        SelectedChoice = new List<String>();
        Usr = [Select id, Name, ContactId,Contact.Name, TimeZoneSidKey from User where id=:UserInfo.getUserId()];
        contactInContext = [Select id, Name,Core_IPS_Email_Opt_Out__c,Core_MINDS__c,Core_Country_Region__c  from Contact where id=: Usr.Contactid];
        /*Start--US254983--Trade Compliance Settings under My Settings tab*/
        selectedCountry = contactInContext.Core_Country_Region__c ;
        radioCheckbox = contactInContext.Core_MINDS__c;
        /*End--US254983--Trade Compliance Settings under My Settings tab*/
        if(contactInContext.Core_IPS_Email_Opt_Out__c == true )
            EmailOptOut = true;
        else
            EmailOptIn = true;
        options = new List<SelectOption>();
        if(EmailOptOut == true)
            options.add(new SelectOption('OptIn', System.Label.Core_IPS_OptIn));
        if(EmailOptIn == true)
        options.add(new SelectOption('OptOut', System.Label.Core_IPS_OptOut));     
    }
    /*Start--US254983--Trade Compliance Settings under My Settings tab*/
    public List<SelectOption> getCountries()
        {
        Schema.DescribeFieldResult fieldResult = Contact.Core_Country_Region__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        countryOptions.add(new SelectOption('-None-', '-None-'));
        for( Schema.PicklistEntry entry : ple)
            {
            countryOptions.add(new SelectOption(entry.getLabel(), entry.getValue()));
            }       
        return countryOptions;
        }
    /*End--US254983--Trade Compliance Settings under My Settings tab*/
    public PageReference SubmitChoice(){
        try{
                    /*Start--US254983--Trade Compliance Settings under My Settings tab*/
                     contactInContext.Core_MINDS__c = radioCheckbox;
                     contactInContext.Core_Country_Region__c = selectedCountry;
                     if(selectedCountry == '-None-'){
                        statusMessage = Label.Core_IPS_CountryErrorMessage;
                        return null;
                     }
                    /*End--US254983--Trade Compliance Settings under My Settings tab*/
                    if(SelectedChoice.size()>0 && SelectedChoice[0] <> null && SelectedChoice[0] == 'OptOut'){
                        contactInContext.Core_IPS_Email_Opt_Out__c = true;
                         
                    }
                    else if(SelectedChoice.size()>0 && SelectedChoice[0] <> null && SelectedChoice[0] == 'OptIn'){
                        contactInContext.Core_IPS_Email_Opt_Out__c = false;
                    }
                    
                   update contactInContext;
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