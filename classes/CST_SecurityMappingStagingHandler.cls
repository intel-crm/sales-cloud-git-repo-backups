public class CST_SecurityMappingStagingHandler {
    
    public static void getInput(){
      String accOwnerManagerJSON = '[{"accManagerWWID":"113589", "workerWWID":"11644296"},{"accManagerWWID":"10645589", "workerWWID":"11644296"},{"accManagerWWID":"11570518", "workerWWID":"11644396"}]';
      String managerRegionRoleJSON = '[{ "accManagerWWID":"113589","Role":"R2","Region":"EMEA"},{"accManagerWWID":"10645589","Role":"Regional Admin","Region":"EMEA"},{ "accManagerWWID":"11570518","Role":"R2","Region":"Canada"},{"accManagerWWID":"113589","Role":"R2","Region":"Canada"},{"accManagerWWID":"113589","Role":"Regional Admin","Region":"Canada"}]';
      List<AccOwnerManagerWrapper> accOwnerManagerList = deserializeFromaccOwnerManagerJSON(accOwnerManagerJSON);
      List<ManagerRegionRoleWrapper> managerRegionRoleList = deserializeFrommanagerRegionRoleJSON(managerRegionRoleJSON);
      Map<String,Id> wwidSalesforceIdMap = populateSFId(accOwnerManagerList);//get SF Id
      Map<String,List<String>> accOwnManagerMap = createAccountOwnerManagerMap(accOwnerManagerList);// Create a Map with Account Ownwer with Managers Map
      List<ManagerRegionRoleWrapper>  mgrRegionRoleList = replaceRoles(managerRegionRoleList);//Replace Role in sheet with actual roles in SF
      Map<String,List<ManagerRegionRoleWrapper>>  mgrRegionRoleMap = createRoleRegionMap(mgrRegionRoleList);
      //createSecurityMappingStagingRecord(accOwnManagerMap,mgrRegionRoleMap,wwidSalesforceIdMap);
      
    }
    //Manager Role Mapping Sheet
    public static List<AccOwnerManagerWrapper> deserializeFromaccOwnerManagerJSON(String jsonString) {
        List<AccOwnerManagerWrapper> accOwnerManagerWrapperList = new List<AccOwnerManagerWrapper>();
        
        List<Object> parsedJson = (List<Object>) JSON.deserializeUntyped(jsonString);
        for (Object obj : parsedJson) {
            Map<String, Object> record = (Map<String, Object>) obj;
            accOwnerManagerWrapper wrapper = new accOwnerManagerWrapper();
            wrapper.managerWWID = (String) record.get('accManagerWWID');
            wrapper.accOwnerWWID = (String) record.get('workerWWID');
            accOwnerManagerWrapperList.add(wrapper);
        }
        System.debug('accOwnerManagerWrapperList IS:'+ accOwnerManagerWrapperList);
        return accOwnerManagerWrapperList;

    }
    //HR Mapping Sheet
    public static List<ManagerRegionRoleWrapper> deserializeFrommanagerRegionRoleJSON(String jsonString) {
        List<ManagerRegionRoleWrapper> managerRegionRoleWrapperList = new List<ManagerRegionRoleWrapper>();
        
        List<Object> parsedJson = (List<Object>) JSON.deserializeUntyped(jsonString);
        for (Object obj : parsedJson) {
            Map<String, Object> record = (Map<String, Object>) obj;
            ManagerRegionRoleWrapper wrapper = new ManagerRegionRoleWrapper();
            wrapper.managerWWID = (String) record.get('accManagerWWID');
            wrapper.Role = (String) record.get('Role');
            wrapper.Region = (String) record.get('Region');
            managerRegionRoleWrapperList.add(wrapper);
        }
        System.debug('managerRegionRoleWrapperList IS:'+ managerRegionRoleWrapperList);
        return managerRegionRoleWrapperList;
    }
    //Filter Active Account Owners start
    //Filter Active Account Owners end
    //Populate SF Id
    public static Map<String,Id> populateSFId(List<AccOwnerManagerWrapper> accOwnerManagerList){
        Map<String,Id> wwidSalesforceIdMap = new Map<String,Id>();
        List<User> userList= new List<User>(); 
        Set<String> wwidSet = new Set<String>();
        for(AccOwnerManagerWrapper rec: accOwnerManagerList){
            wwidSet.add(rec.accOwnerWWID);
            wwidSet.add(rec.managerWWID);
        }
        //get SF Id of Account Owners and Managers
        
        if(wwidSet.size()>0){
            userList=[SELECT Id,Core_WWID__c,IsActive from User WHERE Core_WWID__c IN:wwidSet and IsActive=TRUE];
        }
        for(User us:userList){
            wwidSalesforceIdMap.put(us.Core_WWID__c,us.Id);
        }
        return wwidSalesforceIdMap;
    }
    //Repace Role
    public static List<ManagerRegionRoleWrapper> replaceRoles(List<ManagerRegionRoleWrapper> managerRegionRoleJSON){
        List<ManagerRegionRoleWrapper> hrList = new List<ManagerRegionRoleWrapper>();
        for(ManagerRegionRoleWrapper wrap:managerRegionRoleJSON){
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
    //Create a map with Account Owner as Key and list of managers under him as value
    public static Map<String,List<String>> createAccountOwnerManagerMap(List<AccOwnerManagerWrapper> accOwnerManagerList){
        Map<String,List<String>> accOwnerManagerMap = new Map<String,List<String>>();
        system.debug('Inside accOwnerManagerList:'+accOwnerManagerList);
        for(AccOwnerManagerWrapper rec:accOwnerManagerList){
            if(accOwnerManagerMap.containsKey(rec.accOwnerWWID)){
                accOwnerManagerMap.get(rec.accOwnerWWID).add(rec.managerWWID);
            }
            else{
                List<String> managerList = new List<String>();
                managerList.add(rec.managerWWID);
                accOwnerManagerMap.put(rec.accOwnerWWID,managerList);
            }
        }
        return accOwnerManagerMap;
    }
    //Create a map with Manager as Key and list of region,role as value
    public static Map<String,List<ManagerRegionRoleWrapper>> createRoleRegionMap(List<ManagerRegionRoleWrapper> managerRegionRoleList){
        Map<String,List<ManagerRegionRoleWrapper>> managerRegionRoleMap = new Map<String,List<ManagerRegionRoleWrapper>>();
        system.debug('Manager region rolelist:'+managerRegionRoleList);
        for(ManagerRegionRoleWrapper managerRec:managerRegionRoleList){
            Integer index=0;
            String previousRole = '';
            String previousRegion = '';
            if(managerRegionRoleMap.containskey(managerRec.managerWWID)){
                List<ManagerRegionRoleWrapper> existingList = managerRegionRoleMap.get(managerRec.managerWWID);
                for(ManagerRegionRoleWrapper exRec:existingList){
                    if(exRec.Region==managerRec.Region){
                        ManagerRegionRoleWrapper recordSameRegion = exRec;
                        previousRole = exRec.Role;
                        previousRegion = exRec.Region;
                    }
                    
                }
                if(previousRegion==managerRec.Region && previousRole!=managerRec.Role){
                     managerRegionRoleMap.get(managerRec.managerWWID).remove(index); 
                    managerRec.Role = assignHighestRole(previousRole,managerRec.Role);
                }
                managerRegionRoleMap.get(managerRec.managerWWID).add(managerRec);    
            }
            else{
               List<ManagerRegionRoleWrapper> wrapList = new List<ManagerRegionRoleWrapper>();
               wrapList.add(managerRec);
               managerRegionRoleMap.put(managerRec.managerWWID,wrapList); 
            }
            index++;
            
        }
        system.debug('managerRegionRoleMap IS:'+managerRegionRoleMap);
        return managerRegionRoleMap;
    }
    public static String assignHighestRole(String prevRole, String currentRole){
        String roleValue ;
        Map<String,Integer> highestRoleMap = new Map<String,Integer>();
        highestRoleMap.put('Regional Lead',5);
        highestRoleMap.put('GM',4);
        highestRoleMap.put('VP',3);
        highestRoleMap.put('DR',2);
        Integer prevRoleRating = highestRoleMap.get(prevRole);
        Integer curRoleRating = highestRoleMap.get(currentRole);
        if(prevRoleRating>curRoleRating){
            roleValue = prevRole;
        }
        else{
            roleValue = currentRole;
        }
        return roleValue;
       
    }
    //If Manager belong to 2 regions - EMEA and Canada then create records for both regions
    //If Manager belongs to same region but has 2 different roles - assign the highest role
     /*public static void createSecurityMappingStagingRecord(Map<String,List<String>> accOwnManagerMap, Map<String,List<ManagerRegionRoleWrapper>>  mgrRegionRoleMap,Map<String,Id> wwidSalesforceIdMap){
        List<Security_Mapping_Staging__c> securityStagingRec = new List<Security_Mapping_Staging__c>();
      	Map<String,List<String>> managerRegionMap = new Map<String,List<String>>();
        Map<String,List<String>> managerRoleMap = new Map<String,List<String>>(); 
        system.debug('Inside accOwnManagerMap'+accOwnManagerMap);
        for(String accOwner:accOwnManagerMap.keySet()){
            system.debug('For loop outer accOwner:'+accOwner);
            for(String managerRec:accOwnManagerMap.get(accOwner)){
                	system.debug('For loop inner manager:'+managerRec);
                	List<ManagerRegionRoleWrapper> managerRegionRoleList = mgrRegionRoleMap.get(managerRec);
                for(ManagerRegionRoleWrapper rec:managerRegionRoleList){
                        Security_Mapping_Staging__c stagingRec = new Security_Mapping_Staging__c();
                        stagingRec.Account_Owner_c = wwidSalesforceIdMap.get(accOwner);
                        stagingRec.Manager__c = wwidSalesforceIdMap.get(managerRec);
                        stagingRec.Account_Owner_WWID__c = accOwner;
                        stagingRec.Manager_WWID__c = managerRec;
                        stagingRec.Role__c = rec.Role;
                        stagingRec.Region__c = rec.Region;
                        securityStagingRec.add(stagingRec);
                }
         	}  
        }
       	system.debug('Inside security staging:'+securityStagingRec);
        insertSecurityMappingStaging(securityStagingRec);
    }
    public static void insertSecurityMappingStaging(List<Security_Mapping_Staging__c> securityStagingRec){
        if(securityStagingRec.size()>0){
            insert securityStagingRec;
        }
    }*/
    //Manager Mapping Sheet Wrapper
    public class AccOwnerManagerWrapper{
        public String managerWWID;
        public String accOwnerWWID;  
        public Id mangerSFId;
        public Id accOwnerSFId;
    }
     //HR Mapping Sheet Wrapper
    public class ManagerRegionRoleWrapper{
        public String managerWWID;
        public String Region;
        public String Role;
    }
    public class SecurityMappingStagingWrapper{
        public String managerWWID;
        public String accOwnerWWID; 
        public String region;
        public String role;
    }

}