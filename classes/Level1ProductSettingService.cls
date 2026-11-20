/*********************************************************************************************************************
* Apex Class Name  : Level1ProductSettingService
* Author And Date  : Rohit Podder, 25 MAY 2026
* Function         : Manages creation and updation Core_Level1_Products__c custom settings
*********************************************************************************************************************/
public class Level1ProductSettingService {

    public void createOrUpdateSettings(Map<String, String> mapNameLevel1ProductIds) {
        Map<String, Core_Level1_Products__c> mapLevel1ProductsSetting = Core_Level1_Products__c.getAll();
        List<Core_Level1_Products__c> listLevel1ProductsSetting = new List<Core_Level1_Products__c>();
        List<String> deactivateLevel1Id = new List<String>();

        if (mapLevel1ProductsSetting.values().isEmpty()) {
            for (String level1ProductName : mapNameLevel1ProductIds.keySet()) {
                listLevel1ProductsSetting.add(buildActiveLevel1Record(level1ProductName, mapNameLevel1ProductIds.get(level1ProductName)));
            }
        } else {
            Set<String> existingLevel1Ids = new Set<String>();
            for (Core_Level1_Products__c clp : mapLevel1ProductsSetting.values()) {
                existingLevel1Ids.add(clp.Level_1_Id__c);
            }

            for (String apiLevel1Name : mapNameLevel1ProductIds.keySet()) {
                String incomingId = mapNameLevel1ProductIds.get(apiLevel1Name);
                if (!existingLevel1Ids.contains(incomingId)) {
                    listLevel1ProductsSetting.add(buildActiveLevel1Record(apiLevel1Name, incomingId));
                }
            }

            for (String storedLevel1Id : existingLevel1Ids) {
                if (!mapNameLevel1ProductIds.values().contains(storedLevel1Id)) {
                    deactivateLevel1Id.add(storedLevel1Id);
                }
            }
        }

        if (!deactivateLevel1Id.isEmpty()) {
            List<Core_Level1_Products__c> fetchLevel1ProductsToDeactivate = [
                SELECT Id
                FROM Core_Level1_Products__c
                WHERE Level_1_Id__c IN :deactivateLevel1Id
            ];
            for (Core_Level1_Products__c level1RecordToDeactivate : fetchLevel1ProductsToDeactivate) {
                level1RecordToDeactivate.Is_Active__c = false;
            }
            update fetchLevel1ProductsToDeactivate;
        }

        if (!listLevel1ProductsSetting.isEmpty()) {
            insert listLevel1ProductsSetting;
        }
    }

    private Core_Level1_Products__c buildActiveLevel1Record(String nameValue, String level1Id) {
        Core_Level1_Products__c level1Products = new Core_Level1_Products__c();
        level1Products.Name = nameValue;
        level1Products.Level_1_Id__c = level1Id;
        level1Products.Is_Active__c = true;
        return level1Products;
    }
}