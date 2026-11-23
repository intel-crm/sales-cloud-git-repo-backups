@isTest
public without sharing class Sales_checkHostLicenseType_Bot {
    /*public class ComputerInput {
        @InvocableVariable
        public Sales_Host__c HostData;
        @InvocableVariable
        public String Companion_Server1_ID;
        @InvocableVariable
        public String Companion_Server2_ID;
        @InvocableVariable
        public String Redundant_Server1_ID;
        @InvocableVariable
        public String Redundant_Server2_ID;
    }
    public class Result {
        @InvocableVariable
        public Boolean UpdateResult ;
    }
    @InvocableMethod(label='Update Computer ids on All Rehost Option')
    public static List<Result> createComputerDetails(List<ComputerInput> computerInputs) {
        Set<String> hostIds = new Set<String>(); 
        Map<Id,Sales_License__c> licenseToHostMap = new Map<Id,Sales_License__c>(); 
        //Map<Id, Sales_Host__c> mapOfHostObj = new Map<Id, Sales_Host__c>();-- unused variable
        List<Sales_Host__c> hostObjList = new List<Sales_Host__c>();
        Set<String> hostIdSet = new Set<String>();
        Integer count = 0 ;
        Map<Id,Sales_License__c> licenseMap = new Map<Id,Sales_License__c>();
        List<Sales_License__c> licenseList = new List<Sales_License__c>();
        Map<Id,Sales_Host__c> hostMap = new Map<Id,Sales_Host__c>();
        Boolean availableRehostCheck = false;
        List<Result> res = new List<Result>();
        Result r = new Result();
        String companion1;
        String companion2;
        String redundant1;
        String redundant2;
        String licenseType;
        for(ComputerInput compInput : computerInputs) {
            hostIds.add(compInput.hostData.Id);
            redundant1 = compInput.Redundant_Server1_ID;
            redundant2 = compInput.Redundant_Server2_ID;
            companion1 = compInput.Companion_Server1_ID;
            companion2 = compInput.Companion_Server2_ID;
            licenseType = compInput.hostData.Sales_License_Type__c; 
        }   
        for(Sales_Host__c hostRec : [Select Id,Name,Sales_Computer_Name_Txt__c,Sales_Computer_Type__c,Sales_License_Type__c,Sales_Companion_Server1_Txt__c,Sales_Companion_Server2_Txt__c,Sales_Redundant_Server1_Txt__c,Sales_Redundant_Server2_Txt__c from Sales_Host__c WHERE Id IN:hostIds AND Sales_isActiveHost__c=true]){
            hostMap.put(hostRec.Id,hostRec);
        }
        for(Sales_License__c lic: [Select Id, Sales_Tool_License_Type__c,Sales_License_Avbl_Rehost_Nbr__c, Sales_License_Host_Node_Id__c from Sales_License__c where Sales_License_Host_Node_Id__c IN: hostIds and Sales_License_Status__c != 'Cancelled' and Sales_License_Type__c = 'Original']){
            licenseToHostMap.put(lic.Id,lic);
            if(lic.Sales_License_Avbl_Rehost_Nbr__c > 0){
                if(((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c=='FIXED') && ((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c!=null && (companion1!=null) && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c!=companion1)) ||((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c!=null) && (companion2!=null) &&  (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c!=companion2))))||(((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c=='FLOAT') && ((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c!=null && (redundant1!=null) && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c!=redundant1)) ||((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c!=null) && (redundant2!=null) &&  (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c!=redundant2)))  ))){                   
                    lic.Sales_License_Avbl_Rehost_Nbr__c = lic.Sales_License_Avbl_Rehost_Nbr__c-1;
                    licenseList.add(lic);
                    count++;}
                if(((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c=='FIXED') && ((((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c==null) || (companion1==null)) && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c!=companion1)) || (((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c==null) || (companion2==null)) &&  (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c!=companion2)))) ||((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c=='FLOAT') && ((((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c==null) || (redundant1==null)) &&(hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c!=redundant1)) || (((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c==null) || (redundant2==null)) &&  (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c!=redundant2)))))
                {availableRehostCheck = false; 
                 count++;
                }    
            }
            else if(lic.Sales_License_Avbl_Rehost_Nbr__c < 1){
                if(((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c=='FIXED') && ((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c!=null && (companion1!=null) && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c != companion1)) || ((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c!=null) &&  (companion2!=null) && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c!=companion2)))) ||
                   ((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c=='FLOAT') && ((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c!=null && (redundant1!=null) && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c != redundant1)) && ((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c!=null) &&  (redundant2!=null) && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c!=redundant2))))){
                       availableRehostCheck = true;
                       break;
                   } 
            }
        }
        if(availableRehostCheck==false && count>0){
            for (ComputerInput compInput : computerInputs) {
                if(compInput.Companion_Server1_ID!=null)
                    compInput.HostData.Sales_Companion_Server1_Txt__c = compInput.Companion_Server1_ID;
                if(compInput.Companion_Server2_ID!=null)
                    compInput.HostData.Sales_Companion_Server2_Txt__c = compInput.Companion_Server2_ID;
                if(compInput.Redundant_Server1_ID!=null)
                    compInput.HostData.Sales_Redundant_Server1_Txt__c = compInput.Redundant_Server1_ID;
                if(compInput.Redundant_Server2_ID!=null)
                    compInput.HostData.Sales_Redundant_Server2_Txt__c = compInput.Redundant_Server2_ID;
                hostObjList.add(compInput.HostData);
            }
            Database.SaveResult[] result;
            if(hostObjList.size() > 0){
                result = Database.update(hostObjList);            
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