global class Core_MDF_All_AccountProductMappingBatch implements Database.Batchable<sObject>,Database.Stateful {

    List<String> productIds;
    String program;
    List<Core_MDF_Account_Product_Mapping__c> accProdMappingList = new List<Core_MDF_Account_Product_Mapping__c>();

    global Core_MDF_All_AccountProductMappingBatch(List<String> productIds, String program){
        this.productIds = productIds;
        this.program = program;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program__r.Name, Core_MDF_Parent_Fund_Account__c ' + 
                        'FROM account ' + 
            			'WHERE RecordType.DeveloperName = \'Mastered_Account\' ' +
                        'AND Core_MDF_CoMarketingActive__c = true ' +
                        'AND Core_MDF_Channel_Program__r.Name =: program';

        system.debug('@@query --> '+query);                
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> accObjList){
        for(String productId : productIds){
            for(Account acc : accObjList){  
                Core_MDF_Account_Product_Mapping__c apm = new Core_MDF_Account_Product_Mapping__c();
                apm.Core_MDF_Account__c = acc.Id;                                
                apm.Core_MDF_All_Account_Ind__c = true;                                
                apm.Core_MDF_Product__c = productId;
                apm.Core_MDF_Program_Account_Map__c = program;
                apm.Core_MDF_Active_ind__c = true;
                accProdMappingList.add(apm);
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        if(!accProdMappingList.isEmpty()){
            //Database.insert(accProdMappingList);
            system.debug('@@accProdMappingList -> '+accProdMappingList);
        }
    }

}