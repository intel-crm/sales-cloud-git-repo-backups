public class Sales_CreateRedundantHost_bot {
public class RedundantComputerInput {
        @InvocableVariable
        public Sales_Host__c HostData ;
        @InvocableVariable
        public String Redundant_Server1_ID;
        @InvocableVariable
        public String Redundant_Server2_ID;
    }
    
    public class Result {
        @InvocableVariable
        public Boolean UpdateResult ;
    }
    
    //method to add the redundant computer id to the host records 
    @InvocableMethod(label='Create Redundant Computer')
    public static List<Result> createComputerDetails(List<RedundantComputerInput> computerInputs) {
        List<Sales_Host__c> hostObjList = new List<Sales_Host__c>();
        Set<String> hostIdSet = new Set<String>();
        String redundant1;
        String Redundant2;
        Map<Id,Sales_License__c> licenseMap = new Map<Id,Sales_License__c>();
        List<Sales_License__c> licenseList = new List<Sales_License__c>();
        Map<Id,Sales_Host__c> hostMap = new Map<Id,Sales_Host__c>();
        Boolean availableRehostCheck = false;
        List<Result> res = new List<Result>();
        Result r = new Result();
         for(RedundantComputerInput redundantInput : computerInputs) {
         	hostIdSet.add(redundantInput.HostData.Id);
            Redundant1 = redundantInput.Redundant_Server1_ID;
            Redundant2 = redundantInput.Redundant_Server2_ID;
         }
        for(Sales_Host__c hostRec : [Select Id,Sales_Computer_Name_Txt__c,Sales_License_Type__c,Sales_Redundant_Server1_Txt__c,Sales_Redundant_Server2_Txt__c from Sales_Host__c WHERE Id IN:hostIdSet And Sales_License_Type__c='FLOAT' AND Sales_isActiveHost__c=true]){
            hostMap.put(hostRec.Id,hostRec);
        }
        for(Sales_License__c lic: [Select Id, Sales_Tool_License_Type__c,Sales_License_Avbl_Rehost_Nbr__c, Sales_License_Host_Node_Id__c from Sales_License__c where Sales_License_Host_Node_Id__c IN: hostIdSet AND (Sales_Tool_License_Type__c='FIXED' OR Sales_Tool_License_Type__c='NEUTRAL') and Sales_License_Status__c != 'Cancelled' and Sales_License_Type__c = 'Original']){
            if((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c!=null && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c!=Redundant1)  && (Redundant1!=null)) || ((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c!=null) && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c!=Redundant2) && (Redundant2!=null)) && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c=='FLOAT') && (lic.Sales_License_Avbl_Rehost_Nbr__c > 0)){
                lic.Sales_License_Avbl_Rehost_Nbr__c = lic.Sales_License_Avbl_Rehost_Nbr__c-1;
                licenseList.add(lic);
            }
            else if((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c!=null && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c!=Redundant1)  && (Redundant1!=null)) || ((hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c!=null) && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c!=Redundant2) && (Redundant2!=null)) && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c=='FLOAT') && (lic.Sales_License_Avbl_Rehost_Nbr__c < 1)){
            	availableRehostCheck = true;
                break;
            } 
        }
        
        /*if(availableRehostCheck==false && licenseList.size()>0){
            update licenseList;
        }*/
        
        if(availableRehostCheck==false){
        	for (RedundantComputerInput redundantInput : computerInputs) {
            	if(redundantInput.Redundant_Server1_ID!=null)
                	redundantInput.HostData.Sales_Redundant_Server1_Txt__c = redundantInput.Redundant_Server1_ID;
            	if(redundantInput.Redundant_Server2_ID!=null)
                	redundantInput.HostData.Sales_Redundant_Server2_Txt__c = redundantInput.Redundant_Server2_ID;
            	hostObjList.add(redundantInput.HostData);
         	}
            Database.SaveResult[] result;
        	if(hostObjList.size() > 0){
            	System.debug('hostObjList==>'+hostObjList);
            	result =Database.update(hostObjList);            //updating host record
        	}
        	r.UpdateResult = result[0].isSuccess();
       	}
        else if(availableRehostCheck==true){
            r.UpdateResult = false;
        }
        res.add(r);
        return res;
    }
}