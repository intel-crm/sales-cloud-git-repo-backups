public without sharing class ExecutiveMeetingBrief_ServiceHandler {
	
    public static void account360Sharing(List<Executive_Meeting_Brief__c> newExecMeetBriefList)
    {
        Map<Id,List<Executive_Meeting_Brief__c>> acctRecordListMap = new Map<Id,List<Executive_Meeting_Brief__c>>();
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
        try{
            for(Executive_Meeting_Brief__c emb : newExecMeetBriefList)
            {
                if(acctRecordListMap.containsKey(emb.Account__c)){
                    acctRecordListMap.get(emb.Account__c).add(emb);
                }else{
                    acctRecordListMap.put(emb.Account__c, new List<Executive_Meeting_Brief__c>{emb});
                }            
            }
            if(acctRecordListMap <> null)
            {
                Account360_SharingUtility.account360_Apex_Sharing(acctRecordListMap);
            }
        }catch(Exception e){  /* String message = ''; Integer maxSize = 255;  if(e.getMessage().length() > maxSize ){  message = e.getMessage().substring(0, maxSize);
            }else{message = e.getMessage();}*/
            logEntries.add(new Core_Log_Entry__c(Core_Message__c ='Error',Core_Details__c = e.getMessage(), Core_Origin__c='ExecutiveMeetingBrief_ServiceHandler.account360Sharing', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
            if(!logEntries.isEmpty() && !logSwitch.isEmpty()){
                if(logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c){ 
                    insert logEntries;
                }
            }
        }
    }
}