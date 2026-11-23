/****************************************************************************************************************************************                               
* Class Name        : Core_MDF_IUPGM_ServiceHandler                             
* Created Date      : 07/29/2019                                
* Modification Log                              
* Developer            Date               Description                               
* ---------------------------------------------------------------------------------------------------------------------------------------                               
* Accenture - VD       07/29/2019         Service Class for handling trigger related functions on Internal User Partner Geo Mapping object.                             
* NP(11630236)         06-12-2019         DE62015 fix: IUPGM | Users are not getting added to APJ and WW IUPGM group when we create an IUPGM for all 5 Geos                             
* NP(11630236)         06-02-2020         US579189 - Setting Source of PGM insert
* Ayush                04-02-2024         ApexGuru fix in checkPGM method - converted iupgmList to map and used in query
*****************************************************************************************************************************************/                              
public without sharing class Core_MDF_IUPGM_ServiceHandler {                                
    
    
    public static Map<string,string> channelProgramToMasterGroupId = new Map<string,string>();                              
    public static Map<string,string> newGroupNameToChannelProgramMap = new Map<string,string>();                                
    //key=CCF, value=Client Co-Marketing Fund                               
    public static Map <String , String> channelProgramAbbreviationToNameMap = new Map<String , String>();                               
    //key = programId+geo-subGeo, value = RO Group set                              
    public static Map<String,Id> programGeoSubGeoROGroupSetMap = new Map<String,Id>();                              
    public static Map<String,Id> programGeoSubGeoRWGroupSetMap = new Map<String,Id>();
    
    public static Map<String,String> programRoleToGroupMap = new Map<String,String>();
    public static Map<String,List<String>> groupNameToGroupIdWWMap = new Map<String,List<string>>();
    public static Map<String,ID> groupNameToGroupIdMap = new Map<String,ID>();
    
    public static Map<String,Core_MDF_ProgramGeoGroupMap__mdt> programGeoSubGeoBudgetMap = new Map<String,Core_MDF_ProgramGeoGroupMap__mdt>();
    public static Map<String,Core_MDF_ProgramGeoRoleGroupMap__c> progRoleSecondaryCSMap = new Map<String,Core_MDF_ProgramGeoRoleGroupMap__c>();
    public static Map<String,Core_MDF_ProgramGeoRoleGroupMap__c> progRolePrimaryCSMap = new Map<String,Core_MDF_ProgramGeoRoleGroupMap__c>();
    public static Map<string,Map<string,string>> programToRegionToGroupMap = new Map<string,Map<string,string>>();
    
    static final string STR_WW = 'WW';                              
    static final string STR_No = 'No';                              
    static final string STR_Yes = 'Yes';                                
    
    static final string STR_int = 'INT';                                
    static final string STR_ccp = 'CCP ';                               
    static final string STR_coreMdf = 'Core_MDF_';                             
    static final string STR_MDF = 'MDF_';
    public static Boolean isPrimaryIUPGMRole = false;
    public static List<String> oldBudgetTypeList = new List<String>();
    
    
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();  
    
    
    public static Map<Id, Set<String>> existingIupgmUserIdRegionMap = new Map<Id, Set<String>>();
    public static Map<Id, Set<String>> existingIupgmUserIdBudgMap = new Map<Id, Set<String>>();

    private static Boolean isCoInvBudgetRole(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm){
        return iupgm.Core_MDF_Program_nm__c == Core_MDF_CCP_ConstantClass.Co_Inv_TECHNICAL_PROGRAM &&
            Core_MDF_CCP_ConstantClass.CO_INV_BUDGETTYPE_ROLES.split(';').contains(iupgm.Core_MDF_Role_nm__c);
    }
    
    //Generic Method to prepare RO/ RW Group Ids based on key = Program or Program+Geo+SubGeo                               
    private static void populateprogramGeoSubGeoGroupSetMaps(){                             
        set<String> metadataGroupNames = new set<String> ();                                
        String progGeoSubGeoKey;                                
        String progKey;                             
        String progRoleKey;
        //Avoid using Soql / Sosl queries without filters and limits
        for(Core_MDF_ProgramGeoGroupMap__mdt progGeoSubGeoGrp : [SELECT Core_MDF_Program__c, Core_MDF_Region__c,Core_MDF_Sub_Region__c,                                
                                                                 Core_MDF_Check_SubGeo__c, Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, 
                                                                 Core_MDF_Budget_Type_txt__c,Core_MDF_Budget_Type_Abbr_txt__c                             
                                                                 FROM Core_MDF_ProgramGeoGroupMap__mdt LIMIT 5000]){                               
                                                                     metadataGroupNames.add(progGeoSubGeoGrp.Core_MDF_Group_Name__c);                                
                                                                     metadataGroupNames.add(progGeoSubGeoGrp.Core_MDF_Group_Name_RO__c);                             
                                                                 }                               
        Map<String,ID> groupNameToGroupIdMap = new Map<String,ID>();                                
        if(!metadataGroupNames.isEmpty()){                              
            for(Group gr : [SELECT ID,DeveloperName 
                            from Group 
                            WHERE type='Regular' and (DeveloperName like 'Core_MDF%' or DeveloperName like 'MDF%') and DeveloperName IN : metadataGroupNames] ){
                                
                                groupNameToGroupIdMap.put(gr.DeveloperName,gr.Id);                              
                            }                               
            
        }                               
        //Avoid using Soql / Sosl queries without filters and limits
        for(Core_MDF_ProgramGeoGroupMap__mdt progGeoSubGeoGrp : [SELECT Core_MDF_Program__c, Core_MDF_Region__c,Core_MDF_Sub_Region__c,                                
                                                                 Core_MDF_Check_SubGeo__c, Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, 
                                                                 Core_MDF_Budget_Type_txt__c,Core_MDF_Budget_Type_Abbr_txt__c                             
                                                                 FROM Core_MDF_ProgramGeoGroupMap__mdt LIMIT 5000]){                               
                                                                     
                                                                     if(progGeoSubGeoGrp.Core_MDF_Budget_Type_txt__c != NULL && progGeoSubGeoGrp.Core_MDF_Region__c != NULL){                                
                                                                         progGeoSubGeoKey = (String)progGeoSubGeoGrp.Core_MDF_Program__c + progGeoSubGeoGrp.Core_MDF_Region__c +'-'+ progGeoSubGeoGrp.Core_MDF_Sub_Region__c + progGeoSubGeoGrp.Core_MDF_Budget_Type_txt__c;                             
                                                                         if(progGeoSubGeoKey.contains('-null')){                             
                                                                             progGeoSubGeoKey = progGeoSubGeoKey.remove('-null');                                
                                                                         }                               
                                                                         
                                                                     }                               
                                                                     
                                                                     else if(progGeoSubGeoGrp.Core_MDF_Region__c != NULL){                                                                                   
                                                                         progGeoSubGeoKey = (String)progGeoSubGeoGrp.Core_MDF_Program__c + progGeoSubGeoGrp.Core_MDF_Region__c +'-'+ progGeoSubGeoGrp.Core_MDF_Sub_Region__c;                                
                                                                         if(progGeoSubGeoKey.endsWith('-null')){                             
                                                                             progGeoSubGeoKey = progGeoSubGeoKey.removeEnd('-null');                             
                                                                         }                               
                                                                         
                                                                     }else if(progGeoSubGeoGrp.Core_MDF_Region__c == NULL && progGeoSubGeoGrp.Core_MDF_Sub_Region__c == NULL){                               
                                                                         progGeoSubGeoKey = (String)progGeoSubGeoGrp.Core_MDF_Program__c;                                
                                                                         
                                                                     }                                               
                                                                     
                                                                     //Map with key = ProgGeoSubGeo/Prog/ProgGeoBt value = RO Group Name                             
                                                                     if(progGeoSubGeoGrp.Core_MDF_Group_Name_RO__c != NULL){                             
                                                                         if(groupNameToGroupIdMap.containsKey(progGeoSubGeoGrp.Core_MDF_Group_Name_RO__c)){                              
                                                                             programGeoSubGeoROGroupSetMap.put(progGeoSubGeoKey, groupNameToGroupIdMap.get(progGeoSubGeoGrp.Core_MDF_Group_Name_RO__c));                             
                                                                         }                               
                                                                     }                               
                                                                     //Map with key = ProgGeoSubGeo/Prog value = RW Group Name                                                   
                                                                     if(progGeoSubGeoGrp.Core_MDF_Group_Name__c != NULL){                                
                                                                         if(groupNameToGroupIdMap.containsKey(progGeoSubGeoGrp.Core_MDF_Group_Name__c)){                             
                                                                             programGeoSubGeoRWGroupSetMap.put(progGeoSubGeoKey, groupNameToGroupIdMap.get(progGeoSubGeoGrp.Core_MDF_Group_Name__c));                                
                                                                         }                               
                                                                     } 
                                                                     programGeoSubGeoBudgetMap.put(progGeoSubGeoKey, progGeoSubGeoGrp); 
                                                                 }                               
        
        for(Core_MDF_ProgramGeoRoleGroupMap__c progGeoRoleGroup : [select id,Name, Core_MDF_Program_txt__c, Core_MDF_Region_txt__c, Core_MDF_Role_txt__c,  
                                                                   Core_MDF_Group_Name_txt__c, Core_MDF_Is_Primary_Role__c 
								   from Core_MDF_ProgramGeoRoleGroupMap__c 
								   where Core_MDF_Is_For_IUPGM_Monitor_Ind__c = false AND Core_MDF_Is_Active__c = true]){
                                                                       progRoleKey = progGeoRoleGroup.Core_MDF_Program_txt__c + progGeoRoleGroup.Core_MDF_Role_txt__c;
                                                                       if(!progGeoRoleGroup.Core_MDF_Is_Primary_Role__c){
                                                                           progRoleSecondaryCSMap.put(progRoleKey,progGeoRoleGroup);
                                                                       }
                                                                       if(progGeoRoleGroup.Core_MDF_Is_Primary_Role__c){
                                                                           progRolePrimaryCSMap.put(progRoleKey,progGeoRoleGroup);                                                         
                                                                       }                                                          
                                                                   }
    }                               
    
    /*****************************************************************************************************                              
Method Name   :        checkPGM                             
@return       :        void                             
@parameters   :        Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c>                              
Description   :        Whenever a record is inserted in IUPGM, check if PGM exists else create new group and PGM                                
Added By      :        Accenture - VK - 07/29/2019                              
Modified By   :        Date:           Changes:                                 
Accenture - KS         05/1/2021    Add new MS Claim submitter Role                             
******************************************************************************************************/                                 
    public static void checkPGM(Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmMap){  
        
        
        Set<Id> accountIdSet = new Set<Id>();                               
        Set<Id> programIdSet = new Set<Id>();                               
        list<String> geoList = new list<String>();                              
        list<String> subGeoList = new list<String>();                               
        List<String> geoSubGeoList = new List<String>();                                
        List<String> btList = new List<String>();                               
        //key = accountId+programId+geo-subGeo, value = Set<userIds>                                
        Map<String,Set<Id>> accountProgramGeoUserIdSetMap = new Map<String,Set<Id>>();                              
        
        //key = accountId+programId+geo-subGeo, value = accountName+geo-subGeo or accountName+geo                               
        Map<String,String> accountProgramGeoIdNameMap = new Map<String,String>();                               
        Map<String,String> accountProgramGeoIdNameBTMap = new Map<String,String>();                             
        //key = accountId+programId+geo-subGeo, value = Set<groupIds>                               
        Map<String,Set<Id>> accountProgramGeoGroupIdSetMap = new Map<String,Set<Id>>();                             
        Map<String,Boolean> inactiveIndicatorPGMMAP = new Map<String,Boolean>();                             
        
        List<GroupMember> newGroupMemberList = new List<GroupMember>();                             
        
        //key=Client Co-Marketing Fund, value=CCF                               
        Map <String , String> channelProgramMetadataNameMap = new Map<String , String>();                               
        
        //key=Id, value=CCF                             
        Map<String, String> programIdMap = new Map<String, String>();                               
        
        //key=GroupDeveloperName, value=Group                               
        Map<String, Group> newGroupMap = new Map<String, Group>();                              
        
        
        List<Core_MDF_Partner_Group_Mapping__c> newPGMList = new List<Core_MDF_Partner_Group_Mapping__c>();                             
        Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper geoAndSubGeoWrapper = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper();                              
        
        //List which contains Roles for which Marketing User has to be enabled                              
        List<String> marketingUserRoles = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Account_Manager_Permission_Sets').Split(',');                                
        //List which contain account manager and mystery shopper role                               
        List<String> retailUserRoles = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Acnt_Mgr_Permission_Sets').Split(',');                                
        
        List<User> updatedUserList = new List<User>();                              
        
        List<String> roUsrRoleLst = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_User_Role_with_Read_Only_Access').split(';');                               
        List<String> rwUsrRoleLst = Core_MDF_CCP_ConstantClass.CORE_MDF_USER_ROLE_WITH_READ_WRITE_ACCESS.split(';');
            //Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_User_Role_with_Read_Write_Acces').split(';');
        Map<String, Id> grpDevNameWithGrpIdMap = new Map<String, Id>();                             
        String progKey;                             
        List<String> geoAndBudgetType = new List<String>();                             
        Set<String> geoSet = new Set<String>();                             
        Set<String> btSet = new Set<String>();
        List<Core_MDF_Bulk_Transaction__e> toBeUpdatedUserList = new List<Core_MDF_Bulk_Transaction__e>();                                  
        List<String> singleAccSpecificBTRoleList = new List<String>();
        List<String> singleAccSpecificBTCMDFRoleList = new List<String>();

        List<String> singleAccAllBTCMDFRoleList = new List<String>();
        List<String> allAccSpecificBTRoleList = new List<String>();
        List<String> allAccAllBTRoleList = new List<String>();
	List<String> allAccWithoutBTAccessRoles = new List<String>();
        List<String> allAccAllBTCMDFRoleList = new List<String>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> secondaryRolesIUPGMList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        
        Map<String, List<GroupMember>> groupMemberMap = new Map<String, List<GroupMember>>();
        // Leela - key = intelAccountId + programId, value = Virtual Corp Account Id
        Map<String, Id> intelAccProgramToVCAcctIdMap = new Map<String, Id>();
        
        try{
            singleAccSpecificBTRoleList = Core_MDF_CCP_ConstantClass.CORE_MDF_SINGLEACC_SPECIFICBT_ROLES.split(';');
            
            allAccWithoutBTAccessRoles = Core_MDF_CCP_ConstantClass.Core_MDF_AllAcc_WithoutBTAccess_Roles.split(';');
                //Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SingleAcc_SpecificBT_Roles') != null ? Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SingleAcc_SpecificBT_Roles').Split(';') : new List<String>();
            
      //      singleAccSpecificBTCMDFRoleList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SingleAcc_SpecificBT_CMDF_Roles')!= null ? Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SingleAcc_SpecificBT_CMDF_Roles').Split(';'): new List<String>();
            

           // singleAccAllBTCMDFRoleList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SingleAcct_AllBT_Roles_CMDF ') != null?
              //  singleAccAllBTCMDFRoleList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SingleAcct_AllBT_Roles_CMDF ').Split(';'):new List<String>();
             
            //commented below two strings which we were using from custom label metadata and moved it to constant class
            /*allAccSpecificBTRoleList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AllAcc_SpecificBT_Roles') != null?
                allAccSpecificBTRoleList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AllAcc_SpecificBT_Roles').Split(';'):new List<String>();
            
            allAccAllBTRoleList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AllAcc_SpecificBT_Roles') != null?
                allAccAllBTRoleList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AllAcc_SpecificBT_Roles').Split(';'):new List<String>();*/
            
            
            allAccAllBTRoleList = Core_MDF_CCP_ConstantClass.Core_MDF_AllAcc_SpecificBT_Roles.split(';');
            //allAccAllBTCMDFRoleList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AllAcct_AllBT_Roles_CMDF') != null?
             //   allAccAllBTCMDFRoleList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AllAcct_AllBT_Roles_CMDF').Split(';'):new List<String>();
                                          
            if(programGeoSubGeoROGroupSetMap.isEmpty() || programGeoSubGeoRWGroupSetMap.isEmpty()){                             
                populateprogramGeoSubGeoGroupSetMaps();                             
            }                               
            
            //Avoid using Soql / Sosl queries without filters and limits
            //To prepare programId Map                              
            for(Core_MDF_ChannelProgram__mdt cpm : ([SELECT Core_MDF_Abbreviated_ProgramName_txt__c, MasterLabel                                
                                                     FROM Core_MDF_ChannelProgram__mdt LIMIT 5000])){                              
                                                         channelProgramMetadataNameMap.put(cpm.MasterLabel, cpm.Core_MDF_Abbreviated_ProgramName_txt__c);                                
                                                         
                                                         channelProgramAbbreviationToNameMap.put(cpm.Core_MDF_Abbreviated_ProgramName_txt__c,cpm.MasterLabel);                               
                                                     }                               
            
            
            for (ChannelProgram cp : [SELECT Id, Name                               
                                      FROM ChannelProgram                               
                                      WHERE Name =: channelProgramMetadataNameMap.keySet()]){                               
                                          programIdMap.put(cp.Id,channelProgramMetadataNameMap.get(cp.Name));                             
                                      }                                           
            
            //Iterate over iupgmList to create accountProgramGeoIdNameMap and accountProgramGeoUserIdSetMap map                             
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Core_MDF_All_Accounts_cd__c,Core_MDF_Program_nm__c,Core_MDF_Account_id__r.Name,Core_MDF_Channel_Program_id__r.Name,                               
                                                                   Core_MDF_Region_cd__c, Core_MDF_Account_id__c, Core_MDF_Channel_Program_id__c,Core_MDF_User_id__c,                               
                                                                   Core_MDF_Sub_Region_cd__c,Core_MDF_Region_Sub_Region_nm__c,Core_MDF_User_id__r.UserPermissionsMarketingUser,                             
                                                                   Core_MDF_Role_nm__c,Core_MDF_Account_id__r.Core_MDF_Group_Id__c,Core_MDF_Budget_Type_nm__c,Core_MDF_GeoSubGeo_Budget_Type_nm__c,/*Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c ,*/Core_MDF_All_Budget_Type_Access_Ind__c                             
                                                                   FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c                               
                                                                   WHERE Id IN : iupgmMap.keySet()]){  //converting list to map and using map.keySet() in the query as part of ApexGuru fix
                                                                       
                                                                       String iupgmProgRoleKey = iupgm.Core_MDF_Program_nm__c + iupgm.Core_MDF_Role_nm__c;
                                                                       if(progRoleSecondaryCSMap.containsKey(iupgmProgRoleKey)){
                                                                           secondaryRolesIUPGMList.add(iupgm);
                                                                       }
                                                                       else{
                                                                           if(progRolePrimaryCSMap.containsKey(iupgmProgRoleKey)){
                                                                               secondaryRolesIUPGMList.add(iupgm);
                                                                           } 
                                                                           isPrimaryIUPGMRole = true;
                                                                           if(!iupgm.Core_MDF_User_id__r.UserPermissionsMarketingUser && marketingUserRoles.contains(iupgm.Core_MDF_Role_nm__c)){                                  
                                                                               User userInstance = new User();                             
                                                                               userInstance.Id = iupgm.Core_MDF_User_id__c;                                
                                                                               userInstance.UserPermissionsMarketingUser = TRUE;                               
                                                                               Core_MDF_Bulk_Transaction__e evtObj = new Core_MDF_Bulk_Transaction__e();
                                                                               evtObj.Core_MDF_JSON_Data__c = JSON.serialize(userInstance); 
                                                                               evtObj.Core_MDF_Object_Name__c = 'User';
                                                                               toBeUpdatedUserList.add(evtObj);                                                   
                                                                           }
                                                                           
                                                                           if(STR_No.equals(iupgm.Core_MDF_All_Accounts_cd__c)){                               
                                                                               
                                                                               //If program is RMF and Role is Retail Acc Mgr, then, user must be added to group present on Account                              
                                                                               if(retailUserRoles.contains(iupgm.Core_MDF_Role_nm__c)) {                                
                                                                                   GroupMember rsmGm = new GroupMember();                                                        
                                                                                   rsmGm.GroupId = iupgm.Core_MDF_Account_id__r.Core_MDF_Group_Id__c;                                
                                                                                   rsmGm.UserOrGroupId = iupgm.Core_MDF_User_id__c;                              
                                                                                   newGroupMemberList.add(rsmGm);                                                                
                                                                               }else{                               
                                                                                   
                                                                                   accountIdSet.add(iupgm.Core_MDF_Account_id__c);                               
                                                                                   programIdSet.add(iupgm.Core_MDF_Channel_Program_id__c);                               
                                                                                   String accountIdProgramIdGeo;                             
                                                                                   String geoSubgeo, budgttype;                                                      
                                                                                   if(iupgm.Core_MDF_Region_cd__c != NULL){                              
                                                                                       geoList = iupgm.Core_MDF_Region_cd__c.split(';');                             
                                                                                   }                                                     
                                                                                   if(iupgm.Core_MDF_Sub_Region_cd__c != NULL){                              
                                                                                       subGeoList = iupgm.Core_MDF_Sub_Region_cd__c.split(';');                              
                                                                                   }                             
                                                                                   if(iupgm.Core_MDF_Budget_Type_nm__c != NULL){                             
                                                                                       btList = iupgm.Core_MDF_Budget_Type_nm__c.split(';');                             
                                                                                   } 
                                                                                   
                                                                                   if( iupgm.Core_MDF_All_Budget_Type_Access_Ind__c == false && (singleAccSpecificBTRoleList.contains(iupgm.Core_MDF_Role_nm__c) || singleAccSpecificBTCMDFRoleList.contains(iupgm.Core_MDF_Role_nm__c))){
                                                                                       List<String> budgetTypeList = new List<String>(); 
                                                                                       if(singleAccSpecificBTRoleList.contains(iupgm.Core_MDF_Role_nm__c) && iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c != null  && iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';') != null){
                                                                                           budgetTypeList = iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';');
                                                                                       }
                                                                                       
                                                                                       for(String geobt :budgetTypeList){                                                    
                                                                                           geoSubgeo = geobt.split('->')[0];                             
                                                                                           budgttype = geobt.split('->')[1];                             
                                                                                           
                                                                                           accountIdProgramIdGeo = (String)iupgm.Core_MDF_Account_id__c + (String)iupgm.Core_MDF_Channel_Program_id__c + geoSubgeo + budgttype;                                                              
                                                                                           
                                                                                           
                                                                                           String accId = iupgm.Core_MDF_Account_id__c;                              
                                                                                           //accId = accId.left(15).right(12); //Removes first and last 3 digits
                                                                                           accId = accId.right(15); //Removing just first 3 digit to prevent duplicate accId generation
                                                                                           String accountGeoName = accId + '#' + geoSubgeo;                                                                  
                                                                                           
                                                                                           accountProgramGeoIdNameMap.put(accountIdProgramIdGeo,accountGeoName);                             
                                                                                           accountProgramGeoIdNameBTMap.put(accountIdProgramIdGeo, budgttype);                               
                                                                                           
                                                                                           
                                                                                           //Map of accId+ProgramId+Geo and List of UserId                               
                                                                                           if(accountProgramGeoUserIdSetMap.containsKey(accountIdProgramIdGeo)){                             
                                                                                               accountProgramGeoUserIdSetMap.get(accountIdProgramIdGeo).add(iupgm.Core_MDF_User_id__c);                              
                                                                                           }                             
                                                                                           else{                             
                                                                                               accountProgramGeoUserIdSetMap.put(accountIdProgramIdGeo, new Set<Id>{iupgm.Core_MDF_User_id__c});                             
                                                                                           }                             
                                                                                       }
                                                                                   }
                                                                                   
                                                                                   if((/*Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name').equals(iupgm.Core_MDF_Program_nm__c) ||*/  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name').equals(iupgm.Core_MDF_Program_nm__c) || iupgm.Core_MDF_Program_nm__c == Label.Core_MDF_EEF_Program_Name || iupgm.Core_MDF_Program_nm__c == Label.Core_MDF_Co_GTM_Technical_program_name || isCoInvBudgetRole(iupgm)) && iupgm.Core_MDF_All_Budget_Type_Access_Ind__c == true){
                                                                                       for(String geobt : iupgm.Core_MDF_Region_Sub_Region_nm__c.split(';')){                                
                                                                                           
                                                                                           
                                                                                           geoSubgeo = geobt;                             
                                                                                           budgttype = '_ALL';                             
                                                                                           
                                                                                           accountIdProgramIdGeo = (String)iupgm.Core_MDF_Account_id__c + (String)iupgm.Core_MDF_Channel_Program_id__c + geoSubgeo + budgttype;                                                                                             
                                                                                           
                                                                                           String accId = iupgm.Core_MDF_Account_id__c;                              
                                                                                           //accId = accId.left(15).right(12);  
                                                                                             accId = accId.right(15);
                                                                                           String accountGeoName = accId + '#' + geoSubgeo;                                                                  
                                                                                           accountProgramGeoIdNameMap.put(accountIdProgramIdGeo,accountGeoName);                             
                                                                                           
                                                                                           
                                                                                           accountProgramGeoIdNameBTMap.put(accountIdProgramIdGeo, budgttype);                               
                                                                                           
                                                                                           
                                                                                           //Map of accId+ProgramId+Geo and List of UserId                               
                                                                                           if(accountProgramGeoUserIdSetMap.containsKey(accountIdProgramIdGeo)){                             
                                                                                               accountProgramGeoUserIdSetMap.get(accountIdProgramIdGeo).add(iupgm.Core_MDF_User_id__c);                              
                                                                                           }                             
                                                                                           else{                             
                                                                                               accountProgramGeoUserIdSetMap.put(accountIdProgramIdGeo, new Set<Id>{iupgm.Core_MDF_User_id__c});                             
                                                                                           }                             
                                                                                       }          
                                                                                       
                                                                                   }  
                                                                                   if((!retailUserRoles.contains(iupgm.Core_MDF_Role_nm__c) ||           
                                                                                       (iupgm.Core_MDF_Role_nm__c == 'Core_MDF_CCP_Internal_MDF_Budget_Manager' &&                               
                                                                                        (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NonTranslateCCFRecordType').equals(iupgm.Core_MDF_Program_nm__c) ||                                 
                                                                                         Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NonTranslateDCFRecordType').equals(iupgm.Core_MDF_Program_nm__c)))) &&                              
                                                                                      iupgm.Core_MDF_Region_Sub_Region_nm__c != NULL && iupgm.Core_MDF_Region_Sub_Region_nm__c.split(';') != NULL 
                                                                                      && (iupgm.Core_MDF_Budget_Type_nm__c == null ||iupgm.Core_MDF_Budget_Type_nm__c=='') 
                                                                                      && iupgm.Core_MDF_All_Budget_Type_Access_Ind__c == false){                              
                                                                                          
                                                                                          
                                                                                          for(String geoSubGeoStr : iupgm.Core_MDF_Region_Sub_Region_nm__c.split(';')){                                                          
                                                                                              
                                                                                              accountIdProgramIdGeo = (String)iupgm.Core_MDF_Account_id__c + (String)iupgm.Core_MDF_Channel_Program_id__c + geoSubGeoStr;                                
                                                                                              
                                                                                              
                                                                                              //Using Acc Id instead of Acc Name for group creation                              
                                                                                              String accId = iupgm.Core_MDF_Account_id__c;                               
                                                                                              //accId = accId.left(15).right(12);    
                                                                                              accId = accId.right(15);                          
                                                                                              String accountGeoName = accId + '#' + geoSubGeoStr;                                                        
                                                                                              
                                                                                              //Map of accId+ProgramId+Geo and AccName#Geo-SubGeo                                
                                                                                              accountProgramGeoIdNameMap.put(accountIdProgramIdGeo,accountGeoName);                              
                                                                                              
                                                                                              //Map of accId+ProgramId+Geo and List of UserId                                
                                                                                              if(accountProgramGeoUserIdSetMap.containsKey(accountIdProgramIdGeo)){                              
                                                                                                  accountProgramGeoUserIdSetMap.get(accountIdProgramIdGeo).add(iupgm.Core_MDF_User_id__c);                               
                                                                                              }                              
                                                                                              else{                              
                                                                                                  accountProgramGeoUserIdSetMap.put(accountIdProgramIdGeo, new Set<Id>{iupgm.Core_MDF_User_id__c});                              
                                                                                              }                              
                                                                                              
                                                                                          }
                                                                                      }
                                                                                   
                                                                               }
                                                                           }
                                                                           
                                                                           else if(STR_Yes.equals(iupgm.Core_MDF_All_Accounts_cd__c)){                                  
                                                                               String roGrpDevName, rwGrpDevName;                                
                                                                               String programGeoSubGeo;                                                  
                                                                               List<String> geoSubGeoLst;     
                                                                               if(iupgm.Core_MDF_Region_Sub_Region_nm__c !=null){
                                                                                   geoSubGeoLst = iupgm.Core_MDF_Region_Sub_Region_nm__c.split(';');       
                                                                               }
                                                                               if((iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c == NULL ) && geoSubGeoLst != NULL){ 
                                                                                   if(allAccWithoutBTAccessRoles.contains(iupgm.Core_MDF_Role_nm__c)){
                                                                                       for(String geoSubGeo : geoSubGeoLst){                                 
                                                                                           if(STR_WW.equals(iupgm.Core_MDF_Region_Sub_Region_nm__c)){                                
                                                                                               programGeoSubGeo = (String)iupgm.Core_MDF_Channel_Program_id__r.Name;                                                     
                                                                                           }else{                                
                                                                                               programGeoSubGeo = (String)iupgm.Core_MDF_Channel_Program_id__r.Name + geoSubGeo;                             
                                                                                           }                             
                                                                                           
                                                                                           if(roUsrRoleLst.contains(iupgm.Core_MDF_Role_nm__c)){                             
                                                                                               //Creating Group Member with Group Id = RO Group from mdt                             
                                                                                               if(programGeoSubGeoROGroupSetMap.containsKey(programGeoSubGeo) && programGeoSubGeoROGroupSetMap.get(programGeoSubGeo) != NULL){                               
                                                                                                   GroupMember roGrpMem = new GroupMember();                             
                                                                                                   roGrpMem.GroupId = programGeoSubGeoROGroupSetMap.get(programGeoSubGeo);                               
                                                                                                   roGrpMem.UserOrGroupId = iupgm.Core_MDF_User_id__c;                                                       
                                                                                                   newGroupMemberList.add(roGrpMem);                             
                                                                                               }                             
                                                                                           }                                                         
                                                                                           if(rwUsrRoleLst.contains(iupgm.Core_MDF_Role_nm__c)){                             
                                                                                               //Creating Group Member with Group Id = RW Group from mdt                             
                                                                                               if(programGeoSubGeoRWGroupSetMap.containsKey(programGeoSubGeo) && programGeoSubGeoRWGroupSetMap.get(programGeoSubGeo) != NULL){                               
                                                                                                   GroupMember rwGrpMem = new GroupMember();                                                         
                                                                                                   rwGrpMem.GroupId = programGeoSubGeoRWGroupSetMap.get(programGeoSubGeo);                               
                                                                                                   rwGrpMem.UserOrGroupId = iupgm.Core_MDF_User_id__c;                               
                                                                                                   newGroupMemberList.add(rwGrpMem);                             
                                                                                               }                             
                                                                                           }                             
                                                                                       }
                                                                                   }
                                                                               }
                                                                               else{
                                                                                   
                                                                                   String geoSubGeo,budgtType; 
                                                                                   
                                                                                   List<String> geoSubgeoBTList= new List<String>();
                                                                                   if( iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c != null && iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';') != NULL){
                                                                                       geoSubgeoBTList =iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';');                         
                                                                                   }
                                                                                   
                                                                                   if(!geoSubgeoBTList.isEmpty() && (allAccAllBTRoleList.contains(iupgm.Core_MDF_Role_nm__c) || allAccAllBTCMDFRoleList.contains(iupgm.Core_MDF_Role_nm__c)) ){
                                                                                       
                                                                                       for(String geoSubgeoBT : geoSubgeoBTList){                             
                                                                                           
                                                                                           
                                                                                           geoSubGeo = geoSubgeoBT.split('->')[0];                              
                                                                                           budgtType = geoSubgeoBT.split('->')[1];                              
                                                                                           
                                                                                           programGeoSubGeo = (String)iupgm.Core_MDF_Channel_Program_id__r.Name + geoSubGeo + budgtType;                                
                                                                                           
                                                                                           
                                                                                           if(roUsrRoleLst.contains(iupgm.Core_MDF_Role_nm__c)){                                
                                                                                               
                                                                                               if(programGeoSubGeoROGroupSetMap.containsKey(programGeoSubGeo) && programGeoSubGeoROGroupSetMap.get(programGeoSubGeo) != NULL){                              
                                                                                                   GroupMember roGrpMem = new GroupMember();                                
                                                                                                   roGrpMem.GroupId = programGeoSubGeoROGroupSetMap.get(programGeoSubGeo);                              
                                                                                                   roGrpMem.UserOrGroupId = iupgm.Core_MDF_User_id__c;                                                      
                                                                                                   newGroupMemberList.add(roGrpMem);                                
                                                                                               }                                
                                                                                           }                                                                
                                                                                           if(rwUsrRoleLst.contains(iupgm.Core_MDF_Role_nm__c)){                                
                                                                                               
                                                                                               if(programGeoSubGeoRWGroupSetMap.containsKey(programGeoSubGeo) && programGeoSubGeoRWGroupSetMap.get(programGeoSubGeo) != NULL){                              
                                                                                                   GroupMember rwGrpMem = new GroupMember();                                                        
                                                                                                   rwGrpMem.GroupId = programGeoSubGeoRWGroupSetMap.get(programGeoSubGeo);                              
                                                                                                   rwGrpMem.UserOrGroupId = iupgm.Core_MDF_User_id__c;                              
                                                                                                   newGroupMemberList.add(rwGrpMem);                                
                                                                                               }                                
                                                                                           }                                
                                                                                           
                                                                                       }
                                                                                   }
                                                                                   
                                                                               }
                                                                           }
                                                                       }
                                                                   }
            if(secondaryRolesIUPGMList.size()>0){
                groupMemberMap = addRoleSpecificIUPGMGroupMember(secondaryRolesIUPGMList);
            }
            if(isPrimaryIUPGMRole){                               
                if(!accountIdSet.isEmpty() && !programIdSet.isEmpty()){
                    for(Account vcAcc : [
                        SELECT Id, Core_MDF_Parent_Fund_Account__c, Core_MDF_Channel_Program__c
                        FROM Account
                        WHERE Core_MDF_Parent_Fund_Account__c IN : accountIdSet
                        AND Core_MDF_Channel_Program__c IN : programIdSet
                        ]){
                        String vcKey = (String)vcAcc.Core_MDF_Parent_Fund_Account__c + (String)vcAcc.Core_MDF_Channel_Program__c;
                        if(!intelAccProgramToVCAcctIdMap.containsKey(vcKey)){
                            intelAccProgramToVCAcctIdMap.put(vcKey, vcAcc.Id);
                        }
                    }
                }
                //Get PGM based on the Set and create accountProgramGeoGroupIdSetMap Map    
                
                if(!accountIdSet.isEmpty() && !programIdSet.isEmpty()){                                
                    for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Core_MDF_Account__c, Core_MDF_Channel_Program__c, Core_MDF_Group_Name__c,                               
                                                                 Core_MDF_Group_id__c, Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c, Core_MDF_BudgetType_nm__c, Core_MDF_Inactive_Ind__c                                
                                                                 FROM Core_MDF_Partner_Group_Mapping__c                             
                                                                 WHERE Core_MDF_Channel_Program__c IN : programIdSet AND                                
                                                                 Core_MDF_Type_Of_Access__c = 'Internal' AND                                
                                                                 Core_MDF_Account__c IN: accountIdSet AND                               
                                                                 Core_MDF_Region_cd__c IN : geoList]){                                                  
                                                                     String accountProgramGeoGroupIdMapKey = '';
                                                                     if(subGeoList.Contains(pgm.Core_MDF_Sub_Region_cd__c) || pgm.Core_MDF_Sub_Region_cd__c == NULL){                               
                                                                         
                                                                         if(pgm.Core_MDF_BudgetType_nm__c != NULL){  
                                                                             if(btList.contains(pgm.Core_MDF_BudgetType_nm__c)){
                                                                             accountProgramGeoGroupIdMapKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c +'-'+ pgm.Core_MDF_Sub_Region_cd__c + pgm.Core_MDF_BudgetType_nm__c;                               
                                                                             if(accountProgramGeoGroupIdMapKey.contains('-null')){                               
                                                                                 accountProgramGeoGroupIdMapKey = accountProgramGeoGroupIdMapKey.remove('-null');                                                                     }
                                                                             }
                                                                         }else{                                                              
                                                                             
                                                                             accountProgramGeoGroupIdMapKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c +'-'+ pgm.Core_MDF_Sub_Region_cd__c;                             
                                                                             //if sub region is null, then -null has to be removed from the end                                                                      
                                                                             if(accountProgramGeoGroupIdMapKey.endsWith('-null')){                               
                                                                                 accountProgramGeoGroupIdMapKey = accountProgramGeoGroupIdMapKey.removeEnd('-null');                                 
                                                                             }                               
                                                                            // accountProgramGeoGroupIdMapKey +=pgm.Core_MDF_BudgetType_nm__c;
                                                                         }                               
                                                                         
                                                                         if(string.isNotBlank(accountProgramGeoGroupIdMapKey)){
                                                                             if(accountProgramGeoGroupIdSetMap.containsKey(accountProgramGeoGroupIdMapKey)){                             
                                                                                 accountProgramGeoGroupIdSetMap.get(accountProgramGeoGroupIdMapKey).add(pgm.Core_MDF_Group_id__c);                               
                                                                             }                               
                                                                             else{                               
                                                                                 accountProgramGeoGroupIdSetMap.put(accountProgramGeoGroupIdMapKey, new Set<Id>{pgm.Core_MDF_Group_id__c});                              
                                                                             } 
                                                                             if(pgm.Core_MDF_Inactive_Ind__c == true){
                                                                                 inactiveIndicatorPGMMAP.put(accountProgramGeoGroupIdMapKey, true);
                                                                             }
                                                                         }                           
                                                                         
                                                                     }                               
                                                                     
                                                                 }
                }
                
                //Key=Group Developer Name , value = Set<UserId>                                
                Map<String, Set<Id>> groupNameUserIdsMap = new Map<String, Set<Id>>();                              
                
                //key=GroupDeveloperName, value=AccId+ProgramId+Geo                             
                Map<String,String> pgmGroupNameMap = new Map<String,String>();                              
                
                //Set of GroupDeveloperName                             
                Set<String> groupNameSet = new Set<String>();                               
                
                //key=GroupId, value=Set<UserId>                                
                Map<Id, Set<Id>> groupIdUserIdSetMap = new Map<Id, Set<Id>>();                              
                
                if(accountProgramGeoUserIdSetMap.size() > 0){                               
                    for(String key : accountProgramGeoUserIdSetMap.keySet()){                               
                        //string Newkey = key.endsWith('_ALL') ? key.remove('_ALL') + 'null' : key + 'null'; //-> removed for duplicate issue
                        string Newkey = key.endsWith('_ALL') ? key.remove('_ALL') : key;
                        if(inactiveIndicatorPGMMAP.isEmpty() || (!inactiveIndicatorPGMMAP.containsKey(key) && !inactiveIndicatorPGMMAP.containsKey(Newkey))) {
                            if(accountProgramGeoGroupIdSetMap.containsKey(Newkey)){                                
                                //If key is present, that means PGM already exists,so create the Group Member                               
                                for(Id groupId : accountProgramGeoGroupIdSetMap.get(Newkey)){                              
                                    //if group Id already exists, then we need to add the users from accountProgramGeoUserIdSetMap to the group already present                             
                                    if(groupIdUserIdSetMap.containsKey(groupId)){                               
                                        Set<Id> userIdSet = accountProgramGeoUserIdSetMap.get(key);                             
                                        userIdSet.addAll(groupIdUserIdSetMap.get(groupId));                             
                                        groupIdUserIdSetMap.put(groupId, userIdSet);                                
                                    }                               
                                    else{                               
                                        Set<Id> userIdSet = new Set<Id>();                              
                                        userIdSet.addAll(accountProgramGeoUserIdSetMap.get(key));                               
                                        groupIdUserIdSetMap.put(groupId, userIdSet);                                
                                    }                               
                                }                               
                            }                                                   
                            else{                                                             
                                String accId = key.left(18);                                                             
                                String programId = key.left(36).right(18);                                                            
                                String budType, bt;                             
                                
                                if(accountProgramGeoIdNameMap.containsKey(key) || accountProgramGeoIdNameBTMap.containsKey(key)){   //Uncomment when IPA BT access                            
                                    //String accGeoNameFromMap = Store the Account Name and Geo Name                                
                                    String accGeoNameFromMap = accountProgramGeoIdNameMap.get(key);                             
                                    
                                    Id vcAccId = intelAccProgramToVCAcctIdMap.get((String)accId + (String)programId);
                                    if(vcAccId == null){
                                        continue; // No VC => do not create any group
                                    }
                                    
                                    //Remove all the special characters and change to Upper Case                                
                                    //String accountName = accGeoNameFromMap.split('#')[0].replaceAll('[^a-zA-Z\\s+]', '').deleteWhitespace().toUpperCase();
                                    //String accountName = accGeoNameFromMap.split('#')[0];
                                    String accountName = ((String)vcAccId).right(15);
                                    
                                    
                                    String programName = programIdMap.get(programId);                               
                                    
                                    geoSubGeoList.add(accGeoNameFromMap.split('#')[1].toUpperCase());                               
                                    
                                    
                                    
                                    if(accountProgramGeoIdNameBTMap.get(key) != NULL){                              
                                        budType = accountProgramGeoIdNameBTMap.get(key);                                                            
                                    }                              
                                    
                                    //US870621: 7. Based on Budget Type, passing budget type as param to wrapper method, else null                                  
                                    if(String.isNotBlank(budType) && budType != NULL){                              
                                        
                                        geoAndSubGeoWrapper = getAccProgramGeoSubGeo(geoSubGeoList,accountName,programName,budType);                                                              
                                        geoSubGeoList.clear();                              
                                    }else {                             
                                        geoAndSubGeoWrapper = getAccProgramGeoSubGeo(geoSubGeoList,accountName,programName,null);                                                      
                                        geoSubGeoList.clear();                              
                                        
                                    }                               
                                    String groupDeveloperName = geoAndSubGeoWrapper.groupDeveloperName;                             
                                    String groupName = geoAndSubGeoWrapper.groupName;                               
                                    
                                    //Check if Developer Name already exists in the Set else create new Group                               
                                    if(!groupNameSet.contains(groupDeveloperName)){                             
                                        Group newGroup = new Group();                               
                                        newGroup.Name = groupName;                              
                                        newGroup.DeveloperName = groupDeveloperName;
                                        newGroup.DoesIncludeBosses = false;                                
                                        newGroupMap.put(groupDeveloperName.toUpperCase(), newGroup);                              
                                        groupNameSet.add(groupDeveloperName);                               
                                    }                               
                                    
                                    //DE62015 fix: Create a Map with Group Name and Channel Program                             
                                    string value= channelProgramAbbreviationToNameMap.get(programName);                             
                                    if(value!=null){newGroupNameToChannelProgramMap.put(groupDeveloperName,value);}                                                                  
                                    
                                    for(Id userId : accountProgramGeoUserIdSetMap.get(key)){                                
                                        //Create Group and UserId Map                               
                                        if(groupNameUserIdsMap.containsKey(groupDeveloperName)){                                
                                            Set<Id> userIds = new Set<Id>();                                
                                            userIds = groupNameUserIdsMap.get(groupDeveloperName);                              
                                            userIds.add(userId);                                
                                            groupNameUserIdsMap.put(groupDeveloperName,userIds);                                
                                        }                               
                                        else{                               
                                            groupNameUserIdsMap.put(groupDeveloperName, new Set<Id> {userId});                              
                                        }                               
                                    }                               
                                    
                                    
                                    //Check if the pgmGroupNameMap already contains a pgm  created for a particular group else create new PGM                               
                                    if(!pgmGroupNameMap.containsKey(groupDeveloperName)){                               
                                        Core_MDF_Partner_Group_Mapping__c newPGM = new Core_MDF_Partner_Group_Mapping__c();                             
                                        newPGM.Core_MDF_Account__c = accId;                             
                                        newPGM.Core_MDF_Channel_Program__c = programId; 
                                        if(budType != '_ALL'){
                                            newPGM.Core_MDF_BudgetType_nm__c = budType;
                                        }
                                        
                                        newPGM.Core_MDF_Region_cd__c = String.join(new List<String>(geoAndSubGeoWrapper.geo), ';');                             
                                        if(geoAndSubGeoWrapper.subGeo.Size() > 0){newPGM.Core_MDF_Sub_Region_cd__c = String.join(new List<String>(geoAndSubGeoWrapper.subGeo), ';');}                               
                                        newPGM.Core_MDF_Group_Name__c = groupDeveloperName;                             
                                        newPGM.Core_MDF_Type_of_Access__c = 'Internal';                                                           
                                        newPGM.Core_MDF_Source_Txt__c= 'IUPGM';                                 
                                        
                                        
                                        if(String.isNotBlank(budType) && budType != NULL && budType !='_ALL' ){                              
                                            newPGM.Core_MDF_BudgetType_nm__c = budType;                                
                                        }else{                              
                                            newPGM.Core_MDF_BudgetType_nm__c = null;                               
                                        } 
                                        
                                        
                                        newPGMList.add(newPGM);                                                            
                                        pgmGroupNameMap.put(groupDeveloperName,key);                                
                                    }                               
                                }                               
                            }                               
                        }                               
                    }                               
                }                               
                //key=GroupDeveloperName, value=Group                               
                Map<String, Group> groupDevNameGroupMap = new Map<String, Group>();                             
                
                
                
                if(!newGroupMap.isEmpty()){                             
                    for(Group groupRec : [SELECT Id, DeveloperName, Name                                
                                          FROM Group                                
                                          WHERE DeveloperName IN :groupNameSet ]){                              
                                              newGroupMap.remove(groupRec.DeveloperName.toUpperCase());
                                              groupDevNameGroupMap.put(groupRec.DeveloperName, groupRec);                               
                                          }                             
                    insert newGroupMap.values();                                
                    
                }                               
                
                
                List<Group> groupFinalList = new List<Group>();                             
                if(!newGroupMap.isEmpty()){                             
                    groupFinalList.addAll(newGroupMap.values());                                
                }                               
                if(!groupDevNameGroupMap.isEmpty()){                                
                    groupFinalList.addAll(groupDevNameGroupMap.values());                               
                }                               
                
                //key=GroupDeveloperName, value=GroupId                             
                Map<String, Id> groupNameIdMap = new Map<String, Id>();                             
                
                //Build the map of Name as key and Id as value                              
                if(!groupFinalList.isEmpty()){                              
                    for(Group grp : groupFinalList){                                
                        groupNameIdMap.put(grp.DeveloperName.toUpperCase(), grp.Id);                              
                    }                               
                }                               
                
                //Create GroupMember List 
                for(String groupName : groupNameUserIdsMap.keySet()){    
                    for(Id userId : groupNameUserIdsMap.get(groupName)){                         
                        GroupMember newGroupMember = new GroupMember();                             
                        newGroupMember.GroupId = groupNameIdMap.get(groupName.toUpperCase()); 
                        newGroupMember.UserOrGroupId = userId;                              
                        newGroupMemberList.add(newGroupMember);                                                       
                    }                               
                    
                }                               
                
                //Create groupMember from groupIdUserIdSetMap   
                
                if(!groupIdUserIdSetMap.isEmpty()){                             
                    for(Id groupId : groupIdUserIdSetMap.keySet()){                             
                        for(Id userId : groupIdUserIdSetMap.get(groupId)){                              
                            GroupMember newGroupMember = new GroupMember();                             
                            newGroupMember.GroupId = groupId;                               
                            newGroupMember.UserOrGroupId = userId;                              
                            newGroupMemberList.add(newGroupMember);                             
                            
                        }                               
                    }                               
                }                               
                
                
                if(!newGroupNameToChannelProgramMap.isEmpty()){                               
                    queryMetadataForMasterGroup();                              
                    for(string groupName:newGroupNameToChannelProgramMap.keySet()){     
                        if(newGroupNameToChannelProgramMap.containsKey(groupName) && newGroupNameToChannelProgramMap.get(groupName) != NULL
                           && channelProgramToMasterGroupId.containsKey(newGroupNameToChannelProgramMap.get(groupName)) && channelProgramToMasterGroupId.get(newGroupNameToChannelProgramMap.get(groupName)) != NULL){
                            GroupMember newGroupMember = new GroupMember();                             
                            newGroupMember.GroupId = channelProgramToMasterGroupId.get(newGroupNameToChannelProgramMap.get(groupName));                             
                            newGroupMember.UserOrGroupId = groupNameIdMap.get(groupName.toUpperCase());                               
                            newGroupMemberList.add(newGroupMember);            
                        }                                              
                    }                               
                }                               
                
                Boolean marketingUserUpdateSwitch = FALSE;                              
                if(mapFunctionalityNameTriggerExecution.containsKey('marketingUserPermissionUpdate') &&                             
                   mapFunctionalityNameTriggerExecution.get('marketingUserPermissionUpdate').Core_Active__c){                               
                       marketingUserUpdateSwitch = TRUE;                               
                   }                               
                
                if(marketingUserUpdateSwitch && toBeUpdatedUserList != NULL && !toBeUpdatedUserList.isEmpty()){                                                             
                    List<Database.SaveResult> results = EventBus.publish(toBeUpdatedUserList);
                    for (Database.SaveResult sr : results) {
                        if (sr.isSuccess()) {
                            
                        } 
                        else { 
                            for(Database.Error err : sr.getErrors()) { 
                                 
                            }
                        }
                    }  
                }
                
                
                //To insert GroupMember, Call the createGroupMember method                              
                if(!newGroupMemberList.isEmpty()){      
                    String jsonStringGM = JSON.serialize(newGroupMemberList);                               
                    Core_MDF_IUPGM_ServiceHandler.createGroupMember(jsonStringGM);                              
                }                               
                
                //Insert PGM                                
                if(!newPGMList.isEmpty()){
                    List<Core_Log_Entry__c> logEntryList =  new List<Core_Log_Entry__c>();
                    LogEntryDetailsWrapper logEntryWrapper = new LogEntryDetailsWrapper();
                      List<Database.SaveResult> updateResults = Database.insert(newPGMList,false);                                
                    
                    for(Integer i=0;i<updateResults.size();i++){
                        if (updateResults.get(i) != null && updateResults.get(i).isSuccess()){
                            updateResults.get(i).getId();
                            if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_IUPGMLogEntry')){ // to bypass the log entry record creation
                                logEntryWrapper.origin = 'Core_MDF_IUPGM_ServiceHandler.createPGM';
                                logEntryWrapper.successIds.add(updateResults.get(i).getId());
                            }
                        }else if (updateResults.get(i) != null && (!updateResults.get(i).isSuccess())){
                            
                            if(Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_LogIUPGMFailures')){
                            LogEntryDetailsWrapper errorLogEntryWrapper = new LogEntryDetailsWrapper();
                            Database.Error error = updateResults.get(i).getErrors().get(0);
                            errorLogEntryWrapper.origin = 'Core_MDF_IUPGM_ServiceHandler.createPGM';
                            errorLogEntryWrapper.failedPGMList.add(newPGMList.get(i)); 
                            errorLogEntryWrapper.errorMsg = error.getMessage();
                            Core_Log_Entry__c errorLogEntryObj = createLogInstance(errorLogEntryWrapper);
                            logEntryList.add(errorLogEntryObj);
                            }
                        }
                    }
                    if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_IUPGMLogEntry')){ // to bypass the log entry record creation
                        if(logEntryWrapper != null && !logEntryWrapper.successIds.isEmpty()){
                            Core_Log_Entry__c logEntryObj = createLogInstance(logEntryWrapper); // calling createLogInstance method with wrapper as parameter
                            logEntryList.add(logEntryObj);
                        }
                        if(!logEntryList.isEmpty()){
                            List<Core_MDF_Bulk_Transaction__e> logEntryPEList = createBulkTransactionPlatEventInstance(logEntryList); //calling createBulkTransactionPlatEventInstance method with logEntryObj parameters
                            if(!logEntryPEList.isEmpty()){
                                EventBus.publish(logEntryPEList); 
                            }
                        }
                    }
                }
            }
        }                               
        catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e);}                              
    }                               
    
    /*****************************************************************************************************                              
Method Name   :        createGroupMember                                
@return       :        void                             
@parameters   :        String jsonString which has new GroupMember                              
Description   :        To insert the GroupMember records                                
Added By      :        Accenture - VK - 07/29/2019                              
Modified By   :        Date:       Changes:                                 
******************************************************************************************************/                             
    @future                             
    public static void createGroupMember(String jsonStringGM){                              
        try{                               
            List<Core_Log_Entry__c> logEntryList =  new List<Core_Log_Entry__c>();
            LogEntryDetailsWrapper logEntryWrapper = new LogEntryDetailsWrapper();
            List<GroupMember> gmList = (List<GroupMember>)JSON.deserialize(jsonStringGM,List<GroupMember>.class);                               
            
            Database.SaveResult[] saveList = Database.insert(gmList,true);
            
            if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_IUPGMLogEntry')){ // to bypass the log entry record creation
                for(Integer i=0;i<saveList.size();i++){
                    if (saveList.get(i).isSuccess()){                        
                        logEntryWrapper.origin = 'Core_MDF_IUPGM_ServiceHandler.createGroupMember';
                        logEntryWrapper.successIds.add(saveList.get(i).getId());
                    }
                    else{
                        if(Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_LogIUPGMFailures')){
                            LogEntryDetailsWrapper errorLogEntryWrapper = new LogEntryDetailsWrapper();
                            Database.Error error = saveList.get(i).getErrors().get(0);
                            errorLogEntryWrapper.origin = 'Core_MDF_IUPGM_ServiceHandler.createGroupMember';
                            errorLogEntryWrapper.failedGroupMemberList.add(gmList.get(i)); 
                            errorLogEntryWrapper.errorMsg = error.getMessage();
                            Core_Log_Entry__c errorLogEntryObj = createLogInstance(errorLogEntryWrapper);
                            logEntryList.add(errorLogEntryObj);
                        }
                    }
                }
                if(logEntryWrapper != null && !logEntryWrapper.successIds.isEmpty()){
                    Core_Log_Entry__c logEntryObj = createLogInstance(logEntryWrapper); // calling createLogInstance method with wrapper as parameter
                    logEntryList.add(logEntryObj);
                }
                List<Core_MDF_Bulk_Transaction__e> logEntryPEList = createBulkTransactionPlatEventInstance(logEntryList); //calling createBulkTransactionPlatEventInstance method with logEntryObj parameters
                
                if(!logEntryPEList.isEmpty()){
                    EventBus.publish(logEntryPEList);  
                }
                
            }
        }                               
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}                              
    }                                       
    
    /*****************************************************************************************************                              
Method Name   :        checkUserPermission                              
@return       :        void                             
@parameters   :        List of Internal Users Partner Geo Mapping records                               
Description   :        To validate user permission set and role                             
Added By      :        Accenture - VK - 08/19/2019                              
Modified By   :        Date:       Changes:                                 
******************************************************************************************************/                             
    public static void checkUserPermission(List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList,                               
                                           Boolean isInsert,                                
                                           Boolean isUpdate,                                
                                           Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c> oldIupgmMap){                              
                                               
                                               Set<Id> userIdSet = new Set<Id>();                              
                                               Set<Id> channelProgramIdSet = new Set<Id>();                                
                                               Set<String> roleSet = new Set<String>();                                
                                               Set<String> channelProgramNameSet = new Set<String>();         
                                               Map<Id,String> userIdProfileNameMap =new Map<Id,String>();           
                                               //key=UserId, value=Set<Permission set names>                               
                                               Map<Id,Set<String>> userIdPermissionSetNameMap = new Map<Id,Set<String>>();                             
                                               
                                               //key=Role, value=Set<Channel Program>                              
                                               Map<String,Set<String>> roleChannelProgramMetadatMap = new Map<String,Set<String>>();                               
                                               
                                               //key=Channel Program Name, value=Channel Program Id                                
                                               Map<String,Id> channelProgramNameIdMap = new Map<String,Id>();                              
                                               
                                               //key=channelProgramName, value=Id                              
                                               Map<String,Id> programNameIdMap = new Map<String,Id>();                             
                                               
                                               //List to update region and sub region                              
                                               List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmListToBeUpdated = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();                               
                                               List<String> profileList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IUPGM_ApproverBypassProfiles').split(';');                                
                                               List<String> geoSubGeoList = new List<String>();                                
                                               Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper geoAndSubGeoWrapper = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper();                              
                                               List<String> geoAndBudgetType = new List<String>();                             
                                               Set<String> geoSet = new Set<String>();                             
                                               Set<String> btSet = new Set<String>();                              
                                               Set<String> geobtSet = new Set<String>();                                                                   
                                               Set<String> existinggeobtSet = new Set<String>();  
                                               List<String> singleAccAllBTCMDFRoleList = new List<String>();   
                                               List<String> singleAccSpecificBTCMDFRoleList = new List<String>();      
                                               
                                             /*  if(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SingleAcct_AllBT_Roles_CMDF ') != null){
                                                   singleAccAllBTCMDFRoleList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SingleAcct_AllBT_Roles_CMDF ').Split(';');
                                               }*/
                                              /* if(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SingleAcc_SpecificBT_CMDF_Roles') != null){
                                                   singleAccSpecificBTCMDFRoleList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SingleAcc_SpecificBT_CMDF_Roles').Split(';');
                                               }*/
                                               try{       
                                                   for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){
                                                       if(iupgm.Core_MDF_User_id__c!=null ){
                                                           userIdSet.add(iupgm.Core_MDF_User_id__c);  
                                                       }               
                                                   }
                                                   if(userIdSet!=null && !userIdSet.isEmpty()){
                                                       userIdProfileNameMap = getProfileName(userIdSet);  
                                                   }
                                                   List<string> EGF_BUDGETTYPE_ROLES = Core_MDF_CCP_ConstantClass.EGF_BUDGETTYPE_ROLES != NULL ?
                                                                                       Core_MDF_CCP_ConstantClass.EGF_BUDGETTYPE_ROLES.split(';') : new List<string>();
                                                   
                                                   List<string> Co_GTM_BUDGETTYPE_ROLES = Core_MDF_CCP_ConstantClass.Co_GTM_BUDGETTYPE_ROLES != NULL ?
                                                                                       Core_MDF_CCP_ConstantClass.Co_GTM_BUDGETTYPE_ROLES.split(';') : new List<string>();
                                                   
                                                   for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){ 
                                                       
                                                       
                                                       if(iupgm.Core_MDF_User_id__c != null && iupgm.Core_MDF_Is_Not_an_Approver_Ind__c == false && userIdProfileNameMap.containsKey(iupgm.Core_MDF_User_id__c)){
                                                           String profileName =userIdProfileNameMap.get(iupgm.Core_MDF_User_id__c);
                                                           if(profileList.contains(profileName)){
                                                               iupgm.Core_MDF_Is_Not_an_Approver_Ind__c = true;
                                                           }
                                                       }
                                                       
                                                       if(isInsert || (isUpdate && ((iupgm.Core_MDF_Region_Sub_Region_nm__c != NULL && oldIupgmMap.get(iupgm.Id).Core_MDF_Region_Sub_Region_nm__c != iupgm.Core_MDF_Region_Sub_Region_nm__c) ||                                
                                                                                    (iupgm.Core_MDF_Budget_Type_nm__c != NULL && oldIupgmMap.get(iupgm.Id).Core_MDF_Budget_Type_nm__c != iupgm.Core_MDF_Budget_Type_nm__c) ||                                
                                                                                    (iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c != NULL && oldIupgmMap.get(iupgm.Id).Core_MDF_GeoSubGeo_Budget_Type_nm__c != iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c) ||
                                                                                    (oldIupgmMap.get(iupgm.Id).Core_MDF_All_Budget_Type_Access_Ind__c != iupgm.Core_MDF_All_Budget_Type_Access_Ind__c)))){                             
                                                                                        
                                                                                        if(isInsert){
                                                                                            
                                                                                            if(iupgm.Core_MDF_All_Accounts_cd__c == 'Yes'){
                                                                                                iupgm.Core_MDF_Account_id__c = NULL;
                                                                                            }
                                                                                            
                                                                                            //Making Core_MDF_All_Budget_Type_Access_Ind__c to False for CCF/DCF/RMF and IPA PriceReviewer role as Budget Type is not applicable for these
                                                                                            if((!Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name').equals(iupgm.Core_MDF_Program_nm__c) && iupgm.Core_MDF_Program_nm__c != Label.Core_MDF_EEF_Program_Name && iupgm.Core_MDF_Program_nm__c != Label.Core_MDF_Co_GTM_Technical_program_name && !isCoInvBudgetRole(iupgm)
                                                                                                || ((Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name').equals(iupgm.Core_MDF_Program_nm__c) || iupgm.Core_MDF_Program_nm__c == Label.Core_MDF_EEF_Program_Name || iupgm.Core_MDF_Program_nm__c == Label.Core_MDF_Co_GTM_Technical_program_name
                                                                                                    ) && (iupgm.Core_MDF_Role_nm__c == 'Core_MDF_CCP_Internal_Price_Reviewer' || iupgm.Core_MDF_Role_nm__c == 'Core_MDF_Internal_Escalation_Reviewer_L1'))) 
                                                                                               && iupgm.Core_MDF_All_Budget_Type_Access_Ind__c == true){
                                                                                                   iupgm.Core_MDF_All_Budget_Type_Access_Ind__c = false;
                                                                                               }
                                                                                            
                                                                                            if(iupgm.Core_MDF_Role_nm__c == 'Core_MDF_CCP_Internal_Retail_Account_Manager' || iupgm.Core_MDF_Role_nm__c == 'Core_MDF_CCP_RMF_PRC_Claim_Operations'){
                                                                                                iupgm.Core_MDF_Region_Sub_Region_nm__c = NULL;
                                                                                                //iupgm.Core_MDF_Budget_Type_txt__c = NULL; 
                                                                                                iupgm.Core_MDF_Budget_Type_nm__c = NULL; 
                                                                                                iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c = NULL;
                                                                                            }
                                                                                            
                                                                                            else if(!Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_BudgetTypeRoles').contains(iupgm.Core_MDF_Role_nm__c) &&
                                                                                                    !EGF_BUDGETTYPE_ROLES.contains(iupgm.Core_MDF_Role_nm__c) &&
                                                                                                    !Co_GTM_BUDGETTYPE_ROLES.contains(iupgm.Core_MDF_Role_nm__c) &&
                                                                                                    !isCoInvBudgetRole(iupgm) &&
                                                                                                    !singleAccAllBTCMDFRoleList.contains(iupgm.Core_MDF_Role_nm__c) && !singleAccSpecificBTCMDFRoleList.contains(iupgm.Core_MDF_Role_nm__c)){
                                                                                                        
                                                                                                       // iupgm.Core_MDF_Budget_Type_txt__c = NULL; 
                                                                                                        iupgm.Core_MDF_Budget_Type_nm__c = NULL; 
                                                                                                        iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c = NULL;
                                                                                                    } 
                                                                                            //Budget Type field is cleared when all budget type access is provided for IPA/CMDF
                                                                                            if(!(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name').equals(iupgm.Core_MDF_Program_nm__c) 
                                                                                               && iupgm.Core_MDF_Role_nm__c == 'Core_MDF_CCP_Internal_Price_Reviewer')){
                                                                                                iupgm.Core_MDF_Approval_Region_nm__c = null;
                                                                                            }
                                                                                            if(iupgm.Core_MDF_Program_nm__c =='Channel MDF'|| iupgm.Core_MDF_Program_nm__c =='Intel Partner Alliance' || iupgm.Core_MDF_Program_nm__c == Label.Core_MDF_EEF_Program_Name || iupgm.Core_MDF_Program_nm__c == Label.Core_MDF_Co_GTM_Technical_program_name || isCoInvBudgetRole(iupgm)){
                                                                                                
                                                                                                if(iupgm.Core_MDF_All_Budget_Type_Access_Ind__c == true){
                                                                                                   // iupgm.Core_MDF_Budget_Type_txt__c = NULL; 
                                                                                                    iupgm.Core_MDF_Budget_Type_nm__c = NULL; 
                                                                                                    iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c =NULL;
                                                                                                }
                                                                                                else if(String.isNotBlank(iupgm.Core_MDF_Budget_Type_nm__c)){
                                                                                                    iupgm.Core_MDF_Region_Sub_Region_nm__c = NULL;
                                                                                                }
                                                                                            }
                                                                                            
                                                                                        }
                                                                                        if(isUpdate){
                                                                                            if(oldIupgmMap.get(iupgm.id).Core_MDF_All_Budget_Type_Access_Ind__c != iupgm.Core_MDF_All_Budget_Type_Access_Ind__c){
                                                                                                if(iupgm.Core_MDF_All_Budget_Type_Access_Ind__c == true){
                                                                                                    
                                                                                                    if(iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c != null){
                                                                                                        oldBudgetTypeList = iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';'); 
                                                                                                    }
                                                                                                    
                                                                                                    
                                                                                                   // iupgm.Core_MDF_Budget_Type_txt__c = NULL; 
                                                                                                    iupgm.Core_MDF_Budget_Type_nm__c = NULL; 
                                                                                                    iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c =NULL;
                                                                                                }
                                                                                                else{
                                                                                                    iupgm.Core_MDF_Region_Sub_Region_nm__c = NULL;
                                                                                                }
                                                                                            }
                                                                                        }                        
                                                                                        channelProgramNameSet.add(iupgm.Core_MDF_Program_nm__c);                                
                                                                                        roleSet.add(iupgm.Core_MDF_Role_nm__c);                             
                                                                                        
                                                                                        if(iupgm.Core_MDF_Region_Sub_Region_nm__c != NULL){                               
                                                                                            iupgmListToBeUpdated.add(iupgm);                                
                                                                                        } 
                                                                                        
                                                                                        if(( Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name').equals(iupgm.Core_MDF_Program_nm__c) && Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_BudgetTypeRoles').contains(iupgm.Core_MDF_Role_nm__c))  ||
                                                                                          /* (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name').equals(iupgm.Core_MDF_Program_nm__c) &&  singleAccSpecificBTCMDFRoleList.contains(iupgm.Core_MDF_Role_nm__c))  ||*/
                                                                                            iupgm.Core_MDF_Program_nm__c == Label.Core_MDF_EEF_Program_Name || iupgm.Core_MDF_Program_nm__c == Label.Core_MDF_Co_GTM_Technical_program_name || isCoInvBudgetRole(iupgm)){
                                                                                               List<String> budgetTypeList= new List<String>();
                                                                                               if(iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c != null){
                                                                                                   budgetTypeList = iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';');
                                                                                               }
                                                                                               /*if(iupgm.Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c != null){
                                                                                                   budgetTypeList = iupgm.Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c.split(';');
                                                                                               }*/
                                                                                               if(budgetTypeList != null && !budgetTypeList.isEmpty()){
                                                                                                   for(String bt : budgetTypeList){                             
                                                                                                       
                                                                                                       geoAndBudgetType = bt.split('->');                              
                                                                                                       
                                                                                                       if(geoAndBudgetType.size() >= 2){                               
                                                                                                           geoSet.add(geoAndBudgetType[0].trim());                             
                                                                                                           btSet.add(geoAndBudgetType[1].trim());                                                                      
                                                                                                       }                               
                                                                                                       String geoSubgeo = '';                              
                                                                                                       for(String str1: geoSet){                               
                                                                                                           geoSubgeo = geoSubgeo + str1 +';';                              
                                                                                                       }                               
                                                                                                       if(geoSubgeo != NULL){                              
                                                                                                           iupgm.Core_MDF_Region_Sub_Region_nm__c = geoSubgeo;                             
                                                                                                       }                               
                                                                                                       
                                                                                                       String budType = '';                                
                                                                                                       for(String str2: btSet){                                
                                                                                                           budType = budType + str2 +';';                                                                      
                                                                                                       }                               
                                                                                                       if(budType != NULL){                                
                                                                                                           iupgm.Core_MDF_Budget_Type_nm__c = budType;                             
                                                                                                       }                               
                                                                                                       iupgmListToBeUpdated.add(iupgm);                                
                                                                                                   }
                                                                                               }
                                                                                           }                                                
                                                                                    }
                                                   }
                                                   
                                                   //only during insert validate the roles and update the active check and channel program Id                              
                                                   if(isInsert){                               
                                                       
                                                       if(channelProgramNameSet.Size() > 0){                               
                                                           for(ChannelProgram cp : [SELECT Id, Core_MDF_Technical_Program_Name__c                              
                                                                                    FROM ChannelProgram                             
                                                                                    WHERE Core_MDF_Technical_Program_Name__c IN : channelProgramNameSet]){                              
                                                                                        programNameIdMap.put(cp.Core_MDF_Technical_Program_Name__c,cp.Id);                              
                                                                                    }                               
                                                       }                               
                                                       
                                                       //Check if logged in user has access to the channel program selected for creating IUPGM                             
                                                       Id loggedInUserId = UserInfo.getUserId();                               
                                                       Map<Id,Boolean> cpIdCpAccessMap = new Map<Id,Boolean>();                                
                                                       for(UserRecordAccess  cpRecordAccess : [SELECT RecordId, HasReadAccess                              
                                                                                               FROM UserRecordAccess WHERE UserId =: loggedInUserId AND                                
                                                                                               RecordId IN: programNameIdMap.values()]){                               
                                                                                                   cpIdCpAccessMap.put(cpRecordAccess.RecordId,cpRecordAccess.HasReadAccess);                              
                                                                                               }                               
                                                       
                                                       
                                                       if(userIdSet.Size() > 0){                               
                                                           for(PermissionSetAssignment psa : [SELECT Id, PermissionSet.Name,AssigneeId                             
                                                                                              FROM PermissionSetAssignment                             
                                                                                              WHERE AssigneeId IN :userIdSet]){                                
                                                                                                  if(userIdPermissionSetNameMap.containsKey(psa.AssigneeId)){                             
                                                                                                      userIdPermissionSetNameMap.get(psa.AssigneeId).add(psa.PermissionSet.Name);                             
                                                                                                  }                               
                                                                                                  else{                               
                                                                                                      userIdPermissionSetNameMap.put(psa.AssigneeId, new Set<String>{psa.PermissionSet.Name});                                
                                                                                                  }                               
                                                                                              }
                                                           
                                                       } 
                                                       
                                                       
                                                       for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){                                                           
                                                           Set<String> psNameSet = userIdPermissionSetNameMap.get(iupgm.Core_MDF_User_id__c);                              
                                                           
                                                           if(!cpIdCpAccessMap.get(programNameIdMap.get(iupgm.Core_MDF_Program_nm__c))){                               
                                                               iupgm.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_LoggedInUsrHasNoAccessToProgram'));                                
                                                               
                                                           }                               
                                                           
                                                           else if(psNameSet == NULL){                                 
                                                               iupgm.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_UserHasNoPermissionSet'));                              
                                                               
                                                           }                               
                                                           
                                                           else if(!psNameSet.contains(iupgm.Core_MDF_Role_nm__c)){                                
                                                               iupgm.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_UserWithoutAccessToRole'));                             
                                                               
                                                           }                               
                                                           else{                               
                                                               
                                                               iupgm.Core_MDF_Active_Ind__c = TRUE;                                
                                                               iupgm.Core_MDF_Channel_Program_id__c = programNameIdMap.get(iupgm.Core_MDF_Program_nm__c);                              
                                                               
                                                               iupgm.Core_MDF_AccountIdProgramRoleUserId_txt__c = iupgm.Core_MDF_Account_id__c+iupgm.Core_MDF_Program_nm__c+iupgm.Core_MDF_Role_nm__c+iupgm.Core_MDF_User_id__c;                                 
                                                               
                                                               iupgmListToBeUpdated.add(iupgm);                                    
                                                               
                                                           }
                                                           
                                                       }                               
                                                   }
                                                   
                                                   if(iupgmListToBeUpdated.Size() > 0){                                
                                                       for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmListToBeUpdated){                                
                                                           
                                                           if(iupgm.Core_MDF_Region_Sub_Region_nm__c != NULL){                             
                                                               geoSubGeoList = iupgm.Core_MDF_Region_Sub_Region_nm__c.Split(';');                              
                                                               
                                                               geoAndSubGeoWrapper = getAccProgramGeoSubGeo(geoSubGeoList,null,null,null);                                                                                   
                                                               if(geoAndSubGeoWrapper.geo != NULL){                                
                                                                   iupgm.Core_MDF_Region_cd__c = String.join(new List<String>(geoAndSubGeoWrapper.geo), ';');                              
                                                               }                               
                                                               
                                                               if(geoAndSubGeoWrapper.subGeo != NULL){                             
                                                                   iupgm.Core_MDF_Sub_Region_cd__c = String.join(new List<String>(geoAndSubGeoWrapper.subGeo), ';');                               
                                                               }                               
                                                           }                               
                                                       }                               
                                                   }                               
                                               }                               
                                               catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}                              
                                           }                               
    
    
    /*****************************************************************************************************                              
Method Name   :        removeGroupMember                                
@return       :        void                             
@parameters   :        newMap - Trigger.newMap for Core_MDF_Int_Users_Partner_Geo_Mapping__c                                
oldMap - Trigger.oldMap for Core_MDF_Int_Users_Partner_Geo_Mapping__c                                
Description   :        To remove the user from the group if deactivated or Add the user back to group if activated                              
Added By      :        Accenture - VK - 08/20/2019                              
Modified By   :        Date:           Changes:                                 
Accenture - VK         03/10/2019      Update the method to handle geo update on IUPGM                              
******************************************************************************************************/                             
    public static void removeGroupMember(Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c> newMap,                               
                                         Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c> OldMap){                             
                                             
                                             Set<Id> accountIdSet = new Set<Id>();                               
                                             Set<Id> programIdSet = new Set<Id>();                               
                                             Set<Id> groupIdSet = new Set<Id>();                             
                                             Set<String> groupNameSetFromMdt = new Set<String>();                                
                                             Set<Id> userIdSet = new Set<Id>();                                                                          
                                             List<String> geoSubGeoList = new List<String>();                                
                                             List<String> budTypeList = new List<String>();                                                                  
                                             String progKey;                                 
                                             String progGeoSubGeoKey;                                
                                             List<GroupMember> groupMemToBeDeleted = new List<GroupMember>();
                                             List<GroupMember> groupMemToBeDeletedSecRole = new List<GroupMember>();
                                             //List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmListToBeUpdated = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
                                             Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmMapToBeUpdated = new Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
                                             List<String> roUsrRoleLst = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_User_Role_with_Read_Only_Access').split(';');                                                                           
                                             List<String> rwUsrRoleLst = Core_MDF_CCP_ConstantClass.CORE_MDF_USER_ROLE_WITH_READ_WRITE_ACCESS.split(';');
                                                 //Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_User_Role_with_Read_Write_Acces').split(';');                                   
                                             
                                             Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper geoAndSubGeoWrapper = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper(); 
                                             Map<String,Set<Id>> groupToUsersMap =new Map<String,Set<Id>>();                             
                                             Set<Id> userList = new Set<Id>();                               
                                             Set<Id> usrIdforGm = new Set<Id>();                                                                 
                                             Map<Id, String> CpNametpCpID = new Map<Id, String>();                                   
                                             
                                             Map<Id,Set<Id>> accIdToSetOfUserIdMap = new Map<Id,Set<Id>>();                                                                          
                                             Set<Id> usersToBeRemovedFromAccNodeGroupSet = new Set<Id>();                                
                                             
                                             List<String> marketingUserRoles = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Account_Manager_Permission_Sets').Split(',');                                
                                             //List which contain account manager and mystery shopper role                               
                                             List<String> retailUserRoles = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Acnt_Mgr_Permission_Sets').Split(',');                                                                    
                                             Set<Id> userIdSetToCheckMarketingUser = new Set<Id>();                              
                                             Map<String, String> accProgGeoSubGeoBTMap = new Map<String, String>();                                                                  
                                             List<Core_MDF_Bulk_Transaction__e> toBeUpdatedUserList = new List<Core_MDF_Bulk_Transaction__e>();      
                                             Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmNewMap = new Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
                                             Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmOldMap = new Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>();                                     
                                             
                                             try{                                
                                                 populateprogramGeoSubGeoGroupSetMaps();          
                                                 //Avoid using Soql / Sosl queries without filters and limits                   
                                                 Map<Id,ChannelProgram> channelProgramMap = new Map<Id,ChannelProgram>([Select Id,Name, Core_MDF_Technical_Program_Name__c from ChannelProgram LIMIT 5000]);                                
                                                 Map<String, Set<Id>> accProgGeoToUsrMap = new Map<String, Set<Id>>();                               
                                                 String accProgGeoSubGeo;                                
                                                 String oldGeoSubgeo, oldBudgetType; 
                                                 
                                                 
                                                 ExistingIupgmUserGeoBudgetMap iupgmMap = new ExistingIupgmUserGeoBudgetMap();
                                                 iupgmMap =  getGeoBudgetMapForUser(OldMap);
                                                 for(Id iupgmId : newMap.keySet()){                              
                                                     String iupgmProgRoleKey = newMap.get(iupgmId).Core_MDF_Program_nm__c + newMap.get(iupgmId).Core_MDF_Role_nm__c;
                                                     if(progRoleSecondaryCSMap.containsKey(iupgmProgRoleKey)){ 
                                                         iupgmNewMap.put(iupgmId,newMap.get(iupgmId));
                                                         iupgmOldMap.put(iupgmId,oldMap.get(iupgmId));
                                                     }
                                                     else{
                                                         if(progRolePrimaryCSMap.containsKey(iupgmProgRoleKey)){
                                                             iupgmNewMap.put(iupgmId,newMap.get(iupgmId));
                                                             iupgmOldMap.put(iupgmId,oldMap.get(iupgmId));
                                                         }
                                                         isPrimaryIUPGMRole = true;
                                                         if(!retailUserRoles.contains(newMap.get(iupgmId).Core_MDF_Role_nm__c)) {                                
                                                             
                                                             if(STR_No.equals(newMap.get(iupgmId).Core_MDF_All_Accounts_cd__c)){                     
                                                                 
                                                                 
                                                                 List<String> budgetList = new List<String>();
                                                                 budgetList= oldBudgetTypeList;      
                                                                 
                                                                 if(((Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name').equals(oldMap.get(iupgmId).Core_MDF_Program_nm__c) || oldMap.get(iupgmId).Core_MDF_Program_nm__c == Label.Core_MDF_EEF_Program_Name ||
                                                                     oldMap.get(iupgmId).Core_MDF_Program_nm__c == Label.Core_MDF_Co_GTM_Technical_program_name || isCoInvBudgetRole(oldMap.get(iupgmId))) &&
                                                                     oldMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c !=null && oldMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';') != NULL ) ||
                                                                    (/*Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name').equals(oldMap.get(iupgmId).Core_MDF_Program_nm__c) && */
                                                                     ( /*(oldMap.get(iupgmId).Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c!=null && oldMap.get(iupgmId).Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c.split(';') != NULL) ||*/
                                                                      newMap.get(iupgmId).Core_MDF_All_Budget_Type_Access_Ind__c !=  oldMap.get(iupgmId).Core_MDF_All_Budget_Type_Access_Ind__c)) ){  
                                                                          budgetList = new List<String>();
                                                                          
                                                                          if(oldMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c!= null &&
                                                                             oldMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';') !=null){
                                                                                 budgetList = oldMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';');
                                                                             }
                                                                          
                                                                      }
                                                                 if(budgetList != null && !budgetList.isEmpty()){
                                                                     for(String oldGeoSubgeoBT : budgetList){                               
                                                                         
                                                                         accountIdSet.add(newMap.get(iupgmId).Core_MDF_Account_id__c);                               
                                                                         userIdSet.add(newMap.get(iupgmId).Core_MDF_User_id__c);                             
                                                                         programIdSet.add(newMap.get(iupgmId).Core_MDF_Channel_Program_id__c);                                                                   
                                                                         
                                                                         oldGeoSubgeo = oldGeoSubgeoBT.split('->')[0];                               
                                                                         oldBudgetType = oldGeoSubgeoBT.split('->')[1];                              
                                                                         geoSubGeoList.add(oldGeoSubgeo);   
                                                                         
                                                                         
                                                                         if(((newMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c != null && !newMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';').contains(oldGeoSubgeoBT)))  ||                             
                                                                            ((oldMap.get(iupgmId).Core_MDF_Active_Ind__c) && !newMap.get(iupgmId).Core_MDF_Active_Ind__c) || oldBudgetTypeList.contains(oldGeoSubgeoBT)){                              
                                                                                
                                                                                
                                                                                if(iupgmMap.finalIupgmRegionMap.get(newMap.get(iupgmId).Core_MDF_User_id__c) == null || iupgmMap.finalIupgmRegionMap.get(newMap.get(iupgmId).Core_MDF_User_id__c).contains(oldGeoSubgeo)
                                                                                   || iupgmMap.finalIupgmBudMap.get(newMap.get(iupgmId).Core_MDF_User_id__c) == null || iupgmMap.finalIupgmBudMap.get(newMap.get(iupgmId).Core_MDF_User_id__c).contains(oldGeoSubgeoBT)){
                                                                                       accProgGeoSubGeo = (String)newMap.get(iupgmId).Core_MDF_Account_id__c + newMap.get(iupgmId).Core_MDF_Channel_Program_id__c + oldGeoSubgeo + oldBudgetType;                                                                           
                                                                                   }                               
                                                                                
                                                                                accProgGeoSubGeoBTMap.put(accProgGeoSubGeo, oldBudgetType);                                                                                              
                                                                                
                                                                                if(accProgGeoToUsrMap.containsKey(accProgGeoSubGeo) && accProgGeoToUsrMap.get(accProgGeoSubGeo) != NULL){                                
                                                                                    accProgGeoToUsrMap.get(accProgGeoSubGeo).add(newMap.get(iupgmId).Core_MDF_User_id__c);                               
                                                                                }                                
                                                                                else{                                
                                                                                    Set<Id> usrIdSet = new Set<Id>();                                
                                                                                    usrIdSet.add(newMap.get(iupgmId).Core_MDF_User_id__c);                               
                                                                                    accProgGeoToUsrMap.put(accProgGeoSubGeo,usrIdSet);                               
                                                                                }                                
                                                                                
                                                                            }
                                                                     }
                                                                 }
                                                                 
                                                                 if(oldMap.get(iupgmId).Core_MDF_Region_Sub_Region_nm__c !=null && oldMap.get(iupgmId).Core_MDF_Region_Sub_Region_nm__c.split(';') != NULL){                              
                                                                     
                                                                     
                                                                     for(String geoSubGeo : oldMap.get(iupgmId).Core_MDF_Region_Sub_Region_nm__c.split(';')){                                                                   
                                                                         accountIdSet.add(newMap.get(iupgmId).Core_MDF_Account_id__c);                              
                                                                         userIdSet.add(newMap.get(iupgmId).Core_MDF_User_id__c);                                
                                                                         programIdSet.add(newMap.get(iupgmId).Core_MDF_Channel_Program_id__c);                              
                                                                         geoSubGeoList.add(geoSubGeo);                              
                                                                         
                                                                         
                                                                         if((newMap.get(iupgmId).Core_MDF_Region_Sub_Region_nm__c != null && !newMap.get(iupgmId).Core_MDF_Region_Sub_Region_nm__c.contains(geoSubGeo)) ||                                
                                                                            ((oldMap.get(iupgmId).Core_MDF_Active_Ind__c) && !newMap.get(iupgmId).Core_MDF_Active_Ind__c) ||
                                                                            (oldMap.get(iupgmId).Core_MDF_All_Budget_Type_Access_Ind__c != newMap.get(iupgmId).Core_MDF_All_Budget_Type_Access_Ind__c)){                                 
                                                                                
                                                                                
                                                                                if(iupgmMap.finalIupgmRegionMap.get(newMap.get(iupgmId).Core_MDF_User_id__c) == null
                                                                                   /*|| iupgmMap.finalIupgmRegionMap.get(newMap.get(iupgmId).Core_MDF_User_id__c).isEmpty()*/
                                                                                   || iupgmMap.finalIupgmRegionMap.get(newMap.get(iupgmId).Core_MDF_User_id__c).contains(geoSubGeo)){                              
                                                                                       accProgGeoSubGeo = (String)newMap.get(iupgmId).Core_MDF_Account_id__c + newMap.get(iupgmId).Core_MDF_Channel_Program_id__c + geoSubGeo;                             
                                                                                       
                                                                                   }            
                                                                                if(accProgGeoToUsrMap.containsKey(accProgGeoSubGeo) && accProgGeoToUsrMap.get(accProgGeoSubGeo) != NULL){                               
                                                                                    accProgGeoToUsrMap.get(accProgGeoSubGeo).add(newMap.get(iupgmId).Core_MDF_User_id__c);                              
                                                                                }                               
                                                                                else{                               
                                                                                    Set<Id> usrIdSet = new Set<Id>();                               
                                                                                    usrIdSet.add(newMap.get(iupgmId).Core_MDF_User_id__c);                              
                                                                                    accProgGeoToUsrMap.put(accProgGeoSubGeo,usrIdSet);                              
                                                                                }                               
                                                                                
                                                                            } 
                                                                     }
                                                                 }
                                                                 
                                                                 
                                                             }
                                                             
                                                             //Preparing key to get the RO/RW Group Id and User Id from RO/RW Group                              
                                                             else if(STR_Yes.equals(newMap.get(iupgmId).Core_MDF_All_Accounts_cd__c)){                                                           
                                                                 String usrRole = newMap.get(iupgmId).Core_MDF_Role_nm__c;                                  
                                                                 String localKey ='';                               
                                                                 List<String> budgetList = new List<String>();                           
                                                                 
                                                                 if((Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name').equals(oldMap.get(iupgmId).Core_MDF_Program_nm__c) &&                               
                                                                     Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_BudgetTypeRoles').contains(oldMap.get(iupgmId).Core_MDF_Role_nm__c) &&                                 
                                                                     oldMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c !=null &&
                                                                     oldMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';') != NULL) || 
                                                                  /*  (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name').equals(oldMap.get(iupgmId).Core_MDF_Program_nm__c) &&                                
                                                                     oldMap.get(iupgmId).Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c.split(';') != NULL) ||*/
                                                                    (oldMap.get(iupgmId).Core_MDF_Program_nm__c == Label.Core_MDF_EEF_Program_Name && oldMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c !=null &&
                                                                     oldMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';') != NULL) ||
                                                                     (oldMap.get(iupgmId).Core_MDF_Program_nm__c == Label.Core_MDF_Co_GTM_Technical_program_name && oldMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c !=null &&
                                                                     oldMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';') != NULL) ||
                                                                    (isCoInvBudgetRole(oldMap.get(iupgmId)) &&
                                                                     oldMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c != null)
                                                                   ) {                  //For IPA Prog Adm, L1, L2, RO          
                                                                         if(oldMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c!= null && oldMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';') !=null){
                                                                             budgetList = oldMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';');
                                                                         }
                                                                         String oldGS, oldBT; 
                                                                         if(budgetList != null && !budgetList.isEmpty()){                                 
                                                                             for(String oldGeoSubGeobudtype : budgetList){                              
                                                                                 
                                                                                 oldGS = oldGeoSubGeobudtype.split('->')[0];                             
                                                                                 oldBT = oldGeoSubGeobudtype.split('->')[1];                                 
                                                                                 
                                                                                 if((newMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c != null && !newMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c.contains(oldGeoSubGeobudtype)) ||                               
                                                                                    ((oldMap.get(iupgmId).Core_MDF_Active_Ind__c) && !newMap.get(iupgmId).Core_MDF_Active_Ind__c) ||
                                                                                    (oldMap.get(iupgmId).Core_MDF_All_Budget_Type_Access_Ind__c != newMap.get(iupgmId).Core_MDF_All_Budget_Type_Access_Ind__c)){                          
                                                                                        
                                                                                        if(iupgmMap.finalIupgmRegionMap.get(newMap.get(iupgmId).Core_MDF_User_id__c) == null || iupgmMap.finalIupgmRegionMap.get(newMap.get(iupgmId).Core_MDF_User_id__c).contains(oldGS)
                                                                                           || iupgmMap.finalIupgmBudMap.get(newMap.get(iupgmId).Core_MDF_User_id__c) == null || iupgmMap.finalIupgmBudMap.get(newMap.get(iupgmId).Core_MDF_User_id__c).contains(oldGeoSubGeobudtype)){
                                                                                               localKey = channelProgramMap.get(newMap.get(iupgmId).Core_MDF_Channel_Program_id__c).Name + oldGS + oldBT;                               
                                                                                               
                                                                                           }                                                     
                                                                                        
                                                                                        if(roUsrRoleLst.contains(usrRole)){                              
                                                                                            if(programGeoSubGeoROGroupSetMap != NULL && !programGeoSubGeoROGroupSetMap.isEmpty() && programGeoSubGeoROGroupSetMap.containsKey(localKey) && programGeoSubGeoROGroupSetMap.get(localKey) != NULL){                             
                                                                                                if(groupToUsersMap.containsKey(programGeoSubGeoROGroupSetMap.get(localKey))){                                
                                                                                                    groupToUsersMap.get(programGeoSubGeoROGroupSetMap.get(localKey)).add(oldmap.get(iupgmid).Core_MDF_User_id__c);                               
                                                                                                    usrIdforGm.addAll(groupToUsersMap.get(programGeoSubGeoROGroupSetMap.get(localKey)));                             
                                                                                                }                                
                                                                                                else{                                
                                                                                                    groupToUsersMap.put(programGeoSubGeoROGroupSetMap.get(localKey), new Set<Id>{oldmap.get(iupgmid).Core_MDF_User_id__c});                              
                                                                                                    usrIdforGm.addAll(groupToUsersMap.get(programGeoSubGeoROGroupSetMap.get(localKey)));                             
                                                                                                }                                
                                                                                            }                                
                                                                                        }
                                                                                        if(rwUsrRoleLst.contains(usrRole)){                                 
                                                                                            if(programGeoSubGeoRWGroupSetMap != NULL && !programGeoSubGeoRWGroupSetMap.isEmpty() && programGeoSubGeoRWGroupSetMap.containsKey(localKey) && programGeoSubGeoRWGroupSetMap.get(localKey) != NULL){                                 
                                                                                                if(groupToUsersMap.containsKey(programGeoSubGeoRWGroupSetMap.get(localKey))){                                
                                                                                                    groupToUsersMap.get(programGeoSubGeoRWGroupSetMap.get(localKey)).add(oldmap.get(iupgmid).Core_MDF_User_id__c);                               
                                                                                                    usrIdforGm.addAll(groupToUsersMap.get(programGeoSubGeoRWGroupSetMap.get(localKey)));                             
                                                                                                }                                
                                                                                                else{                                
                                                                                                    groupToUsersMap.put(programGeoSubGeoRWGroupSetMap.get(localKey), new Set<Id>{oldmap.get(iupgmid).Core_MDF_User_id__c});                              
                                                                                                    usrIdforGm.addAll(groupToUsersMap.get(programGeoSubGeoRWGroupSetMap.get(localKey)));                             
                                                                                                }                                
                                                                                            }                                                                
                                                                                        }
                                                                                    }
                                                                             }
                                                                         }                                  
                                                                     }
                                                                 else{                       
                                                                     
                                                                     if(oldMap.get(iupgmId).Core_MDF_Region_Sub_Region_nm__c!=null && oldMap.get(iupgmId).Core_MDF_Region_Sub_Region_nm__c.split(';') != NULL) {                               
                                                                         
                                                                         for(String geoSubGeo : oldMap.get(iupgmId).Core_MDF_Region_Sub_Region_nm__c.split(';')){                             
                                                                             
                                                                             if((newMap.get(iupgmId).Core_MDF_Region_Sub_Region_nm__c != null && !newMap.get(iupgmId).Core_MDF_Region_Sub_Region_nm__c.contains(geoSubGeo)) ||                              
                                                                                (oldMap.get(iupgmId).Core_MDF_Active_Ind__c) && !newMap.get(iupgmId).Core_MDF_Active_Ind__c ||
                                                                                (oldMap.get(iupgmId).Core_MDF_All_Budget_Type_Access_Ind__c != newMap.get(iupgmId).Core_MDF_All_Budget_Type_Access_Ind__c)){                                 
                                                                                    
                                                                                    if(iupgmMap.finalIupgmRegionMap.get(newMap.get(iupgmId).Core_MDF_User_id__c) == null || iupgmMap.finalIupgmRegionMap.get(newMap.get(iupgmId).Core_MDF_User_id__c).contains(geoSubGeo))
                                                                                    {
                                                                                        if(geoSubGeo == 'WW'){                                
                                                                                            localKey = channelProgramMap.get(newMap.get(iupgmId).Core_MDF_Channel_Program_id__c).Name;                                
                                                                                        }else{                                
                                                                                            localKey = channelProgramMap.get(newMap.get(iupgmId).Core_MDF_Channel_Program_id__c).Name + geoSubGeo;                                
                                                                                            
                                                                                        } 
                                                                                    }                                                                        
                                                                                    if(roUsrRoleLst.contains(usrRole)){                               
                                                                                        if(programGeoSubGeoROGroupSetMap != NULL && !programGeoSubGeoROGroupSetMap.isEmpty() && programGeoSubGeoROGroupSetMap.containsKey(localKey) && programGeoSubGeoROGroupSetMap.get(localKey) != NULL){                              
                                                                                            if(groupToUsersMap.containsKey(programGeoSubGeoROGroupSetMap.get(localKey))){                             
                                                                                                groupToUsersMap.get(programGeoSubGeoROGroupSetMap.get(localKey)).add(oldmap.get(iupgmid).Core_MDF_User_id__c);                                
                                                                                                usrIdforGm.addAll(groupToUsersMap.get(programGeoSubGeoROGroupSetMap.get(localKey)));                              
                                                                                            }                             
                                                                                            else{                             
                                                                                                groupToUsersMap.put(programGeoSubGeoROGroupSetMap.get(localKey), new Set<Id>{oldmap.get(iupgmid).Core_MDF_User_id__c});                               
                                                                                                usrIdforGm.addAll(groupToUsersMap.get(programGeoSubGeoROGroupSetMap.get(localKey)));                              
                                                                                            }                             
                                                                                        }                             
                                                                                    }                                    
                                                                                    else if(rwUsrRoleLst.contains(usrRole)){                              
                                                                                        
                                                                                        
                                                                                        if(programGeoSubGeoRWGroupSetMap != NULL && !programGeoSubGeoRWGroupSetMap.isEmpty() && programGeoSubGeoRWGroupSetMap.containsKey(localKey) && programGeoSubGeoRWGroupSetMap.get(localKey) != NULL){                                  
                                                                                            if(groupToUsersMap.containsKey(programGeoSubGeoRWGroupSetMap.get(localKey))){                             
                                                                                                groupToUsersMap.get(programGeoSubGeoRWGroupSetMap.get(localKey)).add(oldmap.get(iupgmid).Core_MDF_User_id__c);                                
                                                                                                usrIdforGm.addAll(groupToUsersMap.get(programGeoSubGeoRWGroupSetMap.get(localKey)));                              
                                                                                            }                             
                                                                                            else{                             
                                                                                                groupToUsersMap.put(programGeoSubGeoRWGroupSetMap.get(localKey), new Set<Id>{oldmap.get(iupgmid).Core_MDF_User_id__c});                               
                                                                                                usrIdforGm.addAll(groupToUsersMap.get(programGeoSubGeoRWGroupSetMap.get(localKey)));                              
                                                                                            }                             
                                                                                        }                                                                 
                                                                                    }
                                                                                    
                                                                                    
                                                                                }
                                                                             
                                                                         }
                                                                     }
                                                                 }
                                                             }
                                                         }
                                                         
                                                         if(!newMap.get(iupgmId).Core_MDF_Active_Ind__c){                                
                                                             if(accIdToSetOfUserIdMap.containsKey(newMap.get(iupgmId).Core_MDF_Account_Id__c)){                              
                                                                 accIdToSetOfUserIdMap.get(newMap.get(iupgmId).Core_MDF_Account_Id__c).add(newMap.get(iupgmid).Core_MDF_User_id__c);                             
                                                             }else{                              
                                                                 accIdToSetOfUserIdMap.put(newMap.get(iupgmId).Core_MDF_Account_Id__c, new Set<Id>{newMap.get(iupgmid).Core_MDF_User_id__c});                                
                                                             }                               
                                                             usersToBeRemovedFromAccNodeGroupSet.add(newMap.get(iupgmid).Core_MDF_User_id__c);                               
                                                         }                               
                                                         
                                                         
                                                         
                                                         if((newMap.get(iupgmId).Core_MDF_Active_Ind__c == TRUE && oldMap.get(iupgmId).Core_MDF_Active_Ind__c == FALSE) ||                               
                                                            ((((newMap.get(iupgmId).Core_MDF_Region_Sub_Region_nm__c != oldMap.get(iupgmId).Core_MDF_Region_Sub_Region_nm__c &&                              
                                                                oldMap.get(iupgmId).Core_MDF_Budget_Type_nm__c == NULL)) ||                              
                                                              (newMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c != oldMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c &&                               
                                                               oldMap.get(iupgmId).Core_MDF_GeoSubGeo_Budget_Type_nm__c != NULL))  ||
                                                             (oldMap.get(iupgmId).Core_MDF_All_Budget_Type_Access_Ind__c != newMap.get(iupgmId).Core_MDF_All_Budget_Type_Access_Ind__c)) && 
                                                            newMap.get(iupgmId).Core_MDF_Active_Ind__c == TRUE)
                                                         {                                            
                                                               //iupgmListToBeUpdated.add(newMap.get(iupgmId)); 
                                                               iupgmMapToBeUpdated.put(iupgmId,newMap.get(iupgmId));                             
                                                         }                               
                                                         
                                                         
                                                         if(newMap.get(iupgmId).Core_MDF_Active_Ind__c == FALSE &&                               
                                                            marketingUserRoles.contains(newMap.get(iupgmId).Core_MDF_Role_nm__c)){                               
                                                                userIdSetToCheckMarketingUser.add(newMap.get(iupgmId).Core_MDF_User_id__c);                              
                                                            }
                                                     }
                                                 }                               
                                                 if(!iupgmNewMap.isEmpty() && !iupgmOldMap.isEmpty()){
                                                     groupMemToBeDeletedSecRole = removeRoleSpecificIUPGMGroupMember(iupgmNewMap,iupgmOldMap); 
                                                 }
                                                 
                                                 if(groupMemToBeDeletedSecRole.size()>0)
                                                 {
                                                     groupMemToBeDeleted.addAll(groupMemToBeDeletedSecRole);
                                                 }//Adding secondary role removal group members
                                                 
                                                 if(isPrimaryIUPGMRole){                                
                                                     Boolean removeMarketingUserCheck = FALSE;                               
                                                     if(mapFunctionalityNameTriggerExecution.containsKey('marketingUserPermissionRemoval') &&                                
                                                        mapFunctionalityNameTriggerExecution.get('marketingUserPermissionRemoval').Core_Active__c){                              
                                                            removeMarketingUserCheck = TRUE;                                
                                                        }                               
                                                     
                                                     //Check if there are any active IUPGM for the users with Acc Manager or IPA approvers roles before removing marketing user permission                               
                                                     if(removeMarketingUserCheck && userIdSetToCheckMarketingUser != NULL && userIdSetToCheckMarketingUser.Size() > 0){                              
                                                         for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Id, Core_MDF_Program_nm__c, Core_MDF_Role_nm__c, Core_MDF_Active_Ind__c,                                                                                                      
                                                                                                                Core_MDF_User_id__c, Core_MDF_User_id__r.UserPermissionsMarketingUser                                                                                                    
                                                                                                                FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c                               
                                                                                                                WHERE Core_MDF_User_id__c IN: userIdSetToCheckMarketingUser AND                              
                                                                                                                Core_MDF_Role_nm__c IN: marketingUserRoles AND                               
                                                                                                                Core_MDF_Active_Ind__c = TRUE]){                             
                                                                                                                    if(userIdSetToCheckMarketingUser.contains(iupgm.Core_MDF_User_id__c)){                              
                                                                                                                        userIdSetToCheckMarketingUser.remove(iupgm.Core_MDF_User_id__c);                                
                                                                                                                    }                                                                                   
                                                                                                                }                               
                                                          
                                                     }                               
                                                     
                                                     List<User> userSetForMarketingUserCheckRemoval = new List<User>();                                          
                                                     
                                                     if(removeMarketingUserCheck && userIdSetToCheckMarketingUser != NULL && userIdSetToCheckMarketingUser.Size() > 0){                              
                                                         for(Id userId : userIdSetToCheckMarketingUser){
                                                             User userInstance = new User();                             
                                                             userInstance.Id = userId;                               
                                                             userInstance.UserPermissionsMarketingUser = FALSE;
                                                             Core_MDF_Bulk_Transaction__e evtObj = new Core_MDF_Bulk_Transaction__e();
                                                             evtObj.Core_MDF_JSON_Data__c = JSON.serialize(userInstance); 
                                                             evtObj.Core_MDF_Object_Name__c = 'User';
                                                             toBeUpdatedUserList.add(evtObj);  
                                                         }
                                                     }                                           
                                                     
                                                     
                                                     Map<Id,Id> accGroupIdToAccIdMap = new Map<Id,Id>();                             
                                                     if(accIdToSetOfUserIdMap != NULL && accIdToSetOfUserIdMap.size() > 0){                              
                                                         for(Account acc : [SELECT Id, Core_MDF_Group_Id__c FROM Account WHERE Id IN : accIdToSetOfUserIdMap.keySet()]){                             
                                                             accGroupIdToAccIdMap.put(acc.Core_MDF_Group_Id__c,acc.Id);                              
                                                         }                               
                                                     }                               
                                                     
                                                     
                                                     geoAndSubGeoWrapper = getAccProgramGeoSubGeo(geoSubGeoList,null,null,null);                             
                                                     Map<String, Set<Id>> pgmGroupToUserMap = new Map<String, Set<Id>>();                                
                                                     
                                                     if(accountIdSet.Size() > 0 && programIdSet.Size() > 0){                             
                                                         for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Core_MDF_Account__c, Core_MDF_Channel_Program__c, Core_MDF_Group_id__c,                                 
                                                                                                      Core_MDF_Region_cd__c,Core_MDF_Sub_Region_cd__c, Core_MDF_BudgetType_nm__c                                                                                            
                                                                                                      FROM Core_MDF_Partner_Group_Mapping__c                             
                                                                                                      WHERE Core_MDF_Account__c IN : accountIdSet AND                                
                                                                                                      Core_MDF_Channel_Program__c IN : programIdSet AND                              
                                                                                                      Core_MDF_Type_Of_Access__c = 'Internal' AND                                
                                                                                                      Core_MDF_Region_cd__c IN : geoAndSubGeoWrapper.geo]){                                                                                                      
                                                                                                          String accPGS;                                                                                              
                                                                                                          if(pgm.Core_MDF_Region_cd__c != NULL){     
                                                                                                              if(pgm.Core_MDF_BudgetType_nm__c != NULL){                                
                                                                                                                  accPGS = (String)pgm.Core_MDF_Account__c + pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c +'-'+ pgm.Core_MDF_Sub_Region_cd__c + pgm.Core_MDF_BudgetType_nm__c;                               
                                                                                                                  if(accPGS.contains('-null')){                               
                                                                                                                      accPGS = accPGS.remove('-null');                                
                                                                                                                  }                               
                                                                                                              } 
                                                                                                              else {                                
                                                                                                                  
                                                                                                                  accPGS = (String)pgm.Core_MDF_Account__c + pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c +'-'+ pgm.Core_MDF_Sub_Region_cd__c;                                                                                                    
                                                                                                                  if(accPGS.endsWith('-null')){                               
                                                                                                                      accPGS = accPGS.removeEnd('-null');                             
                                                                                                                  }                               
                                                                                                              }                               
                                                                                                          }                                                                           
                                                                                                          if(accProgGeoToUsrMap.containsKey(accPGS) && accProgGeoToUsrMap.get(accPGS) != NULL){                               
                                                                                                              pgmGroupToUserMap.put(pgm.Core_MDF_Group_id__c, accProgGeoToUsrMap.get(accPGS));                               
                                                                                                          }                               
                                                                                                      }                               
                                                     }
                                                     
                                                     if((pgmGroupToUserMap.size() > 0  && userIdSet.size() > 0 ) || (groupToUsersMap.size() > 0 && usrIdforGm.size() > 0) ||                             
                                                        (accGroupIdToAccIdMap.size() > 0  && usersToBeRemovedFromAccNodeGroupSet.size() > 0)){                                           
                                                            for(GroupMember gm : [SELECT Id, GroupId, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE                                                                     
                                                                                  (GroupId IN: pgmGroupToUserMap.keySet() AND UserOrGroupId IN: userIdSet) OR                               
                                                                                  (GroupId IN:groupToUsersMap.keySet() AND UserOrGroupId IN: usrIdforGm) OR                                 
                                                                                  (GroupId IN: accGroupIdToAccIdMap.keySet() AND UserOrGroupId IN: usersToBeRemovedFromAccNodeGroupSet)]){
                                                                                      
                                                                                      if(groupToUsersMap.containsKey(gm.GroupId) && groupToUsersMap.get(gm.GroupId) != NULL &&                                
                                                                                         groupToUsersMap.get(gm.GroupId).contains(gm.UserOrGroupId)){                             
                                                                                             groupMemToBeDeleted.add(gm);                                
                                                                                         }                               
                                                                                      else if(pgmGroupToUserMap.containsKey(gm.GroupId) && pgmGroupToUserMap.get(gm.GroupId) != NULL &&                               
                                                                                              pgmGroupToUserMap.get(gm.GroupId).contains(gm.UserOrGroupId)){                              
                                                                                                  groupMemToBeDeleted.add(gm);                                
                                                                                              }                               
                                                                                      else if(accGroupIdToAccIdMap.containsKey(gm.GroupId) && accGroupIdToAccIdMap.get(gm.GroupId) != NULL &&                                 
                                                                                              accIdToSetOfUserIdMap.containsKey(accGroupIdToAccIdMap.get(gm.GroupId)) &&                              
                                                                                              accIdToSetOfUserIdMap.get(accGroupIdToAccIdMap.get(gm.GroupId)) != NULL &&                              
                                                                                              accIdToSetOfUserIdMap.get(accGroupIdToAccIdMap.get(gm.GroupId)).contains(gm.UserOrGroupId)){                                
                                                                                                  groupMemToBeDeleted.add(gm);                                
                                                                                              }                               
                                                                                  }                               
                                                        }    
                                                 }
                                                 if(groupMemToBeDeleted.size() > 0){                             
                                                     if(System.isFuture() || System.isBatch()){                                                  
                                                         System.enqueueJob(new Core_MDF_DeleteGroupMember(groupMemToBeDeleted,toBeUpdatedUserList));                                 
                                                     }else{                              
                                                         String gmJson = JSON.serialize(groupMemToBeDeleted);                                
                                                         Core_MDF_IUPGM_ServiceHandler.deleteGroupMember(gmJson);                                
                                                         if(toBeUpdatedUserList != NULL && !toBeUpdatedUserList.isEmpty()){                              
                                                             List<Database.SaveResult> results = EventBus.publish(toBeUpdatedUserList);
                                                             for (Database.SaveResult sr : results) {
                                                                 if (sr.isSuccess()) {
                                                                     
                                                                 } 
                                                                 else { 
                                                                     for(Database.Error err : sr.getErrors()) { 
                                                                         
                                                                     }
                                                                 }
                                                             }  
                                                         }  
                                                     }                               
                                                 }                               
                                                 
                                                 
                                                 if(!iupgmMapToBeUpdated.isEmpty() && iupgmMapToBeUpdated != null){ 
                                                     Core_MDF_IUPGM_ServiceHandler.checkPGM(iupgmMapToBeUpdated);                               
                                                 }                               
                                                 
                                             }                               
                                             catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}                              
                                         }                                   
    
    /*****************************************************************************************************                              
Method Name   :        deleteGroupMember                                
@return       :        void                             
@parameters   :        String jsonString which has GroupMember records to be deleted                                
Description   :        To delete the GroupMember records                                
Added By      :        Accenture - VK - 08/20/2019                              
Modified By   :        Date:       Changes:                                 
******************************************************************************************************/                             
    @future                                 
    public static void deleteGroupMember(String jsonString){                                
        try{                                
            List<GroupMember> gmListToBeDeleted = (List<GroupMember>)JSON.deserialize(jsonString,List<GroupMember>.class);                              
            Database.delete(gmListToBeDeleted);                             
        }                              
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}                              
    }                               
    
    /*****************************************************************************************************                              
Class Name    :        geoSubGeoWrapper                             
Description   :        Wrapper with geoSet,subGeoSet,groupName and groupDeveloperName                               
Added By      :        Accenture - VK - 10/24/2019                              
Modified By   :        Date:       Changes:                                 
******************************************************************************************************/                             
    public class GeoSubGeoWrapper{                              
        //Preparing set of geo and sub geo which will be used in PGM query of removeGroupMember method                              
        //The same set is used in checkUserPermission and checkPGM method where the set is converted to a string to update iupgm's and pgm's geo and sub geo field                              
        Set<String> geo;                                
        Set<String> subGeo;                             
        //The strings groupName and groupDeveloperName is used in checkPGM method                               
        String groupName;                               
        String groupDeveloperName;                              
    }                               
    
    /*****************************************************************************************************                              
Method Name   :        getAccProgramGeoSubGeo                               
@return       :        geoSubGeoWrapper                             
@parameters   :        List of String with geo-Sub Geo, account name and program name                               
Description   :        To split the geo and sub geo values                              
Added By      :        Accenture - VK - 10/24/2019                              
Modified By   :        Date:       Changes:                                 
******************************************************************************************************/                             
    public static geoSubGeoWrapper getAccProgramGeoSubGeo(List<String> geoSubGeoStringList, String accountName, String programName, String budgetType){                             
        
        String geo;                                 
        String subGeo;                              
        Set<String> geoSet = new Set<String>();                             
        Set<String> subGeoSet = new Set<String>();                              
        String groupName;                               
        String groupDeveloperName;                              
        Integer initalGroupDeveloperName;                               
        Integer accountNameLength;                              
        String budType;                             
        
        
        for(String geoSubGeo : geoSubGeoStringList){                                
            if(geoSubGeo.Split('-').Size() >= 2 && !geoSubGeo.endsWith('-*')){                              
                geo = geoSubGeo.Split('-')[0];                              
                subGeo = geoSubGeo.Split('-')[1];                               
            }                               
            else{                               
                geo = geoSubGeo.Split('-')[0];                              
            }                               
            
            if(geo != NULL){                                
                geoSet.add(geo);                                
            }                                           
            if(subGeo != NULL){subGeoSet.add(subGeo);}                                          
        }                                       
        
        if(accountName != NULL && programName != NULL){                             
            
            if(String.isEmpty(budgetType)){                               
                if(!subGeoSet.isEmpty()){                                 
                    groupDeveloperName = STR_MDF +accountName+'_'+ programName+'_'+subGeo+ '_' +STR_int;                                  
                    groupName = STR_ccp+accountName+ ' ' + programName + ' ' + geo + subGeo + ' ' + STR_int;                                                                           
                }                             
                else if(subGeoSet.isEmpty()){                             
                    groupDeveloperName = STR_MDF +accountName+'_'+ programName+'_'+Geo+ '_' +STR_int;                
                    groupName = STR_ccp+accountName+ ' ' + programName + ' ' + geo + ' ' +STR_int;                                
                    
                }                             
            }                             
            if(String.isNotBlank(budgetType)){
                String budgetTypeLabel='';
                if( budgetType == '_ALL'){                  
                    budgetType = '_';
                    budgetTypeLabel = ' ';
                }
                else{
                    string pgmName =channelProgramAbbreviationToNameMap.get(programName);
                    String subGeoStr = String.isNotBlank(subGeo)? '-'+subGeo : '';
                    String progGeoSubGeoKey = pgmName + geo + subGeoStr + budgetType ;
                    
                    if(programGeoSubGeoBudgetMap.containsKey(progGeoSubGeoKey)){
                        budgetType =  programGeoSubGeoBudgetMap.get(progGeoSubGeoKey).Core_MDF_Budget_Type_Abbr_txt__c;
                        budgetType = budgetType.length() > 6 ? budgetType.SubString(0,6):budgetType;
                        budgetTypeLabel = ' ' + budgetType + ' ';
                        budgetType = '_' + budgetType + '_';
                        
                    }
                    
                }
                
                if(!subGeoSet.isEmpty()){                                 
                    groupDeveloperName = STR_MDF +accountName+'_'+ programName+'_'+subGeo+ budgetType +STR_int;                                  
                    
                    groupName = STR_ccp+accountName+ ' ' + programName + ' ' + subGeo + budgetTypeLabel + STR_int;                              
                    
                }                             
                else if(subGeoSet.isEmpty()){                             
                    groupDeveloperName = STR_MDF + accountName + '_' + programName + '_'+ geo  +budgetType + STR_int;                                 
                    groupName = STR_ccp+accountName+ ' ' + programName + ' ' + geo  + budgetTypeLabel + STR_int;                                
                    
                }  
            }               
            
        }                               
        
        geoSubGeoWrapper wrapper = new geoSubGeoWrapper();                              
        wrapper.geo = geoSet;                               
        wrapper.SubGeo = subGeoSet;                             
        wrapper.groupDeveloperName = groupDeveloperName;                                
        wrapper.groupName = groupName;                              
        return wrapper;                                 
    }                               
    
    
    //Method queries the custom metadata for all the CCP Master group names and creates a map with key: Channel Program ; value: Master group name                              
    public static void queryMetadataForMasterGroup(){                               
        try{                                
            Map<string,ID> groupNameToGroupIdMap = new Map<string,ID>();                                
            Map<string,string> channelProgramToMasterGroupName = new Map<string,string>();                              
            List<string> groupNames=new List<string>();                             
            //Avoid using Soql / Sosl queries without filters and limits
            for(Core_MDF_ObjRecType_Budget_FieldSetMap__mdt  record: [select Core_MDF_Channel_Program_txt__c,Core_MDF_Internal_Master_Group_Name_Txt__c                                
                                                                   from Core_MDF_ObjRecType_Budget_FieldSetMap__mdt  LIMIT 5000]){                                
                                                                       string key = record.Core_MDF_Channel_Program_txt__c;                                
                                                                       channelProgramToMasterGroupName.put(key,record.Core_MDF_Internal_Master_Group_Name_Txt__c);                                 
                                                                       
                                                                       groupNames.add(record.Core_MDF_Internal_Master_Group_Name_Txt__c);                                                                          
                                                                   }                               
            for(Group record: [select DeveloperName,id from group where DeveloperName in : groupNames]){                                
                groupNameToGroupIdMap.put(record.DeveloperName,record.id);                              
            }                               
            for(string channelProgram:channelProgramToMasterGroupName.keyset()){                                
                channelProgramToMasterGroupId.put(channelProgram,groupNameToGroupIdMap.get(channelProgramToMasterGroupName.get(channelProgram)));                                  
            }                               
            
        }                               
        
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}                                
    }                               
    /*@Method Name     : getProfileName
@Input parameter : Set<Id> userIds
@Return          : Return the Map of user id and profileName
#Descrption      : This is used to get Profile Name from user Id 
*/
    public static Map<Id,String> getProfileName(Set<Id> userIds){
        Map<id,String> resultMap = new Map<Id,String>();
        
        if(userIds !=null && !userIds.isEmpty()){
            for(User usrObj: [SELECT Id,Profile.Name FROM User WHERE Id IN: userIds]){                  
                resultMap.put(usrObj.Id,usrObj.Profile.Name);
            }           
        }
        return resultMap;
    } 
    /* @Method Name      : restrictDeletion
@Input parameter : Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c>
@Return          : NA
#Descrption      : This is used to restrict the deletion of IUPGM
*/
    public static void restrictDeletion(Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c> oldMap){ 
        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmObj: oldMap.values() ){           
            iupgmObj.addError('Record is not allow to delete. Please deactivate the record.');
        }
    }
    
    /*****************************************************************************************************                              
Method Name   :        getGeoBudgetMapForUser                               
@return       :        ExistingIupgmUserGeoBudgetMap Wrapper class                              
@parameters   :        oldMap - Trigger.oldMap for Core_MDF_Int_Users_Partner_Geo_Mapping__c                                                                                         
Description   :        //TWC702-1760: [KIIT]: IUPGM Changes and Testing                             
Added By      :        Accenture - Sai - 25/03/2022                            
Modified By   :        Date:           Changes:                                                             
******************************************************************************************************/
    public static ExistingIupgmUserGeoBudgetMap getGeoBudgetMapForUser(Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c> oldMap){
        Set<Id> iupgmAccIdSet = new Set<Id>();
        Set<Id> iupgmProgIdSet = new Set<Id>();
        Set<String> existingIupgmGeoSet = new Set<String>();
        Set<String> newIupgmGeoSet = new Set<String>();
        Map<Id, Set<String>> newIupgmUserIdRegionMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> finalUserGeoMap = new Map<Id, Set<String>>();
        Set<String> existingIupgmGeoBudgSet = new Set<String>();
        Set<String> newIupgmGeoBudgSet = new Set<String>();
        Map<Id, Set<String>> newIupgmUserIdRegionBudgMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> finalUserGeoBudgMap = new Map<Id, Set<String>>();
        ExistingIupgmUserGeoBudgetMap iupgmMap = new ExistingIupgmUserGeoBudgetMap();
        Set<String> iupgmWithAllAccountYes = new Set<String>();
        
        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : oldMap.Values()){
            iupgmProgIdSet.add(iupgm.Core_MDF_Channel_Program_id__c);
            if(newIupgmUserIdRegionMap.containsKey(iupgm.Core_MDF_User_id__c)){
                if(iupgm.Core_MDF_Region_Sub_Region_nm__c != null && iupgm.Core_MDF_Region_Sub_Region_nm__c.split(';') != null){
                    newIupgmUserIdRegionMap.get(iupgm.Core_MDF_User_id__c).addAll(iupgm.Core_MDF_Region_Sub_Region_nm__c.split(';'));
                }   
            }
            else{
                if(iupgm.Core_MDF_Region_Sub_Region_nm__c != null && iupgm.Core_MDF_Region_Sub_Region_nm__c.split(';') != null){
                    newIupgmUserIdRegionMap.put(iupgm.Core_MDF_User_id__c, new Set<String>(iupgm.Core_MDF_Region_Sub_Region_nm__c.split(';')));
                }    
            }
            if(newIupgmUserIdRegionBudgMap.containsKey(iupgm.Core_MDF_User_id__c)){
                if(iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c != null && iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';') != null){
                    newIupgmUserIdRegionBudgMap.get(iupgm.Core_MDF_User_id__c).addAll(iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';'));
                }   
            }
            else{
                if(iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c != null && iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';') != null){
                    newIupgmUserIdRegionBudgMap.put(iupgm.Core_MDF_User_id__c, new Set<String>(iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';')));
                }
            }
            if(iupgm.Core_MDF_All_Accounts_cd__c == 'No'){
                iupgmAccIdSet.add(iupgm.Core_MDF_Account_id__c);
                
            }
            else if(iupgm.Core_MDF_All_Accounts_cd__c == 'Yes'){
                iupgmWithAllAccountYes.add(iupgm.id);
            }
        }
        
        if(iupgmAccIdSet!=null)
        {
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmRec : [SELECT Id, Core_MDF_Program_nm__c, Core_MDF_Channel_Program_id__c, Core_MDF_Account_id__c, Core_MDF_User_id__c,
                                                                      Core_MDF_Role_nm__c, Core_MDF_Active_Ind__c, Core_MDF_Region_cd__c, Core_MDF_Region_Sub_Region_nm__c,
                                                                      /*Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c,*/ Core_MDF_GeoSubGeo_Budget_Type_nm__c                                                                                                
                                                                      FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c                               
                                                                      WHERE Core_MDF_Channel_Program_id__c IN : iupgmProgIdSet AND
                                                                      Core_MDF_Account_id__c IN :iupgmAccIdSet AND //Core_MDF_All_Accounts_cd__c = 'No' AND
                                                                      Core_MDF_Active_Ind__c = true AND Core_MDF_User_id__c IN :newIupgmUserIdRegionMap.KeySet()
                                                                      AND ID NOT IN: (oldMap.keyset())]){
                                                                          iupgmMap = getExistingIupgmUserIdGeoBudgetMap(iupgmRec);
                                                                      }
        }
        if(iupgmWithAllAccountYes!=null)
        {
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmRec : [SELECT Id, Core_MDF_Program_nm__c, Core_MDF_Channel_Program_id__c, Core_MDF_Account_id__c, Core_MDF_User_id__c,
                                                                      Core_MDF_Role_nm__c, Core_MDF_Active_Ind__c, Core_MDF_Region_cd__c, Core_MDF_Region_Sub_Region_nm__c,
                                                                      /*Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c,*/ Core_MDF_GeoSubGeo_Budget_Type_nm__c                                                                                                
                                                                      FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c                               
                                                                      WHERE Core_MDF_Channel_Program_id__c IN : iupgmProgIdSet AND
                                                                      Core_MDF_Active_Ind__c = true AND Core_MDF_User_id__c IN :newIupgmUserIdRegionMap.KeySet()
                                                                      AND Core_MDF_All_Accounts_cd__c = 'Yes' AND ID NOT IN: (oldMap.keyset())]){
                                                                          iupgmMap = getExistingIupgmUserIdGeoBudgetMap(iupgmRec);
                                                                      }
        }
        for(Id userId : newIupgmUserIdRegionMap.keySet()){
            if(iupgmMap.existingIupgmRegionMap != null && iupgmMap.existingIupgmRegionMap.containsKey(userId)){
                existingIupgmGeoSet = iupgmMap.existingIupgmRegionMap.get(userId);
                newIupgmGeoSet = newIupgmUserIdRegionMap.get(userId);
                
                newIupgmGeoSet.removeAll(existingIupgmGeoSet);// shiva
                finalUserGeoMap.put(userId, newIupgmGeoSet);
            }
        }  
        for(Id userId : newIupgmUserIdRegionBudgMap.keySet()){
            if(iupgmMap.existingIupgmBudMap != null && iupgmMap.existingIupgmBudMap.containsKey(userId)){
                existingIupgmGeoBudgSet = iupgmMap.existingIupgmBudMap.get(userId);
                newIupgmGeoBudgSet = newIupgmUserIdRegionBudgMap.get(userId);
                
                newIupgmGeoBudgSet.removeAll(existingIupgmGeoBudgSet);//shiva
                finalUserGeoBudgMap.put(userId, newIupgmGeoBudgSet);
            }
        }
        iupgmMap.finalIupgmRegionMap = finalUserGeoMap;
        iupgmMap.finalIupgmBudMap = finalUserGeoBudgMap;   
        return iupgmMap;  
    }
    
    /*****************************************************************************************************                              
Method Name   :        getExistingIupgmUserIdGeoBudgetMap                               
@return       :        ExistingIupgmUserGeoBudgetMap Wrapper class                              
@parameters   :        queried iupgm record                                                                                        
Description   :        //TWC702-1760: [KIIT]: IUPGM Changes and Testing                             
Added By      :        Accenture - Sai - 26/03/2022                            
Modified By   :        Date:           Changes:                                                             
******************************************************************************************************/
    public static ExistingIupgmUserGeoBudgetMap getExistingIupgmUserIdGeoBudgetMap(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmRec){
        
        ExistingIupgmUserGeoBudgetMap iupgmMap = new ExistingIupgmUserGeoBudgetMap();
        if(existingIupgmUserIdRegionMap.containsKey(iupgmRec.Core_MDF_User_id__c)){
            if(iupgmRec.Core_MDF_Region_Sub_Region_nm__c != null && iupgmRec.Core_MDF_Region_Sub_Region_nm__c.split(';') != null){
                existingIupgmUserIdRegionMap.get(iupgmRec.Core_MDF_User_id__c).addAll(iupgmRec.Core_MDF_Region_Sub_Region_nm__c.split(';'));
            }    
        }
        else{
            if(iupgmRec.Core_MDF_Region_Sub_Region_nm__c != null && iupgmRec.Core_MDF_Region_Sub_Region_nm__c.split(';') != null){
                existingIupgmUserIdRegionMap.put(iupgmRec.Core_MDF_User_id__c, new Set<String>(iupgmRec.Core_MDF_Region_Sub_Region_nm__c.split(';')));
            }
        }
        if(existingIupgmUserIdBudgMap.containsKey(iupgmRec.Core_MDF_User_id__c)){
            if(iupgmRec.Core_MDF_GeoSubGeo_Budget_Type_nm__c != null && iupgmRec.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';') != null){
                existingIupgmUserIdBudgMap.get(iupgmRec.Core_MDF_User_id__c).addAll(iupgmRec.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';'));
            } 
        }
        else{
            if(iupgmRec.Core_MDF_GeoSubGeo_Budget_Type_nm__c != null && iupgmRec.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';') != null){
                existingIupgmUserIdBudgMap.put(iupgmRec.Core_MDF_User_id__c, new Set<String>(iupgmRec.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';')));
            }
        }
        iupgmMap.existingIupgmRegionMap = existingIupgmUserIdRegionMap;
        iupgmMap.existingIupgmBudMap = existingIupgmUserIdBudgMap;
        return iupgmMap;
    }
    
    /*****************************************************************************************************                              
Method Name   :        createIUPGMPlatformEventRecords                                
@return       :        void                             
@parameters   :        newMap - Trigger.newMap for Core_MDF_Int_Users_Partner_Geo_Mapping__c                                
oldMap - Trigger.oldMap for Core_MDF_Int_Users_Partner_Geo_Mapping__c 
operationType - DML opertion type                               
Description   :        To create IUPGM Platform event records for the eligible Roles
Added By      :        JB - Accenture - 05/20/2022                              
Modified By   :        Date:           Changes:                                 
JB - Accenture         05/20/2022      To create IUPGM Platform event records for the eligible Roles
******************************************************************************************************/                             
    /*public static void createIUPGMPlatformEventRecords(Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c> newMap, Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c> oldMap, String operationType){
        
        List<Core_MDF_IUPGM_PE__e> iupgmPlatformEventList = new List<Core_MDF_IUPGM_PE__e>();
        
        try{
            List<String> eligibleRoles = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Eligible_Roles_For_IUPGM_PE');
            
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : newMap.values()){
                if(eligibleRoles.contains(iupgm.Core_MDF_Role_nm__c)){
                    Core_MDF_IUPGM_PE__e iupgmPlatformEvent = new Core_MDF_IUPGM_PE__e();
                    Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmOldValues = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
                    
                    iupgmPlatformEvent.Core_MDF_DML_Operation_Type__c = operationType;
                    iupgmOldValues.Id = iupgm.Id;
                    
                    if(operationType == 'Update'){
                        iupgmOldValues.Core_MDF_Active_Ind__c = oldMap.get(iupgm.Id).Core_MDF_Active_Ind__c;
                        iupgmOldValues.Core_MDF_All_Budget_Type_Access_Ind__c = oldMap.get(iupgm.Id).Core_MDF_All_Budget_Type_Access_Ind__c;
                        iupgmOldValues.Core_MDF_Budget_Type_nm__c = oldMap.get(iupgm.Id).Core_MDF_Budget_Type_nm__c;
                    }
                    iupgmPlatformEvent.Core_MDF_IUPGM_Old_Values__c = JSON.serialize(iupgmOldValues);
                    
                    iupgmPlatformEventList.add(iupgmPlatformEvent);
                }
            }
            
            if(!iupgmPlatformEventList.isEmpty()){
                List<Database.SaveResult> results = EventBus.publish(iupgmPlatformEventList);
                
                for(Database.SaveResult sr : results){
                    if(sr.isSuccess()){
                        
                    }else{
                        for(Database.Error err : sr.getErrors()) {
                            
                        }
                    }       
                }
            }
        }catch(Exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }*/
    
    public class ExistingIupgmUserGeoBudgetMap {
        public Map<Id, Set<String>> existingIupgmRegionMap {get; set;}
        public Map<Id, Set<String>> existingIupgmBudMap {get; set;}
        public Map<Id, Set<String>> finalIupgmRegionMap {get; set;}
        public Map<Id, Set<String>> finalIupgmBudMap {get; set;}
    }
    
    public static void getProgramGeoRoleGroupMap(){
        set<String> CustomSettingGroupNames = new set<String> ();
        
        for(Core_MDF_ProgramGeoRoleGroupMap__c progGeoRoleGroup : [SELECT id,Name, Core_MDF_Program_txt__c, Core_MDF_Region_txt__c, Core_MDF_Role_txt__c,  Core_MDF_Group_Name_txt__c 
                                                                   FROM Core_MDF_ProgramGeoRoleGroupMap__c 
                                                                   WHERE Core_MDF_Is_For_IUPGM_Monitor_Ind__c = false
                                                                   AND Core_MDF_Is_Active__c = true]){
                                                                       CustomSettingGroupNames.add(progGeoRoleGroup.Core_MDF_Group_Name_txt__c);
                                                                   }
        
        if(!CustomSettingGroupNames.isEmpty()) {   
            for(Group gr : [SELECT ID,DeveloperName 
                            from Group 
                            WHERE type='Regular' and (DeveloperName like 'Core_MDF%' or DeveloperName like 'MDF%') and DeveloperName IN : CustomSettingGroupNames] ){                             
                                groupNameToGroupIdMap.put(gr.DeveloperName,gr.Id);                
                            }                              
        }
        
        for(Core_MDF_ProgramGeoRoleGroupMap__c progGeoRoleGroup : [SELECT id,Name, Core_MDF_Program_txt__c, Core_MDF_Region_txt__c, Core_MDF_Role_txt__c,  Core_MDF_Group_Name_txt__c 
                                                                   FROM Core_MDF_ProgramGeoRoleGroupMap__c 
                                                                   WHERE Core_MDF_Is_For_IUPGM_Monitor_Ind__c = false
                                                                   AND Core_MDF_Is_Active__c = true]){
                                                                       string progGeoRoleKey = '';
                                                                       string progRoleWWKey = progGeoRoleGroup.Core_MDF_Program_txt__c + progGeoRoleGroup.Core_MDF_Role_txt__c;
                                                                       
                                                                       getProgRegionGrpMap(progGeoRoleGroup.Core_MDF_Program_txt__c,progGeoRoleGroup.Core_MDF_Region_txt__c,progGeoRoleGroup.Core_MDF_Group_Name_txt__c);
                                                                       
                                                                       if(String.isNotBlank(progGeoRoleGroup.Core_MDF_Region_txt__c)){
                                                                           progGeoRoleKey = progGeoRoleGroup.Core_MDF_Program_txt__c + progGeoRoleGroup.Core_MDF_Region_txt__c + progGeoRoleGroup.Core_MDF_Role_txt__c;
                                                                       }
                                                                       
                                                                       programRoleToGroupMap.put(progGeoRoleKey,groupNameToGroupIdMap.get(progGeoRoleGroup.Core_MDF_Group_Name_txt__c));
                                                                       //Blocker fix
                                                                       getGrpNameToIdMap(progRoleWWKey,progGeoRoleGroup.Core_MDF_Group_Name_txt__c);
                                                                       
                                                                   }
    }

  
    public static void getProgRegionGrpMap(string program, string region, string grpName){
         if(programToRegionToGroupMap.containsKey(program) && programToRegionToGroupMap.get(program) != null){
                 programToRegionToGroupMap.get(program).put(region,grpName);
             }else{
                 Map<string,string> regionToGroupNameMap = new Map<string,string>();
                 regionToGroupNameMap.put(region,grpName);
                 programToRegionToGroupMap.put(program,regionToGroupNameMap);
             }
    }
    
    public static void getGrpNameToIdMap(string progRoleWWKey, string grpName){
        if(groupNameToGroupIdWWMap.containsKey(progRoleWWKey) && groupNameToGroupIdWWMap.get(progRoleWWKey) != null){
             groupNameToGroupIdWWMap.get(progRoleWWKey).add(grpName);
         }       
         else{
             groupNameToGroupIdWWMap.put(progRoleWWKey,new List<string>{grpName});                                                      
         }
    }

    
    /*****************************************************************************************************                              
Method Name   :        addRoleSpecificIUPGMGroupMember                                
@return       :        void                             
@parameters   :        List of IUPGM (iupgmList)                           
Description   :        To create group members for users for secondary role, based on Custom Setting records
Added By      :        Ayush
******************************************************************************************************/    
    Public Static map<String,List<GroupMember>> addRoleSpecificIUPGMGroupMember(List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList){
        List<String> geoList = new List<String>();
        String progGeoRoleKey;
        String progRoleKey;
        String progKey;
        List<GroupMember> newGroupMemberList = new List<GroupMember>();
        Map<String,List<GroupMember>> newGroupMemberMap = new Map<String,List<GroupMember>>();
        try{
            if(programRoleToGroupMap.isEmpty()){                             
                getProgramGeoRoleGroupMap();                             
            }
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){    
                if(iupgm.Core_MDF_Region_Sub_Region_nm__c !=null){
                    geoList = iupgm.Core_MDF_Region_Sub_Region_nm__c.split(';');       
                }
                for(String geo : geoList){
                    if(STR_WW.equals(iupgm.Core_MDF_Region_Sub_Region_nm__c)){ 
                        progRoleKey = iupgm.Core_MDF_Program_nm__c + iupgm.Core_MDF_Role_nm__c;
                        
                        if(groupNameToGroupIdWWMap.containsKey(progRoleKey) && groupNameToGroupIdWWMap.get(progRoleKey) != null){
                            List<string> groupList = groupNameToGroupIdWWMap.get(progRoleKey);
                            for(string grpName: groupList){
                                GroupMember rwGrpMem = new GroupMember();                                                         
                                rwGrpMem.GroupId = groupNameToGroupIdMap.get(grpName);                               
                                rwGrpMem.UserOrGroupId = iupgm.Core_MDF_User_id__c;
                                newGroupMemberList.add(rwGrpMem);  
                                
                                String groupAndUserId=String.valueOf(groupNameToGroupIdMap.get(grpName))+String.valueOf(iupgm.Core_MDF_User_id__c);
                                if(newGroupMemberMap.containskey(groupAndUserId)){
                                    newGroupMemberMap.get(groupAndUserId).add(rwGrpMem);
                                }else{
                                    newGroupMemberMap.put(groupAndUserId,new List<GroupMember>{rwGrpMem});
                                    
                                }
                            }
                        }
                        
                    }
                    else{ 
                        progGeoRoleKey = iupgm.Core_MDF_Program_nm__c + geo + iupgm.Core_MDF_Role_nm__c;
                        
                        if(programRoleToGroupMap.containsKey(progGeoRoleKey) && programRoleToGroupMap.get(progGeoRoleKey) != null){
                            GroupMember rwGrpMem = new GroupMember();                                                         
                            rwGrpMem.GroupId = programRoleToGroupMap.get(progGeoRoleKey);                               
                            rwGrpMem.UserOrGroupId = iupgm.Core_MDF_User_id__c;
                            newGroupMemberList.add(rwGrpMem);
                            
                            String groupAndUserId=String.valueOf(programRoleToGroupMap.get(progGeoRoleKey))+String.valueOf(iupgm.Core_MDF_User_id__c);
                            if(newGroupMemberMap.containskey(groupAndUserId)){
                                    newGroupMemberMap.get(groupAndUserId).add(rwGrpMem);
                            }else{
                                newGroupMemberMap.put(groupAndUserId,new List<GroupMember>{rwGrpMem});
                            }
                            
                        }
                    }
                }
            }
            
            if(!newGroupMemberList.isEmpty()){                           
                String jsonStringGM = JSON.serialize(newGroupMemberList);                              
                Core_MDF_IUPGM_ServiceHandler.createGroupMember(jsonStringGM);                              
            }
        }catch(Exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
         return newGroupMemberMap;   
    }
    
    /*****************************************************************************************************                              
Method Name   :        removeRoleSpecificIUPGMGroupMember                                
@return       :        void                             
@parameters   :        newMap - Trigger.newMap for Core_MDF_Int_Users_Partner_Geo_Mapping__c                                
oldMap - Trigger.oldMap for Core_MDF_Int_Users_Partner_Geo_Mapping__c                            
Description   :        To delete group members from users for secondary role, based on Custom Setting records
Added By      :        Ayush
******************************************************************************************************/
    public static List<GroupMember> removeRoleSpecificIUPGMGroupMember(Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c> newMap,                               
                                                                       Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c> OldMap){
                                                                           
                                                                           List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmListToBeUpdated = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
                                                                           Map<String,Set<Id>> groupToUsersMap =new Map<String,Set<Id>>();
                                                                           Set<Id> usrIdforGm = new Set<Id>();
                                                                           List<GroupMember> groupMemToBeDeleted = new List<GroupMember>();
                                                                           String progGeoRoleKey = '';
                                                                           String progRoleKey = '';
                                                                           Map<string,string> regionToGroupNameMap = new Map<string,string>();
                                                                           Map<String, List<GroupMember>> newGroupMemberMap = new Map<String, List<GroupMember>>();
                                                                           List<String> newGeoList = new List<String>();                                                      
                                                                           
                                                                                                                              
                                                                               if(programRoleToGroupMap.isEmpty()){                             
                                                                                   getProgramGeoRoleGroupMap();                             
                                                                               }          
                                                                               
                                                                               for(String iupgm : newMap.keySet()){                                                     
                                                                                   regionToGroupNameMap = programToRegionToGroupMap.get(oldMap.get(iupgm).Core_MDF_Program_nm__c);
                                                                                   newGeoList = newMap.get(iupgm).Core_MDF_Active_Ind__c ? newMap.get(iupgm).Core_MDF_Region_Sub_Region_nm__c.split(';') : new List<String>();
                                                                                   if(oldMap.get(iupgm).Core_MDF_Region_Sub_Region_nm__c!=null && oldMap.get(iupgm).Core_MDF_Region_Sub_Region_nm__c.split(';') != NULL) {                               
                                                                                       
                                                                                       for(String geo : oldMap.get(iupgm).Core_MDF_Region_Sub_Region_nm__c.split(';')){
                                                                                           
                                                                                           progGeoRoleKey = newMap.get(iupgm).Core_MDF_Program_nm__c + geo + newMap.get(iupgm).Core_MDF_Role_nm__c;
                                                                                           progRoleKey = newMap.get(iupgm).Core_MDF_Program_nm__c + newMap.get(iupgm).Core_MDF_Role_nm__c;
                                                                                           
                                                                                           if(STR_WW.equals(oldMap.get(iupgm).Core_MDF_Region_Sub_Region_nm__c) && 
                                                                                              ((oldMap.get(iupgm).Core_MDF_Region_Sub_Region_nm__c != newMap.get(iupgm).Core_MDF_Region_Sub_Region_nm__c)
                                                                                               || (!newMap.get(iupgm).Core_MDF_Active_Ind__c && oldMap.get(iupgm).Core_MDF_Active_Ind__c))){
                                                                                                   
                                                                                                   if(groupNameToGroupIdWWMap != NULL && !groupNameToGroupIdWWMap.isEmpty() 
                                                                                                      && ((groupNameToGroupIdWWMap.containsKey(progRoleKey) && groupNameToGroupIdWWMap.get(progRoleKey) != NULL))){
                                                                                                          List<string> groupList = groupNameToGroupIdWWMap.get(progRoleKey);
                                                                                                          set<string> groupSet = new set<string>(groupList); 
                                                                                                          for(string newGeo: newGeoList){
                                                                                                              groupSet.remove(regionToGroupNameMap.get(newGeo));
                                                                                                          }
                                                                                                          groupList = new List<string>(groupSet);
                                                                                                          
                                                                                                          for(string grpName: groupList){
                                                                                                              if(groupToUsersMap.containsKey(groupNameToGroupIdMap.get(grpName))){
                                                                                                                  groupToUsersMap.get(groupNameToGroupIdMap.get(grpName)).add(oldMap.get(iupgm).Core_MDF_User_id__c);                                
                                                                                                                  usrIdforGm.addAll(groupToUsersMap.get(groupNameToGroupIdMap.get(grpName)));
                                                                                                              }                             
                                                                                                              else{                             
                                                                                                                  groupToUsersMap.put(groupNameToGroupIdMap.get(grpName), new Set<Id>{oldmap.get(iupgm).Core_MDF_User_id__c});                               
                                                                                                                  usrIdforGm.addAll(groupToUsersMap.get(groupNameToGroupIdMap.get(grpName)));
                                                                                                              }
                                                                                                          } 
                                                                                                          
                                                                                                          
                                                                                                      }
                                                                                               }
                                                                                           else{
                                                                                               if((newMap.get(iupgm).Core_MDF_Region_Sub_Region_nm__c != null && !newMap.get(iupgm).Core_MDF_Region_Sub_Region_nm__c.contains(geo) 
                                                                                                   && !STR_WW.equals(newMap.get(iupgm).Core_MDF_Region_Sub_Region_nm__c)) 
                                                                                                  || (!newMap.get(iupgm).Core_MDF_Active_Ind__c && oldMap.get(iupgm).Core_MDF_Active_Ind__c)){
                                                                                                      
                                                                                                      if(programRoleToGroupMap != NULL && !programRoleToGroupMap.isEmpty() 
                                                                                                         && ((programRoleToGroupMap.containsKey(progGeoRoleKey) && programRoleToGroupMap.get(progGeoRoleKey) != NULL))){ 
                                                                                                             if(groupToUsersMap.containsKey(programRoleToGroupMap.get(progGeoRoleKey))){
                                                                                                                 groupToUsersMap.get(programRoleToGroupMap.get(progGeoRoleKey)).add(oldmap.get(iupgm).Core_MDF_User_id__c);                                
                                                                                                                 usrIdforGm.addAll(groupToUsersMap.get(programRoleToGroupMap.get(progGeoRoleKey)));
                                                                                                             }                             
                                                                                                             else{                             
                                                                                                                 groupToUsersMap.put(programRoleToGroupMap.get(progGeoRoleKey), new Set<Id>{oldmap.get(iupgm).Core_MDF_User_id__c});                               
                                                                                                                 usrIdforGm.addAll(groupToUsersMap.get(programRoleToGroupMap.get(progGeoRoleKey)));
                                                                                                             }                             
                                                                                                         }
                                                                                                      
                                                                                                  }
                                                                                           }     
                                                                                       }
                                                                                   }
                                                                                   if((newMap.get(iupgm).Core_MDF_Active_Ind__c && !oldMap.get(iupgm).Core_MDF_Active_Ind__c) ||                               
                                                                                      (newMap.get(iupgm).Core_MDF_Region_Sub_Region_nm__c != oldMap.get(iupgm).Core_MDF_Region_Sub_Region_nm__c 
                                                                                       && newMap.get(iupgm).Core_MDF_Active_Ind__c)){
                                                                                           iupgmListToBeUpdated.add(newMap.get(iupgm));
                                                                                       }
                                                                               }  
                                                                               if(iupgmListToBeUpdated.size() > 0){                               
                                                                                   newGroupMemberMap = Core_MDF_IUPGM_ServiceHandler.addRoleSpecificIUPGMGroupMember(iupgmListToBeUpdated);                               
                                                                               }
                                                                               if(groupToUsersMap.size() > 0 && usrIdforGm.size() > 0){                                           
                                                                                   for(GroupMember gm : [SELECT Id, GroupId, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE                                                                     
                                                                                                         (GroupId IN:groupToUsersMap.keySet() AND UserOrGroupId IN: usrIdforGm)]){                      
                                                                                                             String groupUserId= String.valueOf(gm.GroupId) + String.valueOf(gm.UserOrGroupId);
                                                                                                             
                                                                                                             if(!newGroupMemberMap.containskey(groupUserId)){
                                                                                                             if(groupToUsersMap.containsKey(gm.GroupId) && groupToUsersMap.get(gm.GroupId) != NULL &&                                
                                                                                                                groupToUsersMap.get(gm.GroupId).contains(gm.UserOrGroupId)){                             
                                                                                                                    groupMemToBeDeleted.add(gm);                                
                                                                                                                }
                                                                                                         }
                                                                                   
                                                                               }
                                                                                   
                                                                               }
                                                                               return groupMemToBeDeleted;
                                                                           
                                                                       }
    
