@isTest
public without sharing class Sales_UpdateHostRecords_Bot {
/*
	public class ComputerInput {
        @InvocableVariable
       	public Sales_Host__c hostData;
        @InvocableVariable(required=true)
        public String Sales_ComputerName_for_New_Computer;
        @InvocableVariable(required=true)
        public String ComputerType_for_NewComputer;
        @InvocableVariable(required=true)
        public String Host_LicenseType;
        @InvocableVariable
        public String NIC_ID_or_Guard_ID;
        @InvocableVariable
        public String Host_ID_or_Guard_ID;
        @InvocableVariable
        public String Guard_ID;
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
    @InvocableMethod(label='Update host computer details')
    public static List<Result> createComputerDetails(List<ComputerInput> computerInputs) {
        Set<String> hostIds = new Set<String>(); 
        Map<Id,Sales_Host__c> hostMap = new Map<Id,Sales_Host__c>();
        Map<Id,Sales_License__c> licenseToHostMap = new Map<Id,Sales_License__c>(); 
        //Map<Id, Sales_Host__c> mapOfHostObj = new Map<Id, Sales_Host__c>();--Unused
        List<Sales_Host__c> hostObjList = new List<Sales_Host__c>();
        //List<Sales_License__c> licenseList = new List<Sales_License__c>();--Unused
        List<Result> res = new List<Result>();
        Integer count=0;
        Result r = new Result();
        Boolean availableRehostCheck = false;
        String companion1;
        String companion2;
        String redundant1;
        String redundant2;
        String licenseType;
        String primaryId;
        String computerType;
        String computerName;
        for(ComputerInput input : computerInputs) {
            hostIds.add(input.hostData.Id);
            companion1 = input.Companion_Server1_ID;
            companion2 = input.Companion_Server2_ID;
            redundant1 = input.Redundant_Server1_ID;
            redundant2 = input.Redundant_Server2_ID;
            licenseType = input.Host_LicenseType;
            computerType = input.ComputerType_for_NewComputer;
            computerName = input.Sales_ComputerName_for_New_Computer;
            if(input.NIC_ID_or_Guard_ID!=null){
                primaryId = input.NIC_ID_or_Guard_ID;			
            }else if(input.Host_ID_or_Guard_ID!=null){
                primaryId = input.Host_ID_or_Guard_ID;    		
            }else if(input.Guard_ID!=null){
                primaryId = input.Guard_ID;    					
            }
        }   
        for(Sales_Host__c hostRec : [Select Id,Name,Sales_Computer_Name_Txt__c,Sales_Computer_Type__c,Sales_License_Type__c,Sales_Companion_Server1_Txt__c,Sales_Companion_Server2_Txt__c,Sales_Redundant_Server1_Txt__c,Sales_Redundant_Server2_Txt__c from Sales_Host__c WHERE Id IN:hostIds AND Sales_isActiveHost__c=true]){
            hostMap.put(hostRec.Id,hostRec);
        }
        for(Sales_License__c lic: [Select Id, Sales_Tool_License_Type__c,Sales_License_Avbl_Rehost_Nbr__c, Sales_License_Host_Node_Id__c from Sales_License__c where Sales_License_Host_Node_Id__c IN: hostIds and Sales_License_Status__c != 'Cancelled' and Sales_License_Type__c = 'Original']){
            licenseToHostMap.put(lic.Id,lic);
            if(lic.Sales_License_Avbl_Rehost_Nbr__c > 0){
                if((hostMap.size()>0) && ((primaryId!=null && (primaryId!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Name)) || (licenseType!=null && licenseType!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c) || (computerType!=null && computerType!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Computer_Type__c) || (licenseType=='FIXED' && ((companion1!=null && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c!=null) && (companion1!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c)) || (companion2!=null && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c!=null)  && (companion2!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c)))) || (licenseType=='FLOAT' && ((redundant1!=null && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c!=null) &&  (redundant1!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c)) || (redundant2!=null && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c!=null) && (redundant2!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c)))))){
                   availableRehostCheck = false;
                    count++;
                }
                if(computerName!=null && computerName != hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Computer_Name_Txt__c){
                    count++;
                    availableRehostCheck = false;
                }
            }
            else if(lic.Sales_License_Avbl_Rehost_Nbr__c < 1 || lic.Sales_License_Avbl_Rehost_Nbr__c == null){
                if((hostMap.size()>0) && ((primaryId!=null && (primaryId!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Name)) || (licenseType!=null && licenseType!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c) || (computerType!=null && computerType!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Computer_Type__c) || (licenseType=='FIXED' && ((companion1!=null && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c!=null) && (companion1!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c)) || (companion2!=null && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c!=null)  && (companion2!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c)))) || (licenseType=='FLOAT' && ((redundant1!=null && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c!=null) &&  (redundant1!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c)) || (redundant2!=null && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c!=null) && (redundant2!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c)))))){
                    availableRehostCheck = true;
                }
                if((computerName!=null && computerName != hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Computer_Name_Txt__c) && (hostMap.size()>0) && !((primaryId!=null && (primaryId!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Name)) || (licenseType!=null && licenseType!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_License_Type__c) || (computerType!=null && computerType!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Computer_Type__c) || (licenseType=='FIXED' && ((companion1!=null && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c!=null) && (companion1!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server1_Txt__c)) || (companion2!=null && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c!=null)  && (companion2!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Companion_Server2_Txt__c)))) || (licenseType=='FLOAT' && ((redundant1!=null && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c!=null) &&  (redundant1!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server1_Txt__c)) || (redundant2!=null && (hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c!=null) && (redundant2!=hostMap.get(lic.Sales_License_Host_Node_Id__c).Sales_Redundant_Server2_Txt__c)))))) {
                    count++;
                    availableRehostCheck = false;
                }
            }
        }
        if(availableRehostCheck==false && count>0){
            for (ComputerInput compInput : computerInputs) {
                compInput.HostData.Sales_Computer_Name_Txt__c = compInput.Sales_ComputerName_for_New_Computer; 
                compInput.HostData.Sales_Computer_Type__c = compInput.ComputerType_for_NewComputer; 
                compInput.HostData.Sales_License_Type__c = compInput.Host_LicenseType;			
                if(compInput.NIC_ID_or_Guard_ID!=null){
                    compInput.HostData.Name = compInput.NIC_ID_or_Guard_ID;			
                }else if(compInput.Host_ID_or_Guard_ID!=null){
                    compInput.HostData.Name = compInput.Host_ID_or_Guard_ID;    		
                }else if(compInput.Guard_ID!=null){
                    compInput.HostData.Name = compInput.Guard_ID;    					
                }
                if(compInput.Host_LicenseType == 'FIXED'){
                    if(compInput.Companion_Server1_ID!=null)
                        compInput.HostData.Sales_Companion_Server1_Txt__c = compInput.Companion_Server1_ID;
                    if(compInput.Companion_Server2_ID!=null)
                        compInput.HostData.Sales_Companion_Server2_Txt__c = compInput.Companion_Server2_ID;
                }
                else if(compInput.Host_LicenseType == 'FLOAT'){
                    if(compInput.Redundant_Server1_ID!=null)
                        compInput.HostData.Sales_Redundant_Server1_Txt__c = compInput.Redundant_Server1_ID;
                    if(compInput.Redundant_Server2_ID!=null)
                        compInput.HostData.Sales_Redundant_Server2_Txt__c = compInput.Redundant_Server2_ID;
                }
                hostObjList.add(compInput.HostData);
            }   
            Database.SaveResult[] result;
            if(hostObjList.size() > 0){
                try{
                    result = Database.update(hostObjList);            
                }catch (Exception ex) {
                    r.UpdateResult = false;
                }
                if(result!=null)
                    r.UpdateResult = result[0].isSuccess();
            }
            List<Sales_License__c > licenseToBeUpdatedList = new List<Sales_License__c>();
        }
       	if(availableRehostCheck==true){
            r.UpdateResult = false;
        }
        res.add(r);
        return res;
    }
*/
}