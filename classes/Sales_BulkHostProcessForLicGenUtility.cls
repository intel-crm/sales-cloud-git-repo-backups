/*********************************************************************************************************************
Class Name    : Sales_BulkHostProcessForLicGenUtility
Version       : 1.0
Created Date  : Aug 2021

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Ananga Mohan Sen           20-Aug-2021              US1085041:optimization license generation
* *********************************************************************************************************************/
public without sharing class Sales_BulkHostProcessForLicGenUtility {
    
    public static void executeLicGeneration(List<Sales_Bulk_Host_Process_Lic_Gen__e> eventList){
        /*system.debug('handler executed');
        set<String> hostIds=new set<String>();
        String eventType;
        String hostIdLogTable='';
        List<Sales_License_Generation_Req_Log__c> logTableLst=new List<Sales_License_Generation_Req_Log__c>();
        //list<String> hostIds=new list<String>();
        for(Sales_Bulk_Host_Process_Lic_Gen__e evtList:eventList){
            if(evtList.Host_Ids__c!=null){
                system.debug('inside controller if');
                hostIds.addAll((evtList.Host_Ids__c).split(','));
                eventType=evtList.Event_Type__c!=null?evtList.Event_Type__c:'';
            }
        }

        for(String idStr:hostIds){
            //calling license generation class
            system.debug('eventType>>>'+eventType);
            Sales_LicenseGenIntegration_Utility.returnHostIdDetail(idStr,'HostId',eventType);
            hostIdLogTable+=idStr+',';          
        }
         //inserting log table to monitor platform event
         system.debug('hostIdLogTable>>'+hostIdLogTable);
         Core_Log_Entry.logEntryWithDetails('Platform Event', 'PSG Sales','','Info','',hostIdLogTable, '', '', '');
        
    }
    public static void triggerPlatformEvt(set<id> hostIdSet,String eventType ){
       // list<Sales_Host__c> hostlist=[select id from Sales_Host__c limit 52 ];
        list<Sales_Host__c> hostlist=[select id from Sales_Host__c where id IN:hostIdSet];
        list<id> hostid=new list<id>();
        List<Sales_Bulk_Host_Process_Lic_Gen__e> PlatformEventList = new List<Sales_Bulk_Host_Process_Lic_Gen__e>();
        Integer counter=0;
        Integer batchCount=Integer.valueOf(system.Label.Sales_batchcount);
        if(Test.isRunningTest()){
            batchCount=1;
        }
        system.debug('batchCount>>>'+batchCount);
        for(Sales_Host__c ss:hostlist){
            counter++;
            if(counter==batchCount){
                system.debug('hostid size inside if>>>'+hostid.size());
                String idStr=String.join(hostid,',');
                system.debug('idStr>>>'+idStr);
                PlatformEventList.add(new Sales_Bulk_Host_Process_Lic_Gen__e(Host_Ids__c=idStr,Event_Type__c=eventType)); 
                if(PlatformEventList.size()>0){
                    system.debug('inside if');
                    List<Database.SaveResult> results = EventBus.publish(PlatformEventList);
                    PlatformEventList.clear();
                    for (Database.SaveResult sr : results) {
                        if (sr.isSuccess()) {
                            System.debug('Successfully published event>>>');
                        }
                        else{
                            system.debug('error inside btach>>>');
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('Error returned>>> ' +
                                            err.getStatusCode() +
                                            ' - ' +
                                            err.getMessage());
                            }
                        }
                    } 
                }
                hostid.clear();
                counter=0;
             }
            hostid.add(ss.id);
        }
        system.debug('host size>>'+hostid.size());
        if(!hostid.isEmpty()){
            system.debug('last batch in PE');
            String idStr=String.join(hostid,',');
            system.debug('last batch ids>>'+idStr);
            PlatformEventList.add(new Sales_Bulk_Host_Process_Lic_Gen__e(Host_Ids__c=idStr,Event_Type__c=eventType)); 
            List<Database.SaveResult> results = EventBus.publish(PlatformEventList);
            PlatformEventList.clear();
          // Inspect publishing result for each event
             for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                }
                else{
                    system.debug('error>>>');
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +
                                    err.getStatusCode() +
                                    ' - ' +
                                    err.getMessage());
                    }
                }
            }   

        }
*/      
 
        }
    
}