/***************************************************************************************************** 
Method Name   :        validateSelectedAccount                              
@return       :        void                             
@parameters   :        List of Internal Users Partner Geo Mapping records                               
Added By      :        Accenture - Shiva - 1 Feb 2024                                                              
******************************************************************************************************/      
    
   public static void validateSelectedAccount(List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList,Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c> oldIupgmMap) {
       
       //Applicable only for EEF Prog
       if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_EEF_RoleToAccAccess')){
           checkSelectedAccountIsValidForRole(iupgmList,oldIupgmMap);
       }
  }                                           
  
/*****************************************************************************************************                              
Method Name   :        checkSelectedAccountIsValidForRole                              
@return       :        void                             
@parameters   :        List of Internal Users Partner Geo Mapping records                               
Description   :        Throw an error when CSP role creates a iupgm with ISV account and vice versa
Added By      :        Accenture - Shiva - 1 Feb 2024                                                              
******************************************************************************************************/      
    
    public static void checkSelectedAccountIsValidForRole(List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList,Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c> oldIupgmMap) {
        
        Map<Id,List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>> ultimateAccIdToIupgmMap = new Map<Id,List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>>();
        Map<Id,List<string>> ultimateAccIdToParterMap = new Map<Id,List<string>>();
        List<string> EEF_ACTIVATING_PRIMARY_PARTNER_ROLES =  Core_MDF_CCP_ConstantClass.EEF_ACTIVATING_PRIMARY_PARTNER_ROLES.split(';');
        String NO_ACCESS_ERROR_MSG = Core_MDF_CCP_ConstantClass.NO_ACCESS_ERROR_MSG;
        String INTEL_ACCOUNT = Core_MDF_CCP_ConstantClass.INTEL_ACCOUNT;
        String CO_MARKETING_ACCOUNT = Core_MDF_CCP_ConstantClass.CO_MARKETING_ACCOUNT;
        try{
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){
                if(iupgm.Core_MDF_Program_nm__c == Label.Core_MDF_EEF_Program_Name && EEF_ACTIVATING_PRIMARY_PARTNER_ROLES.contains(iupgm.Core_MDF_Role_nm__c)){
                    if(iupgm.Core_MDF_Account_id__c != NULL && (oldIupgmMap == NULL || (oldIupgmMap != NULL && iupgm.Core_MDF_Active_Ind__c))) {
                        if(!ultimateAccIdToIupgmMap.containsKey(iupgm.Core_MDF_Account_id__c)){
                            ultimateAccIdToIupgmMap.put(iupgm.Core_MDF_Account_id__c, new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>());
                        }
                        ultimateAccIdToIupgmMap.get(iupgm.Core_MDF_Account_id__c).add(iupgm);
                    } 
                }
            }
            
            if(!ultimateAccIdToIupgmMap.isEmpty()) {
                for(Account acc : [SELECT Id,Core_MDF_Partner_Type_nm__c,Core_MDF_CoMarketing_Ultimate_Account__c 
                                   FROM Account 
                                   WHERE Core_MDF_CoMarketing_Ultimate_Account__c IN: ultimateAccIdToIupgmMap.keySet()
                                   AND Core_MDF_Parent_Fund_Account__r.RecordType.Name =: INTEL_ACCOUNT AND RecordType.Name =: CO_MARKETING_ACCOUNT 
                                   AND Core_MDF_Active_Ind__c = true AND Core_MDF_Channel_Program__r.Name =: Label.Core_MDF_EEF_Program_Name]) {
                                       
                                       //Check the account is meant for which Parter Type
                                       List<string> partnerTypeList = string.isNotBlank(acc.Core_MDF_Partner_Type_nm__c) 
                                           ? acc.Core_MDF_Partner_Type_nm__c.split(';') : new List<string>();
                                       ultimateAccIdToParterMap.put(acc.Core_MDF_CoMarketing_Ultimate_Account__c,partnerTypeList);                     
                                   }
                
                for(Id accId: ultimateAccIdToIupgmMap.keySet()){
                    for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm: ultimateAccIdToIupgmMap.get(accId)){
                        if(validateAccount(iupgm,ultimateAccIdToParterMap)){
                            iupgm.addError(NO_ACCESS_ERROR_MSG);
                        }
                    }
                }
            }
            
        }catch(Exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
    
    public static Boolean validateAccount(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm, Map<Id,List<string>> ultimateAccIdToParterMap) {
        Map<String, string> IUPGM_EGF_ROLE_PARTNER_TYPE_MAP = Core_MDF_CCP_ConstantClass.IUPGM_EGF_ROLE_PARTNER_TYPE_MAP;
        Boolean isInvalidAccount = false;
        
        if(!ultimateAccIdToParterMap.containsKey(iupgm.Core_MDF_Account_id__c) ||
           (ultimateAccIdToParterMap.containsKey(iupgm.Core_MDF_Account_id__c) && 
            ultimateAccIdToParterMap.get(iupgm.Core_MDF_Account_id__c) != NULL && 
            !ultimateAccIdToParterMap.get(iupgm.Core_MDF_Account_id__c).contains(IUPGM_EGF_ROLE_PARTNER_TYPE_MAP.get(iupgm.Core_MDF_Role_nm__c)))){
                isInvalidAccount = true;
            }
        
        return isInvalidAccount;
    }
    

/*****************************************************************************************************                              
Method Name   :        validateDuplicateAccounts                              
@return       :        void                             
@parameters   :        List of Internal Users Partner Geo Mapping records                               
Description   :        Throw an error when IUPGM record is being created for a User whose IUPGM already exist with All account with same role, region and Budget type.
Added By      :        Accenture - Akanksha - 4 Jun 2024                                                              
******************************************************************************************************/ 
public static void validateDuplicateAccounts(List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList,
                                            Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c> oldIupgmMap){

    Set<Id> existingUserIdSet = new Set<Id>();
    Set<String> existingRoleSet = new Set<String>();
    Set<String> existingProgramSet = new Set<String>();
 
    String ALL_ACCOUNT_VALIDATION_ERROR_MESSAGE = Core_MDF_CCP_ConstantClass.ALL_ACCOUNT_VALIDATION_ERROR_MESSAGE;
 
    List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> existingLstOfIUPGMS = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
    Map<String, List<String>> mapOfRegionAndBudgetTypeOld = new Map<String, List<String>>();
 
   try{
        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iterIUPGM : iupgmList){
            existingUserIdSet.add(iterIUPGM.Core_MDF_User_id__c);
            existingRoleSet.add(iterIUPGM.Core_MDF_Role_nm__c);
            existingProgramSet.add(iterIUPGM.Core_MDF_Program_nm__c);
        }
        if(!(existingUserIdSet.isEmpty() && existingRoleSet.isEmpty() && existingProgramSet.isEmpty())){
            existingLstOfIUPGMS = [SELECT Id,Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__c, Core_MDF_Program_nm__c,Core_MDF_User_id__c,Core_MDF_Region_Sub_Region_nm__c,Core_MDF_Role_nm__c,
                                                                                    Core_MDF_Budget_Type_nm__c,Core_MDF_Active_Ind__c,Core_MDF_GeoSubGeo_Budget_Type_nm__c FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                                    WHERE 
                                                                                    Core_MDF_User_id__c IN : existingUserIdSet AND
                                                                                    Core_MDF_Role_nm__c IN :  existingRoleSet AND
                                                                                    Core_MDF_Program_nm__c IN : existingProgramSet AND
                                                                                    Core_MDF_Active_Ind__c = TRUE];
        }
        if(!existingLstOfIUPGMS.isEmpty() && existingLstOfIUPGMS.size() > 0){
            mapOfRegionAndBudgetTypeOld = Core_MDF_IUPGM_ServiceHandler.fetchLstOfBudgetTypesAndRegions(existingLstOfIUPGMS);
        }
        if(mapOfRegionAndBudgetTypeOld!=null && !mapOfRegionAndBudgetTypeOld.isEmpty()){                                       
            //Loop for iterating over new List of IUPGM Rcrds in order to create a unique key of program, user, role and active indicator
            Map<String, List<String>> mapOfRegoinAndBudgetTypeNew = Core_MDF_IUPGM_ServiceHandler.fetchLstOfBudgetTypesAndRegions(iupgmList);
            
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c newIupgm : iupgmList){
                //iterating the new IUPGM map key
                if(mapOfRegoinAndBudgetTypeNew!=null && !mapOfRegoinAndBudgetTypeNew.isEmpty()){
                    for(String newIUPGMKey : mapOfRegoinAndBudgetTypeNew.keySet()){ 
                        //comparing the new IUPGM's key with the OLD IUPGM map
                        if(mapOfRegionAndBudgetTypeOld.containskey(newIUPGMKey)){
                            for(String allAccValue : mapOfRegionAndBudgetTypeOld.get(newIUPGMKey)){
                                if(allAccValue != newIupgm.Core_MDF_All_Accounts_cd__c){
                                    newIupgm.addError(ALL_ACCOUNT_VALIDATION_ERROR_MESSAGE); 
                                }
                            }
                        }
                    }
            	}
            }
        }
    }   
    catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e);} 
}

    
/*****************************************************************************************************
Method Name   :        validateAccountOnboardedForProgram
@return       :        void
@parameters   :        List of Internal Users Partner Geo Mapping records
Description   :        Validates if the account is onboarded by checking Partner Group Mapping for External access
Added By      : Gayathri   - [Date]
******************************************************************************************************/     
public static void validateAccountOnboardedForProgram(List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList) {
    try { 
        // Build candidate Account sets and program names from IUPGM records
        Set<Id> accountIdSet = new Set<Id>();
        Set<String> programNameSet = new Set<String>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> recordsToValidate = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();

        for (Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList) {
            if (iupgm.Core_MDF_Account_id__c != null &&
                String.isNotBlank(iupgm.Core_MDF_Program_nm__c)) {
                
                accountIdSet.add(iupgm.Core_MDF_Account_id__c);
                programNameSet.add(iupgm.Core_MDF_Program_nm__c);
                recordsToValidate.add(iupgm);
            }
        }
        if (accountIdSet.isEmpty()) {
            return;
        }
        // Query accounts to check Core_MDF_CoMarketing_Ultimate_Account__c
        Set<Id> allAccountsToCheckSet = new Set<Id>();
        Map<Id, Id> accountToUltimateAccountMap = new Map<Id, Id>();
        
        for (Account iupgmaccount : [
            SELECT Id, Core_MDF_CoMarketing_Ultimate_Account__c
            FROM Account
            WHERE Id IN :accountIdSet
        ]) {
            if (iupgmaccount.Core_MDF_CoMarketing_Ultimate_Account__c == null) {
                // If Core_MDF_CoMarketing_Ultimate_Account__c is blank, add current account
                allAccountsToCheckSet.add(iupgmaccount.Id);
                accountToUltimateAccountMap.put(iupgmaccount.Id, iupgmaccount.Id); 
            } else {
                // If Core_MDF_CoMarketing_Ultimate_Account__c is not blank, add the ultimate account
                allAccountsToCheckSet.add(iupgmaccount.Core_MDF_CoMarketing_Ultimate_Account__c);
                accountToUltimateAccountMap.put(iupgmaccount.Id, iupgmaccount.Core_MDF_CoMarketing_Ultimate_Account__c);
            }
        }
        

        // Query onboarded account-program combinations
        Set<String> onboardedKeySet = new Set<String>();
        
        for (Core_MDF_Partner_Group_Mapping__c pgm : [
            SELECT Core_MDF_Account__c, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c
            FROM Core_MDF_Partner_Group_Mapping__c
            WHERE Core_MDF_Account__c IN :allAccountsToCheckSet
              AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c IN :programNameSet
              AND Core_MDF_Type_Of_Access__c = 'External'
              AND Core_MDF_Inactive_Ind__c = false
        ]) {
            onboardedKeySet.add(pgm.Core_MDF_Account__c + '_' + pgm.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);
        }

        // Get error message
        String msg = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Account_Not_Onboarded_Error');

        // Validate and add errors (only loop through pre-filtered records)
        for (Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : recordsToValidate) {
            // Get the ultimate account ID for key preparation
            Id ultimateAccountId = accountToUltimateAccountMap.get(iupgm.Core_MDF_Account_id__c);
            String key = ultimateAccountId + '_' + iupgm.Core_MDF_Program_nm__c;
            if (!onboardedKeySet.contains(key)) {
                iupgm.addError(msg);
            }
        }
        
    } catch (Exception e) {
        Core_MDF_CCP_UtilityClass.logError(e);
    }
}
/*****************************************************************************************************                              
Method Name   :        fetchLstOfBudgetTypesAndRegionsLst                              
@return       :        void                             
@parameters   :        List of Strings containing budget types and regions                               
Description   :        The method returns a Map of iupgm unique key with list of geos and budgettypes.
Added By      :        Accenture - Akanksha - 4 Jun 2024                                                              
******************************************************************************************************/ 
public static Map<String, List<String>> fetchLstOfBudgetTypesAndRegions(List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList){

    List<String> allGeosLst = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Exception_AllGeo').Split(',');    
    List<String> regionList = new List<String>();
    Map<String, List<String>> mapofIUPGMkeyWithAllAcc = new Map<String, List<String>>();
    List<String> budgetTypeAndGeoList= new List<String>();
    //List<String> budgetTypeAndGeoListCombinedLst = new List<String>(); 

    String geoSubgeo;
    String budgttype;
    String keyForIupgm = '';
    try{
        if(!iupgmList.isEmpty()){
            //iterating on the iupm list to prepare the key
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iterIUPGM : iupgmList){
                List<String> budgetTypeAndGeoListCombinedLst = new List<String>();
                keyForIupgm =  iterIUPGM.Core_MDF_Program_nm__c + '_' + 
                                        String.valueOf(iterIUPGM.Core_MDF_User_id__c) + '_' +
                                        iterIUPGM.Core_MDF_Role_nm__c + '_' + 
                                        iterIUPGM.Core_MDF_Active_Ind__c;  
                //splitting the budget type and geo and preperaing a combined list                        
                if(iterIUPGM.Core_MDF_GeoSubGeo_Budget_Type_nm__c != null){
                    budgetTypeAndGeoList = iterIUPGM.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';');
    
                    if(budgetTypeAndGeoList != null && !budgetTypeAndGeoList.isEmpty()){
                        for(String btGeo : budgetTypeAndGeoList){  
                            if (btGeo.contains('->')) {
                                geoSubgeo = btGeo.split('->')[0] != null ? btGeo.split('->')[0] : '';                             
                                budgttype = btGeo.split('->')[1] != null ? btGeo.split('->')[1] : ''; 
                                if(geoSubgeo=='WW'){
                                    for(String strOnGeoLst : allGeosLst){
                                        budgetTypeAndGeoListCombinedLst.add(strOnGeoLst + (budgttype != null ? budgttype : ''));
                                    }
                                 }else{
                                    budgetTypeAndGeoListCombinedLst.add(btGeo.remove('->')); //APJBT1
                                 }
                                 
                            } else {
                                budgetTypeAndGeoListCombinedLst.add(btGeo);
                            }                                                  
                        }
                    }
                }
                else if(iterIUPGM.Core_MDF_Region_Sub_Region_nm__c != null){ 
                    if(iterIUPGM.Core_MDF_Region_Sub_Region_nm__c == 'WW'){
                        regionList = allGeosLst;
                    }else{
                        regionList = (iterIUPGM.Core_MDF_Region_Sub_Region_nm__c).split(';'); 
                    }
                    	budgetTypeAndGeoListCombinedLst.addAll(regionList);
                    }
                //iterating over the budget and geo combined list and appending it with the initial key to prepare the final key
                if(budgetTypeAndGeoListCombinedLst != null && !budgetTypeAndGeoListCombinedLst.isEmpty()){    
                    for(String geokey : budgetTypeAndGeoListCombinedLst){
                        String finalKey = keyForIupgm+'_'+geokey;
                        if(!mapofIUPGMkeyWithAllAcc.containsKey(finalKey)){
                            mapofIUPGMkeyWithAllAcc.put(finalKey,new List<string>{iterIUPGM.Core_MDF_All_Accounts_cd__c});
                        }
                        else{
                            mapofIUPGMkeyWithAllAcc.get(finalKey).add(iterIUPGM.Core_MDF_All_Accounts_cd__c);
                        }
                    }
                }
            }
        }
    }
    catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e);}  
    return mapofIUPGMkeyWithAllAcc;                            
}
    
