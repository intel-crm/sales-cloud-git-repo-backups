/****************************************************************************************************
Apex Class Name : PSG_PriceIncreaseProcessBatch
Version         : 1.0 
Created Date    : 11/04/2021
Function        : This class is used to process the PSG Price Increase records.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari Kiran K              11/04/2021                Created
*****************************************************************************************************/
global class PSG_PriceIncreaseProcessBatch implements Database.Batchable<Sobject>, Database.Stateful,Database.AllowsCallouts{
    Map<Id,psg_price_increase__c> failedPriceIncMap=new Map<Id,psg_price_increase__c>();
    Id DPALinesRecordTypeId = Schema.SObjectType.core_cpq_dpa_aln_line__c.getRecordTypeInfosByDeveloperName().get('PSG_DPA_Lines').getRecordTypeId();
    Id ALNLinesRecordTypeId = Schema.SObjectType.core_cpq_dpa_aln_line__c.getRecordTypeInfosByDeveloperName().get('PSG_ALN_Lines').getRecordTypeId();
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,psg_dpa_aln_id__c,psg_dpa_aln_nbr__c,Status__c,Operation_Type__c from psg_price_increase__c where Status__c='Pending']);
    }

    global void execute(Database.BatchableContext bc, List<SObject> sobjLst) {        
        Map<Id,psg_price_increase__c> priceIncRecToUpdate=new Map<Id,psg_price_increase__c>();
        Set<String> dpaNos=new Set<String>();
        Set<String> dpaIds=new Set<String>();
        Map<String,core_cpq_dpa_aln__c> dpaNoToDPAMap=new Map<String,core_cpq_dpa_aln__c>();
        Map<String,String> dpaIdTodpaNoMap=new Map<String,String>();
        Map<String,List<core_cpq_dpa_aln_line__c>> dpaToDpaLineMap=new Map<String,List<core_cpq_dpa_aln_line__c>>();
        for(psg_price_increase__c p : (List<psg_price_increase__c>)sobjLst){
            if(p.psg_dpa_aln_id__c == null && p.psg_dpa_aln_nbr__c == null){
                p.Status__c='Failed';
                p.Sync_Comments__c='Either Dpa/ALN Id (or) Dpa/ALN Number is required to process record.';
                priceIncRecToUpdate.put(p.Id,p);
            }else if(p.psg_dpa_aln_id__c != null){
                dpaIds.add(p.psg_dpa_aln_id__c);
            }else if(p.psg_dpa_aln_nbr__c != null){
                dpaNos.add(p.psg_dpa_aln_nbr__c);
            }
        }
        if(!dpaNos.isEmpty() || !dpaIds.isEmpty()){
            String dpaQuery='Select '+String.join(new List<String>(core_cpq_dpa_aln__c.SObjectType.getDescribe().fields.getMap().keySet()),',' )+' from '
                +String.valueOf(core_cpq_dpa_aln__c.SObjectType)+' Where Name in :dpaNos or Id in :dpaIds';
            for(core_cpq_dpa_aln__c dpaAlnRec : Database.query(dpaQuery)){
                dpaNoToDpaMap.put(dpaAlnRec.Name,dpaAlnRec);
                dpaIdToDpaNoMap.put(dpaAlnRec.Id,dpaAlnRec.Name);
            }
            
            String dpaLineQuery='SELECT '+String.join(new List<String>(core_cpq_dpa_aln_line__c.SObjectType.getDescribe().fields.getMap().keySet()),',')+
                ' FROM '+String.valueOf(core_cpq_dpa_aln_line__c.SObjectType)+' WHERE (core_cpq_cis_no_nbr__r.Name in :dpaNos or core_cpq_cis_no_nbr__c in :dpaIds) AND core_cpq_dollar_change_flag__c = False';
            for(core_cpq_dpa_aln_line__c dpaAlnLineRec : Database.query(dpaLineQuery)){
                if(dpaToDpaLineMap.containsKey(dpaAlnLineRec.core_cpq_cis_no_nbr__c)){
                    dpaToDpaLineMap.get(dpaAlnLineRec.core_cpq_cis_no_nbr__c).add(dpaAlnLineRec);
                }else{
                    dpaToDpaLineMap.put(dpaAlnLineRec.core_cpq_cis_no_nbr__c,new List<core_cpq_dpa_aln_line__c>{dpaAlnLineRec});
                }
            }
               
        }
        List<psg_price_increase__c> priceincreaselist=(List<psg_price_increase__c>)sobjLst;
        if(!priceincreaselist.isEmpty()){
            psg_price_increase__c p=priceincreaselist[0];
            if(!priceIncRecToUpdate.containsKey(p.Id) && p.Operation_Type__c=='SAP Submission'){
                PSG_Integration_DPA.LightningResponse lr;
                if(p.psg_dpa_aln_id__c != null){
                    lr=PSG_Integration_DPA.sendRequestToSAP(p.psg_dpa_aln_id__c, '');
                }else if(dpaNoToDpaMap.containsKey(p.psg_dpa_aln_nbr__c)){
                    lr=PSG_Integration_DPA.sendRequestToSAP(dpaNoToDpaMap.get(p.psg_dpa_aln_nbr__c).Id, '');
                }else{
                    p.Status__c='Failed';
                    p.Sync_Comments__c='Unable to Find DPA/ALN record with provided DPA/ALN Number.';
                    priceIncRecToUpdate.put(p.Id,p);
                }
                if(lr!=null){
                    if(lr.isSuccess){
                        p.Status__c='Processed';
                        p.Sync_Comments__c=lr.message;
                    }else{
                        p.Status__c='Failed';
                        p.Sync_Comments__c=lr.message;
                    }
                    priceIncRecToUpdate.put(p.Id,p);
                }
            }else if(!priceIncRecToUpdate.containsKey(p.Id) && p.Operation_Type__c=='Clone'){
                core_cpq_dpa_aln__c oldDpa;
                core_cpq_dpa_aln__c newDpa;
                List<core_cpq_dpa_aln_line__c> dpaLineToInsert=new List<core_cpq_dpa_aln_line__c>();
                if(p.psg_dpa_aln_id__c != null){
                    oldDpa=dpaNoToDpaMap.get(dpaIdToDpaNoMap.get(p.psg_dpa_aln_id__c));
                }else if(dpaNoToDpaMap.containsKey(p.psg_dpa_aln_nbr__c)){
                    oldDpa=dpaNoToDpaMap.get(p.psg_dpa_aln_nbr__c);
                }
                if(oldDpa != null){
                    newDpa=oldDpa.clone(false, true, false, false);
                    for(String fieldName : (Label.PSG_DPAFieldsNull).split(':')){
                        newdpa.put(fieldName,null);
                    }
                    newdpa.core_cpq_siebel_cis_no_txt__c=null;
                    newdpa.core_cpq_status_txt__c='New';
                    if(newdpa.core_cpq_record_type_identifier__c=='DPA'){
                        newdpa.core_cpq_change_flag__c='N';
                    }else{
                        newdpa.core_cpq_change_flag__c='R'; 
                        newdpa.core_cpq_replace_aln_txt__c=oldDpa.core_cpq_siebel_cis_no_txt__c==null?oldDpa.Name:oldDpa.core_cpq_siebel_cis_no_txt__c;
                    }
                    Savepoint sp = Database.setSavepoint();
                    try{
                        insert newdpa;
                        if(dpaToDpaLineMap.containsKey(oldDpa.Id)){
                            for(core_cpq_dpa_aln_line__c dpaLine: dpaToDpaLineMap.get(oldDpa.Id)){
                                core_cpq_dpa_aln_line__c newDPALine = dpaLine.clone(false,true); // deep clone
                                newDPALine.core_cpq_cis_no_nbr__c = newdpa.Id; //set clonedDpaAln ref
                                if(newDpa.core_cpq_record_type_identifier__c == 'DPA'){
                                    newDPALine.RecordTypeId= DPALinesRecordTypeId; 
                                }else if(newDpa.core_cpq_record_type_identifier__c == 'ALN'){
                                    newDPALine.RecordTypeId = ALNLinesRecordTypeId;
                                }
                                for(String fieldName : (Label.PSG_DPALinesFieldsNull).split(':')){
                                    newDPALine.put(fieldName,null);
                                }
                                newDPALine.core_cpq_approved_qty_nbr__c=dpaLine.core_cpq_approved_qty_nbr__c;
                                dpaLineToInsert.add(newDPALine);
                            }
                            if(!dpaLineToInsert.isEmpty()){
                                insert dpaLineToInsert;
                            }
                        }
                        p.Status__c='Processed';
                        p.Sync_Comments__c='Cloned Successfully';
                        p.Cloned_DPA_ALN_Id__c=newdpa.Id;
                        priceIncRecToUpdate.put(p.Id,p);
                    }catch(Exception e){
                        Database.rollback(sp);
                        p.Status__c='Failed';
                        p.Sync_Comments__c=e.getMessage();
                        priceIncRecToUpdate.put(p.Id,p);
                    } 
                }else{
                    p.Status__c='Failed';
                    p.Sync_Comments__c='Invalid DPA Id & DPA No';
                    priceIncRecToUpdate.put(p.Id,p);
                }                               
            }
        }
        List<Database.SaveResult> result=Database.update(priceIncRecToUpdate.values(),false); 
        for(Integer i=0;i<result.size();i++){
            if(!result[i].isSuccess()){
                failedPriceIncMap.put(priceIncRecToUpdate.values()[i].Id,priceIncRecToUpdate.values()[i]);
            }
        }
    }              
    global void finish(Database.BatchableContext bc) {
        if(!failedPriceIncMap.isEmpty() || Test.isRunningTest()){
            PSG_Utility.createCoreLogEntry('PSG_PriceIncreaseProcessBatch','PSG_PriceIncreaseProcessBatch','Failed Price Increase records to update after processing.',''+failedPriceIncMap
                                         ,'psg_price_increase__c','High','');
        }
    }
}