public class Del_Product_ProcessInboundStagingRecords {
    @InvocableMethod(label = 'Indefdf inbound staging processing' description = 'Process ffthe Product_Inbound_Staging Records')
    public static void processInboundStagingRecords(list<string> Ids){ 
        
        Integer recordCountL1Limit = 3500;
        Integer recordCountL2Limit = 2000;
        Integer recordCountL2HigherLimit = 3000;
        // Changed the method name and description
        list<Core_Products_Staging__c> inbMasterList = new  list<Core_Products_Staging__c>();
        set<string> epmIdSet = new set<string>();
        map<integer,string> vphProductNumberMap = new map<integer,string>();
        Map<Integer,InputWrapper> inputWrapperMap = new Map<Integer,InputWrapper>();
        Integer vphCount = 1;
        Integer IntialCount = 1;   //Intially set to 1. The count will increase on completion of each queueble job.
        Boolean vplchInd = false; 
        String ipaasId;            
        Set<String> opnIDs = new Set<String>();
        
        if(!Ids.IsEmpty() && Ids != null){
            ipaasId = Ids[0];  //This is a unique load id which we get in every payload from Mule.
        }
        
        Set<String> largeDataSetL1ids = new Set<String>();

        if(string.isNotBlank(ipaasId)){
            for(AggregateResult inbRcrd: [select level_1_epm_id__c, count(id)cnt from Product_Inbound_Staging__c where iPaaS_Load_ID__c = :ipaasId and Core_Hierarchy_ID__c = '43' group by level_1_epm_id__c]){
                if(string.isNotBlank((string)inbRcrd.get('level_1_epm_id__c'))  ){
                    // Prepring list of level 1 EPM ids to send to Queueable where count is less than limit
                    if ((Integer)inbRcrd.get('cnt') < recordCountL1Limit) {
                        InputWrapper input = new InputWrapper();
                        input.atLevel2 = false;
                        input.level1EPMId = (string)inbRcrd.get('level_1_epm_id__c');
                        input.vplchInd = false;
                        inputWrapperMap.put(vphCount,input);
                        vphCount = vphCount + 1;
                        
                    }
                    // if count is greater than limit, preparing a set of level emp ids
                    else {
                        largeDataSetL1ids.add((string)inbRcrd.get('level_1_epm_id__c'));
                    }
                }
            }
            
            Integer finCount = 0;
            Set<String> level2EPMIds = new Set<String>();
            String lastepmId = '';
            // Query to get all invound staging records grouped by L2 for all the L1s in the above set(count > limit)
            List<AggregateResult> arList = [select level_2_epm_id__c,level_1_epm_id__c, count(id)cnt from Product_Inbound_Staging__c where iPaaS_Load_ID__c = :ipaasId and Core_Hierarchy_ID__c = '43' and level_1_epm_id__c in:largeDataSetL1ids  group by level_2_epm_id__c,level_1_epm_id__c  order by level_1_epm_id__c,count(Id) desc];
            
            if(!largeDataSetL1ids.isEmpty()){
                for(AggregateResult inbRcrd: arList){
                    if(string.isNotBlank((string)inbRcrd.get('level_2_epm_id__c'))  ){
                        //Below logic will keep adding the l2 epm ids in a set until the sum of records count 
                        //is greater than 900 within the L1 group and send it to Queueable

                        Boolean isAddedLast = finCount > recordCountL2Limit;
                        if(finCount < recordCountL2Limit  && (String.isBlank(lastepmId) || (string)inbRcrd.get('level_1_epm_id__c') == lastepmId || (arList.indexOf(inbRcrd) + 1 == arList.size()))){
                            level2EPMIds.add((string)inbRcrd.get('level_2_epm_id__c'));
                            finCount += (Integer)inbRcrd.get('cnt');
                        }

                        
                        if (finCount > recordCountL2Limit  || (arList.indexOf(inbRcrd) + 1 == arList.size()) || (String.isNotBlank(lastepmId) && (string)inbRcrd.get('level_1_epm_id__c') != lastepmId)){
                            if(!level2EPMIds.isEmpty()){
                                InputWrapper input = new InputWrapper();
                                input.atLevel2 = true;
                                if(String.isNotBlank(lastepmId) && (string)inbRcrd.get('level_1_epm_id__c') != lastepmId){
                                    if((arList.indexOf(inbRcrd) + 1 == arList.size())){
                                        input.level1EPMId = (string)inbRcrd.get('level_1_epm_id__c');
                                    }
                                    else{
                                        input.level1EPMId = lastepmId;
                                    }
                                }
                                else{
                                    input.level1EPMId = (string)inbRcrd.get('level_1_epm_id__c');
                                }
                                input.level2EPMIds = level2EPMIds;
                                input.vplchInd = false;
                                inputWrapperMap.put(vphCount,input);
                                vphCount = vphCount + 1;
                                level2EPMIds = new Set<String>();
                                finCount = 0;
                            }

                            if((String.isNotBlank(lastepmId) && (string)inbRcrd.get('level_1_epm_id__c') != lastepmId) || isAddedLast){
                                level2EPMIds.add((string)inbRcrd.get('level_2_epm_id__c'));
                                finCount += (Integer)inbRcrd.get('cnt');
                            }
                            lastepmId = (string)inbRcrd.get('level_1_epm_id__c');
                               
                        }
                        

                    }

                }
            }


            ///////////////////////////////

            Integer finCount1 = 0;
            Set<String> level1VplchEPMIds = new Set<String>();
            String lastepmId1 = '';
            // Query to get all invound staging records grouped by L2 for all the L1s in the above set(count > limit)
            List<AggregateResult> arList1 = [select level_1_epm_id__c, count(id)cnt from Product_Inbound_Staging__c where iPaaS_Load_ID__c = :ipaasId and Core_Hierarchy_ID__c = '59' group by level_1_epm_id__c  order by count(Id) desc];
            

                for(AggregateResult inbRcrd: arList1){
                    if(string.isNotBlank((string)inbRcrd.get('level_1_epm_id__c'))  ){
                        //Below logic will keep adding the l2 epm ids in a set until the sum of records count 
                        //is greater than 900 within the L1 group and send it to Queueable

                        Boolean isAddedLast = finCount > recordCountL2Limit;
                        if(finCount1 < 2000  || arList1.indexOf(inbRcrd) + 1 == arList1.size()){
                            level1VplchEPMIds.add((string)inbRcrd.get('level_1_epm_id__c'));
                            finCount1 += (Integer)inbRcrd.get('cnt');
                        }

                        
                        if (finCount1 > 2000|| (arList1.indexOf(inbRcrd) + 1 == arList1.size()) ){
                            if(!level1VplchEPMIds.isEmpty()){
                                InputWrapper input = new InputWrapper();
                                input.vplchInd = true;
                                input.level1VplchEPMIds = level1VplchEPMIds;
                                inputWrapperMap.put(vphCount,input);
                                vphCount = vphCount + 1;
                                level1VplchEPMIds = new Set<String>();
                                finCount1= 0;
                            }

                               
                        }
                        

                    }

                }

            //////////////////////////////////
            //system.debug(inputWrapperMap);
			Integer l2Count = 0;
            for(Integer f :inputWrapperMap.keySet()){
                if (inputWrapperMap.get(f).vplchInd) {
                    l2Count += inputWrapperMap.get(f).level1VplchEPMIds.size();
                    system.debug(f+'-'+inputWrapperMap.get(f));    
                }
                        
            }
			system.debug('l2Count '+l2Count);         
            if (inputWrapperMap.size() > 0){
                //System.enqueueJob(new Del_Product_stageQueueable(IntialCount,inputWrapperMap,ipaasId));
            } 
        }
             
    }

    public class InputWrapper {        
        public String level1EPMId{get;set;}        
        public Boolean atLevel2{get;set;}        
        public Set<String> level2EPMIds{get;set;}
        public Set<String> level1VplchEPMIds{get;set;}
        public Boolean vplchInd{get;set;}        

    }
}