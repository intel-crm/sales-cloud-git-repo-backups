global class PMP_Batch_PublishToPIM implements 
    Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
       // Boolean executeOutOfSync=false;
        public PMP_Batch_PublishToPIM(Boolean syncSet ){
            //executeOutOfSync=syncSet;
        }

        global Database.QueryLocator start(Database.BatchableContext bc) {
            String query;
            /*query= 'SELECT Id FROM PMP_Partner_Offering__c where  PMP_Partner_Offering_Lifecycle_Status_Nm__c=\'Published\'' +
                            'and PMP_Working_Copy_Id__c!=\'\' and PMP_Partner_Offering_Source_Id__c !=\'\'';*/
           // query='SELECT Id FROM PMP_Partner_Offering__c where '+ System.label.PMP_PIM_Publish_Batch_Where_Clause;
            query=null;

            return Database.getQueryLocator(query);
        }
    global void execute(Database.BatchableContext bc, List<PMP_Partner_Offering__c> scope){
        // // process each batch of records
        // List<Id> offeringIds=new List<Id>();
        // // system.debug('size:'+scope.size());
        // for (PMP_Partner_Offering__c offering : scope) {
        //     offeringIds.add(offering.Id);
        // }
        // system.debug('qs:'+offeringIds.size());
        // //PMP_PIMProduct.buildProduct(offeringIds);
        // //PMP_PIMProduct p=new PMP_PIMProduct(offeringId);
        // List<PMP_Languages__mdt> nullTranslations = new List<PMP_Languages__mdt>();
        //  	PMP_PIMProduct.generatePIMProduct(offeringIds, nullTranslations, False, False); 
            
    }    
    global void finish(Database.BatchableContext bc){
       
    }    
}