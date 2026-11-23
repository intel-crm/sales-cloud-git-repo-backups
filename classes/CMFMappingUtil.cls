public class CMFMappingUtil {
    public static void mapCMFsToAccounts(Id bagId) {
        Set<String> cmfGroupSet = new Set<String>();
        List<ER_CMFGroupAssociation__c> cmfassociationList = new List<ER_CMFGroupAssociation__c>();
        //Switch mechanism for Direct Account EOL
        Core_ACM_Control_Execution__c eolCheck = [Select IsActive__c From Core_ACM_Control_Execution__c Where Name = 'EOL_Direct_Account' LIMIT 1][0];
        
        
        for (ER_CMFGroupAssociation__c cga : [
            SELECT Id, Name, ER_Customer_Master_File__r.ER_CMFUnique__c
            FROM ER_CMFGroupAssociation__c
            WHERE ER_Customer_Master_File_Group__c = :bagId
            AND ER_Active__c = TRUE
        ]) {
            cmfGroupSet.add(cga.ER_Customer_Master_File__r.ER_CMFUnique__c);
        }
        
        
        Map<String, String> accountToCmfMap = new Map<String, String>();
        if (eolCheck.IsActive__c) {
            for (Account acc : [
                SELECT Id, Core_Direct_Account_Id__c
                FROM Account
                WHERE RecordType.Name = 'Direct Account'
            ]) {
                if (acc.Core_Direct_Account_Id__c != null && !accountToCmfMap.containsKey(acc.Core_Direct_Account_Id__c)) {
                    accountToCmfMap.put(acc.Core_Direct_Account_Id__c, acc.Id);
                }
            }
        }
        
        for (ER_Customer_Master_File__c cmfs : [
            SELECT Id, Name, ER_CMFUnique__c
            FROM ER_Customer_Master_File__c
            WHERE ER_CMFUnique__c NOT IN :cmfGroupSet
            LIMIT 10
        ]) {
            System.debug('🔍 Processing CMF: ' + cmfs.Name);
            
            ER_CMFGroupAssociation__c cga = new ER_CMFGroupAssociation__c();
            cga.ER_Customer_Master_File__c = cmfs.Id;
            cga.ER_Customer_Master_File_Group__c = bagId;
            cga.ER_Active__c = TRUE;
            
            
            if (accountToCmfMap.containsKey(cmfs.Name)) {
                cga.ER_Account__c = accountToCmfMap.get(cmfs.Name);
                System.debug('✅ Mapped Account: ' + cga.ER_Account__c);
            } else {
                System.debug('⚠️ No Account for CMF: ' + cmfs.Name);
            }
            
            cmfassociationList.add(cga);
        }
        
        if (!cmfassociationList.isEmpty()) {
            insert cmfassociationList;
            System.debug('✅ Inserted: ' + cmfassociationList.size() + ' associations.');
        } else {
            System.debug('ℹ️ No associations created.');
        }
    }
}