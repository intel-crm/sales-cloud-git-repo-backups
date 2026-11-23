public class PMP_InsertOffSharingLogic {
    // public static void insertOffSharingLogic()
    // {
    //     Set<Id> partnerIds = new Set<Id>();
    //     partnerIds.add('a5S2i0000008obD');
    //     String opidAccountId = '0012i00000NdeFL';
    //     String groupName = 'PMP_'+ opidAccountId+'%';
    //     Set<Id> offIds = new Set<Id>();
    //     List<PMP_Partner_Offering__c> offList = [Select Id,PMP_Company_Id__c from PMP_Partner_Offering__c where PMP_Company_Id__c in :partnerIds];
    //     for(PMP_Partner_Offering__c off : offList)
    //     {
    //         offIds.add(off.Id);
    //     }
    //     List<PMP_Partner_Offering__Share> partOfferingShareList = new List<PMP_Partner_Offering__Share>();
    //     Group pb =[SELECT Id,DeveloperName,Name FROM Group where DeveloperName like :groupName];
    //     if(pb==null)
    //     {
    //         Group pbGroup = new Group();
    //         pbGroup.Name = groupName;
    //         insert pbGroup;
    //     }
    //     for(Id offeringRecordId : offIds){
    //         PMP_Partner_Offering__Share partOfferingShare = new PMP_Partner_Offering__Share();
    //         partOfferingShare.AccessLevel  = 'Edit';
    //         partOfferingShare.UserOrGroupId  = pb.id;
    //         partOfferingShare.ParentId = offeringRecordId;
    //         partOfferingShareList.add(partOfferingShare);
    //     }        
    //     for(Id offeringRecordId : offIds){
    //         PMP_Partner_Offering__Share partOfferingShare = new PMP_Partner_Offering__Share();
    //         partOfferingShare.AccessLevel  = 'Read';
    //         partOfferingShare.UserOrGroupId  = pb.id;
    //         partOfferingShare.ParentId = offeringRecordId;
    //         partOfferingShareList.add(partOfferingShare);
    //     }       
    //     if(partOfferingShareList != null && !partOfferingShareList.isEmpty()){
    //         Database.insert(partOfferingShareList);
    //     }
    // }
}