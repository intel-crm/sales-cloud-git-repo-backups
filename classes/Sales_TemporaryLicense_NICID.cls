@isTest
public with sharing class Sales_TemporaryLicense_NICID {
/*
    public class NICIDInput {
        @InvocableVariable
        public Sales_Host__c HostData ;
        @InvocableVariable
        public string NICid;
    } 
    public class Result{
        @InvocableVariable
        public Boolean UpdateResult ;
    }
    @InvocableMethod(label='Add NIC Id')
    public static List<Result> addTemporaryNICIdDetails(List<NICIDInput> NicId) {
        boolean TemporaryNICId= false;
        Set<String> hostIdSet = new Set<String>();
        List<Sales_Host__c> hostObjList = new List<Sales_Host__c>();
        List<Result> res = new List<Result>();
        Result r = new Result();
        for(NICIDInput Nid : NicId) {
            hostIdSet.add(Nid.HostData.Id);
        }
        for (NICIDInput Nid : NicId) {
            if(Nid.NICid!=null)
            { Nid.HostData.Temporary_NIC_ID__c = Nid.NICid;
             TemporaryNICId=true;
             hostObjList.add(Nid.HostData);}
        }
        Database.SaveResult[] result;
        if(hostObjList.size() > 0){
            result =Database.update(hostObjList);            
        }
        r.UpdateResult = result[0].isSuccess();         
        res.add(r);
        return res;
    }
*/
}