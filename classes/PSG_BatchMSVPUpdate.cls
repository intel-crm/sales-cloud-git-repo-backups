/****************************************************************************************************
Apex Class Name : PSG_BatchMSVPUpdate
Version         : 1.0 
Created Date    : 01/06/2021
Function        : Batch Class to update MSVP records.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Raju Malepalli                  01/06/2021                 Created
*****************************************************************************************************/

global class PSG_BatchMSVPUpdate implements Database.Batchable<sObject>, Schedulable ,Database.Stateful {
    String query = 'SELECT Id, Name, core_cpq_product_nm__c, core_cpq_effective_date_dt__c, core_cpq_isactive__c FROM price_msvp__c WHERE (core_cpq_isactive__c = true OR core_cpq_effective_date_dt__c >= TODAY) Order by core_cpq_product_nm__c desc';
    Set<String> processedProdIds=new Set<String>();
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<price_msvp__c> lstMsvp1){
        Set<String> prodIds=new Set<String>();
        Map<Id, price_msvp__c> activeMsvpMap = new Map<Id, price_msvp__c>();
        Map<Id, price_msvp__c> pastMsvpMap = new Map<Id, price_msvp__c>();
        list<price_msvp__c>  activeMsvpList= new list<price_msvp__c>();
        list<price_msvp__c>  msvplist= new list<price_msvp__c>();
        try{
            for(price_msvp__c msvp: lstMsvp1){
                if(!processedProdIds.contains(msvp.core_cpq_product_nm__c)){
                    prodIds.add(msvp.core_cpq_product_nm__c);
                }        
            }
            if(!prodIds.isEmpty()){
                List<price_msvp__c> lstMsvp=[SELECT Id, Name, core_cpq_product_nm__c, core_cpq_effective_date_dt__c, core_cpq_isactive__c FROM price_msvp__c WHERE (core_cpq_isactive__c = true OR core_cpq_effective_date_dt__c >= TODAY) and core_cpq_product_nm__c in :prodIds WITH SECURITY_ENFORCED];
                for(price_msvp__c msvp: lstMsvp){
                    if(msvp.core_cpq_isactive__c == true){
                        activeMsvpList.add(msvp);
                    }
                    if(msvp.core_cpq_effective_date_dt__c == System.today()){
                        msvp.core_cpq_isactive__c = true;
                        msvplist.add(msvp);
                        activeMsvpMap.put(msvp.core_cpq_product_nm__c, msvp);
                    }else if(msvp.core_cpq_isactive__c == true && msvp.core_cpq_effective_date_dt__c > System.today()){
                        msvp.core_cpq_isactive__c = false;
                        msvplist.add(msvp);
                        
                    }
                }
                for(price_msvp__c activeMsvp: activeMsvpList){
                    if(activeMsvpMap.containskey(activeMsvp.core_cpq_product_nm__c)){
                        if(activeMsvp.core_cpq_effective_date_dt__c != System.today()){
                            activeMsvp.core_cpq_isactive__c = false;
                            msvplist.add(activeMsvp);
                        }
                    }else if(!pastMsvpMap.isEmpty()){
                        if(pastMsvpMap.containsKey(activeMsvp.core_cpq_product_nm__c) && activeMsvp.core_cpq_effective_date_dt__c < System.today()){
                            if(pastMsvpMap.get(activeMsvp.core_cpq_product_nm__c).core_cpq_effective_date_dt__c < activeMsvp.core_cpq_effective_date_dt__c && pastMsvpMap.get(activeMsvp.core_cpq_product_nm__c).core_cpq_product_nm__c == activeMsvp.core_cpq_product_nm__c){
                                activeMsvp.core_cpq_isactive__c = true;
                                pastMsvpMap.get(activeMsvp.core_cpq_product_nm__c).core_cpq_isactive__c = false;
                                msvplist.add(pastMsvpMap.get(activeMsvp.core_cpq_product_nm__c));
                                pastMsvpMap.put(activeMsvp.core_cpq_product_nm__c, activeMsvp);
                            }else{
                                activeMsvp.core_cpq_isactive__c = false;
                                msvplist.add(activeMsvp);
                            }
                        }else{
                            activeMsvp.core_cpq_isactive__c = true;
                            pastMsvpMap.put(activeMsvp.core_cpq_product_nm__c, activeMsvp);
                            
                        }
                    }else if(activeMsvp.core_cpq_effective_date_dt__c < System.today()){
                        pastMsvpMap.put(activeMsvp.core_cpq_product_nm__c, activeMsvp);
                       
                    }
                }
                if(!pastMsvpMap.isEmpty()){
                    update pastMsvpMap.values();
                }
                
                if(!msvplist.isEmpty()){
                    for(price_msvp__c mlist : msvplist){
                        if(mlist.core_cpq_effective_date_dt__c >  System.today()){
                            mlist.core_cpq_isactive__c = false;
                        }
                    }
                    update msvplist;
                }
                processedProdIds.addAll(prodIds);
            }            
        }catch(Exception e){
            PSG_Utility.logError(e);
        }        
    }
    
    global void finish(Database.BatchableContext bc){
        /*PSG_Utility.logError('MSVP Batch Execution Completed Successfully');
psg_utility.createPSGLogEntry('PSG_BatchMSVPUpdate', 'BatchUpdate', 'MSVP Batch Execution Completed Successfully', 'Success', 'price_msvp__c', 'low', 'Confirmation', sObjectId, sObjectType, sObjectRecord)
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
String[] toAddresses = new String[]{'rajux.mallepalli@intel.com'};
mail.setToAddresses(toAddresses);
mail.setSubject('MSVP Batch Execution Completed Successfully');
mail.setPlainTextBody('MSVP Batch Execution Completed Successfully');*/
    }
    global void execute(System.SchedulableContext sc){
        PSG_BatchMSVPUpdate msvpUpdate = new PSG_BatchMSVPUpdate();
        Database.executeBatch(msvpUpdate);
    }
    
}