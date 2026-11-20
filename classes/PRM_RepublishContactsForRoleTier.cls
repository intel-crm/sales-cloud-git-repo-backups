public with sharing class PRM_RepublishContactsForRoleTier {
    //public static List<Contact> conQueueFullLst=new List<Contact>();
    public static void UpdateRepublishOnContact(List<Id> conList){
        List<Contact> conQueueFullLst=new List<Contact>();
        if(!conList.isEmpty() && conList.size()>0){
        for(contact con: [select Core_ERPM_Integration_Queue_txt__c,Id, Core_Republish_OBM_s__c from contact where Id in: conList]){
            contact repCon = new contact();
            repCon.Id = con.Id;
            repCon.Core_Republish_OBM_s__c = true;
                conQueueFullLst.add(repCon);
            }
            if(!conQueueFullLst.isEmpty() && conQueueFullLst.size()>0){
                update conQueueFullLst;
            }
      }
  }
    
}