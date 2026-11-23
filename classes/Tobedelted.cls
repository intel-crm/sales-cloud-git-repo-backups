public class Tobedelted {
    public static void createError(){
        try{
            List<String>accountIds = new List<String>{'wrongId'};
            Map<String,Account> accounts = new Map<String, Account>([SELECT ID FROM Account where Industry = 'Energy']);
            for(String accountId: accountIds){
                Account account = accounts.get(accountId);
                 System.debug(account.Name);
            }
        }
        	
        catch(Exception ex){
            logError(ex);
        }
    }
        public static String getErrorDetails(Exception e){
        return 'Class & Method Name = ' + e.getStackTraceString().substringBefore(':') + ';\n' +
               'Exception Message = ' + e.getMessage() + ';\n' +
               'LineNumber = ' + String.valueOf(e.getLineNumber()) + ';\n' +
               'StackTrace = ' + e.getStackTraceString() + ';\n' +
               'Logged in user = ' + UserInfo.getName();
    }
      public static void logError(Exception e){
        logErrorinLogObject(getErrorDetails(e), e.getStackTraceString().substringBefore(':'));
    }
    public static void logErrorinLogObject(string errorMessage,string objectName){
            String subject = Label.PSG_Support_Email_Subject + ' ' +  objectName;
            Map<String, String> coreLogMap = new Map<String, String>();
            coreLogMap.put('Core_Details__c', errorMessage);
            coreLogMap.put('Core_Message__c', Label.PSG_SFDC_Environment + ': ' + subject);
            coreLogMap.put('Core_Origin__c', Label.PSG_Program_Name);
            coreLogMap.put('Core_Project__c',Label.PSG_Program_Name);
            coreLogMap.put('Core_Scope__c',objectName);
            coreLogMap.put('Core_Severity__c', 'Critical');
            //coreLogMap.put('Core_Support_Email__c', Label.PSG_Support_Email);
            coreLogMap.put('Core_Support_Email__c', 'Shreyash@xyz.com');
            coreLogMap.put('Core_Support_Link__c', Label.PSG_Support_Link);
            coreLogMap.put('Core_Tags__c', '') ;
            String errorText = createLogEntry(coreLogMap);
    }
     public static String createLogEntry(Map<String, String> coreLogMap){
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c();
        try {
            
            DateTime dtWhen = system.now();
            Map<String, Schema.SObjectField> logFields = Schema.SObjectType.Core_Log_Entry__c.fields.getMap();
            if(coreLogMap != null && coreLogMap.size() > 0){    
                for(String key:coreLogMap.keySet()){        
                    if(logFields.containsKey(key)){
                        Schema.DescribeFieldResult field= logFields.get(key).getDescribe();    
                        Integer length = field.getLength();
                        String value = String.valueOf(coreLogMap.get(key));                        
                        if(String.isNotBlank(value)){                                           
                            objCLE.put(key, value.left(length));
                        }else{
                            objCLE.put(key, '');
                        }                          
                    }
                }
                System.debug('******* CoreLog Map to be Inserted:'+objCLE);
                
                if(objCLE != null){
                    objCLE.put('Core_When__c',dtWhen);
                    Database.insert(objCLE);
                    System.debug('******* Inserted Object:'+ objCLE.id);
                    return objCLE.id;
                }
            }                      
        } catch(Exception e) {
            System.debug('*** App Logging Failed ' + e.getMessage());
        }
        return null;    
    }  
    
    
}