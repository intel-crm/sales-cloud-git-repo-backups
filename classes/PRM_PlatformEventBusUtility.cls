public class PRM_PlatformEventBusUtility {
    //Method to Fetch the EmailLog records 
    public static void sendEmailLogDetails(List<Core_Platform_Event_Bus__e> platformEventList)
    {
        List<PRM_EmailLog__c> emailList = new List<PRM_EmailLog__c>(); 
        String EmailLogDetails;
        EmailWrapper emailLogDetailsParser;
        for(Core_Platform_Event_Bus__e platEventRec: platformEventList){
            if(platEventRec.Core_Message__c  !=null){
                EmailLogDetails = platEventRec.Core_Message__c;
                //Deserializing JSON 
                emailLogDetailsParser =(EmailWrapper) JSON.deserialize(EmailLogDetails, EmailWrapper.Class);
                System.debug('RecordId ='+emailLogDetailsParser.MessageId);
            }
        }
        
        //Fetching EmailLog records 
        if(emailLogDetailsParser != NULL){
            String recordID = emailLogDetailsParser.MessageId;
            emailList = [SELECT Id,CreatedDate,PRM_EmailContent__c,PRM_Subject__c,PRM_Read__c,Name  from PRM_EmailLog__c WHERE Name =: recordID];
        }
        
        //Updating the EmailLog Record 
        for(PRM_EmailLog__c emaillogs:emailList){
            emaillogs.PRM_Read__c =emailLogDetailsParser.MessageReadInd;
        }
        update emailList;
    }
    
    
    //Wrapper class to store EmailLog record details 
    public class EmailWrapper{ 
        public String MessageHeaderTxt;
        public boolean MessageReadInd;
        public String MessageSummaryTxt;
        public datetime MessageDt;
        public string source;
        public string MessageCategoryCd;
        public string MessageId;
    }
    
}