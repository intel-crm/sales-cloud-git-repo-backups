public class PRM_EntitlementResponseWrapper {
    public Set<id> contactIdSet{get;set;}public Map<Id,String> accountIdRecTypemap{get;set;}
    public Map<Id, Set<Id>> actIdCtIdMap{get;set;}public Map<Id, String> OPIDContIdMap{get;set;}
    public Map<Id, String> contactIdRelName{get;set;}
    public Map<Id, Id> ctIdActIdMp{get;set;} public Map<Id, Id> actToOPIDMap{get;set;}
    public Map<Id, String> actIdRoleTierMap{get;set;}
    public Map<Id,String> tierIdNames{get;set;}public Map<Id,List<String>> oldPartnerRoleMap{get;set;}
    public Map<Id,List<String>> newPartnerRoleMap{get;set;}
}