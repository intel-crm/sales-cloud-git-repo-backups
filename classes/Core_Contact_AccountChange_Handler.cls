/*********************************************************************************************
Apex Class Name:  Core_Contact_AccountChange_Handler
Version     : 1.0 
Created Date: 21 April 2017 
Created By: Prem Ranjan
Description    : This class is handle account change for Case, Assest, Project, Entitlement
*Modification Log :
* Developer                   Date                        Description
* ----------------------------------------------------------------------------                 
* Sugandha                    25/05/2018                  Modified(Defect DE39470 Iteration 11)
**********************************************************************************************/
public class Core_Contact_AccountChange_Handler {
    public static boolean IS_CHANGE_ACCOUNT = false;
    /*This method is called when account is changed on the contact and validate target account*/
    public static void validateTargetAccount(List<Contact> lstNewContacts){
        Map<Id,Id> stContNewAccId = new Map<Id,Id>();
        set<Id> stConId = new set<Id>();
        
        for(Contact objConRef : lstNewContacts){
            stConId.add(objConRef.id);
            stContNewAccId.put(objConRef.id,objConRef.accountID);
            system.debug('New Account: '+objConRef.accountID);
        }
        Map<Id,Account> newAccountMap=new Map<ID,Account>([SELECT id,Name,Core_CIM_ID__c,Core_CNDA_Number__c,Core_Deactivated__c,Core_Deactivation_Reason__c,Core_English_Only_Name__c,Core_B2B_Entitlement__c,Core_IPS_Active__c,Owner.UserRole.Name,Core_IsODM__c,Core_Export_Compliance_Block__c from Account where id in : stContNewAccId.values()]);
        
        List<Contact> lstContacts = [SELECT id,Core_AGS_Integration_Status__c,Core_IPS_Active__c,Core_ERPM_Integration_Status__c,AccountId,Account.name,Account.Core_IPS_Active__c,Account.Core_English_Only_Name__c,Account.Core_IsODM__c,Account.Core_Export_Compliance_Block__c,Email,(SELECT id,Core_Contact_Id__c,Core_Selected__c,Core_From_Source__c,Core_Entitlement_Id__c,Core_Entitlement_Id__r.Core_IsActive__c,Core_Entitlement_Id__r.Core_Category__c FROM Contact_Entitlements__r where Core_Selected__c=true and Core_From_Source__c=false ) FROM Contact Where Id IN : stConId];
        
        for(Contact contactRef : lstContacts){
            Contact objContact = new Contact();
            Integer ContactIndex=null;
            for(Integer index =0;index<lstNewContacts.size();index++){
                if(lstNewContacts[index].id==contactRef.id){
                    ContactIndex=index;
                }
            }
            system.debug('Queried old Account :'+contactRef.accountID);
            
            Account newAccountRec=newAccountMap.get(stContNewAccId.get(contactRef.id));
            
            Boolean blnSelectedContactEntitlement=false;
            
            for(Core_Contact_Entitlement__c objConEntitlement : contactRef.Contact_Entitlements__r){
                System.debug('=====1======'+objConEntitlement.Core_Entitlement_Id__r.Core_IsActive__c);
                System.debug('=====2======'+objConEntitlement.Core_Selected__c);
                System.debug('=====3======'+objConEntitlement.Core_From_Source__c);
                if(objConEntitlement.Core_Entitlement_Id__r.Core_IsActive__c == true ){
                    blnSelectedContactEntitlement=true;
                }
            }
            String AllErrorMessages='';
            
            
            if(blnSelectedContactEntitlement){
                if(String.ISBLANK(newAccountRec.Core_CIM_ID__c)){
                    AllErrorMessages = AllErrorMessages+'\n Account CIMID is missing, ';
                    lstNewContacts[ContactIndex].accountid.addError(AllErrorMessages);
                }
                
                if(String.ISBLANK(newAccountRec.Core_CNDA_Number__c)){
                    AllErrorMessages = AllErrorMessages+'\n Account CNDA is missing, ';
                    lstNewContacts[ContactIndex].accountid.addError(AllErrorMessages);
                }
                
                if(String.ISBLANK(newAccountRec.Core_English_Only_Name__c)){
                    AllErrorMessages = AllErrorMessages+'\n Account English only name is missing, ';
                    lstNewContacts[ContactIndex].accountid.addError(AllErrorMessages);
                }
                
                // contact ips active and account ips false
                if(contactRef.Core_IPS_Active__c == true  && newAccountRec.Core_IPS_Active__c == false && String.isBlank(newAccountRec.Owner.UserRole.Name)){
                    AllErrorMessages = AllErrorMessages+'\n Please contact IT Support to have them manually set the UserRole to Account :'+newAccountRec.Name+'\'s Owner :, ';
                    lstNewContacts[ContactIndex].accountid.addError(AllErrorMessages);
                }
                
                // ODM account Validation (Even No entitilement active)
                if(contactRef.Account.Core_IsODM__c != newAccountRec.Core_IsODM__c){
                    if(contactRef.Account.Core_IsODM__c){
                        AllErrorMessages = AllErrorMessages+'\n ODM Account Contact cannot moved to Non ODM Account, ';
                        lstNewContacts[ContactIndex].accountid.addError(AllErrorMessages);
                    }else if(newAccountRec.Core_IsODM__c){
                        AllErrorMessages = AllErrorMessages+'\n Non ODM Account Contact cannot moved to ODM Account, ';
                        lstNewContacts[ContactIndex].accountid.addError(AllErrorMessages);
                    }
                }
                
            }
            // Checking Profile For availble to update contact or not.
            
            // Validation for Account Compliance i.e. GEC Hold
            if(contactRef.Account.Core_Export_Compliance_Block__c){
                AllErrorMessages = AllErrorMessages+'\n  Account :'+contactRef.Account.Name+' is on  GEC Hold , ';
                lstNewContacts[ContactIndex].accountid.addError(AllErrorMessages);
            } 
            
            if(newAccountRec.Core_Export_Compliance_Block__c){
                AllErrorMessages = AllErrorMessages+'\n  Account :'+contactRef.Account.Name+' is on  GEC Hold , ';
                lstNewContacts[ContactIndex].accountid.addError(AllErrorMessages);
            } 
            // Inactive account validation 
            
            if(newAccountRec.Core_Deactivated__c && newAccountRec.Core_Deactivation_Reason__c!=null) {
                AllErrorMessages = AllErrorMessages+'\n Account is deactivated : ';
                lstNewContacts[ContactIndex].accountid.addError(AllErrorMessages);
            }

            //eRPM trigger logic  atb
            //Updating this to pending in after update section in trigger (core_contact)
            //lstNewContacts[ContactIndex].Core_ERPM_Integration_Status__c = 'Pending';
            //lstNewContacts[ContactIndex].Core_AGS_Integration_Status__c = 'Pending'; 
            
        }
    }
    
    
    /*This method is called when account is changed on the contact. This method retrives cases and accounts related to the contact and sending updateAssetsToCase method*/
    public static void updateAssets(List<Contact> lstNewContacts){
        System.debug('*****>>in updateAssets method<<****');
        set<Id> stAccId = new set<Id>();
        set<Id> stConId = new set<Id>();
        List<Case> lstCases = new List<Case>();
        set<ID> gecCaseContact=new set<ID>();
        List<ID> getcaseContactLst=new List<Id>();
        Set<String> stGECStatus = new Set<String>{'On Hold - GEC Review in Progress','On Hold - Government Authorization Needed '};
            
            // No need to check profile.
            Profile userProfileName = [Select Name from Profile where Id = : UserInfo.getProfileId() limit 1];
        
        for(Contact objConRef : lstNewContacts){
            stAccId.add(objConRef.AccountId);
            stConId.add(objConRef.id);
        }
        
        // Core_IPS_Project_Case__c ==null filter should be added  and remove GEC Hold Condition add old account id removed  Core_IPS_GEC_Status__c NOT IN :stGECStatus AND 
        //added Core_IPS_Supported_Product__r.Core_IPS_Public_Product__c field by Sugandha for DE39470 
        lstCases = [SELECT id,Product.name,Contactid,Core_IPS_GEC_Status__c,Core_IPS_Supported_Product__r.Core_Product__c,contact.Accountid,Core_IPS_Project_Case__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Alias__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c,AccountId,Core_IPS_Product_Org1__c,Core_IPS_Supported_Product__c,asset.status,Core_IPS_Supported_Product__r.Core_IPS_Public_Product__c FROM Case WHERE Contactid IN : stConId AND Core_IPS_Project_Case__c = null AND RecordType.Name != 'CEP Case'];
        
        //Any GEC Hold Condition through message.
        for(Case caseObj : lstCases){
            system.debug(stGECStatus+'Object msg: GEC Status : '+caseObj.Core_IPS_GEC_Status__c);
            if(stGECStatus.contains(caseObj.Core_IPS_GEC_Status__c)){
                //Add error for GEC Hold
                gecCaseContact.add(caseObj.Contactid);
            }
        }
        //Converting Set to list;
        getcaseContactLst.addAll(gecCaseContact);
        // Adding error to GEC Hold containg case's contact.
        for(Integer count=0;count<getcaseContactLst.size();count++){
            for(Integer index=0;index<lstNewContacts.size();index++ ){
                if(getcaseContactLst[count]==lstNewContacts[index].id){
                    lstNewContacts[index].addError('Case Having GEC Hold, Cannot Move this contact');
                    break;
                }
            }
        }
        
        System.debug('Core_Contact_AccountChange_Handler.updateAssets==lstCases==>'+lstCases);
        // Check for lstCases size > 0 
        if(lstCases.size()>0){
            updateAssetsToCase(lstCases,stAccId);
            system.debug('No of cases :: '+lstCases.size());
            //Update the addtional Fields to Account, B2B and IPS
            updateTargetAccountAdditionalFields(lstNewContacts);
        }
        System.debug('*****>>End of updateAssets method<<****');
    }
    /* This method is to retrive all the assets for the new accounts and assign to the respected cases or creating an asset if requires. */   
    public static void updateAssetsToCase(List<Case> lstCases,set<Id> stAccId){
        System.debug('*****>>in updateAssetsToCase method<<****');
        List<Asset> lstCreateAsset = new List<Asset>();
        List<Case> lstUpdateCase = new List<Case>();
        List<Asset> lstAssetsForNewAcc = new List<Asset>();
        Map<String,Asset> mapAsset = new Map<String,Asset>();
        List<Case> lstCaseForReupdate = new List<Case>();
        Set<String> stTobeUpdatedAsset = new Set<String>();
        system.debug('Limits.getDMLStatements :: '+Limits.getDMLStatements());
        lstAssetsForNewAcc = [SELECT id,Core_IPS_Project__c,Core_Product_Organization__c,Core_Supported_Product__c,Accountid FROM Asset WHERE Accountid IN : stAccId];
        System.debug('Core_Contact_AccountChange_Handler.updateAssets ==lstAssetsForNewAcc===>'+lstAssetsForNewAcc);
        
        for(Asset objAssetRef : lstAssetsForNewAcc){
            if(objAssetRef.Accountid != null) {
                mapAsset.put(string.valueof(objAssetRef.Accountid) + string.valueof(objAssetRef.Core_Product_Organization__c)  +  string.valueof(objAssetRef.Core_Supported_Product__c),objAssetRef);
            }
        }
        System.debug('Core_Contact_AccountChange_Handler ===mapAsset===>'+mapAsset);
        
        for(Case objCaseRef : lstCases){
            
            objCaseRef.AccountId = objCaseRef.contact.Accountid;
            
            /*System.debug('Core_Contact_AccountChange_Handler.updateAssets===Core_IPS_Project_Case__c====>'+objCaseRef.Core_IPS_Project_Case__c);
            System.debug('Core_Contact_AccountChange_Handler.updateAssets===Core_IPS_Product_Org1__c====>'+objCaseRef.Core_IPS_Product_Org1__c);
            System.debug('Core_Contact_AccountChange_Handler.updateAssets===Core_IPS_Supported_Product__c====>'+objCaseRef.Core_IPS_Supported_Product__c);
            System.debug('Core_Contact_AccountChange_Handler.updateAssets===AccountID====>'+objCaseRef.AccountID);
            System.debug('====Productid===>'+objCaseRef.Productid);
            System.debug('====Productid===>'+objCaseRef.Product.name);
            system.debug('public prod?::'+objCaseRef.Core_IPS_Supported_Product__r.Core_IPS_Public_Product__c);
            system.debug('case account?::'+objCaseRef.AccountId);*/
            //added check for public product by Sugandha for DE39470
            if(objCaseRef.AccountID != null && objCaseRef.Core_IPS_Product_Org1__c !=null && objCaseRef.Core_IPS_Supported_Product__c!= null && !objCaseRef.Core_IPS_Supported_Product__r.Core_IPS_Public_Product__c){
                       
                string strKey_Asset = string.valueof(objCaseRef.AccountID) + string.valueof(objCaseRef.Core_IPS_Product_Org1__c)  +  string.valueof(objCaseRef.Core_IPS_Supported_Product__c) ;
                
                if(!mapAsset.isEmpty() && mapAsset.containsKey(strKey_Asset)){
                    objCaseRef.AssetId = mapAsset.get(strKey_Asset).id;
                    lstUpdateCase.add(objCaseRef);
                }else{
                    /*system.debug('===objcaseref.Core_IPS_Supported_Product__c==>'+objCaseRef.Core_IPS_Supported_Product__c);
                    system.debug('===objCaseRef.supportedprofuct.name==>'+objCaseRef.Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c);
                    system.debug('===strKey_Asset==>'+strKey_Asset);
                    system.debug('===stTobeUpdatedAsset.contains(strKey_Asset)==>'+stTobeUpdatedAsset.contains(strKey_Asset));*/
                    if(objCaseRef.Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c !=null && !stTobeUpdatedAsset.contains(strKey_Asset)){
                        Asset objAsset = new Asset();
                        objAsset.Name = objCaseRef.Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c;
                        objAsset.Product2Id=objCaseRef.Core_IPS_Supported_Product__r.Core_Product__c;
                        objAsset.Core_IPS_Asset__c=true;
                        objAsset.core_alias__c=objCaseRef.Core_IPS_Supported_Product__r.Core_Supported_Product_Alias__c;
                        objAsset.recordtypeid = schema.sobjecttype.Asset.getrecordtypeinfosbyname().get('IPS Asset').getRecordTypeId();
                        objAsset.AccountId = objCaseRef.AccountId;
                        objAsset.Core_Product_Organization__c = objCaseRef.Core_IPS_Product_Org1__c;
                        objAsset.Core_Supported_Product__c = objCaseRef.Core_IPS_Supported_Product__c;
                        objAsset.Status = 'Inactive';
                        objAsset.InstallDate = system.today()-1;
                        objAsset.UsageEndDate = system.today();
                        
                        lstCreateAsset.add(objAsset);
                        stTobeUpdatedAsset.add(strKey_Asset);
                    }
                    lstCaseForReupdate.add(objCaseRef);
                }
            }
            //added by Sugandha to update new account to case for public products for DE39470            
            else if(objCaseRef.Core_IPS_Supported_Product__r.Core_IPS_Public_Product__c){                
                lstUpdateCase.add(objCaseRef);
            }
            //end
        }
        /*System.debug('Core_Contact_AccountChange_Handler.updateAssets====lstUpdateCase===>'+lstUpdateCase);
        System.debug('Core_Contact_AccountChange_Handler.updateAssets====lstCreateAsset===>'+lstCreateAsset);*/
        try{
            if(lstUpdateCase.size()>0){
                update lstUpdateCase;  
            }
            if(lstCreateAsset.size()>0){
                insert lstCreateAsset; 
                if(lstCaseForReupdate.size()>0){
                    Set<Id> staccIdNew = new Set<Id>();
                    for(Case objCase : lstCaseForReupdate){
                        staccIdNew.add(objCase.AccountId); 
                    }
                    updateAssetsToCase(lstCaseForReupdate,staccIdNew);
                }
            }
            
        }catch(Exception e){
            system.debug('Core_Contact_AccountChange_Handler.updateAssets Exception:'+e);
            throw e;
        }
        System.debug('*****>>End of updateAssetsToCase method<<****'); 
    }
    
    
    //Set the target accounts additional fields, currently IPS and B2B flags are setting as per the source contact/Account fields
    public static void updateTargetAccountAdditionalFields(List<Contact> lstNewContacts ){
        
        Set<Id> stConId = new Set<Id>();
        Set<Account> setAcc =new Set<Account>();
        for(Contact objConRef : lstNewContacts){
            stConId.add(objConRef.id);
        }
        List<Contact> lstContacts = [SELECT id,Core_IPS_Active__c,Core_Contact_B2B_Indicator__c,AccountId,Account.name,Account.Core_IPS_Active__c,Account.Core_B2B_Entitlement__c,Email FROM Contact Where Id IN : stConId ];
        
        for(Contact contactRef : lstContacts){
            Account acc=new Account();
            
            //Code to update IPS flag in account if the contact IPS flag is true
            if(contactRef.Core_IPS_Active__c == true && contactRef.Account.Core_IPS_Active__c == false ){
                acc.Id = contactRef.AccountId;
                acc.Core_IPS_Active__c = true;
            }
            
            //Set the Account.B2b indicator to true if it is false when the current contact B2B indicator is true
            if(contactRef.Core_Contact_B2B_Indicator__c == true && contactRef.Account.Core_B2B_Entitlement__c == false){
                acc.Id = contactRef.AccountId;
                acc.Core_B2B_Entitlement__c = true;
            }
            
            //Add acc Only if IPSFlag or B2B flag is set.
            if(String.isNotBlank(acc.Id))
                setAcc.add(acc);
        }  
        //Update account
        if(setAcc.size()>0)
            update new List<Account>(setAcc);
        
    }
    
     /*Pooja*/

    public static void UpdateintStatusLastUpdate(List<Contact> newList, Map<Id, Contact> oldList) {
        for(Contact conObj : newList) {
            if(oldList !=null){
            System.debug('### Contact Update Pooja1' + conObj.Core_ERPM_Integration_Status__c + '  Id :' + conObj.Id+'old status : '+oldList.get(conObj.Id).Core_ERPM_Integration_Status__c);
            if(conObj.Core_ERPM_Integration_Status__c != oldList.get(conObj.Id).Core_ERPM_Integration_Status__c) {
            
            conObj.Core_ERPM_Status_Change_Date_Time__c = System.now();
            }
            System.debug('### Contact Update Pooja2' + conObj.Core_AGS_Integration_Status__c + '  Id :' + conObj.Id+'old status : '+oldList.get(conObj.Id).Core_AGS_Integration_Status__c );
            
            if(conObj.Core_AGS_Integration_Status__c != oldList.get(conObj.Id).Core_AGS_Integration_Status__c) {
            conObj.Core_AGS_Status_Change_Date_Time__c = System.now();
            }
        }
    }
    }
    
    /*Pooja*/
}