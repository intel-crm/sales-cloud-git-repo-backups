public class PSG_Chatbot_login 
{
     public class PrechatOutput{
        @InvocableVariable
        public String sFirstName;
        @InvocableVariable
        public String sLastName;
        @InvocableVariable
        public String sEmail;
        @InvocableVariable
        public Id sContactID;
        @InvocableVariable
        public String sLoggedUser;
    }
    public class PrechatInput{
        @InvocableVariable
        public String sChatKey;
    }
    @InvocableMethod(label='Get SnapIns Prechat Data1')
    public static List<PrechatOutput> getSnapInsPrechatData(List<PrechatInput> inputParameters){
        Id loggedinUserContactId;
        String sChatKey = inputParameters[0].sChatKey;
        List<prechatoutput> outputParameters = new List<prechatoutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        if (sChatKey != null && sChatKey != ''){
          System.debug('key>>'+sChatKey);
            List<LiveChatTranscript> transcripts = [SELECT Id, CaseId, ContactId, Username__c FROM LiveChatTranscript WHERE ChatKey = :sChatKey];
            if (transcripts.size()>0){
                Contact con =[select FirstName from contact where id=:transcripts[0].ContactId];
                system.debug(con.FirstName);
                outputParameter.sFirstName = con.FirstName;
                System.debug('transcripts'+transcripts);
                System.debug('username'+transcripts[0].Username__c);
               // User loggedInUser = [SELECT Id, Email, UserType, Contact.Id,FirstName, LastName  FROM User WHERE Id=:transcripts[0].Username__c]; 
                 //log = [Select Id, Username, FirstName, LastName, Email, contactId From User Where Id = :transcripts[0].Username__c]?.contactId;
                Id userContactId = [Select Id, Username, FirstName, LastName, Email, contactId From User Where Id = :transcripts[0].Username__c]?.contactId;
                if(userContactId!=null){
                    loggedinUserContactId = userContactId;
                outputParameter.sLoggedUser = transcripts[0].Username__c;
            }
            else{
                //id userId = UserInfo.getUserId();
                         User loginUser = [Select id,Email,FirstName, LastName, ContactId,contact.accountid from User where Id = :transcripts[0].Username__c and IsActive=true];

                 Map<String, User> emailUserIdMap = new Map<String, User>();
                System.debug('loginUser.Email'+loginUser.Email);
                System.debug('loginUser'+loginUser);
               
                  emailUserIdMap.put(loginUser.Email, loginUser);
                  loggedinUserContactId = Sales_CreateLicenseContactUser_Utility.createLicenseContactUsers(emailUserIdMap);
                   //loggedinUserContactId= con.id;
                   outputParameter.sLoggedUser = transcripts[0].Username__c;

            }
            }
        }
        if (loggedinUserContactId != null){
            List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, Username__c FROM Contact WHERE Id = :loggedinUserContactId];
            if (contacts.size()>0){
                //outputParameter.sFirstName = contacts[0].FirstName;
                outputParameter.sLastName = contacts[0].LastName;
                outputParameter.sEmail = contacts[0].Email;
                outputParameter.sContactId = contacts[0].Id;
            }
        }else{
            List<User> u = [Select Id, Username, FirstName, LastName, Email, contactId From User Where Id = :outputParameter.sLoggedUser];
            //outputParameter.sFirstName = u[0].FirstName;
            outputParameter.sLastName = u[0].LastName;
            outputParameter.sEmail = u[0].Email;
        }
        
        outputParameters.add(outputParameter);
        return outputParameters;
    }

}