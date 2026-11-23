public class Core_Sales_Assist_Stageing_ServieHandler {
    
    public static void addingSalesAssistAccounts(list<Core_Sales_Assist_Staging__c> salesAssists){
        map<string,ID> cimIdsMap=new map<string,ID>();
        
        for(Core_Sales_Assist_Staging__c salAs : salesAssists){
            if(salAs.Core_SA_Is_Active_Ind__c == true && salAS.Core_CIM_Id__c != NULL && salAS.Core_CIM_Id__c !=''){
                cimIdsMap.put(salAS.Core_CIM_Id__c, salAs.Id);
                
            }
        }
         if(cimIdsMap !=NULL && !cimIdsMap.isempty() ){
        list<Account> aclist=new list<Account>();
        list<Account> accList=[select id,name,Core_CIM_ID__c,Core_Sales_Assist_Staging__c from account where Core_CIM_ID__c IN : cimIdsMap.keyset()];
        if(!accList.isempty()){
            for(Account acc : accList){
                account a=new account(id=acc.id);
                a.Core_Sales_Assist_Staging__c=cimIdsMap.get(acc.Core_CIM_ID__c);
                aclist.add(a);
            }
        }
             if(aclist.size() > 0 && !aclist.isempty()){
        update aclist;
             }
    }
    }
    public static void removingSalesAssistAccounts(list<Core_Sales_Assist_Staging__c> salesAssists){
        map<string,ID> cimIdsMap=new map<string,ID>();
        
        for(Core_Sales_Assist_Staging__c salAs : salesAssists){
            if(salAs.Core_SA_Is_Active_Ind__c == false && salAS.Core_CIM_Id__c != NULL && salAS.Core_CIM_Id__c !=''){
                cimIdsMap.put(salAS.Core_CIM_Id__c, salAs.Id);
                
            }
        }
        
        if(cimIdsMap !=NULL && !cimIdsMap.isempty() ){
            list<Account> aclist1=new list<Account>();
            list<Account> accList1=[select id,name,Core_CIM_ID__c,Core_Sales_Assist_Staging__c from account where Core_CIM_ID__c  IN : cimIdsMap.keyset()];
            if(accList1.size() > 0 ){
            for(Account acc : accList1){
                account a=new account(id=acc.id);
                a.Core_Sales_Assist_Staging__c=NULL;
                aclist1.add(a);
                
            }
             if(aclist1.size() > 0 && !aclist1.isempty()){
            update aclist1;
        }
            }
        }
        
    } 
    
}