/***************************************************************************************************** 
Method Name   :        createLogInstance
@return       :        logEntryObj
@parameters   :        logWrapper
Description   :        creates and returns the log entry object record based on the inputs
******************************************************************************************************/
    
    public static Core_Log_Entry__c createLogInstance(LogEntryDetailsWrapper logWrapper){
        Core_Log_Entry__c logEntryObj = new Core_Log_Entry__c();
        if(!logWrapper.successIds.isEmpty()){
            logEntryObj.Core_Severity__c = 'Info';
        	String logDetails = JSON.serialize(logWrapper.successIds);
        	logEntryObj.Core_Details__c = logDetails.length()> 32765? logDetails.subString(0,32765) : logDetails;  
        }
        if(!logWrapper.failedPGMList.isEmpty()){
            logEntryObj.Core_Severity__c = 'Critical';
            String logDetails = JSON.serialize(logWrapper.failedPGMList);
        	logEntryObj.Core_Details__c = logDetails.length()> 32765? logDetails.subString(0,32765) : logDetails;
        }
        if(!logWrapper.failedGroupMemberList.isEmpty()){
            logEntryObj.Core_Severity__c = 'Critical';
            String logDetails = JSON.serialize(logWrapper.failedGroupMemberList);
        	logEntryObj.Core_Details__c = logDetails.length()> 32765? logDetails.subString(0,32765) : logDetails;
        }

        logEntryObj.Core_Project__c = Label.Core_MDF_Program_Name;
        logEntryObj.Core_When__c = System.now();
        logEntryObj.Core_Origin__c = logWrapper.origin;
        logEntryObj.Core_Scope__c = 'IUPGM Logging for CCP'; // Need to Ask the Scope of Log entry    	
   		logEntryObj.Core_Message__c = logWrapper.errorMsg;
        return logEntryObj;
    }
    
    public static List<Core_MDF_Bulk_Transaction__e> createBulkTransactionPlatEventInstance(List<Core_Log_Entry__c> logEntryList){
        List<Core_MDF_Bulk_Transaction__e> bulkTransactionList = new List<Core_MDF_Bulk_Transaction__e>();
        for(Core_Log_Entry__c log : logEntryList){
        Core_MDF_Bulk_Transaction__e bulkTransactionEvent = new Core_MDF_Bulk_Transaction__e();
        bulkTransactionEvent.Core_MDF_JSON_Data__c = JSON.serialize(log);
        bulkTransactionEvent.Core_MDF_Object_Name__c = 'Core_Log_Entry__c';
        bulkTransactionList.add(bulkTransactionEvent);
        }
        return bulkTransactionList;
    }
    
    //Wrapper to store Log Entry Details
    public class LogEntryDetailsWrapper{
        public String origin;
        public Set<Id> successIds = new Set<Id>();
        public List<Core_MDF_Partner_Group_Mapping__c> failedPGMList = new List<Core_MDF_Partner_Group_Mapping__c>();
        public List<Groupmember> failedGroupMemberList = new List<Groupmember>();
        public String errorMsg;
    }
}