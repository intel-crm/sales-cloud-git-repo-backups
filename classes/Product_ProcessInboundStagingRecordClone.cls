public class Product_ProcessInboundStagingRecordClone {
        @InvocableMethod(label = 'Invoke Product_Inbound_Staging' description = 'Process the Product_Inbound_Staging Records')
        public static void processInboundStagingRecords(list<string> Ids){  
            // Changed the method name and description
            list<Core_Products_Staging__c> inbMasterList = new  list<Core_Products_Staging__c>();
            set<string> epmIdSet = new set<string>();
            map<integer,string> vphProductNumberMap = new map<integer,string>();
            Integer vphCount = 1;
            Integer IntialCount = 1;
            Boolean vplchInd = false; 
            String ipaasId;
            
            if(!Ids.IsEmpty() && Ids != null){
                ipaasId = Ids[0];
            }        
            if(ipaasId != null){
                for(AggregateResult inb: [select level_1_epm_id__c, count(id) from Product_Inbound_Staging__c where iPaaS_Load_ID__c = :ipaasId and Core_Hierarchy_ID__c = '43' group by level_1_epm_id__c]){
                    // Map with count, EpmiId
                    string tempdisplay =  (string)inb.get('level_1_epm_id__c') ;
                    system.debug('inb tempdisplay >>>'+tempdisplay);
                    if(!epmIdSet.contains((string)inb.get('level_1_epm_id__c')) && string.isNotBlank((string)inb.get('level_1_epm_id__c'))  ){
                        epmIdSet.add((string)inb.get('level_1_epm_id__c'));
                        vphProductNumberMap.put(vphCount,(string)inb.get('level_1_epm_id__c') );
                        system.debug('vphProductNumberMap is .get() >>'+vphProductNumberMap.get(vphCount));
                        vphCount = vphCount + 1;                    
                    }
                }
                system.debug('empIdSet is'+epmIdSet);
                system.debug('vphProductNumberMap is >>'+vphProductNumberMap);
            }
            // Invoking the Queueable job by passing only the level  Epm Ids
            if (vphProductNumberMap.size() > 0   ){
                system.debug('Inside execute queueable job '); 
                System.enqueueJob(new Product_stageQueueableCloneP(IntialCount,inbMasterList,vphProductNumberMap,vplchInd, ipaasId));
            }        
        }
}