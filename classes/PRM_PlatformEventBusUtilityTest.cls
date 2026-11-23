@isTest()
public class PRM_PlatformEventBusUtilityTest {
  @isTest() 
  public static void sendEmailLogDetails()
    {
        PRM_EmailLog__c emaillog = new PRM_EmailLog__c();
        emaillog.PRM_Subject__c='Congratulations on Your New Intel® Cloud Insider Status';
        emaillog.PRM_ToEmailID__c='ebert123@mailinator.com';
        emaillog.PRM_EmailContent__c='htmlbody';
        emaillog.Email_Template_Name__c='SCRRENGENRLREV';
        emaillog.Language__c='ENG';
        emaillog.PRM_Read__c=false;
        
        insert emaillog;
        
        String catergoryID ='Partner';
        String sourceOfMsg ='Salesforce';
        String EmailContent = emaillog.PRM_EmailContent__c;
        String EmailLogId  =emaillog.Name;
        System.debug('EmailID'+EmailLogId);
        EmailContent= EmailContent.unescapeHTML4();
        System.debug('EmailContent HTML' +EmailContent);
        EmailWrapper updatedwrap = new EmailWrapper();
        updatedwrap.MessageId =emaillog.Name;
        updatedwrap.MessageHeaderTxt =emaillog.PRM_Subject__c;
        updatedwrap.MessageReadInd =emaillog.PRM_Read__c;
        updatedwrap.MessageSummaryTxt =EmailContent;
        updatedwrap.MessageCategoryCd =catergoryID;
        updatedwrap.MessageDt = emaillog.CreatedDate;
        updatedwrap.source =sourceOfMsg;
        System.debug('updatedwrap' +updatedwrap);
        String emailMsgInJsonFormat = JSON.serialize(updatedwrap);               
        
        
      List<Core_Platform_Event_Bus__e> platformeventList = new List<Core_Platform_Event_Bus__e>();
      Core_Platform_Event_Bus__e e = new Core_Platform_Event_Bus__e();
      e.Core_Message__c = emailMsgInJsonFormat;
      platformeventList.add(e);
        
      Test.startTest();
      PRM_PlatformEventBusUtility.sendEmailLogDetails(platformeventList);  
      Test.stopTest();  
        
    }

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