/*********************************************************************************************************************
Apex Class Name  : PRM_PSG_RegistrationReqUtility
Version       : 1.0
Created Date  : JULY 2021
Function      : Utility class containing business logic for PSG Registration Requests

Modification Log :
* Developer                                             Date               Description
* ----------------------------------------------------------------------------------------------------------------------------------------------
* Mansi Mundhra/Gopikrishna Vankadari                   08/07/2021         Utility class containing business logic for PSG Registration Requests
************************************************************************************************************************************************/
@isTest
public class PRM_PSG_RegistrationReqUtility {
    /**
* @description      : It checks If EV is completed and Contact exists in SF
* @name             : checkEVAndContactExistance
* @param            : List<PRM_Registration_Request__c>, Map<Id,PRM_Registration_Request__c>
* @throws exception : NONE
**/  
/*
    public static void checkEVAndContactExistance(List<PRM_Registration_Request__c> regReqList, Map<Id,PRM_Registration_Request__c> oldRegReqMap){        
        Id accountCreateRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        Set<String> emailIdSet= new Set<String>(); 
        //List<PRM_Registration_Request__c> regRequestList = new List<PRM_Registration_Request__c>();
        String partnerProgram;
        
        for(PRM_Registration_Request__c regReq: regReqList){
            partnerProgram =regReq.PRM_Channel_Program_Level_txt__c;
            
            //If it is a PSG request and registration request is updated with PRM_EmailVerifiedDateTime__c:
            //1.Update Recordtype to AccountCreateRequest
            //2.Change the status to Approved
            if(partnerProgram==System.Label.PSG_Licensing ){
                regReq.OwnerId = System.Label.PSG_Group_id;  
                 
                    regReq.RecordTypeId=accountCreateRequestRT; 
                    regReq.PRM_Legal_Agreement_Criteria__c = 'SUCCESS';
                    regReq.PRM_Status__c = System.Label.PRM_Status;  //Updating Status to Approved 
                    if(regReq.PRM_Email_ID__c!=null && regReq.PRM_Email_ID__c!=''){
                        emailIdSet.add(regReq.PRM_Email_ID__c);    
                    }                
                    //Checking if Contact Exists in SalesforceContact
                    if(emailIdSet!=Null && !emailIdSet.isEmpty()){
                        Map<Id,Contact> contactMap =new Map<Id,Contact>([select id,Email,AccountId,FirstName,LastName from contact where email in :emailIdSet]);
                        
                        //if(!contactMap.isEmpty()){
                            for(Contact con :contactMap.values()){
                                regReq.PRM_Contact_Salesforce_Id__c =con.id; 
                                regReq.PRM_Salesforce_ID__c =con.AccountId;
                            }
                            checkForPSGEntExistence(contactMap);
                        //}
                        
                        createContactforPSG(regReq,contactMap);
                    }
                }
              
        } 
        
    }
   
    public static void createContactforPSG(PRM_Registration_Request__c regreq,Map<Id,Contact> contactMap){
        Set<String> legalAgrmntValues = new Set<String>();
        Map<String,PRM_Registration_Request__c> regReqMap = new Map<String,PRM_Registration_Request__c>();
        regReqMap.put(regreq.PRM_Email_ID__c, regreq);
        if(!String.isEmpty(regreq.PRM_Legal_Agreements__c)){
            legalAgrmntValues.addAll(regreq.PRM_Legal_Agreements__c.split(';'));
        }
        
        // If Contact doesn't exist in SF. Create a Contact and Assign to Default PSG account
        if(regreq.PRM_Contact_Salesforce_Id__c==Null && contactMap.isEmpty()){
            Contact ct = new Contact();
            ct.FirstName = regreq.PRM_First_Name__c;
            ct.LastName = regreq.PRM_Last_Name__c;
            ct.Email = regreq.PRM_Email_ID__c;
            //ct.Core_Login_Id__c=regreq.PRM_Contact_Login_ID__c!=Null?regreq.PRM_Contact_Login_ID__c:regreq.PRM_Email_ID__c;
            ct.Core_Preferred_Language__c=regreq.PRM_Preferred_Language__c!=Null ? regreq.PRM_Preferred_Language__c:'ENG';
            ct.Core_Enterprise_Id__c=regreq.PRM_Enterprise_ID__c != Null ? regreq.PRM_Enterprise_ID__c:null;
            ct.Phone=regreq.PRM_Person_Phone_Number__c != Null ? regreq.PRM_Person_Phone_Number__c:null;
            ct.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.Label.PSG_Intel_Contact).getRecordTypeId();            
            ct.AccountId = Label.PRM_PSG_Account_id;
            ct.Core_Profession__c=regreq.PRM_Profession__c;
            Account acc=[select id,BillingCountry,BillingCountryCode,BillingState from Account where id=:Label.PRM_PSG_Account_id];
            ct.MailingCountry=regreq.PRM_Contact_Country__c!=null?regreq.PRM_Contact_Country__c:acc.BillingCountry;
            Integer i=1;
            While(i<=3){
                try{
                    insert ct;
                    contactMap.put(ct.Id,ct);
                    regReq.PRM_Contact_Salesforce_Id__c=ct.Id;
                    regReq.PRM_Salesforce_ID__c =Label.PRM_PSG_Account_id;
                    break;
                }catch(Exception e){
                    String errMsg=e.getMessage();
                    if(errMsg.containsIgnoreCase('UNABLE_TO_LOCK_ROW') && i<3){
                        i++;
                    }else{
                        PSG_Utility.createCoreLogEntry('PRM_PSG_RegistrationReqUtility', 'createContactforPSG', 'Error while creating SSLC contact','Error Msg : '+errMsg+' Contact Details : '+ ct, 'Contact', 'High', null);
                        throw e;
                    }
                }
            }
        }
        if(!contactMap.isEmpty()){           
            assignPSGEntitlements(contactMap); //Assign the PSG entitelment            
            insertPSGLegalAgreements(contactMap, regReqMap, legalAgrmntValues); //Check and Assign PSG T&C
        }
    }
    
    public static void assignPSGEntitlements(Map<Id,Contact> contactMap){
        List<Core_Contact_Entitlement__c> contactEntitlemtLst = new List<Core_Contact_Entitlement__c>();
        Set<Id> addedEntlmnt = new Set<Id>();
        String PSGEntitelmentName =System.Label.PRM_PSG_Entitlement_Name;
        //List<PRM_VXEnttlmntMatrix__c> vxEntmatLst = new List<PRM_VXEnttlmntMatrix__c>();
        for( PRM_VXEnttlmntMatrix__c vxEntMat : [select id, name,PRM_AGS_Role__c, PRM_Approval_Type_Nm__c, PRM_Channel_Program_Id__r.name,PRM_Channel_Program_Level_Id__r.name,PRM_Contact_Relationship_Id__r.name,PRM_Entitlement_Id__r.name, PRM_IsActive_Ind__c from PRM_VXEnttlmntMatrix__c where PRM_Entitlement_Id__r.name =: PSGEntitelmentName]){            
            addedEntlmnt.add(vxEntMat.PRM_Entitlement_Id__c);
        } 
        
        for(Id entId : addedEntlmnt){
            Core_Contact_Entitlement__c ce;            
            for(Contact con : contactMap.values()){
                ce = new Core_Contact_Entitlement__c();
                ce.Core_Contact_Id__c = con.id;
                ce.Core_Entitlement_Id__c= entId;
                //ce.Core_Unique_Id__c = String.valueOf(con.id).left(15)+String.valueOf(con.id).left(15);//ctId+''+entId; 
                ce.Core_Selected__c=true;
                ce.Core_Status__c ='Pending';
                ce.Core_Data_Loaded__c=true;
                ce.Core_Source__c = 'PSG Registration';
                if(contactEntitlemtLst!=null && !contactEntitlemtLst.contains(ce)){
                    contactEntitlemtLst.add(ce);
                }
            }            
        }        
        
        List<Core_Contact_Entitlement__c> failedList=new List<Core_Contact_Entitlement__c>();
        
        if(contactEntitlemtLst!=null && !contactEntitlemtLst.isEmpty()){    
            Database.SaveResult [] srList = Database.insert(contactEntitlemtLst, false);
            for(Integer i=0;i<srList.size();i++){
                    if(!srList[i].isSuccess()){
                        failedList.add(contactEntitlemtLst[i]);
                    }
                }         
        } 
        
        if(!failedList.isEmpty()){
            
            PSG_Utility.createCoreLogEntry('PRM_PSG_RegistrationReqUtility', 'assignPSGEntitlements', 'Error while Assignment','Failed Records '+failedList, 'Core_Contact_Entitlement__c', 'High', null);
        }
    } 

    public static void checkForPSGEntExistence(Map<Id,Contact> contactMap){
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        String PSGEntitelmentName =System.Label.PRM_PSG_Entitlement_Name;
        for(Core_Contact_Entitlement__c ce : [select id, Core_Entitlement_Nm__c,Core_Status__c,Core_Selected__c from Core_Contact_Entitlement__c where Core_Entitlement_Nm__c =: PSGEntitelmentName and Core_Contact_Id__c IN: contactMap.KeySet()]){
            if(ce.Core_Status__c == 'Complete' && ce.Core_Selected__c == false){
                ce.Core_Selected__c = true;
                ce.Core_Status__c = 'Pending';
                ce.Core_Data_Loaded__c=true;
                ceList.add(ce);
            }
        }
        if(ceList!=null && !ceList.isEmpty()){
            Database.SaveResult [] srList = Database.update(ceList, false);
        }
    } 
    
    public static void insertPSGLegalAgreements(Map<Id,Contact> contactMap, Map<String,PRM_Registration_Request__c> regReqMap, Set<String> legalAgrmntValues){
        if(regReqMap.size() > 0 && legalAgrmntValues.size() > 0){
            List<PRM_AccountLegalAgreemntAssociation__c> accLAs = new List<PRM_AccountLegalAgreemntAssociation__c>();
            Map<String,Id> legalAgrmntMap = new Map<String,Id>();
            //Map<Id,Set<String>> contactLAAssocs = new Map<Id,Set<String>>();
            Map<String,Set<String>> contactLAAssocs = new Map<String,Set<String>>();
            
            for(PRM_PartnerAgreement__c pa : [Select Id,Name,PRM_Agreement_Cd__c from PRM_PartnerAgreement__c where PRM_Agreement_Cd__c IN : legalAgrmntValues]){
                legalAgrmntMap.put(pa.PRM_Agreement_Cd__c,pa.id);
            }

            //IPA 2.0 - TWC729-7874
            List<PRM_AccountLegalAgreemntAssociation__c> AcctLegalAgr = new List<PRM_AccountLegalAgreemntAssociation__c>();
            List<String> ListOfContactEmail = new List<String>();
            for( Contact con : contactMap.values()){
                ListOfContactEmail.add(con.Email);
            } 

            AcctLegalAgr = [SELECT id,PRM_Signed_By_Name__c,PRM_Signed_By_Email__c,PRM_Partner_Agreement_Id__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c  
                            FROM PRM_AccountLegalAgreemntAssociation__c 
                            WHERE PRM_Signed_By_Email__c IN :ListOfContactEmail AND PRM_Partner_Agreement_Id__c in : legalAgrmntMap.values() AND PRM_InActive_Ind__c = false];
            
            for(PRM_AccountLegalAgreemntAssociation__c legalAgrment : AcctLegalAgr)
            {
                if(contactLAAssocs.containsKey(legalAgrment.PRM_Signed_By_Email__c)){
                    contactLAAssocs.get(legalAgrment.PRM_Signed_By_Email__c).add(legalAgrment.PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c);
                }else{
                    contactLAAssocs.put(legalAgrment.PRM_Signed_By_Email__c, new Set<String>{legalAgrment.PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c});
                }
            }   
            //IPA 2.0 - TWC729-7874 - end                                                         
            
            for(Contact cont: contactMap.values()){
                String legalAgrmnts = regReqMap.containsKey(cont.Email) ? regReqMap.get(cont.Email).PRM_Legal_Agreements__c : null;
                if(!String.isEmpty(legalAgrmnts)){
                    for(String legalagrmnt :  legalAgrmnts.split(';')){
                        
                        if(legalAgrmntMap.containsKey(legalagrmnt) && (!contactLAAssocs.containsKey(cont.Email) || (contactLAAssocs.containsKey(cont.Email) && !contactLAAssocs.get(cont.Email).contains(legalagrmnt)))){
                            
                            PRM_AccountLegalAgreemntAssociation__c acntLegalAgrAssoc = new PRM_AccountLegalAgreemntAssociation__c();
                            acntLegalAgrAssoc.PRM_Partner_Agreement_Id__c = legalAgrmntMap.get(legalagrmnt);
                            acntLegalAgrAssoc.PRM_Account_Id__c = cont.AccountId ;
                            // IPA 2.0 - TWC729-7874-start
                            acntLegalAgrAssoc.PRM_Signed_By_Email__c = cont.Email;
                            acntLegalAgrAssoc.PRM_Signed_By_Name__c = cont.FirstName+' '+cont.LastName;
                            // IPA 2.0 - TWC729-7874-end 
                            acntLegalAgrAssoc.PRM_Agreement_Sign_Dt__c = System.Now();
                            accLAs.add(acntLegalAgrAssoc);
                        }
                    }
                    if(accLAs.size() > 0){
                        insert accLAs;
                    }
                }
            }  
        }
    }
    
    @InvocableMethod(label='Send Welcome Email to PSG Contact' description='Sends Welcome Email to PSG contacts once PSG Entitlement is Marked completed')
    public static void sendWelcomeEmailForPSG(List<Id> contactIds){
        try{
            list<PRM_EmailUtility.EmailNotification> objEmailNotifList=new list<PRM_EmailUtility.EmailNotification> ();                              
            List<String> contEmailList=new List<String>();
            if(contactIds.size() > 0){
                List<Contact> contacts = [SELECT id,FirstName,Core_Preferred_Language__c,Email,Account.Name FROM Contact WHERE id IN :contactIds];
                if(contacts.size() > 0){
                    for(Contact cont : contacts){
                        PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();  
                        objEmailNotif.ChannelProgram=System.Label.PSG_Licensing;        
                        objEmailNotif.EmailID= cont.Email ;*/
                        /*if(cont.Core_Preferred_Language__c!=Null){
                            objEmailNotif.Language = cont.Core_Preferred_Language__c;
                        }else{
                            objEmailNotif.Language = 'ENG';
                        }*/ //Athr fixes
                        /*objEmailNotif.Language=cont.Core_Preferred_Language__c!=null?cont.Core_Preferred_Language__c:'ENG';

                        Map<String,String> paramMap = new Map<String,String>();
                        paramMap.put('EV_Contact_ID',cont.Id);
                        objEmailNotif.InputParameters=paramMap;
                        objEmailNotif.BusinessEvent= Label.PSG_Welcome_email_on_request_approval_New;
                        PRM_EmailUtility.customPlaceholdersMap = new Map<String,String>{'{{ACCOUNTNAME}}' => cont.Account.Name};
                            //PRM_EmailUtility.sendEmail(objEmailNotif);  
                            //added as part of governor limit story:4380
                            //PRM_EmailUtility.sendEmail(new List<PRM_EmailUtility.EmailNotification> {objEmailNotif}); 
                            objEmailNotifList.add(objEmailNotif);
                        contEmailList.add(cont.Email);
                        //PRM_createAccountandRelatedRecords.linkEmailLogToContact(cont.Email);
                    }
                }
            }         
            if(!objEmailNotifList.isEmpty()){
                PRM_EmailUtility.sendEmail(objEmailNotifList); 
            }
            if(!contEmailList.isEmpty()){
                PRM_createAccountandRelatedRecords.linkBulkEmailLogToContact(contEmailList);
            }
        }
        catch(Exception exp){
            System.debug('Exception'+exp.getMessage());
        }        
    }
*/    //TWC729-8986 - PSG code removal from PRM classes
}