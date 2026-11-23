public without sharing class Core_IPS_AccountTeamMember_Handler {
 
    public static void shareExistingAssets(List<AccountTeamMember> newList) {
        if (newList == null || newList.isEmpty()) {
            return;
        }
 
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Set<Id>> userIdsByAccountId = new Map<Id, Set<Id>>();
        for (AccountTeamMember teamMember : newList) {
            if (teamMember.AccountId == null || teamMember.UserId == null) {
                continue;
            }
            accountIds.add(teamMember.AccountId);
            if (!userIdsByAccountId.containsKey(teamMember.AccountId)) {
                userIdsByAccountId.put(teamMember.AccountId, new Set<Id>());
            }
            userIdsByAccountId.get(teamMember.AccountId).add(teamMember.UserId);
        }
        if (accountIds.isEmpty()) {
            return;
        }
 
        Set<Id> projectIds = new Set<Id>();
        Map<Id, Set<Id>> accountIdsByProjectId = new Map<Id, Set<Id>>();
        List<Core_IPS_Account__c> accountProjects = (List<Core_IPS_Account__c>) Core_IPS_QueryService.queryRecords(
            'SELECT Core_Account__c, Core_IPS_Project__c FROM Core_IPS_Account__c WHERE Core_Account__c IN :accountIds',
            new Map<String, Object>{'accountIds' => accountIds}
        );
        for (Core_IPS_Account__c accountProject : accountProjects) {
            if (accountProject.Core_Account__c == null || accountProject.Core_IPS_Project__c == null) {
                continue;
            }
            projectIds.add(accountProject.Core_IPS_Project__c);
            if (!accountIdsByProjectId.containsKey(accountProject.Core_IPS_Project__c)) {
                accountIdsByProjectId.put(accountProject.Core_IPS_Project__c, new Set<Id>());
            }
            accountIdsByProjectId.get(accountProject.Core_IPS_Project__c).add(accountProject.Core_Account__c);
        }
 
        Set<Id> publicProjectIds = new Set<Id>();
        if (!projectIds.isEmpty()) {
            List<Core_IPS_Project__c> projects = (List<Core_IPS_Project__c>) Core_IPS_QueryService.queryRecords(
                'SELECT Id FROM Core_IPS_Project__c WHERE Id IN :projectIds AND Core_IPS_Private__c = false',
                new Map<String, Object>{'projectIds' => projectIds}
            );
            for (Core_IPS_Project__c project : projects) {
                publicProjectIds.add(project.Id);
            }
        }
 
        List<Asset> assets = (List<Asset>) Core_IPS_QueryService.queryRecords(
            'SELECT Id, AccountId, Core_IPS_Project__c FROM Asset WHERE AccountId IN :accountIds OR Core_IPS_Project__c IN :publicProjectIds',
            new Map<String, Object>{'accountIds' => accountIds, 'publicProjectIds' => publicProjectIds}
        );
 
        Map<Id, Set<Id>> userIdsByAssetId = new Map<Id, Set<Id>>();
        for (Asset asset : assets) {
            if (asset.AccountId != null && userIdsByAccountId.containsKey(asset.AccountId)) {
                addUsersForAsset(userIdsByAssetId, asset.Id, userIdsByAccountId.get(asset.AccountId));
            }
            if (asset.Core_IPS_Project__c != null && accountIdsByProjectId.containsKey(asset.Core_IPS_Project__c)) {
                for (Id accountId : accountIdsByProjectId.get(asset.Core_IPS_Project__c)) {
                    if (userIdsByAccountId.containsKey(accountId)) {
                        addUsersForAsset(userIdsByAssetId, asset.Id, userIdsByAccountId.get(accountId));
                    }
                }
            }
        }
        if (userIdsByAssetId.isEmpty()) {
            return;
        }
 
        Set<Id> assetIds = userIdsByAssetId.keySet();
        Set<Id> userIds = new Set<Id>();
        for (Set<Id> assetUserIds : userIdsByAssetId.values()) {
            userIds.addAll(assetUserIds);
        }
        List<AssetShare> existingShares = (List<AssetShare>) Core_IPS_QueryService.queryRecords(
            'SELECT AssetId, UserOrGroupId FROM AssetShare WHERE AssetId IN :assetIds AND UserOrGroupId IN :userIds',
            new Map<String, Object>{'assetIds' => assetIds, 'userIds' => userIds}
        );
        for (AssetShare existingShare : existingShares) {
            if (userIdsByAssetId.containsKey(existingShare.AssetId)) {
                userIdsByAssetId.get(existingShare.AssetId).remove(existingShare.UserOrGroupId);
            }
        }
 
        Core_SharingUtility.provideAccess('Asset', 'AssetShare', 'Read', userIdsByAssetId);
    }
 
    private static void addUsersForAsset(Map<Id, Set<Id>> userIdsByAssetId, Id assetId, Set<Id> userIds) {
        if (!userIdsByAssetId.containsKey(assetId)) {
            userIdsByAssetId.put(assetId, new Set<Id>());
        }
        userIdsByAssetId.get(assetId).addAll(userIds);
    }
}