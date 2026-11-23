/********************************************************************************************************************
Class Name    : Sales_LicenseRecordPageComponentsUtility
Version       : 1.0
Created Date  : June 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Jasmine Narula           Jun-2021             Contains method called from LWC on License
* *********************************************************************************************************************/
@isTest
public without sharing class Sales_LicenseRecordPageComponentsUtility {
    /*public static boolean BypassTriggerReassignmentLogic=false;
    public static boolean isCustomOps;
    @AuraEnabled
    public static Boolean askForReassignment(Id hostId, Id licenseId){
        BypassTriggerReassignmentLogic=true;
        Set<Id> hostIds = new Set<id>();
        Set<Id> licenseIds = new Set<id>();
        hostIds.add(hostId);
        licenseIds.add(licenseId);
        Boolean islcexist = Sales_LicenseGenerationGenericFunctions.askForhostReassigment(hostIds, licenseIds);   
        return islcexist;
    }
    @AuraEnabled
    public static String hostReassignment(Id hostId, Id licenseId){
        BypassTriggerReassignmentLogic=true;
        Map<Id, Id> mapofInputs = new Map<Id, Id>();
        mapofInputs.put(hostId, licenseId);
        String reutrnMsg = Sales_LicenseGenerationGenericFunctions.hostReassigmentLogic(mapofInputs);
        return reutrnMsg;
    } 
    @AuraEnabled
    public static List<wrapperforLicense> retriveComputerDetails(String hostName, String licenseactivationcode, String contactId){
        Set<Id> hostIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<String> primaryAdminIdSet = new Set<String>();
        contactIdSet.add(contactId);
        for(Sales_License_Admin_Delegate__c licAdmin : [Select Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c IN:contactIdSet and Sales_License_isActive__c=true]){
            primaryAdminIdSet.add(licAdmin.Sales_License_PrimaryAdmin_Contact__c); 
        }        
        String searchName= '%'+hostName+'%';
        String liceseType = [SELECT Id, Sales_Tool_License_Type__c from Sales_License__c WHERE Sales_License_Activation_Code__c=:licenseactivationcode LIMIT 1]?.Sales_Tool_License_Type__c;
        List<wrapperforLicense> wrapperClass = new List<wrapperforLicense>();
        List<Sales_Host__c> hostList = new List<Sales_Host__c>();
        if(contactIdSet.size() > 0){
            String hostquery = 'SELECT Name, Sales_Contact__c,Sales_Contact__r.Name,Sales_Computer_Name_Txt__c,Sales_License_Type__c FROM Sales_Host__c WHERE (Sales_Computer_Name_Txt__c LIKE :searchName or Name LIKE :searchName) and (Sales_Contact__c IN:primaryAdminIdSet OR Sales_Contact__c IN:contactIdSet) and Sales_isActiveHost__c=true and ';
            if(liceseType == 'FIXED'){
                liceseType = 'Sales_License_Type__c=\'FIXED\'';
            }
            else if (liceseType == 'N-A' || liceseType == 'FLOAT'){
                liceseType = 'Sales_License_Type__c=\'FLOAT\'';
            }
            else if (liceseType == 'NEUTRAL'){
                liceseType = '(Sales_License_Type__c=\'FIXED\' or  Sales_License_Type__c=\'FLOAT\')';
            }
            hostquery = hostquery + liceseType;
            hostList = Database.query(hostquery);
            for(Sales_Host__c host : hostList){
                wrapperforLicense lst = new wrapperforLicense();
                lst.salesComputerName = host.Sales_Computer_Name_Txt__c;
                lst.primaryId = host.Name;
                lst.licenseType = host.Sales_License_Type__c;
                lst.primaryAdminContact = host.Sales_Contact__r.Name;
                lst.hostRecordId = host.Id;
                wrapperClass.add(lst);
            }           
        }
        return wrapperClass; 
    }
    public with sharing class wrapperforLicense{
        @AuraEnabled public String salesComputerName;
        @AuraEnabled public String primaryId;
        @AuraEnabled public String licenseType;
        @AuraEnabled public String primaryAdminContact;
        @AuraEnabled public String hostRecordId;
    }
    @AuraEnabled 
    public static String createHostonLicenseRecord(Id hostId, Id licenseId){
        BypassTriggerReassignmentLogic=true;
        List<Sales_License__c> licenseList = new List<Sales_License__c>();
        List<Sales_Host__c> hostList = new List<Sales_Host__c>();
        Map<Id, Id> mapofInputs = new Map<Id, Id>();
        mapofInputs.put(hostId, licenseId);
        String reutrnMsg = Sales_LicenseGenerationGenericFunctions.hostReassigmentLogic(mapofInputs);
        if(reutrnMsg!=System.Label.Sales_SuccessHostReassignment){
            for(Sales_Host__c host : [SELECT Id from Sales_Host__c where id  =:hostId]){
                hostList.add(host);
            }  
            if(hostList.size() > 0){ 
                delete hostList;
            }
        }
        if(licenseId!=null && reutrnMsg==System.Label.Sales_SuccessHostReassignment){
            isCustomOps=Sales_ValidateUserEditAccess.BypassRehostForCustomOps();
            Sales_License__c license =new Sales_License__c();
            if(isCustomOps==true){
                license = [SELECT id,Sales_License_Host_Node_Id__c, Sales_License_Primary_Admin_Contact__c,Sales_License_Order__r.Sales_Order_Reason__c,Sales_License_Order__c from Sales_License__c where id=:licenseId and Sales_License_Type__c!='Optional'];
            }else{
                license = [SELECT id,Sales_License_Host_Node_Id__c, Sales_License_Primary_Admin_Contact__c,Sales_License_Order__r.Sales_Order_Reason__c,Sales_License_Order__c from Sales_License__c where id=:licenseId and Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional'];
            }
            license.Sales_License_Status__c='Licensed';
            if(license.Sales_License_Order__r.Sales_Order_Reason__c!='Non Stocking Order' && license.Sales_License_Status__c=='Licensed'){
                license.Sales_License_Account__c = [SELECT AccountId from Contact WHERE Id=:license.Sales_License_Primary_Admin_Contact__c]?.AccountId;
            }
            license.Sales_License_Avbl_Qty_Nbr__c = 0;
            licenseList.add(license);
        }
        if(licenseList.size() > 0){
            try{   
                update licenseList;
            }
            catch (Exception ex) {
                if(ex.getMessage().contains('_EXCEPTION')){
                    String pureErrorMessage = ex.getMessage().substringAfter('_EXCEPTION,').substringBeforeLast(': [');
                    reutrnMsg = pureErrorMessage;
                }
            }
        }
        return reutrnMsg;  
    }
    @AuraEnabled
    public static String splitReassignment(Id hostId, List<Id>licenseId){
        String Message; 
        List<Sales_License__c> lic = new List<Sales_License__c>();
        for(Sales_License__c licenseItem : [Select id, Sales_License_Host_Node_Id__c from Sales_License__c where id in: licenseId and Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional'] ){
            licenseItem.Sales_License_Host_Node_Id__c = hostId ;
            lic.add(licenseItem) ;
        }
        if(lic.size() > 0) {
            update lic;
            Message = 'Success';
        } 
        return Message;
    }
    @AuraEnabled
    public static String hostReassignmentonAllLicensesonSplit(Id hostId, String activationCode){
        Map<Id, String> mapofInputs = new Map<Id, String>();
        mapofInputs.put(hostId, activationCode);
        String returnMsg = Sales_LicenseGenerationGenericFunctions.hostReassigmentLogic(mapofInputs);
        return returnMsg;
    }
    @AuraEnabled
    public static Boolean LicenseTypeCheck(Id hostId, Id licenseId){
        Boolean licMsg=false;
        String licenseType = [SELECT Id, Sales_Tool_License_Type__c from Sales_License__c WHERE Id =:licenseId]?.Sales_Tool_License_Type__c;
        String hostLicenseType = [SELECT Id,Sales_License_Type__c FROM Sales_Host__c where Id =:hostId]?.Sales_License_Type__c;
        if((licenseType=='FIXED' || (licenseType=='NEUTRAL')) && hostLicenseType=='FIXED'){
            licMsg=true;
        }
        else if((licenseType=='FLOAT' || (licenseType=='NEUTRAL') || (licenseType=='N-A')) && hostLicenseType=='FLOAT'){
            licMsg=true;
        }
        else{
            licMsg=false;
        }
        return licMsg;
    }
    public with sharing class wrapperforlegacylicense{
        @AuraEnabled public Boolean isvalidHost;
        @AuraEnabled public Id hostId;
    }
    @AuraEnabled
    public static wrapperforlegacylicense validateComputerId(String computerId){
        Boolean isvalidHost=false;
        Map<String,Boolean> compWithValidity =new Map<String,Boolean>();
        wrapperforlegacylicense wrapperObj = new wrapperforlegacylicense(); 
        wrapperObj.isvalidHost=false;
        List<Sales_License__c> licenseList = [SELECT Id, CreatedDate, Sales_License_Host_Node_Id__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Expiration_Date_Dt__c FROM Sales_License__c 
                                              WHERE Sales_License_Host_Node_Id__r.Name =:computerId and Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional'];
        Date legacyDate = date.newInstance(2009, 1, 1); 
        for(Sales_License__c lic : licenseList){
            if(compWithValidity.containsKey(computerId) && !compWithValidity.get(computerId)){
                break; 
            }
            if(lic.Sales_License_Maintenance_Exp_Dt__c < legacyDate && lic.Sales_License_Maintenance_Exp_Dt__c!=null && (lic.Sales_License_Expiration_Date_Dt__c==null || lic.Sales_License_Expiration_Date_Dt__c>=System.Today())){
                wrapperObj.isvalidHost = true; 
                wrapperObj.hostId = lic.Sales_License_Host_Node_Id__c;
                compWithValidity.put(computerId,true);
                break;
            }
        }
        return wrapperObj;
    }*/
}