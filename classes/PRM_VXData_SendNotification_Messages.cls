public without sharing class PRM_VXData_SendNotification_Messages {
    
   /* @InvocableMethod(label='Send  VX Data Notifications Messages')
    public static void sendVxNotification(List<PRM_Value_Exchange_Data__c> vxdataList){
        List<Id> accountList = new List<Id>();
        if(!vxdataList.isEmpty() && vxdataList.size() > 0) {
            for(PRM_Value_Exchange_Data__c vxd: vxdataList){
                accountList.add(vxd.PRM_Account_Id__c);
            }
        }
        if(accountList.size() > 0){
            PRM_SendNotificationMessages.upsertMsgLogRecs(accountList,System.label.PRM_Msgcd_Upgrade);
        }
    }*/
    
}