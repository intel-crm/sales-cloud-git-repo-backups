trigger Core_EntitlementDetail_Request_Trigger on Core_Entitlement_Detail_Request__c (before insert,after insert, before update,after update) {
   new Core_EntitlementDetailReq_Handler().run();
}