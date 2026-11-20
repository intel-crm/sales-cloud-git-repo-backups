/**
* @description       : Batch class is created to validate, clone and insert Quote Line and Performance Matrix records and send result email with CSV attached, and to call Pricing_QLBulkCRSendPayloadBatch to send request to MyDeals for the newly created Change Requests.
* @author            : Rahul Maindalkar
* @group             : 
* @last modified on  : 04-27-2026
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public class Pricing_QLBulkCRValidationBatch implements Database.Batchable<sObject>, Database.Stateful{
    public Map<Id, String> ResultMap = New Map<Id, String>(); 
    public Map<Id,SBQQ__QuoteLine__c> newQLMapData;
    public List<SBQQ__QuoteLine__c> statusToUpdate = New List<SBQQ__QuoteLine__c>();
    public Set<Id> newQLSet = New Set<Id>();
    public Map<Id, String> QuotelineIdProdMap = New Map<Id, String>();
    public Map<Id,SBQQ__QuoteLine__c> QLFieldMap = New Map<Id,SBQQ__QuoteLine__c>();
    // Constructor to get QL Map for the bulk CR
    public Pricing_QLBulkCRValidationBatch(Map<Id,SBQQ__QuoteLine__c> newQLMapBatch){
        newQLMapData = New Map<Id,SBQQ__QuoteLine__c>(newQLMapBatch);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        Set<Id> keys = newQLMapData.keySet();
        List<String> fields = new List<String>(
            SBQQ__QuoteLine__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap().keySet()
        );
        // Explicitly add parent and grandparent fields
        fields.add('SBQQ__Quote__r.SBQQ__Account__r.Id');  // Ensure grandparent field is included
        // Construct the query
        String query = String.format(
            'SELECT {0} FROM {1} WHERE Id IN',
            new String[] { String.join(fields, ','), String.valueOf(SBQQ__QuoteLine__c.SObjectType) }
        );
        query += ':keys ORDER BY SBQQ__Quote__c';

        return Database.getQueryLocator(query);
    }    
    
    /**
* @description Calling helper class to validate, clone and insert Quote Line and Performance Matrix records 
* @author Rahul Maindalkar | 08-24-2022 
* @param bc 
* @param quoteLine 
**/
    public void execute(Database.BatchableContext bc, List<SBQQ__QuoteLine__c> quoteLine){
        Pricing_QLBulkCRWrapper crWrapper = Pricing_QLBulkCRValidationHelper.validateBulkCR(quoteLine, newQLMapData);
        ResultMap.putAll(crWrapper.mapSuccessError); 
        statusToUpdate.addAll(crWrapper.revisedList);
        QuotelineIdProdMap.putAll(crWrapper.QuotelineIdProdMap);
        QLFieldMap.putAll(crWrapper.QuotelineResponseMap);
    } 
    
    /**
* @description Code to send email with CSV attached and to call Pricing_QLBulkCRSendPayloadBatch to send request to MyDeals
* @author Rahul Maindalkar | 08-24-2022 
* @param bc 
**/ 
    public void finish(database.BatchableContext bc) {
        
        String csvColumnHeader;
        List<String> csvRowValues = new List<String>();
        for(Id key : ResultMap.keySet()){            
            String response = ResultMap.get(key);
            String csvRowVal;
            if(response.contains('Success')){
                List<string> successIdRes = response.split('_');
                //csvRowVal = successIdRes[0] + ','  + successIdRes[1] + ','  + QLFieldMap.get(successIdRes[1]).Pricing_Quote_Line_Number__c + ','+ QLFieldMap.get(key).Pricing_Quote_Line_Number__c + ',' + String.valueOf(QLFieldMap.get(key).Pricing_Deal_RFQ_Id__c)  + ',' + String.valueOf((QuotelineIdProdMap.get(key)).replace(',',''))  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Approved_Start_Date_Dt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Approved_End_Date_Dt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Revised_Pricing_Start_Date_dt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_ECAP_Price_Amt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Billing_Start_Date_Dt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Billing_End_Date_Dt__c) + ','  + String.valueOf(newQLMapData.get(key).Pricing_Approved_Unit_Qty__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Backdate_Reason_Txt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Meet_Comp_Price_Amt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_FSE_Recommended_Price_Nm__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Deal_Description__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Additional_T_C_s_Txt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Additional_Comments_Txt__c);               
                csvRowVal = successIdRes[0] + ','  + successIdRes[1] + ','  + QLFieldMap.get(successIdRes[1]).Pricing_Quote_Line_Number__c + ','+ QLFieldMap.get(key).Pricing_Quote_Line_Number__c + ',' + String.valueOf(QLFieldMap.get(key).Pricing_Deal_RFQ_Id__c)  + ',' + String.valueOf((QuotelineIdProdMap.get(key)).replace(',',''))  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Approved_Start_Date_Dt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Approved_End_Date_Dt__c)  + ',' + (newQLMapData.get(key).Pricing_Revised_Pricing_Start_Date_dt__c==null?'': String.valueOf(newQLMapData.get(key).Pricing_Revised_Pricing_Start_Date_dt__c) )+ ',' + (newQLMapData.get(key).Pricing_ECAP_Price_Amt__c==null?'': String.valueOf(newQLMapData.get(key).Pricing_ECAP_Price_Amt__c)) + ',' + String.valueOf(newQLMapData.get(key).Pricing_Billing_Start_Date_Dt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Billing_End_Date_Dt__c) + ','  + (newQLMapData.get(key).Pricing_Approved_Unit_Qty__c==null?'':String.valueOf(newQLMapData.get(key).Pricing_Approved_Unit_Qty__c))  + ','  + (newQLMapData.get(key).Pricing_Payable_Quantity__c==null?'':String.valueOf(newQLMapData.get(key).Pricing_Payable_Quantity__c))  + ',' + (newQLMapData.get(key).Pricing_Backdate_Reason_Txt__c==null?'':String.valueOf(newQLMapData.get(key).Pricing_Backdate_Reason_Txt__c))  + ',' + (newQLMapData.get(key).Pricing_Meet_Comp_Price_Amt__c==null?'': String.valueOf(newQLMapData.get(key).Pricing_Meet_Comp_Price_Amt__c) )+ ',' + (String.valueOf(newQLMapData.get(key).Pricing_FSE_Recommended_Price_Nm__c)=='Blank'?'':String.valueOf(newQLMapData.get(key).Pricing_FSE_Recommended_Price_Nm__c))  + ',' + (newQLMapData.get(key).Pricing_Deal_Description__c==null?'':String.valueOf(newQLMapData.get(key).Pricing_Deal_Description__c))  + ',' + (newQLMapData.get(key).Pricing_Additional_T_C_s_Txt__c==null?'':String.valueOf(newQLMapData.get(key).Pricing_Additional_T_C_s_Txt__c))  + ',' + (newQLMapData.get(key).Pricing_Additional_Comments_Txt__c==null?'':String.valueOf(newQLMapData.get(key).Pricing_Additional_Comments_Txt__c)); 
                newQLSet.add(successIdRes[1]);
            }
            else{
                //csvRowVal = response + ',' + String.valueOf('') + ',' + String.valueOf('') + ',' + QLFieldMap.get(key).Pricing_Quote_Line_Number__c + ',' + String.valueOf(QLFieldMap.get(key).Pricing_Deal_RFQ_Id__c)  + ',' + String.valueOf((QuotelineIdProdMap.get(key)).replace(',',''))  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Approved_Start_Date_Dt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Approved_End_Date_Dt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Revised_Pricing_Start_Date_dt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_ECAP_Price_Amt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Billing_Start_Date_Dt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Billing_End_Date_Dt__c) + ','  + String.valueOf(newQLMapData.get(key).Pricing_Approved_Unit_Qty__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Backdate_Reason_Txt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Meet_Comp_Price_Amt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_FSE_Recommended_Price_Nm__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Deal_Description__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Additional_T_C_s_Txt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Additional_Comments_Txt__c);          
                csvRowVal = response + ',' + String.valueOf('') + ',' + String.valueOf('') + ','+ QLFieldMap.get(key).Pricing_Quote_Line_Number__c + ',' + String.valueOf(QLFieldMap.get(key).Pricing_Deal_RFQ_Id__c)  + ',' + String.valueOf((QuotelineIdProdMap.get(key)).replace(',',''))  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Approved_Start_Date_Dt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Approved_End_Date_Dt__c)  + ',' + (newQLMapData.get(key).Pricing_Revised_Pricing_Start_Date_dt__c==null?'': String.valueOf(newQLMapData.get(key).Pricing_Revised_Pricing_Start_Date_dt__c) )+ ',' + (newQLMapData.get(key).Pricing_ECAP_Price_Amt__c==null?'': String.valueOf(newQLMapData.get(key).Pricing_ECAP_Price_Amt__c)) + ',' + String.valueOf(newQLMapData.get(key).Pricing_Billing_Start_Date_Dt__c)  + ',' + String.valueOf(newQLMapData.get(key).Pricing_Billing_End_Date_Dt__c) + ','  + (newQLMapData.get(key).Pricing_Approved_Unit_Qty__c==null?'':String.valueOf(newQLMapData.get(key).Pricing_Approved_Unit_Qty__c))  + ','+ (newQLMapData.get(key).Pricing_Payable_Quantity__c==null?'':String.valueOf(newQLMapData.get(key).Pricing_Payable_Quantity__c))  + ',' + (newQLMapData.get(key).Pricing_Backdate_Reason_Txt__c==null?'':String.valueOf(newQLMapData.get(key).Pricing_Backdate_Reason_Txt__c))  + ',' + (newQLMapData.get(key).Pricing_Meet_Comp_Price_Amt__c==null?'': String.valueOf(newQLMapData.get(key).Pricing_Meet_Comp_Price_Amt__c) )+ ',' + (String.valueOf(newQLMapData.get(key).Pricing_FSE_Recommended_Price_Nm__c)=='Blank'?'':String.valueOf(newQLMapData.get(key).Pricing_FSE_Recommended_Price_Nm__c))  + ',' + (newQLMapData.get(key).Pricing_Deal_Description__c==null?'':String.valueOf(newQLMapData.get(key).Pricing_Deal_Description__c))  + ',' + (newQLMapData.get(key).Pricing_Additional_T_C_s_Txt__c==null?'':String.valueOf(newQLMapData.get(key).Pricing_Additional_T_C_s_Txt__c))  + ',' + (newQLMapData.get(key).Pricing_Additional_Comments_Txt__c==null?'':String.valueOf(newQLMapData.get(key).Pricing_Additional_Comments_Txt__c));  
            }
            csvRowValues.add(csvRowVal);
        }
        csvColumnHeader = 'Result, New Quote Line ID, New Quote Line Number, Reference Quote Line Number, Deal ID, Product, Approved Pricing Start Date, Approved Pricing End Date, Effective Pricing Start Date, Approved ECAP Price, Billing Start Date (for consumption), Billing End Date (for consumption), Approved Quantity, Payable Quantity, Backdate Reason, My Deals Meet Comp Price, Pricing Manager WWID, Deal Description, Additional Ts and Cs, Additional Comments\n';
        String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
        List<OrgWideEmailAddress> orgWideEmailAdd = [SELECT Id from OrgWideEmailAddress where Address=:Label.Pricing_OrgWideEmailAddress];
        Id orgWideEmailAddId = orgWideEmailAdd[0].id;
        //send email
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment attach1 = new Messaging.EmailFileAttachment();
        blob b;
        if(Test.isRunningTest()) { 
            b = blob.valueOf('Unit.Test');
        } else {
            b = Blob.valueOf(csvFile);
        }                        
        
        string emailAddress = UserInfo.getUserEmail();
        string ccemailAddress = Label.Pricing_Bulk_CR_Email;        
        attach1.setFileName('Bulk CR Success Error File_'+string.valueOf(system.now())+'.csv');
        attach1.setBody(b);
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{attach1});
        String[] toAddresses = new String[] {emailAddress};
        String[] ccAddresses = new String[] {ccemailAddress};
        message.setToAddresses(toAddresses);
        message.setccAddresses(ccAddresses);
        message.setOrgWideEmailAddressId(orgWideEmailAddId);
        message.setSubject('Result : Bulk Change Request Operation'); 
        message.setHtmlBody('Please see attached Bulk CR sucess error csv files');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        
        //Update QL status to Revised for Write In Products Quote Line
        if(statusToUpdate.size()>0){
            SBQQ.TriggerControl.disable();
            database.saveresult[] dsr = Database.update(statusToUpdate, false);
            SBQQ.TriggerControl.enable();
            for (Database.SaveResult sr : dsr) {
                if (!sr.isSuccess()) {
                    string errorMsg='';
                    for(Database.Error err : sr.getErrors()) {
                        errorMsg = string.isBlank(errorMsg) ? err.getMessage() : errorMsg +'; '+ err.getMessage();                
                    }                 
                }
            }              
        }
        
        // Call Batch class to Send request to MyDeals
        if(newQLSet.size()>0){
            string batchSize = Label.Pricing_Bulk_CR_SendPayload_Size; 
            Pricing_QLBulkCRSendPayloadBatch bulkCR = New Pricing_QLBulkCRSendPayloadBatch(newQLSet);
            Database.executeBatch(bulkCR, integer.valueOf(batchSize));
        }
    }
}