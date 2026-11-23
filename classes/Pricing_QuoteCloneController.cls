/**
* @description Helper class to clone parent and its children sObjects
*/
public without sharing class Pricing_QuoteCloneController {
   
    public static Map<id,Pricing_Quote_Team__c> idToQuoteTeamRecMap = new Map<id,Pricing_Quote_Team__c>();
    
    /**
* @description Clone parent and its children
* @param id of the parent sObject
* @return new parent id
*/
    @AuraEnabled
    public static GlobalVariables doClone (String sObjectId , String quoteType) {
        sObjectId =  String.escapeSingleQuotes(String.valueOf(sObjectId));
        GlobalVariables globalVar = new GlobalVariables();
        
        List<SBQQ__Quote__c> parentSObjects;
        SBQQ__Quote__c parent;
        String query;
        id userId = UserInfo.getUserId();
        List<PermissionSetAssignment> lstcurrentUserPerSet =new List<PermissionSetAssignment>([SELECT Id, PermissionSet.Name, AssigneeId, Assignee.ContactId
                                                                                               FROM PermissionSetAssignment
                                                                                               WHERE AssigneeId =: userId]);
        
        Set<String> cloneAllowedPersonaPS = new Set<String>(Label.Pricing_Tender_Quote_Clone_Permission_Sets.Split(':'));                                                                                       // STORE CURRENT USER'S PERMISSION SETS IN A LIST
        // STORE CURRENT USER'S PERMISSION SETS IN A LIST
        Boolean isQuoteCloneAllowed = false;
        for (PermissionSetAssignment psa : lstcurrentUserPerSet) {
            if(cloneAllowedPersonaPS.contains(psa.PermissionSet.Name)){
                isQuoteCloneAllowed = true;
                break;
            }           
        }
        if(isQuoteCloneAllowed) {
            try {
                // Quote query
                query = String.format(
                    'SELECT {0} FROM {1} WHERE Id = \'\'{2}\'\'',
                    new String[] {
                        String.join(
                            new List<String>(
                                SBQQ__Quote__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap().keySet()
                            ),
                            ','
                        ),
                            String.valueOf(SBQQ__Quote__c.SObjectType),
                            String.escapeSingleQuotes(sObjectId)//ch
                            }
                );
                
                // Query and gets results
                parentSObjects = Database.query(query); 
                String capSizeCheck =  Pricing_Manage_Small_Volume_Deal.capSizeCheck(parentSObjects[0].SBQQ__Account__c);
                if(!String.isEmpty(capSizeCheck) && quoteType == null) {
                    integer maxLimit = Integer.valueOf(capSizeCheck.split(':')[2]);
                    if(capSizeCheck.split(':')[0] == 'false' && maxLimit <=0 && parentSObjects[0].Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote){
                        //Create Error Log for CAp size validation
                        globalVar.messageResult = Label.Pricing_Tender_Cap_Size_Quarter_Limit_Error+' ('+Integer.valueOf(capSizeCheck.split(':')[1])+' Quotes).';
                        globalVar.quoteId = null;
                        globalVar.isSuccess = false;
                        return globalVar; 
                    }if(capSizeCheck.split(':')[0] == 'false' && maxLimit >= 0 && parentSObjects[0].Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote){   
                        globalVar.messageResult = Label.Pricing_Tender_SVD_Invalid_Account;
                        globalVar.quoteId = null;
                        globalVar.isSuccess = false;
                        return globalVar; 
                    }
                }
                
                QuoteBusinessLogic.isQuoteClone = true;
                // Clone the original object. Here you can change anything without affecting the original sObject
                parent = parentSObjects[0].clone(false, true, false, false);
                parent.SBQQ__Status__c = Label.Pricing_Tender_Quote_Status_Draft; 
                if(quoteType != null && quoteType == Label.Pricing_Tender_Standard_Quote){
                    
                    parent.Pricing_Program_Type_Nm__c = quoteType;
                    Parent.RecordTypeid = getQuoteCreateRecordTypeId(quoteType);
                    
                }else{
                    parent.RecordTypeId = getQuoteCreateRecordTypeId(parent.Pricing_Program_Type_Nm__c);
                }
               
                    getUsersFromQuoteTeam(parentSObjects);

                //(parent.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote)? Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Small_Volume_Quote_Create) : Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Quote_Create);
                parent.Pricing_Bid_Dt__c = parent.Pricing_Bid_Dt__c > date.today() ? parent.Pricing_Bid_Dt__c : dateFormat();
                parent.Pricing_ShipmentStDate_Dt__c = parent.Pricing_ShipmentStDate_Dt__c > date.today() ? parent.Pricing_ShipmentStDate_Dt__c : dateFormat();          
                parent.Pricing_ShipmentEndDate_Dt__c = parent.Pricing_ShipmentEndDate_Dt__c > date.today() ? parent.Pricing_ShipmentEndDate_Dt__c : dateFormat();
                parent.Pricing_End_Customer_Opportunity_Txt__c = null;
                parent.SBQQ__Opportunity2__c = null;
                parent.Pricing_Customer_Reference_Id__c = null;
                parent.Pricing_Intel_Account_Exec_Email_Txt__c = null;  
                parent.Pricing_Account_Executive_Nm__c = null;
                parent.Pricing_My_Deals_Folio_Name_Nm__c = null;
                parent.Pricing_Folio_ID_Nm__c= null;
                parent.Pricing_SecondaryContact_Nm__c= null;
                parent.Pricing_Intel_Sales_Rep_Email_Txt__c = Pricing_Publish_Quote.quoteSalesRepValidation(parent) == false ? parent.Pricing_Intel_Sales_Rep_Email_Txt__c : null;
                parent.SBQQ__SalesRep__c = Pricing_Publish_Quote.quoteSalesRepValidation(parent) == false ? parent.SBQQ__SalesRep__c : null;
                parent.Pricing_Auto_generate_Quote_Letter__c = true;
                parent.Pricing_Intel_Response_Requested_By_Date__c = null;
                parent.Pricing_Volume_Exception_Quota_Cb__c = false;
                parent.Pricing_Exclude_from_Volume_Excep_Quota__c = false;
                parent.Pricing_Quota_Exclusion_Reason__c = null;
                parent.Pricing_AdditionalRecipients__c = null;
                parent.Pricing_Account_Division_Nm__c = null;
                parent.SBQQ__LastCalculatedOn__c = null;
                parent.Pricing_On_Hold_Cb__c = false;
                parent.Pricing_On_Hold_Comment__c = null;
                parent.Pricing_Partner_Name_Nm__c = null;
                //Clone Logic for End Customer and Write In End Customer
                if(parent.Pricing_IsUnifiedCustomer__c==true){
                    Pricing_UnifiedEndCustomerCountryMapping__c unifiedCountryObj = [SELECT Id,Name,Pricing_Unified_EndCustomer_Id__c,Pricing_Unified_EndCustomer_Act_Mapping__c FROM 
                                                                                     Pricing_UnifiedEndCustomerCountryMapping__c WHERE Id = :parent.Pricing_Unified_Global_End_Customer_Nm__c];
                    if(!String.isEmpty(unifiedCountryObj.Pricing_Unified_EndCustomer_Act_Mapping__c)) {
                        parent.Pricing_End_Customer__c = unifiedCountryObj.Pricing_Unified_EndCustomer_Act_Mapping__c;
                        parent.Pricing_Customer_Nm__c = null;
                    }
                    
                }
                
                String loggedInUserContactId = lstcurrentUserPerSet[0].Assignee.ContactId;
                List<User> primaryConDetails = [SELECT Id, IsActive, (SELECT Id, PermissionSet.Name, AssigneeId, Assignee.ContactId 
                                                                      FROM PermissionSetAssignments 
                                                                      WHERE PermissionSet.Name IN: Label.Pricing_Tender_PermissionSets_AllExternal.Split(':'))
                                                FROM User WHERE ContactId =: parent.SBQQ__PrimaryContact__c];
                if(primaryConDetails.isEmpty() || (!primaryConDetails.isEmpty()  && (!primaryConDetails[0].IsActive || primaryConDetails[0].PermissionSetAssignments.size()==0)))
                {
                    if(loggedInUserContactId != null)
                    {
                        parent.SBQQ__PrimaryContact__c = loggedInUserContactId;
                        parent.Pricing_Primary_Contact_Email__c = null;
                    }
                    else
                    {
                        globalVar.messageResult = Label.Pricing_Reject_Quote_Clone_For_IU_Error_Message;
                        globalVar.isSuccess = false;
                        return globalVar;
                    }
                }
                
                Database.insert(parent);
                
            } catch (Exception error) {
                //Create Error Log when an Exception Occurs
                Pricing_Tender_Utility.logError(error, sObjectId);
                globalVar.messageResult = JSON.serialize(error.getMessage());
                globalVar.quoteId = null;
                globalVar.isSuccess = false;
                return globalVar;
            }
            
            try {
                Map<Id, SBQQ__QuoteLine__c> qliMap = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, Pricing_Competetor_Product__r.Pricing_Active_cb__c FROM SBQQ__QuoteLine__c 
                WHERE SBQQ__Quote__c =: sObjectId]);
                cloneQuoteLines(sObjectId,parent,parentSObjects,quoteType, qliMap);
                
                
            }  catch(Exception error) {
                //Create Error Log when an Exception Occurs
                Pricing_Tender_Utility.logError(error, sObjectId);
                globalVar.messageResult = JSON.serialize(error.getMessage());
                globalVar.quoteId = null;
                globalVar.isSuccess = false;
                return globalVar;
            }
            
            
            try 
            {
                // Query and clone the children. Here you can change anything without affecting the original sObject  
                cloneQuoteTeam(sObjectId,parent,parentSObjects,userId);
                
                
            }
            catch (Exception error){
                //Create Error Log when an Exception Occurs
                Pricing_Tender_Utility.logError(error);
                globalVar.messageResult = JSON.serialize(error.getMessage());
                globalVar.quoteId = null;
                globalVar.isSuccess = false;
                return globalVar;
            }                
            
            globalVar.messageResult = Label.Pricing_Tender_Quote_Clone_Success_Message;
            globalVar.isSuccess = true;
            globalVar.quoteId = parent.Id; 
        }
        else{
            globalVar.messageResult = Label.Pricing_Tender_No_Access_Error_Message;
            globalVar.isSuccess = false;
            globalVar.quoteId = null;
        }
        
        return globalVar;
    }
    
    //Quote Line and Performance metrics clone
    public static void cloneQuoteLines(String sObjectId,SBQQ__Quote__c parent,List<SBQQ__Quote__c> parentSObjects,String quoteType, Map<Id, SBQQ__QuoteLine__c> qliMap) { 
        sObjectId =  String.escapeSingleQuotes(String.valueOf(sObjectId));
        String query = String.format(
             'SELECT {0},(SELECT {3} FROM {4}) FROM {1} WHERE SBQQ__Quote__c = \'\'{2}\'\' AND Pricing_Status_Nm__c <> \'\'Revised\'\' AND Pricing_Change_Request_cb__c  = false ORDER BY Pricing_Quote_Line_Number__c ASC',
            new String[] {
                String.join(
                    new List<String>(
                        SBQQ__QuoteLine__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap().keySet()
                    ),
                    ','
                ),
                    String.valueOf(SBQQ__QuoteLine__c.SObjectType),
                    String.escapeSingleQuotes(sObjectId),//ch
                    String.join(
                        new List<String>(
                            Pricing_Performance_Metric__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap().keySet()
                        ),
                        ','
                    ),
                    'Performance_Metrics__r'
                    }
        );        
        
        List<Pricing_Performance_Metric__c> children2 = new List<Pricing_Performance_Metric__c>();
        Map<Id,List<Pricing_Performance_Metric__c>> perfMetricsMapping = new Map<Id,List<Pricing_Performance_Metric__c>>();
        Map<Id,SBQQ__QuoteLine__c> childQuoteLineIdToCloneQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        // Query and clone the children. Here you can change anything without affecting the original sObject
        for(SBQQ__QuoteLine__c child:(List<SBQQ__QuoteLine__c>)Database.query(query)){
            if(!(child.Pricing_New_Change_Request_cb__c == true && child.Pricing_Status_Nm__c == 'Rejected')){ // Rejected Change request should not get clone 

                SBQQ__QuoteLine__c newQuoteLine = child.clone(false,true); // deep clone
                newQuoteLine.SBQQ__Quote__c = parent.Id; //set parent ref
                newQuoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Draft;
                if(quoteType != null && quoteType == Label.Pricing_Tender_Standard_Quote){
                    newQuoteLine.Pricing_Program_Type_Nm__c =  Label.Pricing_Tender_Standard_QuoteLine;
                    newQuoteLine.RecordTypeId = Pricing_QuoteLineController.getRecordTypeId(newQuoteLine.Pricing_Program_Type_Nm__c);
                }else{
                    newQuoteLine.RecordTypeId = Pricing_QuoteLineController.getRecordTypeId(parentSObjects[0].Pricing_Program_Type_Nm__c);
                }

                if(!qliMap.get(child.Id).Pricing_Competetor_Product__r.Pricing_Active_cb__c) {
                    newQuoteLine.Pricing_Competetor_Product__c = null;
                }
                
                newQuoteLine.Pricing_Consumption_Platform__c = null;
                newQuoteLine.Pricing_Consumption_Sale_Geo__c = null;
                newQuoteLine.Pricing_Consumption_Country__c = null;
                newQuoteLine.Pricing_Consumption_Region__c = null;
                newQuoteLine.Pricing_Consumption_Segment__c = null;
                newQuoteLine.Pricing_Manager__c = null;
                newQuoteLine.Pricing_Meet_Comp_Price_Amt__c = null;
                newQuoteLine.Pricing_ECAP_Price_Amt__c = null;
                newQuoteLine.Pricing_ECAP_Price_Dup_Amt__c = null; //Duplicate Field
                newQuoteLine.Pricing_MMBP_System_Nm__c = null;
                newQuoteLine.Pricing_Deal_RFQ_Id__c = null;
                newQuoteLine.Pricing_Deal_RFQ_Dup_Id__c = null; //Duplicate Field
                newQuoteLine.Pricing_Deal_RFQ_Status_Nm__c = null;
                newQuoteLine.Pricing_Won_Lost_Comments_Txt__c = null;
                newQuoteLine.Pricing_pm_approval_comments_nm__c = null;
                newQuoteLine.Pricing_Rejection_Comments_nm__c = null;
                newQuoteLine.Pricing_Additional_Comments_Txt__c = null;
                newQuoteLine.Pricing_Previous_Status_Nm__c = 'Pending';
                newQuoteLine.Pricing_End_Date_dt__c = newQuoteLine.Pricing_End_Date_dt__c > date.today() ? newQuoteLine.Pricing_End_Date_dt__c : dateFormat();
                newQuoteLine.Pricing_FSE_Recommended_Price_Nm__c = null;
                newQuoteLine.Pricing_Approved_Start_Date_Dt__c = null;
                newQuoteLine.Pricing_Approved_Start_Date_Dup_Dt__c = null; //Duplicate Field
                newQuoteLine.Pricing_Approved_End_Date_Dt__c = null;
                newQuoteLine.Pricing_Approved_End_Date_Dup_Dt__c = null; //Duplicate Field
                newQuoteLine.Pricing_Approved_Unit_Qty__c = null;
                newQuoteLine.Pricing_Approved_Unit_Dup_Qty__c = null; //Duplicate Field
                newQuoteLine.Pricing_Payable_Quantity__c = null;
                newQuoteLine.Pricing_Quote_Line_Number__c = null;
                newQuoteLine.Pricing_Reference_Quote_Line_Nbr__c = null;
                newQuoteLine.Pricing_Change_Request_cb__c = false;
                newQuoteLine.Pricing_Sales_Rep_Approver__c = null;
                newQuoteLine.Pricing_New_Quantity_qty__c = null;
                newQuoteLine.Pricing_Ready_for_Review_cb__c = false;
                newQuoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c = null;
                newQuoteLine.Pricing_Revised_Pricing_Start_Date_dt__c = null;
                newQuoteLine.Pricing_Deal_Description__c = null;
                newQuoteLine.Pricing_Billing_Start_Date_Dt__c = null;
                newQuoteLine.Pricing_Billing_End_Date_Dt__c = null;
                newQuoteLine.Pricing_Quote_Line_Won_Lost_Status__c = null;
                newQuoteLine.Pricing_Additional_RPM_Notify_Recipients__c = null;
                newQuoteLine.Pricing_Rejection_Reason__c = null;
                newQuoteLine.Pricing_Save_After_Calculation_cb__c = false;
                newQuoteLine.Pricing_Lost_Reason_Nm__c = null;
                newQuoteLine.Pricing_SDM_Fast_Track__c = false;
                
                //TPT
                newQuoteLine.Pricing_Original_Submitted_By_Id__c = null;
                newQuoteLine.Pricing_Original_Submitted_Date_dt__c = null;
                newQuoteLine.Pricing_Last_Approved_Date_dt__c = null;
                newQuoteLine.Customer_Revision_Count_Cnt__c = null;
                newQuoteLine.Field_Revision_Count_Cnt__c = null;
                newQuoteLine.Pricing_Last_Submitted_By_Id__c = null;
                newQuoteLine.Pricing_Last_Submitted_Date_dt__c = null;
                newQuoteLine.Pricing_Approved_Rejected_Month_Txt__c = null;
                //TPT
                //walk story updates US544539
                newQuoteLine.Pricing_Integration_Status_Nm__c = null;
                newQuoteLine.Pricing_Deal_RFQ_Status_Nm__c = null;
                newQuoteLine.Pricing_Error_Messages__c = null;
                newQuoteLine.Pricing_Price_Rule_Error_Message__c = null;
                //walk story updates US544539
                
                newQuoteLine.Pricing_Additional_T_C_s_Txt__c = null;
                newQuoteLine.Pricing_Is_Additional_T_C_Not_Blank_cb__c = false;
                newQuoteLine.Pricing_Backdate_Reason_Txt__c = null;
                newQuoteLine.Pricng_Exclude_from_Price_Approval_Rules__c = false;
                newQuoteLine.Pricing_Group_Type_nm__c = 'Mutually Exclusive';
                newQuoteLine.Pricng_Exclude_from_Price_Approval_Rules__c = false;
                
                newQuoteLine.Pricing_Request_Discount_Unit_Price_qty__c = null;
                newQuoteLine.Pricing_Revised_Pricing_Start_Date_dt__c = null;
                newQuoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c = null;
                newQuoteLine.Pricing_Start_Date_dt__c = null;
                
                newQuoteLine.Pricing_RegionQL_Nm__c = Label.Pricing_Tender_Default_Region_Worldwide;
                //blank out Performance Metrics fields for Client Quote Line on Clone
                if(newQuoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote){
                    newQuoteLine.Pricing_Comp_SKU_Performance_Nbr__c = null;
                    newQuoteLine.Pricing_Intel_SKU_Performance_Nbr__c = null;
                    newQuoteLine.Pricing_Performance_Metric_Nm__c = null;
                    newQuoteLine.Pricing_Write_In_Performance_Metric_Nm__c = null;

                }
                else{
                    newQuoteLine.Pricing_Market_Segment_Nm__c = Label.Pricing_Tender_Market_Segment_Default;
                    newQuoteLine.Pricing_Market_Segment_values_Nm__c = Label.Pricing_Tender_Market_Segment_Values_Default;
                }
                
                newQuoteLine.Pricing_Quote_Line_Status_Number__c = null;
                newQuoteLine.Pricing_Integration_Time_Stamp__c = null;
                newQuoteLine.Pricing_Previous_MyDeal_Action_Nm__c = null;
                newQuoteLine.Pricing_Create_Deal_Actor_Id__c = null;
                newQuoteLine.Pricing_Update_Status_to_Rejected_cb__c = false;
                newQuoteLine.Pricing_Previous_Inbound_Msg_Number__c = null;
                
                //blank out AI fields on clone, OEM CR, RPM CR
                newQuoteLine.Pricing_Reason_for_FeedBack_Txt__c = null;
                newQuoteLine.Pricing_Recommendation_FeedBack_Nm__c = null;  
                newQuoteLine.Pricing_Recommended_Price_Amt__c   = null;
                newQuoteLine.Pricing_Price_Interval_Txt__c = null;
                newQuoteLine.Pricing_Discount_Pct__c = null;
                newQuoteLine.Pricing_Tentative_ECAP_Price_Amt__c = null;
                newQuoteLine.Pricing_Debit_Volume_qty__c = null;
                newQuoteLine.Pricing_Debit_Dollars_Amt__c = null;
                newQuoteLine.Pricing_Last_Credit_Debit_Date_Dt__c = null;
                newQuoteLine.Pricing_Credit_Volume_qty__c = null;
                newQuoteLine.Pricing_Credit_Dollars_Amt__c = null;
                //insert newQuoteLine;
                quoteLineList.add(newQuoteLine);
                //Database.insert(newQuoteLine);
                perfMetricsMapping.put(child.Id,child.Performance_Metrics__r.deepClone(false,false,false));
                childQuoteLineIdToCloneQuoteLineMap.put(child.Id,newQuoteLine);                
            }
        }
        if(!quoteLineList.isEmpty()){
            insert quoteLineList; 
        }
        for(Id quoteLineId : perfMetricsMapping.keySet()){ 
            for(Pricing_Performance_Metric__c performanceMetricsItem : perfMetricsMapping.get(quoteLineId)){
                performanceMetricsItem.Pricing_Quote_Line__c = childQuoteLineIdToCloneQuoteLineMap.get(quoteLineId).Id;
                children2.add(performanceMetricsItem);
            }
        }           
        
        if(!children2.isEmpty()){
            Database.insert(children2);
        }  
    }
    
    //Quote Team Clone
    public static void cloneQuoteTeam(String sObjectId,SBQQ__Quote__c parent, List<SBQQ__Quote__c> parentSObjects, id userId) {
        sObjectId =  String.escapeSingleQuotes(String.valueOf(sObjectId));
        List<Pricing_Quote_Team__c> quoteTeamTobeCloned = new List<Pricing_Quote_Team__c>();
        String query = String.format ('SELECT {0} FROM {1} WHERE Pricing_Quote_Id__c= \'\'{2}\'\'' ,
                                      new String[] {
                                          String.join(
                                              new List<String>(
                                                  Pricing_Quote_Team__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap().keySet()
                                              ),
                                              ','
                                          ),
                                              String.valueOf(Pricing_Quote_Team__c.SObjectType),
                                              String.escapeSingleQuotes(sObjectId)//ch
                                              }
                                     );
        
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> fseUserIdSet= new Set<Id>();
        for(Pricing_Quote_Team__c qtmMem : (List<Pricing_Quote_Team__c>)Database.query(query)){ 
            userIdSet.add(qtmMem.Pricing_Quote_Team_Member_Id__c);
            if(qtmMem.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_FSE){
                fseUserIdSet.add(qtmMem.Pricing_Quote_Team_Member_Id__c);  //Set with all FSE quote team members(Valid/Invalid)
            } 
        }
        
        Map<Id,User> userIdMap = new Map<Id,User>([Select id,isActive from User where Id IN:userIdSet and isActive = true]);
        Set<Id> validFSEUserSet = new Set<Id>();
        if(!fseUserIdSet.isEmpty()){
            validFSEUserSet = Pricing_QuoteTeam_SharingController.getValidFSEUserIdSet(fseUserIdSet,parentSObjects[0].SBQQ__Account__c);
        }

        for(Pricing_Quote_Team__c qtm : (List<Pricing_Quote_Team__c>)Database.query(query)){
            Boolean isAE = qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_Account_Executive? true : false;
            Boolean isITS = qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_ITS? true : false;
            Boolean isFSE = qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_FSE? true : false;
            if(userIdMap.containsKey(qtm.Pricing_Quote_Team_Member_Id__c) && 
               (((isAE || isITS) && qtm.Pricing_Quote_Team_Member_Id__c!=parentSObjects[0].Pricing_Account_Executive_Nm__c && idToQuoteTeamRecMap.get(qtm.id).Pricing_Quote_Team_Member_Id__r.Email != parentSObjects[0].Pricing_Intel_Account_Exec_Email_Txt__c && qtm.Pricing_Quote_Team_Member_Id__c != userId ) || 
                (isFSE && (validFSEUserSet.contains(qtm.Pricing_Quote_Team_Member_Id__c) && qtm.Pricing_Quote_Team_Member_Id__c!=parentSObjects[0].SBQQ__SalesRep__c)))){
                    Pricing_Quote_Team__c quoteTM = new Pricing_Quote_Team__c();  
                    quoteTM.Pricing_Quote_Id__c = parent.Id;
                    quoteTM.Pricing_Quote_Team_Member_Id__c = qtm.Pricing_Quote_Team_Member_Id__c;
                    quoteTM.Pricing_Role_Nm__c = qtm.Pricing_Role_Nm__c; 
                    quoteTeamTobeCloned.add(quoteTM); 
                }
        }  
   
        if(!quoteTeamTobeCloned.isEmpty()){
            insert quoteTeamTobeCloned; 
        }
    }
    
    public static String getQuoteCreateRecordTypeId(String quoteType) {
        Id recordTypeId;
        String recordTypeDeveloperName = '';
        recordTypeDeveloperName = (quoteType == Label.Pricing_Tender_Standard_Quote) ? Label.Pricing_Tender_Quote_RecordType_Create
            :(quoteType == Label.Pricing_Tender_Small_Volume_Quote) ? Label.Pricing_Small_Volume_Quote_Create : Label.Pricing_Tender_Quote_RecordType_Create;
        
        if(recordTypeDeveloperName!= null){
            recordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',recordTypeDeveloperName);
        }
        return recordTypeId;
    }

    /**
    * @description : Method to get QuoteTeam Members in Map.
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 12-21-2023 
    * @param parentSObjects 
    **/
    public static void getUsersFromQuoteTeam(List<SBQQ__Quote__c> parentSObjects) {
        List<Pricing_Quote_Team__c> qteamList = [select id ,Pricing_Quote_Team_Member_Id__c,Pricing_Quote_Team_Member_Id__r.Email,Pricing_Role_Nm__c from Pricing_Quote_Team__c where Pricing_Quote_Id__c =: parentSObjects[0].id];
        if(qteamList.size() > 0){
            for(Pricing_Quote_Team__c qteamMember :qteamList){
                idToQuoteTeamRecMap.put(qteamMember.id,qteamMember);
            }
        }
    }
    
    //Setup date format
    public static date dateFormat(){
        DateTime stringDateTime = date.today();
        DateTime dt = stringDateTime.dateGMT();
        DateTime tomorrow = dt.addDays(1);
        String formattedDateTime = tomorrow.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        return date.valueOf(formattedDateTime);
    }
    
    public class GlobalVariables {
        @AuraEnabled public String messageResult {get;set;}
        @AuraEnabled public Id quoteId {get;set;}
        @AuraEnabled public Boolean isSuccess {get;set;}
    }

    /**
    * @description 
    * @author Vrushabh Uprikar | 01-07-2025 
    * @param recordId 
    * @return SBQQ__Quote__c 
    **/
    @AuraEnabled(cacheable=true)
    public static SBQQ__Quote__c  getQuoteDetails(Id recordId) {
        SBQQ__Quote__c quote = [SELECT Id, Pricing_Program_Type_Nm__c, SBQQ__Account__c FROM SBQQ__Quote__c WHERE Id = : recordId];
        return quote;
    }

    /**
    * @description 
    * @author Vrushabh Uprikar | 01-07-2025 
    * @param accId 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean isSVDCloneAllowed(String accId) {
        return Pricing_Manage_Small_Volume_Deal.isRecordTypeSelectionAllowed(accId);
    }

    /**
    * @description return if svd metadata is active then false else true
    * @author Vrushabh Uprikar | 01-07-2025 
    * @return Boolean 
    **/
    @AuraEnabled(cacheable=true)
    public static Boolean getSVDQuoteActiveStatus() {
        return Pricing_Manage_Small_Volume_Deal.getSVDQuoteActiveStatus();
    }

}