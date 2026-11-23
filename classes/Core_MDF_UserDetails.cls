public  without sharing Class Core_MDF_UserDetails{
    public static List<String> geoList;
    public static List<String> subGeoList;
	@AuraEnabled
    public static List<IntelActivityOwnerWrapper> getIntelActivityOwners(String accId,String program, List<String> country,String budgetType) { 
    Set<String> customPermissionSet = new Set<String>();
    Set<String> roles = new Set<String>();
    Set<Id> userIdSet = new Set<Id>();
    getGeoDetails(country);
    String accountId = getUltimateAccountId(accId);
    system.debug('accountId:'+accountId);
    if(string.isNotBlank(budgetType)){
        if(budgetType == 'OEM CMP' || budgetType =='Service Provider CMP'){
            if(program == 'Client Co-Marketing Fund'){
                customPermissionSet.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Marketing_Owner'));
                roles.add('Core_MDF_CCP_Internal_CCF_Acct_Mgr');              
            }
            if(program == 'Data Center Co-Marketing Fund'){
                customPermissionSet.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Marketing_Owner'));
                roles.add('Core_MDF_CCP_Internal_DCF_Acct_Mgr');      
            }
        }
        else if(budgetType == 'MDF' || budgetType =='MDF+'){
            if(program == 'Client Co-Marketing Fund'){
                customPermissionSet.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Field_Owner'));
                roles.add('Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr');                
            }
            if(program == 'Data Center Co-Marketing Fund'){
                customPermissionSet.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Field_Owner'));
                roles.add('Core_MDF_CCP_Internal_DCF_Field_Acct_Mgr');        
            }
        }
    }
     System.debug('1>>'+program);
     System.debug('geoList>>'+geoList);
     System.debug('subGeoList>>'+subGeoList);
     System.debug('Core_MDF_Role_nm__c>>'+roles);
     List<IntelActivityOwnerWrapper> resultWrapperList = new List<IntelActivityOwnerWrapper>();
        String geoStr='';
        if(!geoList.isEmpty()){
            geoList.add('WW');
            geoStr ='(\'' + String.join(geoList, '\', \'') + '\')';
                    // geoStr = String.escapeSingleQuotes(geoStr);
      }  
        System.debug('<<geoStr>>'+geoStr);
        String qryStr = 'SELECT Id, Core_MDF_User_id__c '+
            			' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
            			' WHERE toLabel(Core_MDF_Program_nm__c) =: program' +
             			' and Core_MDF_Account_id__c =:accountId' +
            			' and Core_MDF_Region_cd__c INCLUDES ' + geoStr +
            			' and Core_MDF_Role_nm__c IN : roles'+
            			' and Core_MDF_is_User_Active_ind__c = true '+
                        ' and Core_MDF_Active_Ind__c = true' +
            			' and  Core_MDF_Is_Not_an_Approver_Ind__c = false';
        System.debug('<<qryStr>>'+qryStr); 
            
       List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList= Database.query(qryStr);
     for( Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm: iupgmList){                                                                 
          System.debug('<<iupgm>>'+iupgm);  
          userIdSet.add(iupgm.Core_MDF_User_id__c);
     }
      System.debug('userIdSet>>'+userIdSet);
    
      System.debug('userIdSet>>'+userIdSet);
     if(!userIdSet.isEmpty()){
         for(user userObj : [SELECT Id, Name,FirstName, LastName, Email FROM User WHERE Id IN: userIdSet]){
                            IntelActivityOwnerWrapper actOwnerObj = new IntelActivityOwnerWrapper();
                            actOwnerObj.userId = userObj.Id; 
                            actOwnerObj.fullName= userObj.Name;
                            actOwnerObj.firstName = userObj.FirstName;
                            actOwnerObj.lastName = userObj.LastName;
                            actOwnerObj.email = userObj.Email;
                            resultWrapperList.add(actOwnerObj);
         }
     }
        system.debug('resultWrapperList:'+resultWrapperList);
     return resultWrapperList;
    
    }
   //  public static String returnsGeoForActvitity (List<String> countryList){ 
    public static void getGeoDetails (List<String> countryList){
             geoList = new List<String>();
             subGeoList = new List<String>();
             Map<String,countryGeoSubGeoWrapper> wrapperMap = new Map<String,countryGeoSubGeoWrapper>();
             wrapperMap = getCountryGeoMap();
            System.debug('<<wrapperMap >>'+ wrapperMap );
            for(String countryStr : countryList){
                if(wrapperMap.containsKey(countryStr) && wrapperMap.get(countryStr) != NULL ){
                    if(wrapperMap.get(countryStr).subgeo.equals('LAR') || wrapperMap.get(countryStr).subgeo.equals('NAR')){
                        subGeoList.add(wrapperMap.get(countryStr).subgeo);
                    }
                    geoList.add(wrapperMap.get(countryStr).geo);
                }
            }    
          
    }
    public static Id getUltimateAccountId(String accId){
        Id accountId;
        List<Account> accountList =[SELECT Id,Core_MDF_CoMarketing_Ultimate_Account__c FROM Account WHERE Id =:accId LIMIT 1];
        if(accountList != null && !accountList.isEmpty()){
         accountId = accountList[0].Core_MDF_CoMarketing_Ultimate_Account__c;
        }
        return accountId;
    }
    public class IntelActivityOwnerWrapper{ 
         @AuraEnabled public String fullName{get;set;}    
        @AuraEnabled public String firstName{get;set;}
        @AuraEnabled public String lastName{get;set;}
        @AuraEnabled public String email{get;set;}
        @AuraEnabled public String userId{get;set;}     
    }
    /*thod Name   :        getCountryGeoMap
    @return       :        Map of Country and CountryGeoSubGeoWrapper
    @parameters   :        NULL
    Description   :        Prepares the country-geo-subGeo mapping
    Added By      :        Accenture - VK - 08/05/2019
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    public static Map<String,countryGeoSubGeoWrapper> getCountryGeoMap(){
        
        Map<String,countryGeoSubGeoWrapper> countryWrapperMap = new Map<String,countryGeoSubGeoWrapper>();
        
        try{
            List<Core_MDF_CCP_Country_Geo_Mapping__mdt> cgmList = [SELECT MasterLabel, Core_MDF_Geo__c, Core_MDF_Sub_Geo__c, Core_MDF_Code_2_Digits__c
                                                                   FROM Core_MDF_CCP_Country_Geo_Mapping__mdt];
            
            if(cgmList != NULL && cgmList.size() > 0){
                for(Core_MDF_CCP_Country_Geo_Mapping__mdt mdt : cgmList){
                    countryGeoSubGeoWrapper countryGeoSubGeoInst = new countryGeoSubGeoWrapper();
                    countryGeoSubGeoInst.country = mdt.MasterLabel;
                    countryGeoSubGeoInst.geo = mdt.Core_MDF_Geo__c;
                    countryGeoSubGeoInst.subGeo = mdt.Core_MDF_Sub_Geo__c;
                    countryGeoSubGeoInst.countryCode = mdt.Core_MDF_Code_2_Digits__c;
                    countryWrapperMap.put(countryGeoSubGeoInst.country, countryGeoSubGeoInst);
                }
            }                                                 
            
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        return countryWrapperMap;
    }
  
    public class CountryGeoSubGeoWrapper{
        public String country;
        public String geo;
        public String subGeo;
        public String countryCode;
    }
 }