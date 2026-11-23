public class PRM_CIM_Utility {
    public static void CIMIdStamped(Set<Id> CimUpdatedId){
        
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> CimIdStampedSet = new Set<Id>();
        List<PRM_AccountChannelMembership__c> AcmList = new List<PRM_AccountChannelMembership__c>();
        Map<Id,PRM_AccountChannelMembership__c> AcmMapold = new Map<Id,PRM_AccountChannelMembership__c> ();
        system.debug('Inside CIM Utiity');
        for(Id CimId :CimUpdatedId ){
            CimIdStampedSet.add(CimId);
        }
        if(!CimIdStampedSet.IsEmpty()){
            for(PRM_AccountChannelMembership__c acm : [Select id, PRM_Partner_Role__c, PRM_Account_Id__c, PRM_Channel_Program_Level_Id__c  from PRM_AccountChannelMembership__c where PRM_Account_Id__c in :CimIdStampedSet and PRM_Status_Nm__c = 'Approved']){
                AcmList.add(acm) ;   
            }
        }
        system.debug('The Final Account set is'+AcmList);
        if(!AcmList.IsEmpty()){
            PRM_ACM_Utility.CreateOPIDRecomndtn(AcmList,null);             
        }
    } 
    

}