/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 06-16-2025
* @last modified by  : Bharath Chandrashekar
**/
public without sharing class Pricing_QuoteEmailAlertController {
    //Logic to access image from documents folder
    public Id quoteId {get;set;}
    public Id quoteLineId {get;set;}
    public SBQQ__Quote__c quoteData;
    public SBQQ__QuoteLine__c quoteLineData;
    public Id quotesIds {get;set;}
    public List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
    public Boolean isValidAE {get;set;}
    private List<SBQQ__Quote__c> quoteDataToBeDisplayed = new List<SBQQ__Quote__c>();
    private List<SBQQ__QuoteLine__c> quoteLineDataToBeDisplayed = new List<SBQQ__QuoteLine__c>();
    public List<Pricing_Quote_Line_Status_Age__c> tptRecs = new List<Pricing_Quote_Line_Status_Age__c>();
    public String stageActorEmail {set;get;}
    public String changedFields {set;get;}
    public static String qlEndDate {set;get;}
    public static String qlStartDate {set;get;}
    public static String newQuantity {set;get;}
    public static String newRequestedPrice {set;get;}
    public static Integer quoteLineRequestedQuantity {set;get;}
    public static Integer totalRequestedQuantity {set;get;}
    //public String currentPrimaryContact {set;get;}
    public date currentDate {set;get;}
    public String headerURL;
    public List<String> approverEmailList = new List<String>();
    
    //Added by Vishal Sharma 
    public static Boolean isRecallMail{set;get;}
    public static Set<String> toEmail = new Set<String>();
    public static Set<String> ccEmail = new Set<String>();
    public static Set<String> bccEmail = new Set<String>();
    
    
    //// Added by Naresh
    public Id qtmId {get;set;}
    public String agsFilter {set;get;}
    public Pricing_Quote_Team__c qtmData;  
    public Pricing_Quote_Team_Role_Access_Mapping__mdt roleMap {set;get;}
    

    public String gettoEmails(){
        set<String> toEmailsSet = new set<String>();
        toEmailsSet.addAll(toEmail);
       String toEmails = splitEmails(toEmailsSet);
        
        return toEmails;
    }
    public String getccEmails(){
       set<String> ccEmailsSet = new set<String>();
        ccEmailsSet.addAll(ccEmail);
       String ccEmails = splitEmails(ccEmailsSet);//= String.join(new List<String>(ccEmail), ',');
    
        return ccEmails;
    }
    public String getbccEmails(){
       set<String> bccEmailsSet = new set<String>();
        bccEmailsSet.addAll(bccEmail);
       String bccEmails = splitEmails(bccEmailsSet);//= String.join(new List<String>(bccEmail), ',');
    
        return bccEmails;
    }
    
    public Static String splitEmails(Set<String> emails){
        String result = '';
		Integer counter = 0;
        for (String item : emails) {
             if (counter > 0) {
                result += '; '; // Added a semi colon for separation
            }
    		result += item;
    		counter++;
		}
        return result;
    }
    
    public String getHeaderURL(){
        String domainName;
        String orgId;
        
        Document document;            
        document = [select Id from Document where Name=:Label.Pricing_IQR_Intel_Logo LIMIT 1];
        domainName = String.valueOf(System.Url.getOrgDomainUrl());
        domainName = domainName.split('=')[1].split(']')[0];
        orgId = UserInfo.getOrganizationId();
        headerURL = domainName + '/servlet/servlet.ImageServer?id=' + document.Id + '&oid=' + orgId;
        return headerURL;
    }
    //Method to get the domain name
    public String getDomainName(){
        String domainName;          
        // domainName = String.valueOf(URL.getSalesforceBaseUrl().toExternalForm());
        domainName =  String.valueOf(System.Url.getOrgDomainUrl());
        domainName = domainName.split('=')[1].split(']')[0];
        return domainName;
    }
    
    public String getExternalDomainName(){
        String externalDomainName;          
        Network site = [Select id from Network where Name =: Label.Pricing_Tenders_Community_Name];
        externalDomainName = Network.getLoginUrl(site.Id);
        externalDomainName = externalDomainName.removeEnd('/login');
        return externalDomainName;
    }
    public String getDealRegExternalDomainName(){
        String dealRegExternalDomainName;          
        Network site = [Select id from Network where Name =: Label.Pricing_DealReg_Community_Name];
        dealRegExternalDomainName = Network.getLoginUrl(site.Id);
        dealRegExternalDomainName = dealRegExternalDomainName.removeEnd('/login');
        return dealRegExternalDomainName;
    }
    
    //Method To fetch Quote data to be displayed in email Template
    public SBQQ__Quote__c getQuoteData() {
        isValidAE = false;
        quoteDataToBeDisplayed = new List<SBQQ__Quote__c>([SELECT Id,Name,Owner.Name,LastModifiedBy.Name,Pricing_Account_Executive_Nm__c,SBQQ__PrimaryContact__r.Name,SBQQ__PrimaryContact__c,
                                                           Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Customer_Nm__c,Pricing_End_Customer_Name__c,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.Name,
                                                           Pricing_Project_Name_Nm__c,Pricing_Bid_Dt__c,Pricing_Customer_Reference_Id__c,SBQQ__Status__c FROM SBQQ__Quote__c 
                                                           WHERE Id =:quoteId LIMIT 1]);
        if(!quoteDataToBeDisplayed.isEmpty()){
            quoteData = quoteDataToBeDisplayed[0];
        }else {
            quoteData = new SBQQ__Quote__c();
        }
        if(String.isNotBlank(quoteData.Pricing_Intel_Account_Exec_Email_Txt__c)){  
            List<PermissionSetAssignment> accountExecutiveDtl = new List<PermissionSetAssignment>([SELECT Assignee.Email,PermissionSet.Name,AssigneeId
                                                                                                   FROM PermissionSetAssignment 
                                                                                                   WHERE Assignee.Email =:quoteData.Pricing_Intel_Account_Exec_Email_Txt__c AND Assignee.IsActive = true
                                                                                                   AND PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_TenderAccountExecutive]);
            if(!accountExecutiveDtl.isEmpty()){
                isValidAE = true;
            }
        }                                                                                       
        return quoteData;                                        
    }
    
    //Method To fetch Quote Line data to be displayed in email Template
    public SBQQ__QuoteLine__c getQuoteLineData() {
        try{
            stageActorEmail = UserInfo.getUserEmail();
            currentDate=system.today();
            quoteLineDataToBeDisplayed = quoteLineDataToBeDisplayed.isEmpty() ? new List<SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__r.Id,SBQQ__Quote__r.Name,SBQQ__Quote__r.Owner.Name,Pricing_Primary_Contact_Nm__c,Pricing_Primary_Contact_Nm__r.Name,SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Program_Type_Nm__c,
                                                                                                              Pricing_Project_Nm__c,Pricing_End_Customer_Nm__c,Pricing_EndCustomer_Nm__c,Pricing_Customer_Reference_txt__c,Pricing_Last_Submitted_By_Id__r.Email,Pricing_CPUs_per_system_qty__c,Pricing_Systems_qty__c,Pricing_Units_per_system_qty__c,
                                                                                                              Pricing_Change_Request_cb__c,SBQQ__ProductName__c,Pricing_Request_Discount_Unit_Price_qty__c,Pricing_New_Change_Request_cb__c,Pricing_Total_Volume_Qty__c,
                                                                                                              Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_ECAP_Price_Amt__c,Pricing_Approved_Unit_Dup_Qty__c,Pricing_Quote_Line_Number__c,Pricing_Other_Product_Nm__c,Pricing_Sales_Rep__r.firstName,Pricing_Sales_Rep__r.Email,Pricing_Rejection_Reason__c,
                                                                                                              Pricing_Status_Nm__c,Pricing_Deal_RFQ_Id__c,Pricing_Manager__r.Name,Pricing_Additional_T_C_s_Txt__c,Pricing_pm_approval_comments_nm__c, Pricing_Rejection_Comments_nm__c,Pricing_Product_Nm__r.Name,
                                                                                                              Pricing_Reference_Quote_Line_Nbr__r.Pricing_End_Date_dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Unit_Qty__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Req_Discounted_Unit_Price__c,Pricing_Lost_Reason_Nm__c,Pricing_Start_Date_dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c,Pricing_Unit_Qty__c,Pricing_Quote_Total_Requested_Quantity__c,
                                                                                                              //Added By Naresh as part of US871654
                                                                                                              SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,LastModifiedBy.Email,Pricing_ECAP_Price_Amt__c,Pricing_Approved_Unit_Qty__c,Pricing_OEM_Account_Nm__c,Pricing_Won_Lost_Comments_Txt__c,Pricing_Req_Discounted_Unit_Price__c,Pricing_End_Date_dt__c, Pricing_New_Quantity_qty__c,Pricing_Reference_Quote_Line_Nbr__c,Pricing_Additional_Comments_Txt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,
                                                                                                              SBQQ__Quote__r.Pricing_Deal_Registration_Id__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,SBQQ__Quote__r.Pricing_Customer_Reference_Id__c,SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Quote__r.Pricing_End_Customer_Name__c,SBQQ__Quote__r.Pricing_Deal_Registration_Id__r.Name,SBQQ__Quote__r.SBQQ__PrimaryContact__r.Name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name 
                                                                                                              FROM SBQQ__QuoteLine__c 
                                                                                                              WHERE Id =:quoteLineId LIMIT 1]) : quoteLineDataToBeDisplayed;
            
            if(!quoteLineDataToBeDisplayed.isEmpty()){
                boolean isDrafterLimitedContact = false;
                quoteLineData = quoteLineDataToBeDisplayed[0];
                quoteLineRequestedQuantity = (Integer) Math.round(quoteLineData.Pricing_Unit_Qty__c);
                totalRequestedQuantity = (Integer) Math.round(quoteLineData.Pricing_Quote_Total_Requested_Quantity__c);
                tptRecs = tptRecs.isEmpty() ? [SELECT Pricing_TPT_To_Stage_Actor_Nm__c FROM Pricing_Quote_Line_Status_Age__c 
                                               WHERE Pricing_TPT_Status_Name__c=:quoteLineDataToBeDisplayed[0].Pricing_Status_Nm__c AND Pricing_TPT_Quote_Line_Number__c=:quoteLineDataToBeDisplayed[0].Id
                                               ORDER BY CreatedDate DESC LIMIT 1] : tptRecs;
                if(tptRecs.size() > 0){
                    //List<User> usrs = [SELECT Id,Email FROM User WHERE Name= :tptRecs[0].Pricing_TPT_To_Stage_Actor_Nm__c LIMIT 1];
                    //if(usrs.size() > 0){
                    stageActorEmail = tptRecs[0].Pricing_TPT_To_Stage_Actor_Nm__c;
                    //}                   
                }
                
            }else {
                quoteLineData = new SBQQ__QuoteLine__c();
            }
            changedFields = getChangedFields(quoteLineData);
            
        }catch(Exception e){
            //Create Error Log when an Exception Occurs
            Pricing_Tender_Utility.logError(e);
            quoteLineData = new SBQQ__QuoteLine__c();
        }
        return quoteLineData;                                        
    }
    
    public static String getChangedFields(SBQQ__QuoteLine__c quoteLineData){
        String changedFieldsInd;
        Date edt;
        Date sdt;
        
        if(quoteLineData.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c != quoteLineData.Pricing_Start_Date_dt__c && quoteLineData.Pricing_Start_Date_dt__c != null){
            changedFieldsInd = 'Start Date';
            sdt = quoteLineData.Pricing_Start_Date_dt__c;
            qlStartDate = String.valueof(sdt.month()+'-'+sdt.day()+'-'+sdt.year());
        }
        if(quoteLineData.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c != quoteLineData.Pricing_End_Date_dt__c && quoteLineData.Pricing_Reference_Quote_Line_Nbr__r.Pricing_End_Date_dt__c != null && quoteLineData.Pricing_Reference_Quote_Line_Nbr__r.Pricing_End_Date_dt__c != quoteLineData.Pricing_End_Date_dt__c){
            changedFieldsInd = !String.isEmpty(changedFieldsInd)?changedFieldsInd+', End Date':'End Date';
            edt = quoteLineData.Pricing_End_Date_dt__c;
            qlEndDate = String.valueof(edt.month()+'-'+edt.day()+'-'+edt.year());
        }
        
        if(quoteLineData.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Unit_Qty__c != quoteLineData.Pricing_New_Quantity_qty__c){
            changedFieldsInd = !String.isEmpty(changedFieldsInd)?changedFieldsInd+', Quantity':'Quantity';
            newQuantity = String.valueof(quoteLineData.Pricing_New_Quantity_qty__c);
        }
        if(quoteLineData.Pricing_Reference_Quote_Line_Nbr__r.Pricing_ECAP_Price_Amt__c != quoteLineData.Pricing_Request_Discount_Unit_Price_qty__c && quoteLineData.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Req_Discounted_Unit_Price__c != quoteLineData.Pricing_Request_Discount_Unit_Price_qty__c){
            changedFieldsInd = !String.isEmpty(changedFieldsInd)?changedFieldsInd+', Price':'Price';
            newRequestedPrice = String.valueof(quoteLineData.Pricing_Request_Discount_Unit_Price_qty__c);
        }
        return changedFieldsInd;
    }
    
    public String getCurrentPrimaryContact() {
        String currPrimaryContact='';
        try{           
            
            List<SBQQ__QuoteLine__c>  qli = new List<SBQQ__QuoteLine__c>([SELECT Id,Pricing_Primary_Contact_Nm__c,Pricing_Primary_Contact_Nm__r.Name FROM SBQQ__QuoteLine__c WHERE Id =:quoteLineId LIMIT 1]); 
            
            if(!qli.isEmpty()){
                boolean isDrafterLimitedContact = false;
                quoteLineData = qli[0];              
                if(!String.isEmpty(quoteLineData.Pricing_Primary_Contact_Nm__c)){
                    List<User> primaryCotactUsr = [SELECT id,Contact.Name FROM User WHERE ContactId=: quoteLineData.Pricing_Primary_Contact_Nm__c];
                    if(!primaryCotactUsr.isEmpty()) {
                        for(PermissionSetAssignment psa : [SELECT PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId=:primaryCotactUsr[0].id]){
                            if(psa.PermissionSet.Name == Label.Pricing_Tender_PermissionSets_TenderDrafterLimited){
                                isDrafterLimitedContact = true;
                                break;
                            }
                        }
                    }
                    
                    if(isDrafterLimitedContact || primaryCotactUsr.isEmpty()){                        
                        User currentUser = [SELECT id,Contact.Name FROM User WHERE id=:UserInfo.getUserId()];
                        currPrimaryContact = currentUser.Contact.Name;
                    }else{                       
                        currPrimaryContact =  quoteLineData.Pricing_Primary_Contact_Nm__r.Name;                        
                    }
                }
                
            }            
        }catch(Exception e){
            //Create Error Log when an Exception Occurs
            Pricing_Tender_Utility.logError(e);
            
        }
        return currPrimaryContact;                                        
    }
    
    public Pricing_Quote_Team__c getQtmData() {
        
        Pricing_Quote_Team__c quoteTeam = [SELECT id,Pricing_Role_Nm__c,Pricing_Quote_Team_Member_Id__r.Name,LastModifiedBy.Name,
                                           Pricing_Quote_Id__c,Pricing_Quote_Id__r.Name,Pricing_Quote_Id__r.Pricing_Customer_Nm__c,Pricing_Quote_Id__r.Pricing_End_Customer_Name__c,
                                           Pricing_Quote_Id__r.Pricing_Project_Name_Nm__c,Pricing_Quote_Id__r.Pricing_Bid_Dt__c,Pricing_Grant_Access_Ind__c 
                                           FROM Pricing_Quote_Team__c WHERE Id= :qtmId LIMIT 1];                                                                              
        
        if(quoteTeam==null){
            quoteTeam = new Pricing_Quote_Team__c();
        }else {
            roleMap = [SELECT AGS_Role_Filter_Txt__c FROM Pricing_Quote_Team_Role_Access_Mapping__mdt WHERE Pricing_IsActive_Ind__c=True AND Pricing_Role_Nm__c=: quoteTeam.Pricing_Role_Nm__c LIMIT 1];
            agsFilter = roleMap?.AGS_Role_Filter_Txt__c;  
            agsFilter = String.isEmpty(agsFilter)?'IQR':agsFilter;
        }
        return quoteTeam;                                        
    }
    
    //Method to get Primary FSE, Primary FSE Delegate and Quote Team FSE's
    public List<String> getApproverEmailList(){
        SBQQ__QuoteLine__c qli = [SELECT Id,SBQQ__Quote__c,Pricing_Sales_Rep__c,Pricing_Sales_Rep__r.Email,Pricing_Sales_Rep__r.DelegatedApproverId 
                                  FROM SBQQ__QuoteLine__c WHERE Id =: quoteLineId LIMIT 1];
        Set<Id> quoteIds = new Set<Id>{qli.SBQQ__Quote__c};
            List<Id> qtmIds = new List<Id>();
        Map<Id,Set<Id>> quoteIdToQTMIdsMap = new Map<Id,Set<Id>>();

        quoteIdToQTMIdsMap = Pricing_Publish_Quote.validateQtmFse(quoteIds);
        for(Set<Id> qtmId: quoteIdToQTMIdsMap.values()){
            qtmIds.addAll(qtmId);
        }
        for(Pricing_Quote_Team__c qtm: [SELECT Pricing_Quote_Team_Member_Id__r.Email FROM Pricing_Quote_Team__c 
                                        WHERE Pricing_Quote_Team_Member_Id__c IN: qtmIds]){
                                            if(!approverEmailList.contains(qtm.Pricing_Quote_Team_Member_Id__r.Email)){
                                                approverEmailList.add(qtm.Pricing_Quote_Team_Member_Id__r.Email);
                                                approverEmailList.add('; ');
                                            }
                                        }
        for(PermissionSetAssignment psa : [SELECT  Assignee.Email FROM PermissionSetAssignment 
                                           WHERE AssigneeId =:qli.Pricing_Sales_Rep__r.DelegatedApproverId AND Assignee.IsActive = true 
                                           AND PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_TenderUser]){
                                               if(!approverEmailList.contains(psa.Assignee.Email)){
                                                   approverEmailList.add(psa.Assignee.Email);
                                               }
                                           }
        if(approverEmailList.get(approverEmailList.size()-1) == '; '){
            approverEmailList.remove(approverEmailList.size()-1);
        }
        return approverEmailList;
    }
    
    public List<SBQQ__QuoteLine__c> getQlList(){
        Map<Id,SBQQ__QuoteLine__c> qlidsToRecordMap =(quotesIds != null)?new Map<Id,SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__r.Id,SBQQ__Quote__r.Name,Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,SBQQ__Quote__r.Pricing_Opportunity_Status__c,Pricing_EndCustomer_Nm__c,Pricing_Project_Nm__c,Pricing_Product_Nm__r.Name,Pricing_Approved_Unit_Qty__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c  =: quotesIds and Pricing_Status_Nm__c = 'Approved']):new Map<Id,SBQQ__QuoteLine__c>();
        qlList =  (!qlidsToRecordMap.isEmpty())?qlidsToRecordMap.values():new List<SBQQ__QuoteLine__c>();
        return qlList;               
        
    }
    
    
}