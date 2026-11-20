public without sharing class Core_Opportunity_Support_statusupdate {
     @AuraEnabled(cacheable=true)
    public static Map<id,String> getStatusValue(String recId){

     
        Map<id,String> opptSuppReqMap = new Map<id,String>();
        Core_Opportunity_Support__c opptSuppReq=  new Core_Opportunity_Support__c();
        try{
            if(recId!=null){
             opptSuppReq = [select id,Core_Status__c,RecordType.id from Core_Opportunity_Support__c where id=:recId limit 1];   
               opptSuppReqMap.put(opptSuppReq.RecordType.id,opptSuppReq.Core_Status__c);
            }     
        }catch (Exception e) { 
             Core_Exceptions__c excep = new Core_Exceptions__c(
             Core_Exception__c = '@Failure:'+e.getStackTraceString()+' Cause'+e.getMessage(),
             Core_Class_Name__c ='Core_Opportunity_Support_statusupdate',
             Core_Method_Name__c ='getStatusValue');
        }
        return opptSuppReqMap;
    } 
    @AuraEnabled
   	public static boolean updateOnMS(Id recordId , String statusvalue){
        boolean notMSUser = false;
        try{
            String labelString = '';
            for(GroupMember groupEmail : [select id,UserOrGroup.Email, Group.name from GroupMember where group.name = 'Opportunity Support email alert']){
                labelString = labelString + groupEmail.UserOrGroup.Email+',';
            }
            labelString = labelString.removeEnd(',');
            if(labelString.contains(UserInfo.getUserEmail())){update new Core_Opportunity_Support__c(Id = recordId, Core_Status__c = statusvalue);
                notMSUser = false;
            }
            else{
                notMSUser = true;
            }
            
        }catch(exception ex){
            string errormsg = ex.getMessage();
            String pureErrorMsg = errormsg.substringAfter('_EXCEPTION,');
            List<String>pureErrorMsglist =pureErrorMsg.Substring(0,(pureErrorMsg.length())).split(':', 2);
            throw new AuraHandledException(pureErrorMsglist[0]);
        }
      
        return notMSUser;
    
    }   
}