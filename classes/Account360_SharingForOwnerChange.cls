public without sharing class Account360_SharingForOwnerChange {
    
    @InvocableMethod
    public static void invokeAccount360SharingforOnwerChange(List<Account> accList)
    {
        Map<Id,List<Id>> acctIdUserIdListMap = new Map<Id,List<Id>>();
        for(Account rec : accList)
            {
                if(acctIdUserIdListMap.containsKey(rec.Id)){
                    acctIdUserIdListMap.get(rec.Id).add(rec.OwnerId);
                }else{
                    acctIdUserIdListMap.put(rec.Id, new List<Id>{rec.OwnerId});
                } 
                
            }
        Account360_SharingUtility.performAccount360Sharing(acctIdUserIdListMap);
    }

}