/********************************************************************************************************************
Class Name    : Sales_NonIPSCaseCreation
Version       : 1.0
Created Date  : July 2021
Project       : SALES Project
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Chaithanya Lakshman       05.07.2021              NonIPSCaseCreation class
*----------------------------------------------------------------------------------------------------------*/
@isTest
public without sharing class Sales_NonIPSCaseCreation {
    /*private static final string ORIGIN = 'Sales_NonIPSCaseCreation';
    private static final string SEVERITY = 'info';
    private static final string PROJECT = 'Sales';
    public static final String FROM_EMAIL=System.label.sales_NonIpsFromemail; 
    public static final String SENT_EMAIL=System.label.sales_NonIpsToemail; 
    @AuraEnabled (cacheable=true)
    public static List<pickListWrapper> fetchNonIPSCaseCreation() {
        List<pickListWrapper> tempWrapperList = new List<pickListWrapper>();
        for(Sales_Non_IPS_Service__mdt temp: [SELECT Id,Type_of_License_Issue__c FROM Sales_Non_IPS_Service__mdt  where Active__c = true order by Type_of_License_Issue__c]){
            tempWrapperList.add(new pickListWrapper(temp.Type_of_License_Issue__c,temp.Type_of_License_Issue__c));
        }
        return tempWrapperList;
    }
    @AuraEnabled
    public static String validateFieldsCaseCreation(String po,String serialnumber,String hostid,String description,String productName,String subject){
        List<Order> orderList = new List<Order>();
        List<Sales_License__c> licenseList = new List<Sales_License__c>();
        List<Sales_Host__c> hostList = new List<Sales_Host__c>();
        String errorMsg = '';
        if(String.isNotBlank(po)){
            orderList = new List<Order>([SELECT Id from Order where Sales_PO_Number_Txt__c =:po]);
            if(orderList.isEmpty()){
                errorMsg = 'PO';
            }
        }
        if(String.isNotBlank(serialnumber)){
            licenseList = new List<Sales_License__c>([SELECT Id from Sales_License__c where Sales_License_Activation_Code__c =:serialnumber]);
            if(licenseList.isEmpty()){
                if(String.isNotBlank(errorMsg)){
                    errorMsg = errorMsg + ' ,'+'SerialNumber';
                }else{
                    errorMsg = 'SerialNumber';
                }
            }
        }
        if(String.isNotBlank(hostid)){
            hostList = new List<Sales_Host__c>([SELECT Id from Sales_Host__c where Temporary_NIC_ID__c=: hostid OR Name=:hostid]);
            if(hostList.isEmpty()){
                if(String.isNotBlank(errorMsg)){
                    errorMsg = errorMsg + ' ,'+'NIC/Host Id/Guard Id';
                }else{
                    errorMsg = 'NIC/Host Id/Guard Id';
                }
            }
        }
        if(String.isNotBlank(errorMsg)){
            errorMsg = errorMsg + ' entered is invalid';
        }else{
            errorMsg = 'success';
            sendEmail(po,serialnumber,hostid,description,productName,subject);
        }
        return errorMsg;
    }
    public static void sendEmail(String po,String serialnumber,String hostid,String description,String productName,String subject){
        OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address=:FROM_EMAIL];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       mail.setToAddresses(new List<String>{SENT_EMAIL}); 
       mail.setOrgWideEmailAddressId(orgWideEmailAdd.Id); 
        Sales_Non_IPS_Service__mdt subjectline=[SELECT Id,Type_of_License_Issue__c,Subject__c FROM Sales_Non_IPS_Service__mdt  where Active__c = true AND Type_of_License_Issue__c =:subject ];
        String subjectemail=subjectline.Subject__c;
            mail.setSubject(subjectemail+'(from SSLC form)');
        User u1=userManagement();
        String emailBody = '{'+'<br/>';
        emailBody = emailBody + '\"Description\": {'+'<br/>';
        emailBody = emailBody + '\"Contact Email\": \"'+u1.Contact.Email+'\",'+'<br/>';
        emailBody = emailBody + '\"License Activation Code/Serial No\": \"'+serialnumber+'\",'+'<br/>';
        emailBody = emailBody + '\"Description\": \"'+description+'\",'+'<br/>';
        emailBody = emailBody + '\"Contact Name\": \"'+u1.Contact.Name+'\",'+'<br/>';
        emailBody = emailBody + '\"Product Name\": \"'+productName+'\",'+'<br/>';
        emailBody = emailBody + '\"NIC/Host/Guard ID\": \"'+hostid+'\",'+'<br/>';
        emailBody = emailBody + '\"PO": \"'+po+'\"'+'<br/>';
        emailBody = emailBody + '},'+'<br/>';
        emailBody = emailBody +'\"subject\": \"'+subjectemail+'\"'+'<br/>';
        emailBody = emailBody +'}';
        mail.setHtmlBody(emailBody);
        emailBody.deleteWhitespace();
        Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY,null, emailBody,null,'NON IPS EMAIL', '');
    }
    @AuraEnabled
    public static Boolean checkIPSUser(){
        User u1=userManagement();
        if(u1.Contact.Core_IPS_Active__c == true){
            return true;
        }else{
            return false;
        }
    }
     @AuraEnabled
    public static Boolean checkExternal(){
        User u1=userManagement();
        if(u1.usertype == 'PowerPartner'){
            return true;
        }else{
            return false;
        }
    }
    public static User userManagement(){
        User u1 = [SELECT Id,Contact.Core_IPS_Active__c,Contact.Email,Contact.Name,usertype from User where Id =: userInfo.getUserId()];
        return u1;
    }
    public without sharing class pickListWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public pickListWrapper(String label,String value){
            this.label = label;
            this.value = value;
        }
    }*/
}