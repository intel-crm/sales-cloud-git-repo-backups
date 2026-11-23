@isTest
public with sharing class Sales_CreateCompanionHost_bot {
    /*public class CompanionComputerInput {
        @InvocableVariable
        public Sales_Host__c HostData ;
        @InvocableVariable
        public String Companion_Server1_ID;
        @InvocableVariable
        public String Companion_Server2_ID;
    }
    public class Result {
        @InvocableVariable
        public Boolean UpdateResult ;
    }
    @InvocableMethod(label='Create Companion Computer')
    public static List<Result> createComputerDetails(List<CompanionComputerInput> computerInputs) {
        List<Sales_Host__c> hostObjList = new List<Sales_Host__c>();
        Set<String> hostIdSet = new Set<String>();
        String companion1;
        String companion2;
        Integer count = 0 ;
        //Map<Id,Sales_License__c> licenseMap = new Map<Id,Sales_License__c>();-- unused variable
        List<Sales_License__c> licenseList = new List<Sales_License__c>();
        Map<Id,Sales_Host__c> hostMap = new Map<Id,Sales_Host__c>();
        Boolean availableRehostCheck = false;
        List<Result> res = new List<Result>();
        Result r = new Result();
        for(CompanionComputerInput compInput : computerInputs) {
            hostIdSet.add(compInput.HostData.Id);
            companion1 = compInput.Companion_Server1_ID;
            companion2 = compInput.Companion_Server2_ID;
        }
        for(Sales_Host__c hostRec : [Select Id,Sales_Computer_Name_Txt__c,Sales_License_Type__c,Sales_Companion_Server1_Txt__c,Sales_Companion_Server2_Txt__c from Sales_Host__c WHERE Id IN:hostIdSet And Sales_License_Type__c='FIXED' AND Sales_isActiveHost__c=true]){
            hostMap.put(hostRec.Id,hostRec);
        }
        for(Sales_License__c lic: [Select Id, Sales_Tool_License_Type__c,Sales_License_Avbl_Rehost_Nbr__c, Sales_License_Host_Node_Id__c from Sales_License__c where Sales_License_Host_Node_Id__c IN: hostIdSet AND (Sales_Tool_License_Type__c='FIXED' OR Sales_Tool_License_Type__c='NEUTRAL') and Sales_License_Status__c != 'Cancelled' and Sales_License_Type__c = 'Original']){
            if(lic.Sales_License_Avbl_Rehost_Nbr__c > 0){
                if((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c=='FIXED') && ((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c!=null && (companion1!=null) && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c!=companion1)) || ((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c!=null) && (companion2!=null) &&  (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c!=companion2)))){
                    lic.Sales_License_Avbl_Rehost_Nbr__c = lic.Sales_License_Avbl_Rehost_Nbr__c - 1;
                    licenseList.add(lic);
                    count++;
                }
                if((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c=='FIXED') && ((((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c==null) || (companion1==null)) && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c!=companion1)) || (((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c==null) || (companion2==null)) &&  (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c!=companion2)))){
                    availableRehostCheck = false;
                    count++; 
                }
            }
            else if(lic.Sales_License_Avbl_Rehost_Nbr__c < 1 || lic.Sales_License_Avbl_Rehost_Nbr__c==null){
                if((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c=='FIXED') && (lic.Sales_License_Avbl_Rehost_Nbr__c==0 || lic.Sales_License_Avbl_Rehost_Nbr__c==null) && (companion1!=null || companion2!=null) && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c==null &&hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c==null)){
                    availableRehostCheck = false;
                    count++;
                    break; 
                }
                if((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c=='FIXED') && ((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c!=null && (companion1!=null) && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c != companion1)) || ((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c!=null) &&  (companion2!=null) && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c!=companion2)))){
                    availableRehostCheck = true;
                    break;
                }
            }    
        }
        if(availableRehostCheck==false && count>0){
            for (CompanionComputerInput compInput : computerInputs) {
                if(compInput.Companion_Server1_ID!=null)
                    compInput.HostData.Sales_Companion_Server1_Txt__c = compInput.Companion_Server1_ID;
                if(compInput.Companion_Server2_ID!=null)
                    compInput.HostData.Sales_Companion_Server2_Txt__c = compInput.Companion_Server2_ID;
                hostObjList.add(compInput.HostData);
            }
            Database.SaveResult[] result;
            if(hostObjList.size() > 0){
                result =Database.update(hostObjList);            
            }
            r.UpdateResult = result[0].isSuccess();
        }
        else if(availableRehostCheck==true){
            r.UpdateResult = false;
        }
        res.add(r);
        return res;
    }*/
}