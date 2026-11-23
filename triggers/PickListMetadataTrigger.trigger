trigger PickListMetadataTrigger on Pricing_Picklist_Field_Value_Mapping__c (after insert) {
    set<Id> accountIds = new Set<Id>();
    for(Pricing_Picklist_Field_Value_Mapping__c recObj : trigger.new){
        accountIds.add(recObj.Pricing_Account_Nm__c);
    }
    //List<Account> accts = [SELECT id,Name FROM Account WHERE id IN :accountIds];
    List<AggregateResult> aggRes = [SELECT UserRoleId,AccountId FROM User WHERE AccountId IN :accountIds AND Account.IsPartner=True And UserRole.Name Like '%partner%' Group By AccountId,UserRoleId];
    Map<Id, Set<Id>> accountRoleIdMap = new Map<Id,Set<Id>>();
    Set<Id> userRoleIds = new Set<Id>();
    Map<Id,Id> userRoleGroupIdMap = new Map<Id,Id>();
    if(aggRes.size() > 0){
        for(AggregateResult ar: aggRes){
            userRoleIds.add((Id) ar.get('UserRoleId'));
        }    
        for(Group grp : [SELECT Id,RelatedId FROM Group WHERE RelatedId IN :userRoleIds AND Type='Role']){
            userRoleGroupIdMap.put(grp.RelatedId, grp.Id);
        }
        for(AggregateResult ar: aggRes){
            if(accountRoleIdMap.containsKey((Id) ar.get('AccountId'))){
                accountRoleIdMap.get((Id) ar.get('AccountId')).add(userRoleGroupIdMap.get((Id) ar.get('UserRoleId')));
            }else{
                accountRoleIdMap.put((Id) ar.get('AccountId'), new Set<Id>{userRoleGroupIdMap.get((Id) ar.get('UserRoleId'))});
            }
        }
        List<Pricing_Picklist_Field_Value_Mapping__share> shares = new List<Pricing_Picklist_Field_Value_Mapping__share>();
        for(Pricing_Picklist_Field_Value_Mapping__c recObj : trigger.new){
            for(Id grpId: accountRoleIdMap.get(recObj.Pricing_Account_Nm__c)){
                Pricing_Picklist_Field_Value_Mapping__share objShare = new Pricing_Picklist_Field_Value_Mapping__share();
                objShare.ParentId = recObj.Id;
                objShare.UserOrGroupId = grpId;
                objShare.AccessLevel = 'Read';
                objShare.RowCause = 'Manual';
                shares.add(objShare);
            }
        }
        if(shares.size() > 0){
            insert shares;
        }
    }    
}