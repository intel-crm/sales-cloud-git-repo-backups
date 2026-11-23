public class Core_Goal_GiveShareAccessDWG{


    @InvocableMethod(label='Give_sharing_to_Goal' description='Give sharing to Goal')
    public static List<Core_Goal__c> getAccountNames(List<Core_Goal__c> goalList) {
        List<Core_Goal__Share> goalShareList = new List<Core_Goal__Share>();
        for(Core_Goal__c dwg : goalList){
            goalShareList.add(new Core_Goal__Share(UserOrGroupId = dwg.CreatedById, ParentId = dwg.Id, RowCause='Core_Deal_Win_Goal__c', AccessLevel = 'read'));
        }
        if(!goalShareList.isEmpty()){
            insert goalShareList;
        }
        return null;
    }
}