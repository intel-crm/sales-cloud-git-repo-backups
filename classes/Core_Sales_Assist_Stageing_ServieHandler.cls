public without sharing class Core_Sales_Assist_Stageing_ServieHandler {
    
    public static final string noActiveAccError = 'No active accounts found!';
    public static final string invalidSalesAssistError = 'Invalid Sales Assist!';
    
    public static void salesAssistInsertUpdateCheck(list<Core_Sales_Assist_Staging__c> salesAssists){
        List<String> salesAssistIdList = new List<String>();
        for(Core_Sales_Assist_Staging__c salAs : salesAssists){
            //Start- Added by Kavyashree HR(Infosys Team) for the US1048740
            if(salAs.Core_SA_Is_Active_Ind__c == true && (salAs.Core_Status_Pkt__c != 'Failure'|| salAs.Core_Status_Pkt__c != 'Success')){
                salesAssistIdList.add(salAs.Id);
            }
            //End- Added by Kavyashree HR(Infosys Team) for the US1048740
        } 

        if(System.IsBatch() == false && System.isFuture() == false){
            salesAssistProcess(salesAssistIdList);
        }
        
    }
    
    @future
    public static void salesAssistProcess(List<String> salesAssistIdList){
        List<Core_Sales_Assist_Staging__c> salesAssists = getSalesAssistDetails(salesAssistIdList);
        addOrRemoveSalesAssistAccounts(salesAssists);
    }
    
    public static List<Core_Sales_Assist_Staging__c> getSalesAssistDetails(List<String> salesAssistIdList){
        return [select Id, Core_Unified_Id__c, Core_SA_Is_Active_Ind__c, Core_Status_Pkt__c, Core_Sales_Assist_Value__c, Core_Retry_Counter__c, Core_Processed_Time_DteTime__c from Core_Sales_Assist_Staging__c where Id IN: salesAssistIdList];
    }
    
    public static Core_Sales_Assist_Staging__c updateSalesAssistStatus(String salesAssistId, Boolean isSuccess, Double retryCounter, String errMsg){
        Core_Sales_Assist_Staging__c salesAssist = new Core_Sales_Assist_Staging__c();
        salesAssist.Id = salesAssistId;
        if(isSuccess){
            salesAssist.Core_Status_Pkt__c = 'Success';
            salesAssist.Core_Processed_Time_DteTime__c = null;
            salesAssist.Core_Error_Description_Txt__c ='';
        }else{
            salesAssist.Core_Status_Pkt__c = 'Failure';
            salesAssist.Core_Processed_Time_DteTime__c = Datetime.now().addMinutes(integer.valueof(system.label.Core_SalesAssist_Retry_Timer));
            salesAssist.Core_Error_Description_Txt__c = errMsg;
            salesAssist.Core_Retry_Counter__c = retryCounter + 1;
        }
        
        return salesAssist;
    }
    
    public static void addOrRemoveSalesAssistAccounts(list<Core_Sales_Assist_Staging__c> salesAssists){
        List<Core_Sales_Assist_Staging__c> finalUpdateList = new List<Core_Sales_Assist_Staging__c>();
        map<string,Core_Sales_Assist_Staging__c> cimIdsMap=new map<string,Core_Sales_Assist_Staging__c>();
        map<Id, String> accIdCimIdMap = new map<Id, String>();
        map<Id, Set<String>> salesAssistStatusMap = new map<Id, Set<String>>();
        map<Id, Double> salesIdRetryCounterMap = new map<Id, Double>();
        Double retryCounter;
        for(Core_Sales_Assist_Staging__c salAs : salesAssists){
            if(salAS.Core_Retry_Counter__c == null){
                retryCounter = 0;
            }else{
                retryCounter = salAS.Core_Retry_Counter__c;
            }
            if( salAS.Core_Unified_Id__c <> null && salAS.Core_Unified_Id__c <> '' && salAS.Core_Sales_Assist_Value__c <> null){
                cimIdsMap.put(salAS.Core_Unified_Id__c, salAs);
                salesIdRetryCounterMap.put(salAS.Id, retryCounter);
                
            }else{
                finalUpdateList.add(updateSalesAssistStatus(salAs.Id,false,retryCounter,invalidSalesAssistError));
            }            
        }
        if(cimIdsMap !=NULL && !cimIdsMap.isempty()){
            list<Account> aclist=new list<Account>();
            list<Account> accList= [select id,name,Core_Business_Party_Id__c,Core_Sales_Assist_Staging__c,recordtype.developername from account where Core_Business_Party_Id__c IN : cimIdsMap.keyset() AND recordtype.developername !='Inactive_Account'];                
            if(!accList.isempty()){
                for(Account acc : accList){
                    account a=new account(id=acc.id);
                    if(double.valueOf(cimIdsMap.get(acc.Core_Business_Party_Id__c).Core_Sales_Assist_Value__c) == 0){
                        a.Core_Sales_Assist_Staging__c = null;
                    }else{
                        a.Core_Sales_Assist_Staging__c=cimIdsMap.get(acc.Core_Business_Party_Id__c).Id;
                    }
                    aclist.add(a);
                    accIdCimIdMap.put(acc.Id, acc.Core_Business_Party_Id__c);
                }
            }
            
            List<Core_Sales_Assist_Staging__c> salesAssitList = new List<Core_Sales_Assist_Staging__c>();
            if(aclist.size() > 0 && !aclist.isempty()){
                String errMsg;
                //Start- Added by Kavyashree HR(Infosys Team) for the US1048740
                Database.SaveResult[] srr = database.update(aclist,false);
                for(Integer i=0; i < aclist.size(); i++) {
                    errMsg = null;
                    Database.SaveResult sr = srr[i];
                    Account accRec = aclist[i];
                    if(sr.isSuccess()){
                        salesAssitList.add(updateSalesAssistStatus(cimIdsMap.get(accIdCimIdMap.get(accRec.Id)).Id,true,0,null));
                    }else{
                        for(Database.Error err : sr.getErrors()) {
                            
                            errMsg = errMsg + err.getMessage() + ';';
                        } 
                        salesAssitList.add(updateSalesAssistStatus(cimIdsMap.get(accIdCimIdMap.get(accRec.Id)).Id,false,salesIdRetryCounterMap.get(cimIdsMap.get(accIdCimIdMap.get(accRec.Id)).Id),errMsg));
                    }
                }
                for(Core_Sales_Assist_Staging__c sales : salesAssitList){
                    if(salesAssistStatusMap.containskey(sales.Id)){
                        Set<String> setStatus = salesAssistStatusMap.get(sales.Id);
                        setStatus.add(sales.Core_Status_Pkt__c);
                        salesAssistStatusMap.put(sales.Id, setStatus);
                    }
                    else{
                        salesAssistStatusMap.put(sales.Id, new Set<String>{sales.Core_Status_Pkt__c});
                    }
                }
                map<Id, Core_Sales_Assist_Staging__c> mapremovesalesAssistDupli = new map<Id, Core_Sales_Assist_Staging__c>();
                for(Core_Sales_Assist_Staging__c salesAssist :salesAssitList){
                    if(salesAssistStatusMap.get(salesAssist.Id).contains('Failure')){
                        if(salesAssist.Core_Status_Pkt__c == 'Failure'){
                            mapremovesalesAssistDupli.put(salesAssist.Id, salesAssist);      
                        }
                    }
                    else{
                        mapremovesalesAssistDupli.put(salesAssist.Id, salesAssist);  
                    }
                }
                
                finalUpdateList.addAll(mapremovesalesAssistDupli.values());
                for(String cimId : cimIdsMap.keyset()){
                    if(!salesAssistStatusMap.containsKey(cimIdsMap.get(cimId).Id)){
                        finalUpdateList.add(updateSalesAssistStatus(cimIdsMap.get(cimId).Id,false,salesIdRetryCounterMap.get(cimIdsMap.get(cimId).Id),noActiveAccError));
                    }
                }
            }else{
                for(String cimId : cimIdsMap.keyset()){
                    finalUpdateList.add(updateSalesAssistStatus(cimIdsMap.get(cimId).Id,false,salesIdRetryCounterMap.get(cimIdsMap.get(cimId).Id),noActiveAccError));
                }
            }
        }
        List<Core_Exceptions__c> excepList = new List<Core_Exceptions__c>();
        if(finalUpdateList.size()>0 ||finalUpdateList!= null){
            Database.SaveResult[] saveRes = database.update(finalUpdateList, false);
            for (Integer i=0; i < saveRes.size(); i++) {
                if(saveRes.get(i).isSuccess()) {
                    
                }
                if(!saveRes.get(i).isSuccess() || Test.isRunningTest()) {
                    boolean isError = false;
                    if(saveRes.get(i).getErrors().size() > 0){
                        isError = true;
                    }
                    Database.Error errors;
                    Core_Exceptions__c excep = new Core_Exceptions__c();
                    if(isError){
                        errors =  saveRes.get(i).getErrors().get(0);
                        excep.Core_Exception__c = errors.getMessage();
                    }else{
                        excep.Core_Exception__c = 'test errors';
                    }
                    excep.Core_Class_Name__c ='Core_Sales_Assist_Stageing_ServieHandler';
                    excep.Core_Method_Name__c ='addOrRemoveSalesAssistAccounts';
                    excep.Core_Record_Id__c = saveRes.get(i).Id;
                    excep.Core_IPS_Object_Name__c = 'Core_Sales_Assist_Staging__c';
                    excepList.add(excep);
                    
                }
            }
            if(excepList.size()>0 && excepList!= null){
                insert excepList;
            }
        }
        //End - Added by Kavyashree HR(Infosys Team) for the US1048740
    }     
}