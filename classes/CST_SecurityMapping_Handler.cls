public class CST_SecurityMapping_Handler {
  public static void inputData(){
      //accManagerWWID - Managers
      //workerWWID - Account Owner
      String managerMappingJSON = '[{"accManagerWWID":"11644296", "workerWWID":"11644296"},{"accManagerWWID":"10645589", "workerWWID":"11644296"},{"accManagerWWID":"11570518", "workerWWID":"11644296"}]';
      String hrMappingJSON = '[{ "accManagerWWID":"11644296","Role":"R2","Region":"EMEA"},{"accManagerWWID":"10645589","Role":"Regional Admin","Region":"EMEA"},{ "accManagerWWID":"11644296","Role":"R2","Region":"Canada"}]';
      List<ManagerMappingWrapper> managerWrapperList = deserializeFromManagerMappingJson(managerMappingJSON);
      List<HRMappingWrapper> hrMappingWrapperList =  deserializeFromHRMappingJson(hrMappingJSON);
      //List<ManagerMappingWrapper> managerList = getActiveAccountOwners(managerWrapperList);
      List<HRMappingWrapper> hrList = replaceRoles(hrMappingWrapperList) ;
      system.debug('MANAGERlist:'+managerWrapperList);
      system.debug('HRMappingWrapper:'+hrList);
      Map<String,List<HRMappingWrapper>> managerRegionRoleMap = createRoleRegionMap(hrMappingWrapperList);
      createSecurityMappingRecords(managerWrapperList,managerRegionRoleMap);
      					
    }
    //Manager Mapping Sheet
    public static List<ManagerMappingWrapper> deserializeFromManagerMappingJson(String jsonString) {
        List<ManagerMappingWrapper> managerMappingWrapperList = new List<ManagerMappingWrapper>();
        
        List<Object> parsedJson = (List<Object>) JSON.deserializeUntyped(jsonString);
        for (Object obj : parsedJson) {
            Map<String, Object> record = (Map<String, Object>) obj;
            ManagerMappingWrapper wrapper = new ManagerMappingWrapper();
            wrapper.accManagerWWID = (String) record.get('accManagerWWID');
            wrapper.workerWWID = (String) record.get('workerWWID');
            managerMappingWrapperList.add(wrapper);
        }
        System.debug('managerMappingWrapperList IS:'+ managerMappingWrapperList);
        return managerMappingWrapperList;

    }
    //HR Mapping Sheet
    public static List<HRMappingWrapper> deserializeFromHRMappingJson(String jsonString) {
        List<HRMappingWrapper> hrMappingWrapperList = new List<HRMappingWrapper>();
        
        List<Object> parsedJson = (List<Object>) JSON.deserializeUntyped(jsonString);
        for (Object obj : parsedJson) {
            Map<String, Object> record = (Map<String, Object>) obj;
            HRMappingWrapper wrapper = new HRMappingWrapper();
            wrapper.accManagerWWID = (String) record.get('accManagerWWID');
            wrapper.Role = (String) record.get('Role');
            wrapper.Region = (String) record.get('Region');
            hrMappingWrapperList.add(wrapper);
        }
        System.debug('hrMappingWrapperList IS:'+ hrMappingWrapperList);
        return hrMappingWrapperList;
    }
    public static List<ManagerMappingWrapper> getActiveAccountOwners(List<ManagerMappingWrapper> managerWrapperList){
        List<ManagerMappingWrapper> activeOOList = new List<ManagerMappingWrapper>();
        Set<String> accountOwnerSet = new Set<String>();
        List<SPM_Account_Detail__c> accDetailList=[SELECT Id,Account_Owner_WWID__c FROM SPM_Account_Detail__c];
        for(SPM_Account_Detail__c accDetail:accDetailList){
            accountOwnerSet.add(accDetail.Account_Owner_WWID__c);
        }
        for(ManagerMappingWrapper managerWrapper:managerWrapperList){
            if(accountOwnerSet.contains(managerWrapper.workerWWID)){
                activeOOList.add(managerWrapper);
            }
        }
        return activeOOList;
    }
    //Repace Role
    public static List<HRMappingWrapper> replaceRoles(List<HRMappingWrapper> mappingRecList){
        List<HRMappingWrapper> hrList = new List<HRMappingWrapper>();
        for(HRMappingWrapper wrap:mappingRecList){
        	String roleValue='';
            String Role = wrap.Role;
            switch on Role{
                when 'R1'{
                    roleValue = 'DR';
                }
                when 'R2'{
                    roleValue = 'VP';
                }
                when 'D'{
                    roleValue = 'GM';
                }
                when 'Regional Admin'{
                    roleValue = 'Regional Lead';
                }
                when 'R3'{
                    roleValue = 'LATAM';
                }
            }
            wrap.Role = roleValue; 
            hrList.add(wrap);
        }
        return hrList;
    }
    public static Map<String,List<HRMappingWrapper>> createRoleRegionMap(List<HRMappingWrapper> hrList){
        Map<String,List<HRMappingWrapper>> managerRegionRoleMap = new Map<String,List<HRMappingWrapper>>();
        for(HRMappingWrapper managerRec:hrList){
            
            if(managerRegionRoleMap.containskey(managerRec.accManagerWWID)){
                 managerRegionRoleMap.get(managerRec.accManagerWWID).add(managerRec); 
            }
            else{
               List<HRMappingWrapper> wrapList = new List<HRMappingWrapper>();
               managerRegionRoleMap.put(managerRec.accManagerWWID,wrapList); 
            }
            
        }
        system.debug('managerRegionRoleMap IS:'+managerRegionRoleMap);
        return managerRegionRoleMap;
    }
    public static void createSecurityMappingRecords(List<ManagerMappingWrapper> managerWrapperList ,Map<String,List<HRMappingWrapper>> managerRegionRoleMap){
        system.debug('Inside createSecurityMappingRec:'+managerWrapperList);
        system.debug('Inside createSecurity managerRegionRoleMap:'+managerRegionRoleMap);
        Map<String,HRMappingWrapper> accOwnerManagerMap = new  Map<String,HRMappingWrapper>();
        List<SPM_Security_Mapping__c> securityMappingList = new  List<SPM_Security_Mapping__c>();
        for(ManagerMappingWrapper managerWrapper:managerWrapperList){
            if(managerRegionRoleMap.containsKey(managerWrapper.accManagerWWID)){
                List<HRMappingWrapper> mappingRecs = managerRegionRoleMap.get(managerWrapper.accManagerWWID);
                system.debug('MAPPING REC IS:'+mappingRecs);
                SPM_Security_Mapping__c securityRec = new SPM_Security_Mapping__c();
                //securityRec.Region__c = mappingRec.Region;
                //securityRec.Role__c =  mappingRec.Role;
                securityMappingList.add(securityRec);
            }            
        }
        system.debug('securityMappingList is:'+securityMappingList);
        
    }
 
 //Manager Mapping Sheet Wrapper
 public class ManagerMappingWrapper{
	public String accManagerWWID;
    public String workerWWID;
 }
 //HR Mapping Sheet Wrapper
 public class HRMappingWrapper{
    public String accManagerWWID;
    public String Role;
    public String Region;
 }
}