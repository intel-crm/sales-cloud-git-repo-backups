/*********************************************************************************************************************
Apex Class Name  : PRM_RegRequest_TriggerHandler
Version       : 1.0
Created Date  : OCT 2018
Function      : 

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Kushal Soni               10/05/2018                    

*********************************************************************************************************************/
public without sharing class PRM_RegRequest_TriggerHandler extends TriggerHandler{
    /**
*  @description      : calls 'applyRecordType','dupCheck' and 'evStampCheck' method of 'PRM_RegistrationRequestUtility'
*  @name             : beforeInsert
*  @param            : NONE
*  @throws exception : NONE
**/
    public override void beforeInsert(){     
        
        if(isActive('Assign_Record_Type_to_Reg_Requests')){
            PRM_RegistrationRequestUtility.applyRecordType((List<PRM_Registration_Request__c>)Trigger.new);
        }
        if(isActive('EV_Stamp_Check')){
            PRM_RegistrationRequestUtility.evStampCheck((List<PRM_Registration_Request__c>)Trigger.new);
        }
        //LA check needs to be implemented for admin reg req at time of insertion (for AccountCreateReq--> in before update)
        if(isActive('Legal_Agreement_Check')){
            //String recordTypeId == Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId()
            PRM_RegistrationRequestUtility.updateLA((List<PRM_Registration_Request__c>)Trigger.new);
        }
        if(isActive('Admin_Reg_Approve')){
            PRM_RegistrationRequestUtility.approveAdminRegRecords((List<PRM_Registration_Request__c>)Trigger.new);
        }
    }
    
    /**
*  @description      : calls 'evCheck' method of 'PRM_ApplyRecordType'
*  @name             : beforeUpdate
*  @param            : NONE
*  @throws exception : NONE
**/
    public override void beforeUpdate(){
        
        //Rahul added for US664501
        //if(isActive('Reject_Duplicate_Results')){
            //PRM_RegistrationRequestUtility.rejectDuplicates((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
        //}
        
        //PRM_RegistrationRequestUtility.approve
        
        map<id,PRM_Registration_Request__c> regRequestOldMap = new map<id,PRM_Registration_Request__c>();
        regRequestOldMap=(map<id,PRM_Registration_Request__c>)trigger.oldMap;
        for(PRM_Registration_Request__c regRequest: (list<PRM_Registration_Request__c>)trigger.new){
            if(regRequest.PRM_Partner_Relationship__c == null || String.isBlank(regRequest.PRM_Partner_Relationship__c))
            {
                system.debug('inside IF@@');
                regRequest.PRM_Partner_Relationship__c = regRequestOldMap.get(regRequest.id).PRM_Partner_Relationship__c; 
            }
        }
        
        if(isActive('EV_Check')){
            PRM_RegistrationRequestUtility.evCheck((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
        }
        
        //Rahul added for US626612/US638396
        //if(isActive('Auto_Approve_User_Registration')){
            //PRM_RegistrationRequestUtility.autoApproveEndUserRegistration((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
        //}
        
        if(isActive('Legal_Agreement_Check')){
            PRM_RegistrationRequestUtility.updateLA((List<PRM_Registration_Request__c>)Trigger.new);
        }
        
        if(isActive('Dup_Check')){
            PRM_RegistrationRequestUtility.dupCheck((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
        }
        
        //Harshit added on 30/7/2019 , as part of US406788 
        if(isActive('Populate_Approval_Link'))
        {
            PRM_RegistrationRequestUtility.setApprovalLink((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap); 
        }
        
         if(isActive('Registration_Profile_Response')){
            PRM_RegistrationRequestUtility.regResponse((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
        }
       
        // Code for calling CIM on Duplicate Account status update
        if(isActive('Dup_Check')){
            List<PRM_Registration_Request__c> newRegReqList = new List<PRM_Registration_Request__c>();
            map<PRM_Registration_Request__c,string> regReqEmailIds = new map<PRM_Registration_Request__c,string>();
            Map<String,Contact> cntEmailMap = new Map<String,Contact>();
            Set<String> regEmail = new Set<String>();
            for (PRM_Registration_Request__c regReqNewCnt: (List<PRM_Registration_Request__c>)Trigger.new) {
                regEmail.add(regReqNewCnt.PRM_Email_ID__c); 
            }
            for(Contact con: [Select Id, Email from Contact where Email in: regEmail]){
                cntEmailMap.put(con.Email,con);
            }
            for (PRM_Registration_Request__c regReqNew: (List<PRM_Registration_Request__c>)Trigger.new) {
                
                PRM_Registration_Request__c regReqOld = (PRM_Registration_Request__c)Trigger.oldMap.get(regReqNew.ID);
                
                if(regReqOld.PRM_Dup_Status__c == System.Label.PRM_Error &&  regReqNew.PRM_Dup_Status__c==System.Label.PRM_NOTPROC){
                    
                    System.debug('CALL CIM AGAIN TRIGGER');
                    //PRM_RegistrationRequestUtility.dupCheck((List<PRM_Registration_Request__c>)Trigger.new);
                    newRegReqList.add(regReqNew);
                    
                    // Code for checking the duplicate contact
                    if(cntEmailMap!= null && cntEmailMap.containsKey(regReqNew.PRM_Email_ID__c)){
                        regReqNew.PRM_Matching_Contact__c = cntEmailMap.get(regReqNew.PRM_Email_ID__c).Id;
                    }  
                    
                }
                
            }
            System.debug('newRegReqList'+newRegReqList);
            if(newRegReqList!= null && newRegReqList.size()>0) PRM_RegistrationRequestUtility.dupCheck(newRegReqList,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
        }
        
        //Added by bishal as part of US626882/US638376/US638377
        /*if(isActive('Auto_Approval')){
          PRM_RegistrationRequestUtility.autoApprovalOnPartnerRole((List<PRM_Registration_Request__c>)Trigger.new);
        }*/
        
        //Rahul added for US626612/US638396
        //creating end user registration related records
        //if(isActive('Create_Records_On_Approval')){
            //PRM_RegistrationRequestUtility.createRelatedRecords((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
        //}
    }
    public override void afterInsert(){
        //if(isActive('Dup_Check')){
        //  PRM_RegistrationRequestUtility.dupCheck((List<PRM_Registration_Request__c>)Trigger.new);
        //}
        if(isActive('EmailNotificationOnAccountCreation')){
            List<Sobject> objectList = new List<Sobject>();
            for (SObject registrationRequest : Trigger.new) {
                objectList.add(registrationRequest);
            }
            PRM_RegistrationRequestUtility.sendEmailNotification(objectList, 'EmailNotificationOnAccountCreation');
        }
        // Only for EV recordType 
        if(isActive('EmailNotificationOnReceivingRegistration'))
        {
            PRM_RegistrationRequestUtility.EmailNotificationOnReceivingRegistration((List<PRM_Registration_Request__c>)Trigger.new);
        }
        //if(isActive('Registration_Profile_Response')){
          //  PRM_RegistrationRequestUtility.regResponse((List<PRM_Registration_Request__c>)Trigger.new);
        //}
        if(isActive('Process_Admin_Registration')){
            PRM_RegistrationRequestUtility.processAdminRegistrationRecords((List<PRM_Registration_Request__c>)Trigger.new);
            
        }
        
        if(isActive('Admin_Reg_Approve')){            
            //System.enqueueJob(new PRM_AccountACRUpdateQueueable(Trigger.newMap));
            PRM_RegistrationRequestUtility.updateRelatedACROfAccount(Trigger.newMap);
        }
    }
    public override void afterUpdate(){
        if(isActive('EmailNotificationOnAccountCreateRequest')){
            PRM_RegistrationRequestUtility.sendEmailOnReceivingAccountCreateRequest((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
        }
       // System.debug('Callme');
       // PRM_RegistrationRequestUtility.sendMailtoPrimaryContactAfterSecondaryReq((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
    }
    
}