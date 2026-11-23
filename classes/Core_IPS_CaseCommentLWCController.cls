public with sharing class Core_IPS_CaseCommentLWCController {
    Case currentcase;
   public static UserProperties UP = new UserProperties();
   public static  Core_IPS_CaseCommentHelper helper = new Core_IPS_CaseCommentHelper(); 
   public static  case currentcase ;
    // Niyaz -- 12/06/2025 --- added as part of vulnerability fix, removed CreatedBy.Email from all the below queries as it is not used in any return value
    @AuraEnabled
    public static void initialize(string caseId){
        currentcase = [select id,subject,Core_IPS_Comment__c,RecordType.Name,AccountId,Core_Sub_Status__c,status,contactid,Core_IPS_Date_Time_Close_Pending__c from Case where id =:caseId ];
      
    }

    @AuraEnabled
    public static string saveCaseComment(string caseId, String visibility, string comment){
       if(currentcase == null ){
             currentcase = [select id,subject,Core_IPS_Comment__c,RecordType.Name,AccountId,Core_Sub_Status__c,status,contactid,Core_IPS_Date_Time_Close_Pending__c from Case where id =:caseId ];
       }
        return helper.saveComments(currentcase, visibility, comment);

    }

    @AuraEnabled(cacheable=true )
    public static List<string> getVisibilityOptions(string caseId){
         currentcase = [select id,subject,Core_IPS_Comment__c,RecordType.Name,AccountId,Core_Sub_Status__c,status,contactid,Core_IPS_Date_Time_Close_Pending__c from Case where id =:caseId ];
        if(up == null ){
            up = new UserProperties();
        }
        List<string> options = new List<string>();
        if( (!(up.externalUser) || (up.partnerAgentUser) || (up.partDFAEUser != null)) && !(helper.isNACCase(currentcase))){
                options.add('Public to Customers');
                options.add('Private to Partner');
        }
        if( !(up.externalUser) || (up.partnerAgentUser) ){
                options.add('Private to Intel');
        }
        if( up.userHasAccess || up.partnerAgentUser ){
                options.add('Private to Agents');
        }    
        return options;
    }
    @AuraEnabled(cacheable=true )
    public static boolean  showVisibilityOptions(){
        if(up == null ){
            up = new UserProperties();
        }
        boolean flag = ( (!(up.ExtUser)) && (up.partnerType != 'Partner') && (up.partDFAEUser != null) );
        return flag;
    }
}