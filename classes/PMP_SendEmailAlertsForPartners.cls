/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_SendEmailAlertsForPartners
* Description : Stores the logic for sending the email for all partner email scenarios.
* Version     : 1.0 
* Created Date: 20-Nov-2020
* Modification Log :
* Created By  : Priyanka (Infosys)
********************************************************************************************************************************************************************************************************/

public without sharing class PMP_SendEmailAlertsForPartners {
    //wrapper which holds the offerings and submitter and template details
    public class SendEmailRequestWrapper {
        @InvocableVariable(label='Partner Id' description='Partner Id Captured here' required=true)
        public Id partnerId;
        @InvocableVariable(label='Template Name' description='Template Name is Captured here' required=true)
        Public String templateName;
    }
    //ipa 2.0
	 public String headerMessage {get;set;}
	  //Logic to access image from documents folder 
    public String headerURL;  
    public String getHeaderURL(){
        
        String domainName;
        String orgId;
        Document document;
        
        
        document = [select Id from Document where Name='IntelLogo' LIMIT 1];
        
        
        //domainName = String.valueOf(URL.getSalesforceBaseUrl().toExternalForm());
        //below line added as part of the logo issue in email template - by priyanka 
        domainName=String.valueOf(System.Url.getOrgDomainUrl().toExternalForm());
        orgId = UserInfo.getOrganizationId();
        
        if(document!=Null){
            headerURL =domainName+'/servlet/servlet.ImageServer?id=' + document.Id + '&oid=' + orgId;
            
            
        }
        
        return headerURL;
    }
    
    /*******************************************************************************************************************************************************************************************************
* Method Name : sendOfferingEmailNotifications
* Description : This method will send the email to all offering email scenarios and it is invoked by a process builder -PMP_Company_Change_Alerts
* Params	  : SendEmailRequestWrapper[] , which contains template name , partner id, submitter id
* Version     : 1.0 
* Created Date: 20-Nov-2020
* Modification Log :
* Created By  : Priyanka (Infosys)
********************************************************************************************************************************************************************************************************/
    
    @InvocableMethod(label='Send Emails for Partners' description='Sends the email to recent submitter of Partner')
    public static void sendPartnerEmailNotifications(List<SendEmailRequestWrapper> partnerAndSubmitterDetails) {
        //fetch the template name
        String templateName=partnerAndSubmitterDetails[0].templateName;
        
        //to capture the partners whose submitter is inactive, so that mail can be send to all PA's
        Map<Id,Id> inActivatedUsersAndPartnerMap= new Map<Id,Id>();
        
        //Map will store all the submitter-Partner Id
        Map<Id,Id> submitterPartnerIdMap = new Map<Id,Id>();
        
        //All partner Ids recieved from process builder
        List<Id> partnerIds= new List<Id>();
        
        //user and partner object map which holds the return value from fetchUsersMapFromPagMember method
        Map<Id,Id> userCompanyMap = New Map<Id,Id>();
        
        //partner Id and Partner map, this is used in inactive scenarios to fetch company records using the partner id
        Map<Id,PMP_Company__c> partnerIdAndPartnerMap= new Map<Id,PMP_Company__c>();
        
        
        //get all the parner ids from process builder, this variable used in query to filter the partners
        for(SendEmailRequestWrapper req: partnerAndSubmitterDetails){
            partnerIds.add(req.partnerId);
        }
        List<PMP_Company__c> partnersList= new List<PMP_Company__c>();
        if(PMP_Company__c.SObjectType.getDescribe().isAccessible()){
             partnersList=[SELECT id,PMP_Partner_Submitter_UserId__c,PMP_Account_Id__c from PMP_Company__c  WHERE Id IN:partnerIds ];
            }
        //form the submitter and partner id map , and submitterPartnerIdMap is send to the sendEmailAndLogData method
        for(PMP_Company__c partner:partnersList){
            if(partner.PMP_Partner_Submitter_UserId__c!=null){
                submitterPartnerIdMap.put(partner.PMP_Partner_Submitter_UserId__c,partner.Id);
                partnerIdAndPartnerMap.put(partner.Id, partner);
            }
        }
        
        
        If(!submitterPartnerIdMap.keySet().isEmpty()){ //check if map is not empty
            //all submitters including inactive users
            Set<Id> userIds= submitterPartnerIdMap.keySet();
            
            //get only the active users out of userIds
            List<Id> activeUsers =PMP_Utility.getActiveUsers(userIds);
            
            //remove inactive users from submitterPartnerIdMap which will be send to sendEmailAndLogData for  sending email.
            for(Id userId:userIds){
                if(!activeUsers.contains(userId)){
                    inActivatedUsersAndPartnerMap.put(userId,submitterPartnerIdMap.get(userId));
                    submitterPartnerIdMap.remove(userId);
                }
            }
            
            // to send the email to recent submitter and log the email to associated offering.
            if(!submitterPartnerIdMap.keySet().isEmpty()){

                PMP_Utility.sendEmailAndLogData(templateName, submitterPartnerIdMap);
                
            }
         }
        
        //Sending Email to all PA's of that partners if submitter is inactive
        sendEmailToAllPAs(inActivatedUsersAndPartnerMap,templateName,userCompanyMap,partnerIdAndPartnerMap); 
   
        
    }
    public static void sendEmailToAllPAs(Map<Id,Id> inActivatedUsersAndPartnerMap,String templateName,Map<Id,Id> userCompanyMap, Map<Id,PMP_Company__c> partnerIdAndPartnerMap){
             if(inActivatedUsersAndPartnerMap.keySet().size()>0){ // check if we have some partner whose submitter is inactive 
            
            Core_Apex_EmailNotification__c apexEmailRec = New Core_Apex_EmailNotification__c();
            
            //Apex Notificcation record name           
            String apexEmailRecName = templateName;  
            
            //querying apexEmail to get the permission sets required on user to send email
            apexEmailRec = PMP_Utility.getApexEmailRecord(apexEmailRecName);
            
            //fetch permission set to send email for users of those permissionset 
            List<string> allowedPermissionSets = New List<string>(); //allowed permission sets are stored in the apexEmailRec  as comma seperate values    
            allowedPermissionSets = apexEmailRec.Core_Allowed_Permission_Nm__c.split(',');
            List<PMP_Company__c> comInfoList= new List<PMP_Company__c>();
            
            //add all companies for which email has to be send to all PA's
            for(Id partnerId:inActivatedUsersAndPartnerMap.values()){
                comInfoList.add(partnerIdAndPartnerMap.get(partnerId));
            }
            
            //fetch users to send the email
            userCompanyMap = PMP_Utility.fetchUsersMapFromPagMember(comInfoList, allowedPermissionSets);
            
            //Filter Inactive PA's
            userCompanyMap = PMP_Utility.removeInactiveUsers(userCompanyMap);
            
            
            //Send emails to all actives PA's
            if(!userCompanyMap.keySet().isEmpty()){
                PMP_Utility.sendEmailAndLogData(templateName, userCompanyMap);  
            }  
        }
        
    }
}