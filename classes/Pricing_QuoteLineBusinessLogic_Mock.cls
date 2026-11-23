public without sharing class Pricing_QuoteLineBusinessLogic_Mock { 
    public static boolean hasRunOnce = false;
    private static Map < Id, SBQQ__Quote__c > existingQuote = new Map < Id, SBQQ__Quote__c > ();
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public static void validateChangeRequestEdit(List < SBQQ__QuoteLine__c > lstquoteLines, boolean isInsert, Map < id, SBQQ__QuoteLine__c > oldMap) {
        if(lstquoteLines!=null && !lstquoteLines.isEmpty()){
            Set < String > changeRequestFieldsEditableByOEMField = new Set < String > ((Label.Pricing_Tender_Change_Request_OEM_Field_Edit_Fields).split(':'));
            Set < String > changeRequestFieldsEditableByRPM = new Set < String > ((Label.Pricing_Tender_Change_Request_RPM_Edit_Fields).split(':'));
            Set < String > changeRequestFieldsNonEditable = new Set < String > ();
            Boolean isOEMField = false;
            Boolean isRPM = false;
            for(PermissionSetAssignment permissionSetAssignmentRec: Pricing_PermissionSetAssignment_Selector.newInstance().selectbyUserId(UserInfo.getUserId())){
                if(permissionSetAssignmentRec.PermissionSet.Name == Label.Pricing_Tender_PermissionSets_TenderUser) {
                    isOEMField = true;
                } else if(permissionSetAssignmentRec.PermissionSet.Name == Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager) {
                    isRPM = true;
                }
            }
            List < Metadata.Metadata > layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List < String > {
                'SBQQ__QuoteLine__c-Pricing Tender Quote Line Layout - Int - Edit'
                    });
            if(isOEMField || isRPM) {
                Metadata.Layout layoutMd = (Metadata.Layout) layouts.get(0);
                for(Metadata.LayoutSection section: layoutMd.layoutSections) {
                    for(Metadata.LayoutColumn column: section.layoutColumns) {
                        if(column.layoutItems != null) {
                            for(Metadata.LayoutItem item: column.layoutItems) {
                                if(item.field != null) {
                                    changeRequestFieldsNonEditable.add(item.field);
                                }
                            }
                        }
                    }
                }
                //New fields added for SSD/PMem that should be non editable on Change requests by FSE/RPM to be added in Pricing_CR_Additional_Non_Editable_Fields.
                Set < String > cRFldsAdditionalNonEditable = new Set < String > ((Label.Pricing_CR_Additional_Non_Editable_Fields).split(':'));
                changeRequestFieldsNonEditable.addAll(cRFldsAdditionalNonEditable);
                if(isOEMField) {
                    changeRequestFieldsNonEditable.removeAll(changeRequestFieldsEditableByOEMField);
                } else if(isRPM) {
                    changeRequestFieldsNonEditable.removeAll(changeRequestFieldsEditableByRPM);
                }
            }
            for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {
                String priceValidationError = '';
                if(quoteLine.Pricing_Change_Request_cb__c) {
                    if(isOEMField) {
                        for(String field: changeRequestFieldsNonEditable) {
                            System.debug(field);
                            if(quoteLine.get(field) != oldMap.get(quoteLine.Id).get(field)) {
                                quoteLine.addError(Label.Pricing_Tender_Change_Request_OEMField_Validation_Error_Message);
                                break;
                            }
                        }
                    } else if(isRPM) {
                        for(String field: changeRequestFieldsNonEditable) {
                            System.debug(field);
                            if(quoteLine.get(field) != oldMap.get(quoteLine.Id).get(field)) {
                                quoteLine.addError(Label.Pricing_Tender_Change_Request_RPM_Validation_Error_Message);
                                System.debug(Label.Pricing_Tender_Change_Request_RPM_Validation_Error_Message);
                                break;
                            }
                        }
                    }
                }
            }
        }
        
    }
    public static void updateQuoteLineDetails(List < SBQQ__QuoteLine__c > lstquoteLines, boolean isInsert, Map < id, SBQQ__QuoteLine__c > oldMap) {
        if(lstquoteLines!=null && !lstquoteLines.isEmpty()){
            Map < ID, Schema.RecordTypeInfo > rtMap = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosById();
            Set < Id > quoteIds = new Set < Id > ();
            Set < Id > quoteLineIds = new Set < Id > ();
            for(SBQQ__QuoteLine__c ql: lstquoteLines) {
                quoteIds.add(ql.SBQQ__Quote__c);
                quoteLineIds.add(ql.Id);
            }
            Map<String,Decimal> quoteLineNumberToStatusMap = new Map<String,Decimal>(); 
            quoteLineNumberToStatusMap.put(Label.Pricing_Tender_QuoteLine_Status_Draft,10); 
            quoteLineNumberToStatusMap.put(Label.Pricing_Tender_QuoteLine_Status_Rejected,20);
            quoteLineNumberToStatusMap.put(Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview,30);
            quoteLineNumberToStatusMap.put(Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview,40);
            quoteLineNumberToStatusMap.put(Label.Pricing_Tender_QuoteLine_Status_Approved,50);
            quoteLineNumberToStatusMap.put(Label.Pricing_Tender_QuoteLine_Status_Lost,60);
            quoteLineNumberToStatusMap.put(Label.Pricing_Tender_QuoteLine_Status_Won,70); 
            
            if(isInsert) {
                Map < Id, SBQQ__Quote__c > quoteDtls = new Map < id, SBQQ__Quote__c > (Pricing_Quote_Selector.newInstance().selectByIds(quoteIds));
                Boolean isRPMUser = userHasValidPermissionSet(new Set < String > {
                    Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager
                        });
                
                for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {
                    //if(rtMap.get(quoteLine.RecordTypeId).getDeveloperName() == Label.Pricing_Tender_QuoteLine_RecordType_Create || rtMap.get(quoteLine.RecordTypeId).getDeveloperName() == Label.Pricing_SVD_Quote_Line_Create) {
                    if(rtMap.get(quoteLine.RecordTypeId).getDeveloperName() == Label.Pricing_Tender_QuoteLine_RecordType_Create || rtMap.get(quoteLine.RecordTypeId).getDeveloperName() == Label.Pricing_SVD_Quote_Line_Create || rtMap.get(quoteLine.RecordTypeId).getDeveloperName() == Label.Pricing_SSD_Quote_Line_Create || rtMap.get(quoteLine.RecordTypeId).getDeveloperName() == Label.Pricing_PMem_Quote_Line_Create  || rtMap.get(quoteLine.RecordTypeId).getDeveloperName() == Label.Pricing_NIC_Quote_Line_Create) {
                        if(quoteLine.Pricing_Market_Segment_Nm__c == Label.Pricing_Tender_QuoteLine_Market_Segment_Embedded 
                           && String.isNotBlank(quoteLine.Pricing_Market_Segment_values_Nm__c) 
                           && quoteLine.Pricing_Market_Segment_values_Nm__c.containsIgnoreCase(';')){
                               quoteLine.addError(System.Label.Pricing_Market_Segment_Exceed_Exception);
                               Continue;
                           }
                        if(isRPMUser){
                            quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
                            quoteLine.RecordTypeId = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Submitted) :Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Submitted);
                            //Revert Status fix
                            quoteLine.Pricing_Original_Submitted_By_Id__c = UserInfo.getUserId();
                            quoteLine.Pricing_Original_Submitted_Date_dt__c = Datetime.now();
                            quoteLine.Pricing_Last_Submitted_Date_dt__c = Datetime.now();
                            quoteLine.Pricing_Last_Submitted_By_Id__c = UserInfo.getUserId();
                            //US750594
                            quoteLine.Pricing_Approved_Start_Date_Dt__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_ShipmentStDate_Dt__c;
                            quoteLine.Pricing_Approved_End_Date_Dt__c = quoteLine.Pricing_End_Date_dt__c;
                            quoteLine.Pricing_Approved_Unit_Qty__c = (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_SSD_Quote || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_NIC_Quote) ? quoteLine.Pricing_Total_Volume_Qty__c:quoteLine.Pricing_Unit_Qty__c;
                            quoteLine.Pricing_ECAP_Price_Amt__c = null;//quoteLine.Pricing_Req_Discounted_Unit_Price__c; //US817773
                            
                            quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c = quoteLine.Pricing_Approved_Start_Date_Dt__c;
                            quoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c = null;
                            quoteLine.Pricing_Billing_End_Date_Dt__c = quoteLine.Pricing_End_Date_dt__c;
                            quoteLine.Pricing_Billing_Start_Date_Dt__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_ShipmentStDate_Dt__c;
                        }else{
                            quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Draft;
                            quoteLine.RecordTypeId =quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Edit) :Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Edit);
                        }
                        /*if(quoteLine.Pricing_Program_Type_Nm__c  != quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Program_Type_Nm__c){
quoteLine.addError(Label.Pricing_Quote_Line_Type_Error_Message);
}*/
                        //US763473
                        //quoteLine.Pricing_Billing_End_Date_Dt__c = quoteLine.Pricing_End_Date_dt__c;
                        //quoteLine.Pricing_Billing_Start_Date_Dt__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_ShipmentStDate_Dt__c;
                        
                        //US
                        quoteLine.Pricing_Group_Type_nm__c = Label.Pricing_Tender_Default_Group_Type;
                        if(quoteLine.Pricing_Market_Segment_Nm__c == Label.Pricing_Tender_QuoteLine_Market_Segment_Non_Embedded && String.isBlank(quoteLine.Pricing_Market_Segment_values_Nm__c)){
                               quoteLine.Pricing_Market_Segment_values_Nm__c = Label.Pricing_Tender_QuoteLine_Market_Segment_Values_Corp;
                           }
                        quoteLine.SBQQ__ListPrice__c = 0;
                        quoteLine.SBQQ__SpecialPrice__c = 0;
                        quoteLine.SBQQ__Quantity__c = 1;
                        quoteLine.SBQQ__NetPrice__c = 0;
                        quoteLine.Pricing_Sales_Rep__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).SBQQ__SalesRep__c;
                        quoteLine.Pricing_Region_Nm__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Region_Nm__c;
                        quoteLine.Pricing_Server_Deal_Type_Nm__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Server_Deal_Type_Nm__c;
                        quoteLine.Pricing_End_Customer_Nm__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Customer_Nm__c;
                        quoteLine.Pricing_OEM_Account_Nm__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).SBQQ__Account__r.Name;
                        quoteLine.Pricing_Project_Nm__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Project_Name_Nm__c;
                        quoteLine.Pricing_End_Customer_Country__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_End_Customer_Country_Nm__c;
                        quoteLine.Pricing_Primary_Contact_Nm__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).SBQQ__PrimaryContact__c;
                        if(quoteLine.Pricing_Product_Nm__c != null) {
                            quoteLine.SBQQ__Product__c = quoteLine.Pricing_Product_Nm__c;
                        }
                    }  
                    //}
                    //Revert Status fix
                    if(quoteLineNumberToStatusMap.containsKey(quoteLine.Pricing_Status_Nm__c)){
                        quoteLine.Pricing_Quote_Line_Status_Number__c = quoteLineNumberToStatusMap.get(quoteLine.Pricing_Status_Nm__c);
                    }
                    //Populate Pricing Manager for Write In Product Quoteline on RPM CR for Write In Product
                    if(quoteLine.SBQQ__ProductName__c == Label.Pricing_Tender_Write_In_Product &&  (quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null && (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved))){
                        quoteLine.Pricing_Manager__c = userInfo.getUserId();
                    }
                    //Validate QuoteLine Text fields and throw error if Non Latin Characters are present
                    validateQLTextFieldsForLatinChars(quoteLine,oldMap,true);
                }
            } else {
                boolean isCalculationPending = false;
                if(TriggerHandler.isActive('Pricing_Prevent_Save_After_Calculation')) {
                    for(SBQQ__QuoteLine__c quoteLine: lstquoteLines){
                        if(!quoteLine.Pricing_Save_After_Calculation_cb__c && System.isQueueable()){
                            isCalculationPending = true;
                            quoteLine.Pricing_Save_After_Calculation_cb__c = true;
                        }  
                    }
                    
                    for(SBQQ__QuoteLine__c quoteLine: lstquoteLines){
                        if(System.isQueueable() && !isCalculationPending){
                            quoteLine.addError(Label.Pricing_IQR_SFDC_Environment + ' ' + Label.Pricing_Quote_Service_Exception_Message);
                            break;
                        }    
                    }                    
                }
                Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
                List<Pricing_Comments__c> commentsFilled = new List<Pricing_Comments__c>(Pricing_Comments_Selector.newInstance().selectByIdsAndReq(quoteIds,commentRecordTypeId));
                Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>(Pricing_QuoteLines_Selector.newInstance().selectByIdsAndPM(quoteLineIds));
                Set<Id> pfirQLSet = new Set<Id>();
                Set<Id> billingStartDateChangeQLSet = new Set<Id>();
                List<SBQQ__QuoteLine__c> billingStartDateQuoteLineList = new List<SBQQ__QuoteLine__c>();
                Set<Id> quoteLinePrimaryStatusSet = new Set<Id>();
                Set<Id> quoteLineSecondaryStatusSet = new Set<Id>();
                Set<Id> restrictWonNotUnifiedSet = new Set<Id>();
                Set<Id> qliQuarterSet = new Set<Id>();
                Set<Id> autoRejectSanctionedQLSet = new Set<Id>();  //Set of Quote Lines which are auto rejected that are sanctioned on submission
                Set<Id> autoRejectedECCommentsQLSet = new Set<Id>();  //Set of Quote Lines where RPL status is EC
                Map<Id,Set<Id>> qliToMultipleFSEUserIdMap = new Map<Id,Set<Id>>();
                
                //creating map of quoteline to pending approval user
                for(ProcessInstanceWorkitem workItem : Pricing_ProcessInstanceWorkitem_Selector.newInstance().selectbyQliIdsandStatus(quoteLineIds,'Pending')){
                    if(!qliToMultipleFSEUserIdMap.containsKey(workItem.ProcessInstance.TargetObjectId))
                        qliToMultipleFSEUserIdMap.put(workItem.ProcessInstance.TargetObjectId,new Set<Id>{workItem.OriginalActorId});
                    else
                        qliToMultipleFSEUserIdMap.get(workItem.ProcessInstance.TargetObjectId).add(workItem.OriginalActorId);
                }
                //creating list of non editable fields for user not present in above map
                Set < String > fieldsNonEditable = new Set < String > ();
                List < Metadata.Metadata > layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List < String > {
                    'SBQQ__QuoteLine__c-Pricing Tender Quote Line Layout - Int - Edit'
                        });
                Metadata.Layout layoutMd = (Metadata.Layout) layouts.get(0);
                for(Metadata.LayoutSection section: layoutMd.layoutSections) {
                    for(Metadata.LayoutColumn column: section.layoutColumns) {
                        if(column.layoutItems != null) {
                            for(Metadata.LayoutItem item: column.layoutItems) {
                                if(item.field != null) {
                                    fieldsNonEditable.add(item.field);
                                }
                            }
                        }
                    }
                }
                fieldsNonEditable.removeAll(Label.Pricing_Tender_Field_Edit_With_PIFR.split(':'));
                
                //Date highestApprovedStartDate;
                for(SBQQ__QuoteLine__c quoteLine: lstquoteLines){
                    if(TriggerHandler.isActive('Pricing_Status_Revert_Fix')) {
                        //revert status fix Approved ==> PFIR
                        if((oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) {
                            quoteLine.Pricing_Status_Nm__c =  Label.Pricing_Tender_QuoteLine_Status_Approved;
                        }
                        
                        //revert status fix Rejected ==> PFIR
                        if((oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) {
                            quoteLine.Pricing_Status_Nm__c =  Label.Pricing_Tender_QuoteLine_Status_Rejected;
                        }
                        
                        //revert status fix Won ==> Approved
                        if((oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved) {
                            quoteLine.Pricing_Status_Nm__c =  Label.Pricing_Tender_QuoteLine_Status_Won;
                        }
                    }
                    
                    //restricting non QTM FSE to edit quoteline during Field review
                    if(qliToMultipleFSEUserIdMap.get(quoteLine.id) != null){
                        if(!qliToMultipleFSEUserIdMap.get(quoteLine.id).contains(UserInfo.getUserId()) && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview) {
                            for(String field: fieldsNonEditable) {
                                if(quoteLine.get(field) != oldMap.get(quoteLine.Id).get(field)) {
                                    quoteLine.addError(Label.Pricing_Tender_No_Access_FSE_Error_Message);
                                    break;
                                }
                            }
                        }
                    } 
                    
                    if(quoteLine.Pricing_Market_Segment_Nm__c == Label.Pricing_Tender_QuoteLine_Market_Segment_Embedded 
                       && (oldMap.get(quoteLine.id).Pricing_Market_Segment_values_Nm__c != quoteLine.Pricing_Market_Segment_values_Nm__c) 
                       && String.isNotBlank(quoteLine.Pricing_Market_Segment_values_Nm__c) 
                       && quoteLine.Pricing_Market_Segment_values_Nm__c.containsIgnoreCase(';')){
                           quoteLine.addError(System.Label.Pricing_Market_Segment_Exceed_Exception);
                           Continue;
                       }
                    if(oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c){
                        if((quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) ||(quoteLine.Pricing_Change_Request_cb__c && quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null && (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won))){
                            pfirQLSet.add(quoteLine.Id);
                        }
                    }
                    if(quoteLine.Pricing_Status_Nm__c != oldMap.get(quoteLine.id).Pricing_Status_Nm__c) {
                        //Populate Pricing Manager for Write In Product Quoteline on Approval/Rejection
                        if(quoteLine.SBQQ__ProductName__c == Label.Pricing_Tender_Write_In_Product && oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview &&((quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected) || (quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won))) {
                                    quoteLine.Pricing_Manager__c = userInfo.getUserId();
                   }                   
                        //Populate Pricing Manager for Intel Product Quoteline if Rejected before deal creation                                                                                        }
                        if(quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product &&
                           oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview &&
                           quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected && (quoteLine.Pricing_Integration_Status_Nm__c == '' || quoteLine.Pricing_Integration_Status_Nm__c == null)) {
                               quoteLine.Pricing_Manager__c = userInfo.getUserId();
                           }
                    }
                    System.debug(mapFunctionalityNameTriggerExecution);
                    if (!mapFunctionalityNameTriggerExecution.isEmpty() &&
                        mapFunctionalityNameTriggerExecution.containsKey('pricingSendOutboundMessagesIQR') &&
                        mapFunctionalityNameTriggerExecution.get('pricingSendOutboundMessagesIQR').Core_Active__c){
                            if((oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && 
                               (quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product) &&
                               ((oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won) ||
                                (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost) ||
                                (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved) ||
                                (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Cancelled) || 
                                (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && quoteLine.Pricing_Integration_Status_Nm__c == Label.Pricing_Tender_MyDeal_Integration_Status_Complete && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected))) {
                                    quoteLine.Pricing_Integration_Status_Nm__c = Label.Pricing_Tender_MyDeal_Integration_Status_Pending;
                                }
                        }
                    
                    if((oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && 
                       (((oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved) && (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won ||  quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost)) ||
                        (oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won && quoteLine.Pricing_Reference_Quote_Line_Nbr__c !=null))){
                            quoteLineSecondaryStatusSet.add(quoteLine.Id);
                        }
                    
                    if((oldMap.get(quoteLine.Id).Pricing_Quote_Line_Won_Lost_Status__c != quoteLine.Pricing_Quote_Line_Won_Lost_Status__c) && (oldMap.get(quoteLine.Id).Pricing_Quote_Line_Won_Lost_Status__c == null) && (quoteLine.Pricing_Quote_Line_Won_Lost_Status__c == Label.Pricing_Tender_QuoteLine_Status_Won || quoteLine.Pricing_Quote_Line_Won_Lost_Status__c == Label.Pricing_Tender_QuoteLine_Status_Lost)){
                        quoteLinePrimaryStatusSet.add(quoteLine.Id);
                    }
                    
                    if ((oldMap.get(quoteLine.Id).Pricing_Quote_Line_Won_Lost_Status__c != quoteLine.Pricing_Quote_Line_Won_Lost_Status__c) && (oldMap.get(quoteLine.Id).Pricing_Quote_Line_Won_Lost_Status__c == null) && (quoteLine.Pricing_Quote_Line_Won_Lost_Status__c == Label.Pricing_Tender_QuoteLine_Status_Won)) {
                        restrictWonNotUnifiedSet.add(quoteLine.Id);
                    }
                    
                    if(quoteLine.Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_Approved && 
                       (oldMap.get(quoteLine.Id).Pricing_Quote_Line_Won_Lost_Status__c != quoteLine.Pricing_Quote_Line_Won_Lost_Status__c)){
                           quoteLine.addError(Label.Pricing_Restrict_Bulk_Won_Lost_Error);
                       }
                    
                    //Populate Approved/Rejected Date on Approval/Rejection and Change request Won QL
                    if((oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && (((oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview &&(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won)) ||
                                                                                                              quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected)) || (quoteLine.Pricing_Is_Sanctioned__c == true && (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft && (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview)))){
                                                                                                                  qliQuarterSet.add(quoteLine.id);
                                                                                                              }
                    //Auto Rejection of quotelines on submission i.e. Draft => PIFR and Draft => PFIR and Is sanctioned = true
                    if(Test.isRunningTest() || quoteLine.Pricing_Status_Nm__c != oldMap.get(quoteLine.id).Pricing_Status_Nm__c && quoteLine.Pricing_Is_Sanctioned__c == true && (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft && (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview))) {
                        autoRejectSanctionedQLSet.add(quoteLine.Id);
                    }
                }
                Map<Id,SBQQ__QuoteLine__c> changeRequestQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                
                if(!pfirQLSet.isEmpty()){
                    changeRequestQuoteLineMap =  new Map<Id,SBQQ__QuoteLine__c>(Pricing_QuoteLines_Selector.newInstance().selectByRefQlis(pfirQLSet)); 
                } 
                Set < String > currentUserPermissionSet = new Set < String > ();
                Set < String > quoteLineReadOnlyStatusSet = new Set < String > ((Label.Pricing_Tender_QuoteLine_ReadOnly_Status).split(':'));
                Set < String > quoteLineEditStatusSet = new Set < String > ((Label.Pricing_Tender_QuoteLine_Edit_Status).split(':'));
                
                Set < String > quoteLineReadOnlyDealRFQStatusSet = new Set < String > ((Label.Pricing_Tender_QuoteLine_ReadOnly_DealRFQStatus).split(':'));
                Set < String > quoteLineEditDealRFQStatusSet = new Set < String > ((Label.Pricing_Tender_QuoteLine_Edit_DealRFQStatus).split(':'));         
                
                Set < String > quoteLineReadOnlyIntegrationStatusSet = new Set < String > ((Label.Pricing_Tender_QuoteLine_ReadOnly_IntegrationStatus).split(':'));
                Set < String > quoteLineEditIntegrationStatusSet = new Set < String > ((Label.Pricing_Tender_QuoteLine_Edit_IntegrationStatus).split(':'));
                
                List<SBQQ__QuoteLine__c> hasPendingChangeRequestList = Pricing_QuoteLines_Selector.newInstance().selectByRefQLIIdsAndStatus(quoteLinePrimaryStatusSet,'Rejected');
                Set<Id> hasPendingChangeRequestSet =  new Set<Id>();
                Map<Id, String>  restrictStatusUnifiedQuoteLineMsgMap = new Map<Id, String>();
                if(!hasPendingChangeRequestList.isEmpty()){
                    for(SBQQ__QuoteLine__c qLId : hasPendingChangeRequestList){
                        hasPendingChangeRequestSet.add(qLId.Pricing_Reference_Quote_Line_Nbr__c);
                    }
                }
                if(restrictWonNotUnifiedSet.size() > 0) {
                    restrictStatusUnifiedQuoteLineMsgMap = Pricing_QuoteLineController_Mock.isNotUnifiedQuoteLineBulk(restrictWonNotUnifiedSet);
                }
                String quarter;
                List<String> quarterLst = new List<String>();
                List<Period> month = new List<Period>();
                if(qliQuarterSet.size()>0){
                    quarter = [SELECT FullyQualifiedLabel FROM Period WHERE FiscalYearSettings.YearType='Custom' and Type =: 'Quarter' and StartDate <= : System.today() order by StartDate desc limit 1][0].FullyQualifiedLabel ;
                    System.debug('quarter------->'+quarter);
                    month = [SELECT FiscalYearSettings.Name,Number FROM Period WHERE FiscalYearSettings.YearType='Custom' and Type =: 'Month' and StartDate <= : System.today() order by StartDate desc limit 1];
                    quarterLst = quarter.split(' ');
                }
                
                //Auto Rejection of quotelines on submission if Sanctioned and get Quotelines that have RPL status as EC
                if(autoRejectSanctionedQLSet.size() > 0) {
                    for(SBQQ__QuoteLine__c qLine : Pricing_QuoteLines_Selector.newInstance().selectByQuoteLineIds(autoRejectSanctionedQLSet)) {
                        List<String> complianceWatchList = qLine.SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c.split(';');
                        if(complianceWatchList.contains('EC')){
                            autoRejectedECCommentsQLSet.add(qLine.Id);
                        }
                    }
                }
                
                for(SBQQ__QuoteLine__c quoteLine: lstquoteLines){
                    
                    
                    if((oldMap.get(quoteLine.Id).Pricing_Update_Status_to_Rejected_cb__c 
                        != quoteLine.Pricing_Update_Status_to_Rejected_cb__c) 
                       && quoteLine.Pricing_Update_Status_to_Rejected_cb__c
                       && Pricing_QuoteTeam_Trigger_Handler.hasQuoteLineResubmission == false){
                           quoteLine.Pricing_Update_Status_to_Rejected_cb__c = false;
                           if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview){
                               quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Rejected;
                               quoteLine.Pricing_Sales_Rep_Approver__c = UserInfo.getUserId();
                               if(quoteLine.Pricing_Change_Request_cb__c){
                                   quoteLine.Pricing_Change_Request_cb__c = false;
                               }
                           }
                       }
                    if((!quoteLineReadOnlyStatusSet.isEmpty() && (oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && (quoteLineReadOnlyStatusSet.contains(quoteLine.Pricing_Status_Nm__c))) || 
                       (!quoteLineReadOnlyDealRFQStatusSet.isEmpty() && (oldMap.get(quoteLine.id).Pricing_Deal_RFQ_Status_Nm__c != quoteLine.Pricing_Deal_RFQ_Status_Nm__c) && (quoteLineReadOnlyDealRFQStatusSet.contains(quoteLine.Pricing_Deal_RFQ_Status_Nm__c))) ||
                       (!quoteLineReadOnlyIntegrationStatusSet.isEmpty() && (oldMap.get(quoteLine.id).Pricing_Integration_Status_Nm__c != quoteLine.Pricing_Integration_Status_Nm__c) && (quoteLineReadOnlyIntegrationStatusSet.contains(quoteLine.Pricing_Integration_Status_Nm__c)))) { 
                           quoteLine.RecordTypeId = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Read_Only): Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_ReadOnly);
                       } 
                    else if((!quoteLineEditStatusSet.isEmpty() && (oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && (quoteLineEditStatusSet.contains(quoteLine.Pricing_Status_Nm__c))) ||
                            (!quoteLineEditDealRFQStatusSet.isEmpty() && (oldMap.get(quoteLine.id).Pricing_Deal_RFQ_Status_Nm__c != quoteLine.Pricing_Deal_RFQ_Status_Nm__c) && (quoteLineEditDealRFQStatusSet.contains(quoteLine.Pricing_Deal_RFQ_Status_Nm__c))) ||
                            (!quoteLineEditIntegrationStatusSet.isEmpty() && (oldMap.get(quoteLine.id).Pricing_Integration_Status_Nm__c != quoteLine.Pricing_Integration_Status_Nm__c) && (quoteLineEditIntegrationStatusSet.contains(quoteLine.Pricing_Integration_Status_Nm__c) 
                            && ((String.isBlank(quoteLine.Pricing_Deal_RFQ_Id__c) && String.isBlank(quoteLine.Pricing_Deal_RFQ_Status_Nm__c))|| (String.isNotBlank(quoteLine.Pricing_Deal_RFQ_Id__c) && (quoteLineEditDealRFQStatusSet.contains(quoteLine.Pricing_Deal_RFQ_Status_Nm__c) || (String.isBlank(quoteLine.Pricing_Deal_RFQ_Status_Nm__c) && (quoteLineEditIntegrationStatusSet.contains(quoteLine.Pricing_Integration_Status_Nm__c))))))))) {                    
                              quoteLine.RecordTypeId = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Submitted):Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Submitted);
                        }
                    else if((oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft){
                        quoteLine.RecordTypeId =quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Edit) :Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Edit);
                    }
                    //TPT
                    if(oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) {
                        if(qliQuarterSet.contains(quoteLine.id)){
                            quoteLine.Pricing_Last_Approved_Date_dt__c = DateTime.now();
                            quoteLine.Pricing_Approved_Rejected_Quarter__c = quarterLst[3]+'-'+quarterLst[0]+quarterLst[1];
                            quoteline.Pricing_Approved_Rejected_Month_Txt__c = month[0].FiscalYearSettings.Name+'-'+month[0].Number;
                        }
                        if(quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null 
                           &&(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected || 
                              quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won)) {
                                  //Check if Change Request Quote Line is getting Approved then make the Parent as Revised
                                  if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved 
                                     && changeRequestQuoteLineMap.containsKey(quoteLine.Id)) {
                                         SBQQ__QuoteLine__c changeRequestQL =  changeRequestQuoteLineMap.get(quoteLine.Id);
                                         if(changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Action_Won) {
                                             quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Action_Won;
                                             quoteLine.Pricing_Won_Lost_Comments_Txt__c = changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Won_Lost_Comments_Txt__c;
                                         }
                                     }
                                  quoteLine.Pricing_Change_Request_cb__c = false;
                              }
                        
                        if((quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved) || (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won) || (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost) || (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Revised)){
                            quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c=quoteLine.Pricing_Approved_Start_Date_Dt__c;
                            quoteLine.Pricing_Approved_End_Date_Dup_Dt__c=quoteLine.Pricing_Approved_End_Date_Dt__c;
                            quoteLine.Pricing_Approved_Unit_Dup_Qty__c=quoteLine.Pricing_Approved_Unit_Qty__c;
                            quoteLine.Pricing_ECAP_Price_Dup_Amt__c=quoteLine.Pricing_ECAP_Price_Amt__c;
                            quoteLine.Pricing_Deal_RFQ_Dup_Id__c=quoteLine.Pricing_Deal_RFQ_Id__c;
                            quoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c = quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c;
                            
                        }
                        
                        //US750594
                        if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview){
                            if(quoteLine.Pricing_Change_Request_cb__c){
                                if(changeRequestQuoteLineMap.containsKey(quoteLine.Id)){
                                    SBQQ__QuoteLine__c changeRequestQL =  changeRequestQuoteLineMap.get(quoteLine.Id);
                                    quoteLine.Pricing_Approved_Start_Date_Dt__c = changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c;
                                    quoteLine.Pricing_Approved_End_Date_Dt__c = changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c;
                                    quoteLine.Pricing_Approved_Unit_Qty__c = changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Unit_Qty__c;
                                    quoteLine.Pricing_ECAP_Price_Amt__c = changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_ECAP_Price_Amt__c;
                                    /*Date maxDate = System.today();
if(changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c != null 
&& maxDate < changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c){
maxDate = changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c;
}*/
                                    
                                    //changed the date logic to compare with approved end date 28/07
                                    if(changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c > quoteLine.Pricing_Approved_End_Date_Dt__c){
                                        quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c = quoteLine.Pricing_Approved_End_Date_Dt__c;
                                    }else{
                                        quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c = changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c;
                                    }
                                }
                            }else{
                                if(changeRequestQuoteLineMap.containsKey(quoteLine.Id)){
                                    quoteLine.Pricing_Approved_Start_Date_Dt__c = changeRequestQuoteLineMap.get(quoteLine.Id).SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c;
                                }
                                quoteLine.Pricing_Approved_End_Date_Dt__c = quoteLine.Pricing_End_Date_dt__c;
                                quoteLine.Pricing_Approved_Unit_Qty__c = (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_SSD_Quote || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_NIC_Quote ) ? quoteLine.Pricing_Total_Volume_Qty__c:quoteLine.Pricing_Unit_Qty__c;//quoteLine.Pricing_Unit_Qty__c;
                                quoteLine.Pricing_ECAP_Price_Amt__c = null;//quoteLine.Pricing_Req_Discounted_Unit_Price__c;
                                quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c = quoteLine.Pricing_Approved_Start_Date_Dt__c;   
                                quoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c = null;
                                quoteLine.Pricing_Billing_End_Date_Dt__c = quoteLine.Pricing_End_Date_dt__c;
                                quoteLine.Pricing_Billing_Start_Date_Dt__c = changeRequestQuoteLineMap.get(quoteLine.Id).SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c;
                            }
                        }
                    }else if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview&& quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c != quoteLine.Pricing_Approved_Start_Date_Dt__c&& quoteLine.Pricing_Reference_Quote_Line_Nbr__c == null){
                                 //When Revised pricing start date gets changed then we need to revert it to old value 
                                 quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c = quoteLine.Pricing_Approved_Start_Date_Dt__c;
                             }
                    if(oldMap.get(quoteLine.Id).Pricing_Product_Nm__c != quoteLine.Pricing_Product_Nm__c) {
                        quoteLine.SBQQ__Product__c = quoteLine.Pricing_Product_Nm__c;
                    }
                    if(quoteLine.Pricing_Additional_T_C_s_Txt__c != null && oldMap.get(quoteLine.Id).Pricing_Additional_T_C_s_Txt__c != quoteLine.Pricing_Additional_T_C_s_Txt__c){
                           quoteLine.Pricing_Is_Additional_T_C_Not_Blank_cb__c = true;
                       }else if (quoteLine.Pricing_Additional_T_C_s_Txt__c == null){
                           quoteLine.Pricing_Is_Additional_T_C_Not_Blank_cb__c = false;   
                       }
                    if(oldMap.get(quoteLine.Id).Pricing_Ready_for_Review_cb__c != quoteLine.Pricing_Ready_for_Review_cb__c) {
                        String errorMessage = '';
                        if(quoteLine.Pricing_Ready_for_Review_cb__c == true){
                            for(Pricing_Comments__c cmnt:commentsFilled){
                                if(quoteLine.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_Small_Volume_Quote && cmnt.Pricing_Quote__c == quoteLine.SBQQ__Quote__c && cmnt.Pricing_Answer__c == null){                                
                                    errorMessage = Label.Pricing_Tender_Quote_Comment_Submit_Error_Message;
                                    break;
                                }
                            }
                            /*if(!Label.Pricing_Tender_ExceptionQuoteType.contains(quoteLineMap.get(quoteLine.Id).Pricing_Program_Type_Nm__c) && quoteLineMap.get(quoteLine.Id).Performance_Metrics__r.IsEmpty() && TriggerHandler.isActive('Pricing_Check_Performance_Metrics')){
                                if(errorMessage != ''){
                                    errorMessage = errorMessage+'<br/>'+Label.Pricing_Tender_QuoteLine_Performance_Metric_Submit_Error_Message;
                                }else{
                                    errorMessage = Label.Pricing_Tender_QuoteLine_Performance_Metric_Submit_Error_Message;
                                }
                            }*/
                            if(!String.isEmpty(errorMessage)){
                                quoteLine.addError(errorMessage,true);  
                            }
                        }    
                    }
                    
                    if((!quoteLinePrimaryStatusSet.isEmpty() && quoteLinePrimaryStatusSet.contains(quoteLine.Id)) || (!restrictStatusUnifiedQuoteLineMsgMap.isEmpty()  && restrictStatusUnifiedQuoteLineMsgMap.containsKey(quoteLine.Id))){
                        if(hasPendingChangeRequestSet.contains(quoteLine.Id)){
                            quoteLine.addError(Label.Pricing_CR_Reference_Status_Change_Message_Trigger);
                        }else if (restrictStatusUnifiedQuoteLineMsgMap.containsKey(quoteLine.Id)) {
                            quoteLine.addError(restrictStatusUnifiedQuoteLineMsgMap.get(quoteLine.Id));
                        } else {
                            quoteLine.Pricing_Status_Nm__c = quoteLine.Pricing_Quote_Line_Won_Lost_Status__c;
                        }
                    }
                    if(!quoteLineSecondaryStatusSet.isEmpty() && quoteLineSecondaryStatusSet.contains(quoteLine.Id) ){
                        quoteLine.Pricing_Quote_Line_Won_Lost_Status__c = quoteLine.Pricing_Status_Nm__c;
                    }
                    //Revert Status fix
                    if(quoteLineNumberToStatusMap.containsKey(quoteLine.Pricing_Status_Nm__c)){
                        quoteLine.Pricing_Quote_Line_Status_Number__c = quoteLineNumberToStatusMap.get(quoteLine.Pricing_Status_Nm__c);
                        if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview){
                            if(quoteLineReadOnlyDealRFQStatusSet.contains(quoteLine.Pricing_Deal_RFQ_Status_Nm__c) || quoteLineEditDealRFQStatusSet.contains(quoteLine.Pricing_Deal_RFQ_Status_Nm__c) || quoteLineReadOnlyIntegrationStatusSet.contains(quoteLine.Pricing_Integration_Status_Nm__c)){
                                quoteLine.Pricing_Quote_Line_Status_Number__c = 45;
                            }else if((quoteLineEditIntegrationStatusSet.contains(quoteLine.Pricing_Integration_Status_Nm__c) || String.isBlank(quoteLine.Pricing_Integration_Status_Nm__c)) && String.isBlank(quoteLine.Pricing_Deal_RFQ_Id__c) && String.isBlank(quoteLine.Pricing_Deal_RFQ_Status_Nm__c)){
                                quoteLine.Pricing_Quote_Line_Status_Number__c = 40;
                            }
                        }
                    }
                    //Validate QuoteLine Text fields and throw error if Non Latin Characters are present on Update
                    validateQLTextFieldsForLatinChars(quoteLine,oldMap,false); 
                    
                    //Auto Rejection of quotelines on submission i.e. Draft => PIFR and Draft => PFIR
                    if(TriggerHandler.isActive('Pricing_UCD_Switch') && autoRejectSanctionedQLSet.contains(quoteLine.Id) && !quarterLst.isEmpty()) {
                        quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Rejected;
                        quoteLine.Pricing_Change_Request_cb__c = false;
                        quoteLine.Pricing_Last_Approved_Date_dt__c = DateTime.now();
                        quoteLine.Pricing_Approved_Rejected_Quarter__c = quarterLst[3]+'-'+quarterLst[0]+quarterLst[1];
                        quoteline.Pricing_Approved_Rejected_Month_Txt__c = month[0].FiscalYearSettings.Name+'-'+month[0].Number;
                        quoteLine.Pricing_Previous_Status_Nm__c = 'Rejected';
                        //If RPL status is EC 
                        quoteLine.Pricing_pm_approval_comments_nm__c = autoRejectedECCommentsQLSet.contains(quoteLine.Id) ? Label.Pricing_UCD_Auto_Rejection_Comments_For_EC:Label.Pricing_UCD_Auto_Rejection_Comments;
                    } 
                    System.debug('autoRejectSanctionedQLSet-->'+autoRejectSanctionedQLSet);
                    
                    if(quoteLine.Pricing_Previous_Status_Nm__c == 'Pending' && 
                       (oldMap.get(quoteLine.id).Pricing_Quote_Line_Status_Number__c == 10 ||
                        oldMap.get(quoteLine.id).Pricing_Quote_Line_Status_Number__c == 40 || 
                        oldMap.get(quoteLine.id).Pricing_Quote_Line_Status_Number__c == 30 || 
                        oldMap.get(quoteLine.id).Pricing_Quote_Line_Status_Number__c == 45) && quoteLine.Pricing_Quote_Line_Status_Number__c ==20) {
                            quoteLine.Pricing_Previous_Status_Nm__c = 'Rejected';
                            System.debug('quoteline Id previous status->'+quoteLine.Id);
                        }
                    
                    
                }
            }    
        }
    }
    private static Boolean userHasValidPermissionSet(Set < string > permissionSets) {
        return Pricing_PermissionSetAssignment_Selector.newInstance().selectByName(UserInfo.getUserId(),permissionSets);
    }
    public static Map < Id, List < SBQQ__QuoteLine__c >> generateQuoteLineMap(List < SBQQ__QuoteLine__c > lstquoteLines) {
        Set < Id > quoteIds = new Set < Id > ();
        for(SBQQ__QuoteLine__c ql: lstquoteLines) {
            quoteIds.add(ql.SBQQ__Quote__c);
        }
        Map < Id, List < SBQQ__QuoteLine__c >> quoteLineDtls = new Map < Id, List < SBQQ__QuoteLine__c >> ();
        List < SBQQ__QuoteLine__c > mapQuoteLine = new List < SBQQ__QuoteLine__c > (Pricing_QuoteLines_Selector.newInstance().selectByQuoteIdAndRefQlisNull(quoteIds));
        existingQuote = new Map < id, SBQQ__Quote__c > (Pricing_Quote_Selector.newInstance().selectByIds(quoteIds));
        For(SBQQ__QuoteLine__c ql: mapQuoteLine) {
            if(quoteLineDtls.containsKey(ql.SBQQ__Quote__c)) {
                List < SBQQ__QuoteLine__c > quoteLine = quoteLineDtls.get(ql.SBQQ__Quote__c);
                quoteLine.add(ql);
                quoteLineDtls.put(ql.SBQQ__Quote__c, quoteLine);
            } else {
                quoteLineDtls.put(ql.SBQQ__Quote__c, new List < SBQQ__QuoteLine__c > {ql});
            }
        }
        return quoteLineDtls;
    }
    
    public static void updateQuoteLineNumber(List < SBQQ__QuoteLine__c > lstquoteLines) {
        if(lstquoteLines!=null && !lstquoteLines.isEmpty()){
            Map < Id, List < SBQQ__QuoteLine__c >> mapOfQuoteAndQuoteLine = generateQuoteLineMap(lstquoteLines); 
            Map<Id,List<Integer>> mapOfQuoteIdQLINumber = new Map<Id,List<Integer>>();
            Map<Id,Integer> mapOfQIdNumber = new Map<Id,Integer>();
            Integer i = 1;
            for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {
                List < integer > lineNbr = new List < integer > ();
                List < SBQQ__QuoteLine__c > existingQuoteLine = new List < SBQQ__QuoteLine__c > ();
                if(mapOfQuoteAndQuoteLine != null && mapOfQuoteAndQuoteLine.containsKey(quoteLine.SBQQ__Quote__c) && !mapOfQuoteIdQLINumber.containsKey(quoteLine.SBQQ__Quote__c)) {
                    existingQuoteLine = mapOfQuoteAndQuoteLine.get(quoteLine.SBQQ__Quote__c);
                    if(existingQuoteLine.size() > 0) {
                        for(SBQQ__QuoteLine__c ql: existingQuoteLine) {
                            if(ql.Pricing_Quote_Line_Number__c != null && ql.Pricing_Quote_Line_Number__c != '') {                               
                                if(mapOfQuoteIdQLINumber.containsKey(ql.SBQQ__Quote__c)){
                                    mapOfQuoteIdQLINumber.get(ql.SBQQ__Quote__c).add(Integer.valueOf(ql.Pricing_Quote_Line_Number__c.substringAfter('-').substringAfter('-')));
                                }else{
                                    mapOfQuoteIdQLINumber.put(ql.SBQQ__Quote__c, new List<Integer> {Integer.valueOf(ql.Pricing_Quote_Line_Number__c.substringAfter('-').substringAfter('-'))});
                                }
                            }
                        }                       
                    }
                }
                
                
            }
            
            
            for(Id quoteId: mapOfQuoteIdQLINumber.keySet()){
                mapOfQuoteIdQLINumber.get(quoteId).sort();
            }
            
            for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {               
                List < SBQQ__QuoteLine__c > existingQuoteLine = new List < SBQQ__QuoteLine__c > ();
                if(mapOfQuoteIdQLINumber.containsKey(quoteLine.SBQQ__Quote__c)) {
                    List<integer> lineNbr = mapOfQuoteIdQLINumber.get(quoteLine.SBQQ__Quote__c);                                        
                    if(quoteLine.Pricing_Quote_Line_Number__c == null || quoteLine.Pricing_Quote_Line_Number__c == '') {
                        quoteLine.Pricing_Quote_Line_Number__c = existingQuote.get(quoteLine.SBQQ__Quote__c).Name + '-' + String.valueOf(lineNbr.get(lineNbr.Size() - 1) + 1).leftPad(3, '0');
                        mapOfQuoteIdQLINumber.get(quoteLine.SBQQ__Quote__c).add(lineNbr.get(lineNbr.Size() - 1) + 1);  //added for multiple quote line
                    }                    
                }else if(quoteLine.Pricing_Quote_Line_Number__c == null || quoteLine.Pricing_Quote_Line_Number__c == '') {
                    Integer qliNumber = 1;
                    if(mapOfQIdNumber.containsKey(quoteLine.SBQQ__Quote__c)){
                        qliNumber = mapOfQIdNumber.get(quoteLine.SBQQ__Quote__c);
                    }                    
                    quoteLine.Pricing_Quote_Line_Number__c = existingQuote.get(quoteLine.SBQQ__Quote__c).Name + '-' + String.valueOf(qliNumber).leftPad(3, '0');
                    mapOfQIdNumber.put(quoteLine.SBQQ__Quote__c, qliNumber+1);
                    //i = i+1;
                }
                
            }
        }
    }
    
    public static void updateQuoteStatus(List < SBQQ__QuoteLine__c > lstquoteLines, Map < id, SBQQ__QuoteLine__c > oldMap){
        if(lstquoteLines!=null && !lstquoteLines.isEmpty()){
            try {
                Boolean isChange = false;
                Boolean quoteStatusChangeRequired = true;
                Set < Id > QuoteIds = new Set < Id > ();
                Set<Id> quoteLineIdSet = new Set<Id>();
                Set<Id> changeRequestUpdationIdSet = new Set<Id>();
                Set<Id> quoteLineIdSetToApprove = new Set<Id>();
                Set<Id> quoteLineIdSetToReject = new Set<Id>();
                for(SBQQ__QuoteLine__c ql: lstquoteLines){
                    if(ql.Pricing_Status_Nm__c != oldMap.get(ql.id).Pricing_Status_Nm__c && (ql.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved || ql.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won || ql.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected)  && ql.Pricing_Reference_Quote_Line_Nbr__c != null){
                        changeRequestUpdationIdSet.add(ql.Pricing_Reference_Quote_Line_Nbr__c);
                    }
                    if(ql.Pricing_Status_Nm__c != oldMap.get(ql.id).Pricing_Status_Nm__c && oldMap.get(ql.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview){
                        if(ql.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview ) {
                            quoteLineIdSetToApprove.add(ql.Id);
                        }else if(ql.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected){
                            quoteLineIdSetToReject.add(ql.Id);
                        }
                    }
                    
                }
                Map < Id, List<SBQQ__QuoteLine__c> > quoteDtls = new Map < Id, List<SBQQ__QuoteLine__c> >();
                Map<Id,SBQQ__QuoteLine__c> referenceQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                if(!changeRequestUpdationIdSet.isEmpty()){
                    for(SBQQ__QuoteLine__c quoteLine : Pricing_QuoteLines_Selector.newInstance().selectByQuoteLineIds(changeRequestUpdationIdSet)){
                        referenceQuoteLineMap.put(quoteLine.Id,quoteLine);
                    }   
                }
                
                if(!quoteLineIdSetToApprove.isEmpty()){
                    Pricing_Publish_Quote.setFSEActionOnQuoteLine(quoteLineIdSetToApprove,Label.Pricing_Tender_QuoteLine_Action_Approve,null,true);
                }
                if(!System.isBatch()){
                    if(!quoteLineIdSetToReject.isEmpty()){
                        Pricing_Publish_Quote.setFSEActionOnQuoteLine(quoteLineIdSetToReject,Label.Pricing_Tender_QuoteLine_Action_Reject,null,true);
                    }
                }
                
                Set < String > quoteLineReadOnlyDealRFQStatusSet = new Set < String > ((Label.Pricing_Tender_QuoteLine_ReadOnly_DealRFQStatus).split(':'));
                Set < String > quoteLineEditDealRFQStatusSet = new Set < String > ((Label.Pricing_Tender_QuoteLine_Edit_DealRFQStatus).split(':'));         
                
                Set < String > quoteLineReadOnlyIntegrationStatusSet = new Set < String > ((Label.Pricing_Tender_QuoteLine_ReadOnly_IntegrationStatus).split(':'));
                Set < String > quoteLineEditIntegrationStatusSet = new Set < String > ((Label.Pricing_Tender_QuoteLine_Edit_IntegrationStatus).split(':'));
                Map<Id,SBQQ__Quote__c> readOnlyQuoteMap = new Map<Id,SBQQ__Quote__c>();
                Map<Id,SBQQ__Quote__c> editQuoteMap = new Map<Id,SBQQ__Quote__c>();
                Map<Id,SBQQ__Quote__c> changeQuoteMap = new Map<Id,SBQQ__Quote__c>();
                Set<String> quoteReadOnlyStatusSet = new Set<String>((Label.Pricing_Tender_Quote_ReadOnly_Status).split(':'));
                Map<Id,SBQQ__QuoteLine__c> referenceQuoteLineUpdateMap = new Map<Id,SBQQ__QuoteLine__c>();
                Date currentDate = System.today();
                //Map<Id,Id> quoteLineIdToUserIdNotifyRPMMap = new Map<Id,Id>();
                Map<String, Set<Id>> quoteLineActionMap = new Map<String, Set<Id>>();
                Set<Id> approvedQLIIds = new Set<Id>();
                Set<Id> rejectedQLIIds = new Set<Id>();
                //set<Id> writeInQuoteLineIds = new Set<Id>();
                //Pricing_IQR_Event_Action_Won_Lost_Notification
                for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {                
                    if (!mapFunctionalityNameTriggerExecution.isEmpty() &&
                        mapFunctionalityNameTriggerExecution.containsKey('pricingSendOutboundMessagesIQR') &&
                        mapFunctionalityNameTriggerExecution.get('pricingSendOutboundMessagesIQR').Core_Active__c){
                            if((oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && 
                               //updated By Naresh
                               //(quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product) &&
                               ((oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved &&  (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost)) ||
                                (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved) ||
                                (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Cancelled) ||
                                (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && 
                                 oldMap.get(quoteLine.id).Pricing_Integration_Status_Nm__c == Label.Pricing_Tender_MyDeal_Integration_Status_Complete
                                 && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected)
                               )){
                                   //updated By Naresh
                                   String action = '';
                                   if(quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product){
                                       quoteLineIdSet.add(quoteLine.Id);
                                       action = Label.Pricing_IQR_Event_Action_Won_Lost_Integration;
                                   }else{
                                       action = Label.Pricing_IQR_Event_Action_Won_Lost_Notification;
                                   } 
                                   if(!String.isEmpty(action)){
                                       if(quoteLineActionMap.containsKey(action)){
                                           quoteLineActionMap.get(action).add(quoteLine.Id);
                                       }else{
                                           quoteLineActionMap.put(action, new Set<id>{quoteLine.Id});
                                       }
                                   }
                               }
                        }
                    //RPM Email Notification Triggering scenario
                    if((oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && 
                       (quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product) && 
                       ((oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) &&
                        ((quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved) || 
                         (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won)))){
                             approvedQLIIds.add(quoteLine.id);
                         }       
                    
                    if(quoteLine.Pricing_Status_Nm__c != oldMap.get(quoteLine.id).Pricing_Status_Nm__c && (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved 
                                                                                                           || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won) && quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null
                       && referenceQuoteLineMap.containsKey(quoteLine.Pricing_Reference_Quote_Line_Nbr__c)){
                           SBQQ__QuoteLine__c referenceQuoteLine = referenceQuoteLineMap.get(quoteLine.Pricing_Reference_Quote_Line_Nbr__c);
                           if(referenceQuoteLineUpdateMap.containsKey(referenceQuoteLine.Id)){
                               referenceQuoteLineUpdateMap.get(referenceQuoteLine.Id).Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Revised;
                           }else{
                               referenceQuoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Revised;
                               referenceQuoteLineUpdateMap.put(referenceQuoteLine.Id,referenceQuoteLine);
                           }
                           
                       }
                    //Rejection Email Notification Triggering scenario
                    if((oldMap.get(quoteLine.id).Pricing_Previous_Status_Nm__c == 'Pending' && quoteLine.Pricing_Previous_Status_Nm__c == 'Rejected') && 
                       quoteLine.Pricing_Status_Nm__c != oldMap.get(quoteLine.id).Pricing_Status_Nm__c && 
                       (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft || 
                        oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview || oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected) {
                           rejectedQLIIds.add(quoteLine.Id);
                       }
                }
                if(!referenceQuoteLineUpdateMap.isEmpty()){
                    SBQQ.TriggerControl.disable();
                    Pricing_QuoteLines_DML.updateQLI(referenceQuoteLineUpdateMap.values());
                    SBQQ.TriggerControl.enable();
                }
                //updated By Naresh
                //system.debug('quoteLineIdSet==>'+quoteLineIdSet);
                /*if(!quoteLineIdSet.isEmpty()){
publishIQR(quoteLineIdSet);
}*/
                //updated By Naresh
                if(quoteLineActionMap.size() > 0){
                    publishIQR(quoteLineActionMap);
                }
                /*
if(!quoteLineIdToUserIdNotifyRPMMap.isEmpty()){
sendEmailNotification(quoteLineIdToUserIdNotifyRPMMap,Label.Pricing_RPM_Notification_Email_Template_Name);
}*/
                if(approvedQLIIds.size() > 0){
                    Pricing_EmailUtility.sendEmail(approvedQLIIds, Label.Pricing_RPM_Notification_Email_Template_Name);
                }
                if(rejectedQLIIds.size() > 0){
                    Pricing_EmailUtility.sendEmail(rejectedQLIIds, Label.Pricing_QuoteLineRejectedNotification_Template);
                }
            } catch(exception ex) {Pricing_Tender_Utility.logError(ex);}
            finally{
                SBQQ.TriggerControl.enable();
            }
        }
    }
    //updated By Naresh
    public static void publishIQR(Map<String, Set<Id>> quoteLineIdActionMap){
        try{
            //List to hold event objects to be published.
            List<Pricing_IQR_Event__e> newsEventList = new List<Pricing_IQR_Event__e>();
            for(String actionKey : quoteLineIdActionMap.keySet()){
                List<Id> quoteLineIds = new List<Id>();
                for(Id qliId : quoteLineIdActionMap.get(actionKey)){
                    quoteLineIds.add(qliId);
                }
                String quoteLineIdStr =  String.join(quoteLineIds,',');               
                if(!String.isEmpty(quoteLineIdStr)){
                    newsEventList.add(new Pricing_IQR_Event__e(
                        Pricing_QuoteLineId_Txt__c = quoteLineIdStr,
                        Pricing_IQR_Action_Nm__c = actionKey));
                    //Label.Pricing_IQR_Event_Action_Won_Lost_Integration)); 
                }
            }
            if(newsEventList.size() > 0){               
                // Call method to publish events.
                List<Database.SaveResult> results = EventBus.publish(newsEventList);
                // Inspect publishing result for each event
                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully published event.');
                    } else {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('Error returned: ' +
                                         err.getStatusCode() +
                                         ' - ' +
                                         err.getMessage());
                        }
                    }
                }
            }                            
        }catch(exception ex) {Pricing_Tender_Utility.logError(ex);}
    }
    
    public static void validateQLEditWithPFIRNotRPM(List < SBQQ__QuoteLine__c > lstquoteLines, Map < id, SBQQ__QuoteLine__c > oldMap) {
        if(lstquoteLines!=null && !lstquoteLines.isEmpty()){
            Set < String > fieldsEditableWithPFIR = new Set < String > ((Label.Pricing_Tender_Field_Edit_With_PFIR).split(':'));
            Set < String > fieldsNonEditable = new Set < String > ();
            Boolean isRPM = false;
            for(PermissionSetAssignment permissionSetAssignmentRec: Pricing_PermissionSetAssignment_Selector.newInstance().selectbyUserId(Userinfo.getUserId())) {
                if(permissionSetAssignmentRec.PermissionSet.Name == Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager) {
                    isRPM = true;
                }
            }
            List < Metadata.Metadata > layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List < String > {
                'SBQQ__QuoteLine__c-Pricing Tender Quote Line Layout - Int - Edit'
                    });
            if(!isRPM) {
                Metadata.Layout layoutMd = (Metadata.Layout) layouts.get(0);
                for(Metadata.LayoutSection section: layoutMd.layoutSections) {
                    for(Metadata.LayoutColumn column: section.layoutColumns) {
                        if(column.layoutItems != null) {
                            for(Metadata.LayoutItem item: column.layoutItems) {
                                if(item.field != null) {
                                    fieldsNonEditable.add(item.field);
                                }
                            }
                        }
                    }
                }
                fieldsNonEditable.removeAll(fieldsEditableWithPFIR);
            }
            for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {
                if(!isRPM && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview &&
                   oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) {
                       for(String field: fieldsNonEditable) {
                           if(quoteLine.get(field) != oldMap.get(quoteLine.Id).get(field)) {
                               quoteLine.addError(Label.Pricing_Tender_No_Access_Error_Message);
                               break;
                           }
                       }
                   }
            }
        }
    }
    public static Group adminQueue = null;
    public static List<Pricing_Quote_Line_Status_Age__c> PopulateQLStatusAgeRecord(List <SBQQ__QuoteLine__c> lstquoteLines, Map <Id, SBQQ__QuoteLine__c> oldObjectMap,Boolean isInsert,Boolean isIntegration,String userRole,String actorName,DateTime integrationTime,String subStatus){
        List<Pricing_Quote_Line_Status_Age__c> statusChanges = new List<Pricing_Quote_Line_Status_Age__c>();
        if(adminQueue == null){
            adminQueue = [Select Id from Group where DeveloperName =:Label.Pricing_Tender_TPT_Admin_Queue];
        }
        if(isInsert){ 
            for (SBQQ__QuoteLine__c quoteLine: lstquoteLines) {
                Pricing_Quote_Line_Status_Age__c statusChange = new Pricing_Quote_Line_Status_Age__c();
                //TPT record owner assigned to queue
                statusChange.OwnerId = adminQueue.Id;                 
                statusChange.Pricing_TPT_Quote_Line_Number__c = quoteLine.Id;
                statusChange.Pricing_TPT_Status_From__c = quoteLine.Pricing_Status_Nm__c;
                statusChange.Pricing_TPT_Set_Time__c = Datetime.now();
                statusChange.Pricing_TPT_From_Actor_Nm__c = UserInfo.getName();
                statusChange.Pricing_TPT_Change_Request_QuoteLine_cb__c = quoteLine.Pricing_Change_Request_cb__c;
                statusChange.Pricing_TPT_Role_Aggregate_cb__c = true;   //AggregateLogic 
                statusChange.Pricing_TPT_Share_Required__c = true;
                statusChanges.add(statusChange);
            }
        }else{
            for (SBQQ__QuoteLine__c quoteLine: lstquoteLines) {
                if (isIntegration  || (oldObjectMap.containsKey(quoteLine.Id) && quoteLine.Pricing_Status_Nm__c != (oldObjectMap.get(quoteLine.Id)).Pricing_Status_Nm__c&& (quoteLine.Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_Approved || (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved && ((oldObjectMap.get(quoteLine.Id)).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost || quoteLine.SBQQ__ProductName__c == Label.Pricing_Tender_Write_In_Product))))){ 
                                                      
                                                      Pricing_Quote_Line_Status_Age__c statusChange = new Pricing_Quote_Line_Status_Age__c();
                                                      statusChange.OwnerId = adminQueue.Id;
                                                      statusChange.Pricing_TPT_Quote_Line_Number__c = quoteLine.Id;
                                                      
                                                      if(isIntegration && !String.isBlank(subStatus)){
                                                          statusChange.Pricing_TPT_Status_From__c = (subStatus == Label.Pricing_Tender_QuoteLine_Status_Approved) ? 
                                                              subStatus : (quoteLine.Pricing_Status_Nm__c +'-'+subStatus);
                                                                  }else{
                                                                      statusChange.Pricing_TPT_Status_From__c = quoteLine.Pricing_Status_Nm__c;
                                                                  }
                                                      statusChange.Pricing_TPT_From_Actor_Nm__c =  isIntegration ? actorName : UserInfo.getName();
                                                      statusChange.Pricing_TPT_Set_Time__c = isIntegration ? integrationTime : Datetime.now();
                                                      if(!isIntegration){
                                                          SBQQ__QuoteLine__c oldObjectRec = oldObjectMap.get(quoteLine.Id);
                                                          if(((oldObjectRec.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview || oldObjectRec.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview)
                                                              && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft) || (oldObjectRec.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview)){
                                                                     statusChange.Revision_QuoteLine__c = true;  
                                                                 }
                                                      }
                                                      statusChange.Pricing_TPT_Share_Required__c = true;
                                                      statusChanges.add(statusChange);
                                                  }
            }
        }
        return statusChanges;
    }
    private static String getAge(Decimal milliseconds) {
        Double duration = milliseconds;
        Double d = Math.floor(duration/86400000); //Get whole days
        duration -= d*86400000;
        Double h = Math.floor(duration/3600000); //Get whole hours
        duration -= h*3600000;
        Double m = Math.floor(duration/60000);
        duration -= m*60000;
        Double s = Math.floor(duration/1000);
        return d.format()+' days '+h.format()+' hours '+ m.format() + ' minutes ' + s.format() +' seconds';
    }
    private static String getUserRole(){
        Set < String > ps = new Set < String >{Label.Pricing_Tender_PermissionSets_TenderUser,
            Label.Pricing_Tender_PermissionSets_TenderPartner,
            Label.Pricing_Tender_PermissionSets_TenderDrafter,
            Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager,
            Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator,
            Label.Pricing_Tender_PermissionSets_TenderAccountExecutive,
            Label.Pricing_Tender_Permission_Set_IT_Specialist,
            Label.Pricing_Tender_PermissionSets_PartnerLimitedAccess,
            Label.Pricing_Tender_PermissionSets_TenderDrafterLimited};
                
                if(!String.isEmpty(Label.Pricing_IQR_API_UserPermissionSets) ){
                    ps.addAll(Label.Pricing_IQR_API_UserPermissionSets.split(','));
                }                                     
        
        List<PermissionSetAssignment> permissionRecList = new List<PermissionSetAssignment>(Pricing_PermissionSetAssignment_Selector.newInstance().selectByPSName(Userinfo.getUserId(),ps));
        if(!permissionRecList.isEmpty()){
            String psUser = permissionRecList[0].PermissionSet.Name;
            switch on psUser {
                when 'Tender_Partner' , 'Pricing_Tender_Partner_Administrator' , 'Tender_Partner_Drafter_Access' , 'Tender_Partner_Limited_Access' , 'Tender_Partner_Drafter_Limited_Access', 'Pricing_IQR_HPE_B2B', 'Pricing_IQR_Cisco_B2B'{
                    return 'OEM';
                }
                when 'Tender_User' {
                    return 'SDM';
                }
                when 'Pricing_Tender_Regional_Pricing_Manager' {
                    return 'RPM';
                }
                when 'Tender_Account_Executive' {
                    return 'Account Executive';
                }
                when 'Pricing_Tender_IT_Specialist' {
                    return 'IT Specialist';
                }
                when else {
                    return null;
                }
            }
        }
        else{
            return null;
        }
    }
    public static void CreateQuoteLineStatusAgeRecord(SBQQ__QuoteLine__c[] newObjects,Boolean isInsert){
        if(newObjects!=null && !newObjects.isEmpty()){
            try{
                List<Pricing_Quote_Line_Status_Age__c> tptList = new List<Pricing_Quote_Line_Status_Age__c>();
                tptList.addAll(PopulateQLStatusAgeRecord(newObjects, null, isInsert,false,null,null,null,null));
                Pricing_Quote_Line_Status_Age_DML.insertTPT(tptList);
            }catch(exception ex) {Pricing_Tender_Utility.logError(ex);}
        }
    }
    public static void UpdateQuoteLineStatusAgeRecord(SBQQ__QuoteLine__c[] updatedObjects, Map<Id, SBQQ__QuoteLine__c> oldObjectMap,Boolean isInsert,Boolean isIntegration,String userRole,String actorName,DateTime integrationTime,String subStatus){
        if(updatedObjects!=null && !updatedObjects.isEmpty()){
            try{
                List<Pricing_Quote_Line_Status_Age__c> tptList = new List<Pricing_Quote_Line_Status_Age__c>();
                Set<String> oldStatusSet = new Set<String>();
                Set<Id> quoteLineIdSet = new Set<Id>();
                Map<Id,SBQQ__QuoteLine__c> quoteLinesMap = new Map<Id,SBQQ__QuoteLine__c>();
                Map<Id,Pricing_Quote_Line_Status_Age__c> quoteLineIdToTPTMap = new Map<Id,Pricing_Quote_Line_Status_Age__c>();
                tptList.addAll(PopulateQLStatusAgeRecord(updatedObjects, oldObjectMap, isInsert,isIntegration,userRole,
                                                         actorName,integrationTime,subStatus));
                
                for (Pricing_Quote_Line_Status_Age__c statusChange: tptList) {
                    quoteLineIdSet.add(statusChange.Pricing_TPT_Quote_Line_Number__c);  
                }    
                if(quoteLineIdSet.size() > 0){
                    quoteLinesMap = new Map<Id,SBQQ__QuoteLine__c>(Pricing_QuoteLines_Selector.newInstance().selectByQuoteLineIds(quoteLineIdSet));
                }                                     
                //construct old status List and Ids to retrieve old case status changes to update the business hours
                for (Pricing_Quote_Line_Status_Age__c statusChange: tptList) {
                    if(quoteLinesMap.containsKey(statusChange.Pricing_TPT_Quote_Line_Number__c)){
                        SBQQ__QuoteLine__c qli = quoteLinesMap.get(statusChange.Pricing_TPT_Quote_Line_Number__c);
                        if(isIntegration && substatus==Label.Pricing_Tender_QuoteLine_Status_Approved){
                            DateTime apprdDt = (qli.Pricing_Last_Approved_Date_dt__c==null? Datetime.now() : qli.Pricing_Last_Approved_Date_dt__c);
                            if(qli.Pricing_Original_Submitted_Date_dt__c!=null){                                
                                Decimal firstResponseInMillSecs = calculateStatusAge(qli.Pricing_Original_Submitted_Date_dt__c, apprdDt);
                                statusChange.Pricing_First_SubmissionToResponse_Time__c = (firstResponseInMillSecs/(60*60*1000));
                            }   
                            if(qli.Pricing_Last_Submitted_Date_dt__c!=null){
                                Decimal lastResponseInMillSecs = calculateStatusAge(qli.Pricing_Last_Submitted_Date_dt__c, apprdDt);
                                statusChange.Pricing_Last_Submission_to_Response_Time__c = (lastResponseInMillSecs/(60*60*1000));
                            }                        
                        }else{
                            if(qli.Pricing_Last_Approved_Date_dt__c!=null && qli.Pricing_Original_Submitted_Date_dt__c!=null){
                                Decimal firstResponseInMillSecs = calculateStatusAge(qli.Pricing_Original_Submitted_Date_dt__c, qli.Pricing_Last_Approved_Date_dt__c);
                                statusChange.Pricing_First_SubmissionToResponse_Time__c = (firstResponseInMillSecs/(60*60*1000));
                            }   
                            if(qli.Pricing_Last_Approved_Date_dt__c!=null && qli.Pricing_Last_Submitted_Date_dt__c!=null){
                                Decimal lastResponseInMillSecs = calculateStatusAge(qli.Pricing_Last_Submitted_Date_dt__c, qli.Pricing_Last_Approved_Date_dt__c);
                                statusChange.Pricing_Last_Submission_to_Response_Time__c = (lastResponseInMillSecs/(60*60*1000));
                            }                     
                        }
                    }
                    oldStatusSet.add(statusChange.Pricing_TPT_Status_From__c);                   
                    quoteLineIdToTPTMap.put(statusChange.Pricing_TPT_Quote_Line_Number__c,statusChange);
                }
                
                //Query for Previous TPT
                if (!quoteLineIdSet.isEmpty() && !oldStatusSet.isEmpty()) {       
                    system.debug('currentUserName===>'+UserInfo.getName());      
                    String currentUserRole = isIntegration ? userRole : (UserInfo.getName()==Label.Pricing_Integration_User? 'DPM' : getUserRole());
                        system.debug('currentUserRole==>'+currentUserRole);
                    List<Pricing_Quote_Line_Status_Age__c> oldTPTList = new List<Pricing_Quote_Line_Status_Age__c>();
                    Map<String,Pricing_Quote_Line_Status_Age__c> aggreagateTPTMap = new Map<String,Pricing_Quote_Line_Status_Age__c>();
                    for(Pricing_Quote_Line_Status_Age__c oldStatusChange : Pricing_Quote_Line_Status_Age_Selector.newInstance().selectbyQliIdandRole(quoteLineIdSet,currentUserRole)) {
                        if(oldStatusChange.Pricing_TPT_Change_Time__c == null){
                            oldTPTList.add(oldStatusChange);
                        }
                        if(oldStatusChange.Pricing_TPT_Role_Aggregate_cb__c && oldStatusChange.Pricing_TPT_User_Role__c == currentUserRole){
                            aggreagateTPTMap.put(oldStatusChange.Pricing_TPT_Quote_Line_Number__c,oldStatusChange);
                        }
                    }
                    
                    Set<Id> tptIdSet = new Set<Id>();
                    for (Pricing_Quote_Line_Status_Age__c oldStatusChange : oldTPTList) {
                        if(!tptIdSet.contains(oldStatusChange.Id) && (!quoteLineIdToTPTMap.containsKey(oldStatusChange.Id) || (oldStatusChange.Pricing_TPT_Status_From__c != oldStatusChange.Pricing_TPT_Status_Name__c)) ){
                            tptIdset.add(oldStatusChange.Id);
                            oldStatusChange.Pricing_TPT_Change_Time__c = isIntegration ? integrationTime : Datetime.now();
                            //Convert the difference to milliseconds
                            //Double milliseconds = (oldStatusChange.Pricing_TPT_Change_Time__c.getTime() - oldStatusChange.Pricing_TPT_Set_Time__c.getTime());
                            Decimal milliseconds = calculateStatusAge(oldStatusChange.Pricing_TPT_Set_Time__c, oldStatusChange.Pricing_TPT_Change_Time__c);
                            //oldStatusChange.Pricing_TPT_Status_Time__c = (Decimal.valueOf(milliseconds)).Divide((60*60*1000), 2);
                            oldStatusChange.Pricing_TPT_Status_Time__c = (milliseconds).Divide((60*60*1000), 2);
                            if(aggreagateTPTMap.containsKey(oldStatusChange.Pricing_TPT_Quote_Line_Number__c)){
                                oldStatusChange.Pricing_TPT_Aggregate_Role_Time__c = aggreagateTPTMap.get(oldStatusChange.Pricing_TPT_Quote_Line_Number__c).Pricing_TPT_Aggregate_Role_Time__c + oldStatusChange.Pricing_TPT_Status_Time__c;
                                
                                oldStatusChange.Pricing_TPT_Role_Aggregate_cb__c = true; 
                                aggreagateTPTMap.get(oldStatusChange.Pricing_TPT_Quote_Line_Number__c).Pricing_TPT_Role_Aggregate_cb__c = false;
                                tptList.add(aggreagateTPTMap.get(oldStatusChange.Pricing_TPT_Quote_Line_Number__c));
                            }else{
                                oldStatusChange.Pricing_TPT_Aggregate_Role_Time__c = oldStatusChange.Pricing_TPT_Status_Time__c;
                                oldStatusChange.Pricing_TPT_Role_Aggregate_cb__c = true;
                            }
                            oldStatusChange.Pricing_TPT_Age__c = getAge(milliseconds);
                            oldStatusChange.Pricing_TPT_Current_QL_Approver__c = isIntegration ? actorName : UserInfo.getName();
                            oldStatusChange.Pricing_TPT_User_Role__c  = isIntegration ? userRole : currentUserRole;
                            oldStatusChange.Pricing_TPT_To_Stage_Actor_Nm__c = isIntegration ? actorName : UserInfo.getName();
                            
                            if(quoteLineIdToTPTMap.containsKey(oldStatusChange.Pricing_TPT_Quote_Line_Number__c)){
                                oldStatusChange.Pricing_TPT_Status_Name__c = quoteLineIdToTPTMap.get(oldStatusChange.Pricing_TPT_Quote_Line_Number__c).Pricing_TPT_Status_From__c;
                                quoteLineIdToTPTMap.get(oldStatusChange.Pricing_TPT_Quote_Line_Number__c).Pricing_TPT_Change_Request_QuoteLine_cb__c = oldStatusChange.Pricing_TPT_Change_Request_QuoteLine_cb__c;
                                if(oldStatusChange.Revision_QuoteLine__c){
                                    quoteLineIdToTPTMap.get(oldStatusChange.Pricing_TPT_Quote_Line_Number__c).Revision_QuoteLine__c = oldStatusChange.Revision_QuoteLine__c;
                                }
                            }
                            if(!tptList.contains(oldStatusChange)){
                                tptList.add(oldStatusChange);
                            }
                        }
                    }
                }
                //Create new TPT 
                if(!tptList.isEmpty()){
                    Pricing_Quote_Line_Status_Age_DML.upsertTPT(tptList);
                }
            }catch(exception ex) {Pricing_Tender_Utility.logError(ex);}
        }
    }
    //Method to check if Non-Latin characters are present in Text fields
    public static void validateQLTextFieldsForLatinChars(SBQQ__QuoteLine__c quoteLine,Map < id, SBQQ__QuoteLine__c > oldMap, Boolean isInsert){
        try{
            Set<String> quoteLineTextFields = new Set < String > ((Label.Pricing_Tender_Quote_Line_Text_Fields).split(':'));
            if(quoteLineTextFields.size()>0){
                for(String field:quoteLineTextFields){
                    String fieldValue = '';
                    if(isInsert){
                        if(quoteLine.get(field) != null){
                            fieldValue = (String)quoteLine.get(field);
                        }
                    }else{
                        if((String)quoteLine.get(field) != (String)oldMap.get(quoteLine.Id).get(field)){
                            fieldValue = (String)quoteLine.get(field);
                        }
                    }
                    if(!String.isEmpty(fieldValue)){
                        if(Pricing_Tender_Utility.validateNonLatinChars(fieldValue)){
                            quoteLine.addError(field,Label.Pricing_Non_Latin_Char_Validation_Error);
                        }
                    }
                }
            }
        }catch(exception ex){Pricing_Tender_Utility.logError(ex);}  
    } 
    
    
    public static Decimal calculateStatusAge(DateTime startDateTime, DateTime endDateTime)  
    {    
        Decimal timeDiff = 0;  
        try{            
            system.debug('Start Date===>'+startDateTime);
            system.debug('End Date===>'+endDateTime);
            Decimal oneDayinMilliSecs = (24*60*60*1000);
            timeDiff = endDateTime.getTime() - startDateTime.getTime();
            
            String startDay  = startDateTime.format('EEEE');
            String endDay  = endDateTime.format('EEEE');        
            
            Date startDate = date.newinstance(startDateTime.year(), startDateTime.month(), startDateTime.day());
            Date endDate = date.newinstance(endDateTime.year(), endDateTime.month(), endDateTime.day());
            
            system.debug('startDay '+ startDay);
            system.debug('endDay '+ endDay);
            
            startDate = startDate.toStartOfWeek();
            endDate = endDate.toStartOfWeek();
            
            DateTime newWeekStart = date.newinstance(startDate.year(), startDate.month(), startDate.day());
            
            integer dayss = date.newinstance(startDateTime.year(), startDateTime.month(), startDateTime.day()).
                daysBetween(date.newinstance(endDateTime.year(), endDateTime.month(), endDateTime.day()));
            
            system.debug('weekendsbetweenOld '+ dayss/7);
            
            integer weeksbetween = startDate.daysBetween(endDate)/7;
            
            system.debug('weeksbetween '+ weeksbetween);
            
            if(weeksbetween > 0){
                system.debug('BeforetimeDiff ==>'+(timeDiff).Divide((24*60*60*1000), 2));
                timeDiff = (timeDiff - (weeksbetween * 2 * oneDayinMilliSecs));
                System.debug('Deduct '+(weeksbetween * 2 * oneDayinMilliSecs).Divide((24*60*60*1000), 2));
                system.debug('AftertimeDiff ==>'+(timeDiff).Divide((24*60*60*1000), 2));
                
                if(startDay == 'Saturday') {
                    timeDiff = timeDiff + oneDayinMilliSecs;
                    system.debug('Start Date is Saturday adding 1 day');
                }
                
                if(endDay == 'Sunday') {
                    timeDiff = timeDiff + oneDayinMilliSecs;
                    system.debug('End date is Sunday adding 1 day');
                }
            }
        }catch(exception ex) {Pricing_Tender_Utility.logError(ex);}
        return timeDiff;
    }  
    
    public static void generateQuoteLetter(List < SBQQ__QuoteLine__c > lstquoteLines, Map < id, SBQQ__QuoteLine__c > oldMap){
        Set<Id> quoteIds = new Set<Id>();
        
        for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {
            if(quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c  && (quoteLine.Pricing_Status_Nm__c==Label.Pricing_Tender_QuoteLine_Status_Approved || quoteLine.Pricing_Status_Nm__c==Label.Pricing_Tender_QuoteLine_Status_Rejected || (oldMap.get(quoteLine.Id).Pricing_Status_Nm__c== Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && quoteLine.Pricing_Status_Nm__c==Label.Pricing_Tender_QuoteLine_Status_Won))){
                                                                                                                                                                                   quoteIds.add(quoteLine.SBQQ__Quote__c);
                                                                                                                                                                               }
        }
        if(quoteIds.size() > 0){
            Map<Id,SBQQ__Quote__c> quotesMap = new Map<Id,SBQQ__Quote__c>(Pricing_Quote_Selector.newInstance().selectByQuoteLetter(quoteIds));
            if(quotesMap.size() > 0){
                String quoteIdsStr = '';
                for(Id quoteId : quotesMap.keySet()){
                    quoteIdsStr = String.isEmpty(quoteIdsStr) ? String.valueOf(quoteId) : quoteIdsStr+','+String.valueOf(quoteId);
                }
                Database.SaveResult result = EventBus.publish(new Pricing_Quote_Letter_Event__e(
                    Pricing_QuoteIds_Txt__c = quoteIdsStr,
                    Pricing_Action_Nm__c = Label.Pricing_Generate_QuoteLetter_Action));
                
                if (result.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : result.getErrors()) {
                        System.debug('Error returned: ' +
                                     err.getStatusCode() +
                                     ' - ' +
                                     err.getMessage());
                    }
                }
                
            }
        }
    }
    
    //Method to get list of product Ids based on program type
    public static Map<String, List<Id>> validateQuoteLineProduct (Map<String, List<Id>> prdTypeNewProductListMap) {
        Map<String, List<Id>> quoteLineTypeProductIdsMap = new Map<String, List<Id>>();//product Type ==> List of product Ids
        Map<String, String> quoteLineTypeProductQueryMap = new Map<String, String>();//product Type ==> product SOQL
        List<Product2> productList = new List<Product2>();
        
        //List<Pricing_Dynamic_Data_Table__mdt> productTypeMetadataList = Pricing_Dynamic_Data_Table__mdt.getall().values();
        List<Pricing_Dynamic_Data_Table__mdt> productTypeMetadataList = Pricing_Dynamic_Data_Table_Selector.newInstance().selectByType(prdTypeNewProductListMap.keySet());
        
        if(productTypeMetadataList.size() > 0) {
            for(Pricing_Dynamic_Data_Table__mdt mdt : productTypeMetadataList ) {
                if(String.isNotBlank(mdt.Pricing_Query__c) && String.isNotBlank(mdt.Pricing_Where_Clause__c)) {
                    String query =  mdt.Pricing_Query__c + ' ' +mdt.Pricing_Where_Clause__c;
                    System.debug('query===>'+query);
                    if(!quoteLineTypeProductQueryMap.containsKey(mdt.Pricing_Record_Type__c)) {
                        quoteLineTypeProductQueryMap.put(mdt.Pricing_Record_Type__c, query);
                    }
                }
            }
        }
        
        if(!quoteLineTypeProductQueryMap.isEmpty() && !prdTypeNewProductListMap.isEmpty()) {
            if(prdTypeNewProductListMap.containsKey(Label.Pricing_Tender_SSD_Quote) && quoteLineTypeProductQueryMap.containsKey(Label.Pricing_Tender_SSD_Quote)) {
                quoteLineTypeProductIdsMap = getQuoteLineProduct(Label.Pricing_Tender_SSD_Quote, quoteLineTypeProductQueryMap.get(Label.Pricing_Tender_SSD_Quote), prdTypeNewProductListMap.get(Label.Pricing_Tender_SSD_Quote));
            }  
            
            if(prdTypeNewProductListMap.containsKey(Label.Pricing_Tender_PMem_Quote) && quoteLineTypeProductQueryMap.containsKey(Label.Pricing_Tender_PMem_Quote)) {
                quoteLineTypeProductIdsMap = getQuoteLineProduct(Label.Pricing_Tender_PMem_Quote, quoteLineTypeProductQueryMap.get(Label.Pricing_Tender_PMem_Quote), prdTypeNewProductListMap.get(Label.Pricing_Tender_PMem_Quote));
            }
            
            if(prdTypeNewProductListMap.containsKey(Label.Pricing_Tender_NIC_Quote) && quoteLineTypeProductQueryMap.containsKey(Label.Pricing_Tender_NIC_Quote)) {
                quoteLineTypeProductIdsMap = getQuoteLineProduct(Label.Pricing_Tender_NIC_Quote, quoteLineTypeProductQueryMap.get(Label.Pricing_Tender_NIC_Quote), prdTypeNewProductListMap.get(Label.Pricing_Tender_NIC_Quote));
            }
            
            if(prdTypeNewProductListMap.containsKey(Label.Pricing_Tender_Standard_QuoteLine) && quoteLineTypeProductQueryMap.containsKey(Label.Pricing_Tender_Standard_QuoteLine)) {
                quoteLineTypeProductIdsMap = getQuoteLineProduct(Label.Pricing_Tender_Standard_QuoteLine, quoteLineTypeProductQueryMap.get(Label.Pricing_Tender_Standard_QuoteLine), prdTypeNewProductListMap.get(Label.Pricing_Tender_Standard_QuoteLine));
            }
            
            if(prdTypeNewProductListMap.containsKey(Label.Pricing_Tender_Small_Volume_Quote)  && quoteLineTypeProductQueryMap.containsKey(Label.Pricing_Tender_Small_Volume_Quote)) {
                quoteLineTypeProductIdsMap = getQuoteLineProduct(Label.Pricing_Tender_Small_Volume_Quote, quoteLineTypeProductQueryMap.get(Label.Pricing_Tender_Small_Volume_Quote), prdTypeNewProductListMap.get(Label.Pricing_Tender_Small_Volume_Quote));
            }
        }
        
        System.debug('quoteLineTypeProductIdsMap===>'+quoteLineTypeProductIdsMap);
        return quoteLineTypeProductIdsMap;
    }
    
    //Method to get list of product Ids based on program type
    public static Map<String, List<Id>> getQuoteLineProduct(String type, String productQuery, List<Id> prdList) {
        Map<String, List<Id>> qlProductListMap = new Map<String, List<Id>>();//product Type ==> List of product Ids
        List<Product2> productList = new List<Product2>();
        String query1 = productQuery + ' AND Id IN : prdList';
        System.debug('query111===>'+query1);
        System.debug('prdList===>'+prdList);
        productList = Pricing_Product_Selector.newInstance().selectByText(query1);
        
        System.debug('Product List==>'+productList);
        if(productList.size() > 0) {
            for(Product2 prd : productList) {
                if(!qlProductListMap.containsKey(type)) {
                    qlProductListMap.put(type, new List<Id>{prd.Id});
                } else {
                    qlProductListMap.get(type).add(prd.Id);
                }
            }
        }
        return qlProductListMap;
    }
    
    //method to validate the product mismatch on insert and update of Quote Line
    public static void validateProductMismatch(List<SBQQ__QuoteLine__c> lstquoteLines, boolean isInsert, Map<Id, SBQQ__QuoteLine__c> oldMap) {
        try {
            if(lstquoteLines!= null && !lstquoteLines.isEmpty()) {
                List<String> quoteLineTypeList = new List<String>();
                Map<String, List<Id>> productTypeProductIdsMap = new Map<String, List<Id>>();
                Map<String, List<Id>> productTypeNewProductIdMap = new Map<String, List<String>>();
                
                for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {
                    System.debug('Product name ==>'+quoteLine.Pricing_Product_Nm__c);
                    if((isInsert || (!isInsert && oldMap.get(quoteLine.id).Pricing_Product_Nm__c != quoteLine.Pricing_Product_Nm__c)) && quoteLine.Pricing_Product_Nm__c != null) {
                        if(!productTypeNewProductIdMap.containsKey(quoteLine.Pricing_Program_Type_Nm__c)) {
                            productTypeNewProductIdMap.put(quoteLine.Pricing_Program_Type_Nm__c, new List<String>{quoteLine.Pricing_Product_Nm__c});
                        } else {
                            productTypeNewProductIdMap.get(quoteLine.Pricing_Program_Type_Nm__c).add(quoteLine.Pricing_Product_Nm__c);
                        }
                    }              
                }
                
                if(!productTypeNewProductIdMap.isEmpty()) {
                    productTypeProductIdsMap = validateQuoteLineProduct(productTypeNewProductIdMap);
                }
                
                for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {
                    if((isInsert || (!isInsert && oldMap.get(quoteLine.id).Pricing_Product_Nm__c != quoteLine.Pricing_Product_Nm__c)) 
                       && quoteLine.Pricing_Product_Nm__c != null && (productTypeProductIdsMap.isEmpty() || !(productTypeProductIdsMap.get(quoteLine.Pricing_Program_Type_Nm__c)).contains(quoteLine.Pricing_Product_Nm__c))) {
                           string label = Label.Pricing_IQR_Product_Mismatch_Error.replace('<quote type>', quoteLine.Pricing_Program_Type_Nm__c);
                           quoteLine.addError(label);
                       }
                }
            }
        } catch (exception ex) {
            Pricing_Tender_Utility.logError(ex);
        }
    }
    
    /**
* @description method to update QuoteLine Records from Flow  
* @author Accenture | 04-25-2022 
* @param quoteLineList 
**/
    @InvocableMethod(label = 'updateQuoteLineRecords' description = 'To update QuoteLine Records')
    public static void updateQuoteLineRecords(List<List<SBQQ__QuoteLine__c>> quoteLineList){
        List<SBQQ__QuoteLine__c> qliListtoUpdate = new List<SBQQ__QuoteLine__c>();
        SBQQ__Quote__c quote = Pricing_Quote_Selector.newInstance().selectByIds(new Set<Id>{quoteLineList[0][0].SBQQ__Quote__c})[0];
        if(quoteLineList[0].size() > 0 && !quoteLineList.isEmpty()){
            for(SBQQ__QuoteLine__c qli: quoteLineList[0]){
                qli.Pricing_End_Customer_Country__c = quote.Pricing_End_Customer_Country_Nm__c;
                qli.Pricing_End_Customer_Nm__c = quote.Pricing_Customer_Nm__c;
                qli.Pricing_OEM_Account_Nm__c = quote.SBQQ__Account__r.Name;
                qli.Pricing_Primary_Contact_Nm__c = quote.SBQQ__PrimaryContact__c;
                qli.Pricing_Project_Nm__c = quote.Pricing_Project_Name_Nm__c;
                qli.Pricing_Region_Nm__c = quote.Pricing_Region_Nm__c;
                qli.Pricing_Sales_Rep__c = quote.SBQQ__SalesRep__c;
                qli.Pricing_Server_Deal_Type_Nm__c = quote.Pricing_Server_Deal_Type_Nm__c;
                qliListtoUpdate.add(qli);
            }
        }
        if(!qliListtoUpdate.isEmpty()){
            SBQQ.TriggerControl.disable();
            Pricing_QuoteLines_DML.updateQLI(qliListtoUpdate);
            SBQQ.TriggerControl.enable();
        }
    }
}