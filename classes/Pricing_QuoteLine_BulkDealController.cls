/**
 * @description       : Controller class used for Bulk Deals 
 * @author            : Sandeep
 * @group             : Accenture
 * @last modified on  : 05-23-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_QuoteLine_BulkDealController {

    /**
    * @description Method to fetch records to display on Bulk Deals pop up
    * @author Sandeep | 11-17-2022 
    * @param quoteId 
    * @return List<SBQQ__QuoteLine__c> containing records to display
    **/
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c>  getQuoteLineDetails(Id quoteId){
        List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id,SBQQ__Quote__c,Pricing_Quote_Line_Number__c,Pricing_Product_Nm__r.Id,Pricing_Product_Nm__r.Name,Pricing_Req_Discounted_Unit_Price__c,Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Reason_for_FeedBack_Txt__c,Pricing_SIPP_Cb__c,Pricing_Change_Request_cb__c,
                                                Pricing_ECAP_Price_Amt__c,Pricing_Billing_Start_Date_Dt__c,Pricing_Billing_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_Payable_Quantity__c,Pricing_Backdate_Reason_Txt__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_Program_Type_Nm__c,Pricing_Other_Competitor_Product_Nm__c,Pricing_Recommendation_FeedBack_Nm__c,
                                                Pricing_Group_Type_nm__c,Pricing_Market_Segment_values_Nm__c,Pricing_Market_Segment_Nm__c,Pricing_Reference_Quote_Line_Nbr__c,Pricing_Form_Factor_Nm__c,Pricing_Tentative_ECAP_Price_Amt__c,Pricing_Recommended_Price_Amt__c,Pricing_Price_Interval_Txt__c,Pricing_Discount_Pct__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,
                                                Pricing_Competetor_Product__c,Pricing_Competetor_Product__r.Name,Pricing_Comp_Product_Txt__c,Pricing_Processor_Number_Nm__c,Pricing_Family_Name_Nm__c,Pricing_DealProduct_Nm__c,SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,Pricing_Workload_Nm__c,Pricing_Server_Deal_Type_Nm__c,Pricing_EndCustomer_Nm__c,Pricing_Unit_Qty__c,
                                                Pricing_Manager__c,Pricing_Manager__r.Name,Pricing_Additional_T_C_s_Txt__c,Pricing_RegionQL_Nm__c,Pricing_pm_approval_comments_nm__c, Pricing_Rejection_Comments_nm__c,Pricing_Deal_Description__c,SBQQ__Quote__r.SBQQ__Account__c
                                                FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND Pricing_Status_Nm__c =: Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview AND Pricing_Other_Product_Nm__c = '' AND
                                                Pricing_Deal_RFQ_Id__c = '' AND Pricing_Integration_Status_Nm__c = '' AND Pricing_Reference_Quote_Line_Nbr__c = ''
                                                ORDER By Pricing_Quote_Line_Number__c];
        return quoteLineList;
    }

    /**
    * @description Method used to validate Additional RPM Recipients who are having valid RPM permission set.
    * @author Divya Gangasaram | 01-17-2023 
    * @param List<SBQQ__QuoteLine__c> quotelinelist 
    * @param Map<id String> idTOEmails 
    * @return Map<id, String> 
    **/
    @AuraEnabled
    public static Map<id,String> userHasValidRPMPermission(List<SBQQ__QuoteLine__c> quotelinelist, Map<id,String> idTOEmails) {
          Map<id,String> quotelineIdToErrorMsgMap = new Map<id,String>();
          Set<String> recipients = new Set<String>();
          List<String> rpmRecipients = new List<String>();
          for(String Emails : idTOEmails.values()){
            recipients.addAll((Emails.deleteWhitespace()).split(';'));
          }
          for(PermissionSetAssignment RPM_permission : [SELECT Id, AssigneeId,Assignee.Email FROM PermissionSetAssignment WHERE Assignee.Email in: recipients AND Assignee.IsActive = true 
                                                        AND  PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager]){
            rpmRecipients.add(RPM_permission.Assignee.Email);
        }
        for(SBQQ__QuoteLine__c quotine: quotelinelist ){
            integer count = 0;
            String emailsWithNoPermission = '';
            if(quotine.Pricing_Additional_RPM_Notify_Recipients__c != null && quotine.Pricing_Additional_RPM_Notify_Recipients__c != ''){
            integer listSize = (((quotine.Pricing_Additional_RPM_Notify_Recipients__c).deleteWhitespace()).split(';')).size();
            for( String qulineEmails : ((quotine.Pricing_Additional_RPM_Notify_Recipients__c).deleteWhitespace()).split(';')){
           
               if(rpmRecipients.contains(qulineEmails)){
                   count++;
               }
               else{
                emailsWithNoPermission += qulineEmails+';';
               }
            }
                if(count==listSize){
                    quotelineIdToErrorMsgMap.put(quotine.id ,'Success');
                }
                else{
                    quotelineIdToErrorMsgMap.put(quotine.id ,(Label.Pricing_Addition_RPM_Recipients_Validation_Error_Msg.replace('<<placeholder for RPM emails>>',emailsWithNoPermission.removeEnd(';'))));
                }
            }
            else{
                quotelineIdToErrorMsgMap.put(quotine.id ,'Success');
            }
                
        }
        return quotelineIdToErrorMsgMap;
    }

    /**
    * @description 
    * @author Sandeep | 11-17-2022 
    * @param quoteLineListtoUpdate - QuoteLine record list to update
    * @param parentId -- List containing QuoteLine Id's which are selected in Bulk Deal pop up
    * @param isCreateDeal - Boolean to check if Create Deals is clicked
    * @return Map<Id, String> - containing Quoteline Id to success, errormsg Map
    **/
    @AuraEnabled
    public static Map<Id,String> updateQuoteLineDetails(List<SBQQ__QuoteLine__c> quoteLineListtoUpdate,List<String> parentId,Boolean isCreateDeal, Boolean isUpdateDeal){
        String action = isUpdateDeal == true ?'Update' : 'Create';
        String retMsg;
        Map<Id,String> errorMap = new Map<Id,String>();
        Set<Id> qliIds = new Set<Id>();
        Map<Id,String> qlIdToRuleIdRuleNameMap = new Map<Id,String>();
        for(String qliId:parentId){
            qliIds.add(Id.valueOf(qliId));
        }
        try{
            for(SBQQ__QuoteLine__c ql :quoteLineListtoUpdate){
                if(isUpdateDeal && ql.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Action_Won && !Pricing_QuoteLineCloneController.restrictedAccountMethod(ql.SBQQ__Quote__r.SBQQ__Account__c,'')){
                    ql.Pricing_Payable_Quantity__c = ql.Pricing_Approved_Unit_Qty__c;
                }
            }
            Pricing_Tender_Utility.createUsageTrackingLog(qliIds,quoteLineListtoUpdate[0].SBQQ__Quote__c,(action+' Deal'));
            if(quoteLineListtoUpdate.size() > 0){
                SBQQ.TriggerControl.disable();
                update quoteLineListtoUpdate;
                SBQQ.TriggerControl.enable();
    
            }
            if(isCreateDeal || isUpdateDeal){
                errorMap = insertOutbound(parentId, action, qlIdToRuleIdRuleNameMap);  
            }
        }
        catch(Exception exp){
            retMsg = Pricing_Tender_Utility.getExceptionMessage(exp);
            Pricing_Tender_Utility.logError(exp); 
        }
        finally {
            SBQQ.TriggerControl.enable();
        }
        return errorMap;
    }

    /**
    * @description 
    * @author Sandeep | 11-17-2022 
    * @param parentId -- List containing QuoteLine Id's which are selected in Bulk Deal pop up 
    * @param action -- Create
    * @return Map<Id, String> - containing Quoteline Id to success, errormsg Map 
    **/
    public Static Map<Id,String> insertOutbound(List<String> parentId,String action,Map<Id,String> qlIdToRuleIdRuleNameMap) 
    {
        Map<Id,String> quoteLineIdToActionMap = new Map<Id,String>();
        Map<Id,String> quoteLineIdToErrorMap = new Map<Id,String>();
        Map<Id,SBQQ__QuoteLine__c> quoteLineMap;
        Integer count = 0;
        Integer noOverLapErrorCount = 0;
        quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,
                                                       SBQQ__Quote__r.Name, Pricing_EndCustomer_Nm__c, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,
                                                       Pricing_Reference_Quote_Line_Nbr__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,
                                                       SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,
                                                       Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Program_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,
                                                       Pricing_Manager__r.Core_WWID__c,SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_Business_Party_Id__c,SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c,
                                                       Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,Pricing_Workload_Nm__c,Pricing_New_Change_Request_cb__c,
                                                       Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,SBQQ__Product__r.Core_Item_Id__c,
                                                       Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                                       Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Project_Nm__c,Pricing_Approved_Unit_Qty__c,Pricing_Payable_Quantity__c,Pricing_Deal_RFQ_Status_Nm__c,Pricing_Consumption_Segment__c,
                                                       Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c,Pricing_Consumption_Platform__c,Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Country__c,Pricing_Consumption_Region__c,
                                                       Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Name,
                                                       SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,SBQQ__Product__r.Core_Family_Nm__c,SBQQ__Product__r.Core_Forecast_Product_Name__c,SBQQ__Product__r.Core_Processor_Number_Nm__c,Pricing_Product_Nm__r.Name,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,
                                                       Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,Pricing_Competetor_Product__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c,
                                                       SBQQ__Quote__r.Pricing_End_Customer__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__c,SBQQ__Quote__r.Pricing_End_Customer__c,SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c,
                                                       SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c,SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c,SBQQ__Quote__r.Pricing_End_Customer_Name__c,Pricing_Program_Type_Nm__c,Pricing_SDM_Fast_Track__c,
                                                       SBQQ__Quote__r.Pricing_Is_Sanctioned__c,Pricing_Account_Division_Nm__c,Pricing_Comp_Product_Txt__c,Pricing_Performance_Metric_Nm__c,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,(SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,
                                                        Pricing_Performance_Metric_Nm__c FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) FROM SBQQ__QuoteLine__c WHERE 
                                                       Id IN : parentId]); 
        Pricing_IntegrationSFDCToPricingSystems integrationSystem =  new Pricing_IntegrationSFDCToPricingSystems();
        quoteLineIdToErrorMap.putAll(integrationSystem.validationMethod(quoteLineMap.values()));
        for(integer i = 0; i<parentId.size(); i++){
            if(quoteLineIdToErrorMap.containsKey(parentId[i]) && quoteLineIdToErrorMap.get(parentId[i]) == 'Success'){
                count++;
                quoteLineIdToActionMap.put(parentId[i],action);
            }
        }
        if(count == quoteLineIdToErrorMap.size() && count != 0){
            if (TriggerHandler.isActive('Pricing_OverLap_Deal_QL_Switch')){
                quoteLineIdToErrorMap = isOverLapDealQL(quoteLineMap,parentId);
            }
        
            for(integer i = 0; i<parentId.size(); i++){
                if(quoteLineIdToErrorMap.containsKey(parentId[i]) && quoteLineIdToErrorMap.get(parentId[i]) == 'Success'){
                    noOverLapErrorCount++;
                }
            }
            if(noOverLapErrorCount == quoteLineIdToActionMap.size() && quoteLineIdToActionMap.size() != 0){
                User loggedInUser = [SELECT Id,Name,Core_WWID__c from User where Id =: userInfo.getUserId()];
                Boolean isPricingManager = !QuoteLineBusinessLogic.isAutoApproveReject ? true : false;
                quoteLineIdToErrorMap = Pricing_IntegrationSFDCToPricingSystems.insertQuoteOutBoundMessage(quoteLineIdToActionMap,quoteLineMap,loggedInUser.Core_WWID__c,isPricingManager,qlIdToRuleIdRuleNameMap);
            }
        }
        return quoteLineIdToErrorMap;
    }


    /**
    * @description Method written to prevent RPM from creating/updating a Deal for a Quote Line which belongs to the 
                    same Account, End Customer, Product, Project and has a partial overlap or exact match as the Approved Start 
                    and Approved End Date of the existing Quote Lines of a Quote
    * @author Sandeep | 11-18-2022 
    * @param quoteLineMap - contains QuoteLine Id to record mapping for selected rows 
    * @param parentId - contains QuoteLine Id for selected rows 
    * @return Map<Id, String> - contains quoteline Id to succes or error msg
    **/
    public static Map<Id,String> isOverLapDealQL(Map<Id,SBQQ__QuoteLine__c> quoteLineMap,List<Id> parentId){
        String overLapDealMsg = Label.Pricing_OverlapDeal_Error_Message;
        Map<Id,String> errorMsgMap = new Map<Id,String>();
        List<SBQQ__QuoteLine__c> overLapQLList = new List<SBQQ__QuoteLine__c>();
        String projName = (quoteLineMap.get(parentId[0]).Pricing_Project_Nm__c).trim();
        /*Query which retrieves the overlapping quote lines belonging to the same Account and Project of a Quote*/
        List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id, Pricing_Quote_Line_Number__c, SBQQ__Quote__r.Pricing_Customer_Nm__c, SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name, SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__c, SBQQ__Quote__r.Pricing_End_Customer__r.Name, 
                                                  Pricing_Product_Nm__r.Name, Pricing_Approved_Start_Date_Dt__c, Pricing_Approved_End_Date_Dt__c,Pricing_Consumption_Platform__c,Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Country__c,Pricing_Consumption_Region__c,Pricing_Consumption_Segment__c 
                                                  FROM SBQQ__QuoteLine__c WHERE Pricing_Project_Nm__c =: projName 
                                                  AND SBQQ__Quote__r.SBQQ__Account__c =: quoteLineMap.get(parentId[0]).SBQQ__Quote__r.SBQQ__Account__c 
                                                  AND (Pricing_Deal_RFQ_Id__c != null OR Pricing_Integration_Status_Nm__c =: Label.Pricing_Tender_MyDeal_Integration_Status_Pending) 
                                                  AND Pricing_Status_Nm__c IN : Label.Pricing_QL_Overlap_Deal_Statuses_Label.split(',')];
        
        for(SBQQ__QuoteLine__c oQL: quoteLineList){
            /*Condition to check the Unified End Customer/End Customer/Write in End Customer against the Unified Global End 
            Customer lookup field or the End Customer lookup field or the Write In End Customer text field. 
            If a match is found, the overlapping QL numbers are added to the list and then concatenated with the error message 
            to be shown on the UI*/
            if((quoteLineMap.get(parentId[0]).SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c == true && (oQL.SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name == quoteLineMap.get(parentId[0]).SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name || 
            oQL.SBQQ__Quote__r.Pricing_End_Customer__r.Name == quoteLineMap.get(parentId[0]).SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name || 
            oQL.SBQQ__Quote__r.Pricing_Customer_Nm__c == quoteLineMap.get(parentId[0]).SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name)) || 
            (quoteLineMap.get(parentId[0]).SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c == false && (oQL.SBQQ__Quote__r.Pricing_End_Customer__r.Name == quoteLineMap.get(parentId[0]).SBQQ__Quote__r.Pricing_End_Customer_Name__c || 
            oQL.SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name == quoteLineMap.get(parentId[0]).SBQQ__Quote__r.Pricing_End_Customer_Name__c || 
            oQL.SBQQ__Quote__r.Pricing_Customer_Nm__c == quoteLineMap.get(parentId[0]).SBQQ__Quote__r.Pricing_End_Customer_Name__c))){
                overLapQLList.add(oQL);
            }
        }

        overLapQLList.addAll(quoteLineMap.values());
        for(Id qliId: parentId){
            List<String> overLapQLNums = new List<String>();
            for(SBQQ__QuoteLine__c overLapQL: overLapQLList){
                Boolean isDateOverlap = false;
                if(overLapQL.Id != qliId && overLapQL.Pricing_Quote_Line_Number__c != quoteLineMap.get(qliId).Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c && 
                overLapQL.Pricing_Product_Nm__r.Name == (quoteLineMap.get(qliId).Pricing_Product_Nm__r.Name).trim() &&
                ((overLapQL.Pricing_Approved_Start_Date_Dt__c <= quoteLineMap.get(qliId).Pricing_Approved_Start_Date_Dt__c && overLapQL.Pricing_Approved_End_Date_Dt__c >= quoteLineMap.get(qliId).Pricing_Approved_Start_Date_Dt__c) ||
                    (overLapQL.Pricing_Approved_Start_Date_Dt__c <= quoteLineMap.get(qliId).Pricing_Approved_End_Date_Dt__c && overLapQL.Pricing_Approved_End_Date_Dt__c >= quoteLineMap.get(qliId).Pricing_Approved_End_Date_Dt__c) || 
                    (overLapQL.Pricing_Approved_Start_Date_Dt__c >= quoteLineMap.get(qliId).Pricing_Approved_Start_Date_Dt__c && overLapQL.Pricing_Approved_End_Date_Dt__c <= quoteLineMap.get(qliId).Pricing_Approved_End_Date_Dt__c))){
                        //overLapQLNums.add(overLapQL.Pricing_Quote_Line_Number__c);
                        isDateOverlap = true;
                    }

                    if(isDateOverlap) {

                        Boolean isConsumptionOverlap = consumptionOverlap(overLapQL, quoteLineMap.get(qliId));
                        
                        if(isConsumptionOverlap) {
                            overLapQLNums.add(overLapQL.Pricing_Quote_Line_Number__c);
                        }
                    }
            }
            if(overLapQLNums.size() > 0){
                errorMsgMap.put(qliId, overLapDealMsg + ' ' + overLapQLNums);
            }
            else{
                errorMsgMap.put(qliId, 'Success');
            }
        }
        return errorMsgMap;
    }

    /**
    * @description Method to return PickList Values for Recommendation Feedback Field
    * @author Vrushabh | 04-07-2023 
    * @return List<List<String>> -- list of picklist values
    **/
    @AuraEnabled 
    public static List<List<String>> getPicklistBulkDealController(){

        List<List<String>> bulkDealPickListvalue = new List<List<String>>();

        List<String> pickListValuesRecommendation_FeedBack = new List<String>();
        Schema.DescribeFieldResult fieldResult = SBQQ__QuoteLine__c.Pricing_Recommendation_FeedBack_Nm__c.getDescribe();        
        List<Schema.PicklistEntry> picklistValuesForFeedback = fieldResult.getPicklistValues();        
        for(Schema.PicklistEntry pickList : picklistValuesForFeedback){
            pickListValuesRecommendation_FeedBack.add(pickList.getValue());            
        }

        List<String> pickListValuesRegionQL = new List<String>();
        Schema.DescribeFieldResult fieldResult_RegionQL = SBQQ__QuoteLine__c.Pricing_RegionQL_Nm__c.getDescribe();        
        List<Schema.PicklistEntry> pickListForRegionQL = fieldResult_RegionQL.getPicklistValues();        
        for(Schema.PicklistEntry pickList : pickListForRegionQL){
            pickListValuesRegionQL.add(pickList.getValue());            
        }
        //Using getPicklistValuesQLI from Pricing_QuoteLineCloneController Class , since it's already available
        bulkDealPickListvalue.add(Pricing_QuoteLineCloneController.getPicklistValuesQLI()); // Pricing_Backdate_Reason_Txt__c
        bulkDealPickListvalue.add(pickListValuesRecommendation_FeedBack);
        bulkDealPickListvalue.add(pickListValuesRegionQL);


        if(!bulkDealPickListvalue.isEmpty()){
            return bulkDealPickListvalue;
        }else{
            return null; 
        }
    }

    /**
    * @description Method to return User List having RPM Permission Set
    * @author Vrushabh | 05-07-2023 
    * @return List<User>
    **/
    @AuraEnabled
    public static List<User> findRecords(String searchKey) {  
        //This method is called by LWC to find the user from searchkey
        String searchText = String.escapeSingleQuotes(searchKey) + '%';               
        String query =  'SELECT Id, Name, Email, Isactive,IsPortalEnabled FROM User WHERE Name LIKE :searchText AND IsPortalEnabled = false AND ContactId = null AND Isactive = true LIMIT 5';
        return Database.query(query);
    }

    /**
    * @description Method to send List of End Customer excluded Names
    * @author Sandeep Chamate | 09-04-2023 
    * @return List<String> - End Customer excluded list
    **/
    @AuraEnabled
    public static List<String> getCustomSettingRecordsforExcludedList(){
        Set<String> endCustomerNames = new Set<String>();
        endCustomerNames = Pricing_CSP_End_Customer_Exclusion_List__c.getAll().keySet();
        return new List<String>(endCustomerNames);
    }

    /**
    * @description : Method to get accountToCIMId metadata records.
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-10-2024 
    * @return Map<String, Decimal> 
    **/
    @AuraEnabled
    public static Map<String,Decimal> accountToCIMIdMappingMtdRec(){
      Map<String,Decimal> accountIdMtdRecordMap = new Map<String,Decimal>();
        for(Pricing_Account_To_CIM_ID_Mapping__mdt metadataRec : Pricing_Account_To_CIM_ID_Mapping__mdt.getAll().values()){
            if(metadataRec.Pricing_Number_of_Days__c != null){
                accountIdMtdRecordMap.put(metadataRec.DeveloperName,metadataRec.Pricing_Number_of_Days__c);
            }

        }
        return accountIdMtdRecordMap;
    }

    /**
    * @description Method to check consumption parameters onerlap
    * @author Sandeep Chamate | 05-22-2024 
    * @return Boolean 
    **/
    public static Boolean consumptionOverlap(SBQQ__QuoteLine__c overLapQL, SBQQ__QuoteLine__c parentQL) {
        List<String> consumptionPlatform = String.isNotBlank(overLapQL.Pricing_Consumption_Platform__c) ? overLapQL.Pricing_Consumption_Platform__c.split(', ') : new List<String>();
        List<String> consumptionSalesGeo = String.isNotBlank(overLapQL.Pricing_Consumption_Sale_Geo__c) ? overLapQL.Pricing_Consumption_Sale_Geo__c.split(', ') : new List<String>() ;
        List<String> consumptionCountry = String.isNotBlank(overLapQL.Pricing_Consumption_Country__c) ? overLapQL.Pricing_Consumption_Country__c.split(', ') : new List<String>();
        List<String> consumptionRegion = String.isNotBlank(overLapQL.Pricing_Consumption_Region__c) ? overLapQL.Pricing_Consumption_Region__c.split(', ') : new List<String>();
        List<String> consumptionSegment = String.isNotBlank(overLapQL.Pricing_Consumption_Segment__c) ? overLapQL.Pricing_Consumption_Segment__c.split(', ') : new List<String>();
        Integer count = 0;
        Boolean isOverLap = false;
        
        if(String.isBlank(parentQL.Pricing_Consumption_Platform__c) && consumptionPlatform.isEmpty()) {
            count++;
        }
        else{
            if(String.isNotBlank(parentQL.Pricing_Consumption_Platform__c)) {
                for(String str: parentQL.Pricing_Consumption_Platform__c.split(', ')) {
                    if(consumptionPlatform.contains(str)) {
                        count++;
                        break;
                    }
                }
            }
        }
        
        if(String.isBlank(parentQL.Pricing_Consumption_Sale_Geo__c) && consumptionSalesGeo.isEmpty()) {
            count++;
        }
        else {
            if(String.isNotBlank(parentQL.Pricing_Consumption_Sale_Geo__c)) {
                for(String str: parentQL.Pricing_Consumption_Sale_Geo__c.split(', ')) {
                    if(consumptionSalesGeo.contains(str)) {
                        count++;
                        break;
                    }
                }
            }
        }
        
        if(String.isBlank(parentQL.Pricing_Consumption_Country__c) && consumptionCountry.isEmpty()) {
            count++;
        }
        else {
            if(String.isNotBlank(parentQL.Pricing_Consumption_Country__c)) {
                for(String str: parentQL.Pricing_Consumption_Country__c.split(', ')) {
                    if(consumptionCountry.contains(str)) {
                        count++;
                        break;
                    }
                }
            }
        }
        
        if(String.isBlank(parentQL.Pricing_Consumption_Region__c) && consumptionRegion.isEmpty()) {
            count++;
        }
        else {
            if(String.isNotBlank(parentQL.Pricing_Consumption_Region__c)) {
                for(String str: parentQL.Pricing_Consumption_Region__c.split(', ')) {
                    if(consumptionRegion.contains(str)) {
                        count++;
                        break;
                    }
                }
            }
        }
        
        if(String.isBlank(parentQL.Pricing_Consumption_Segment__c) && consumptionSegment.isEmpty()) {
            count++;
        }
        else {
            if(String.isNotBlank(parentQL.Pricing_Consumption_Segment__c)) {
                for(String str: parentQL.Pricing_Consumption_Segment__c.split(', ')) {
                    if(consumptionSegment.contains(str)) {
                        count++;
                        break;
                    }
                }
            }
        }
        
        if(count == 5) {
            isOverLap = true;
            //overLapQLNums.add(overLapQL.Pricing_Quote_Line_Number__c);
        }

        return isOverLap;
    }
}