/**
 * @description : This class is called from flow - PCC_Change_Request_Approval
 * @Date : 26 August 2024
 * Developer : DINESH
 * Version  : 1.0
 **/

// Class that approves change requests
public with sharing class PCC_ChangeRequestApproval {
      public static boolean rollbackMode = Boolean.valueOf(label.PCC_Run_Change_Request_in_Rollback_Mode);
      // Invokable method that approves change requests
      @InvocableMethod(label='Approve Change Request Line Items' description='Approve the Change Request Line Item on the PCC Change Request' category='Other')
      public static List<ApprovalResult> approveChangeRequest(List<Id> changeRequestId){
            
            System.debug('SOQL Before transaction starts'+Limits.getQueries() +'/'+Limits.getLimitQueries() );
            // Get approved change requests
            List<PCC_Deal_Change_Request_Line_Item__c> approvedLines = [select id,PCC_Change_Request_Quote_Line__c,PCC_Approved_Pricing_End_Date__c,PCC_Approved_Pricing_Start_Date__c, PCC_Change_Request__r.PCC_Transaction_Information_Message__c,PCC_Deal_Product__r.Programs_Eligible__c,PCC_Deal_Product__r.Product__c,PCC_Change_Request__r.PCC_Opportunity__c,PCC_Request_Type__c,PCC_Product_JSON__c,PCC_Opportunity_Product_Id__r.SBQQ__QuoteLine__r.SBQQ__Quote__c,PCC_Opportunity_Product_Id__r.SBQQ__QuoteLine__c,PCC_Opportunity_Product_Id__c,PCC_Quantity__c,PCC_Start_Date__c,PCC_End_Date__c,PCC_Partner_Comment__c from PCC_Deal_Change_Request_Line_Item__c where (PCC_Approval_Status__c ='Approved' and PCC_Request_Type__c ='Cancel') and PCC_Change_Request__c = :changeRequestId[0]];
            
            // Initialize maps to store different types of change requests
            Map<Id, PCC_Deal_Change_Request_Line_Item__c> changedLinesMp = new Map<Id, PCC_Deal_Change_Request_Line_Item__c>();
            Map<Id, PCC_Deal_Change_Request_Line_Item__c> newLinesMp = new Map<Id, PCC_Deal_Change_Request_Line_Item__c>();
            Map<Id, PCC_Deal_Change_Request_Line_Item__c> cancelledLinesMp = new Map<Id, PCC_Deal_Change_Request_Line_Item__c>();
            Map<id, PCC_Deal_Change_Request_Line_Item__c> oliToCrli = new Map<id, PCC_Deal_Change_Request_Line_Item__c>();
            boolean pdiEligible = false;
            //to be updated
            List<PCC_Deal_Change_Request_Line_Item__c> changeRequestToBeUpdated = new List<PCC_Deal_Change_Request_Line_Item__c>();
            
            // Process approved lines and classify the requests as change, add or cancel
            for(PCC_Deal_Change_Request_Line_Item__c changeRquestLine : approvedLines){
                  if(changeRquestLine.PCC_Request_Type__c =='Cancel'){
                        cancelledLinesMp.put(changeRquestLine.PCC_Change_Request_Quote_Line__c, changeRquestLine);
                        oliToCrli.put(changeRquestLine.PCC_Opportunity_Product_Id__c, changeRquestLine); // created for easy update post record creation/updation
                  }
            }
            
            // publish the messages
            if(cancelledLinesMp.isEmpty() && cancelledLinesMp.size() == 0){
                  // publish the message for add product
                  publishPlatformEvent(null, 'REQUEST_FOR_ADD_PRODUCT', (String)changeRequestId[0], 'OpportunityLineItem');
            }else{
                  if(cancelledLinesMp != null && cancelledLinesMp.size()>0){
                        cancelOLI(JSON.serialize(cancelledLinesMp.values()), (String)changeRequestId[0]);
                  }
            }
            return new List<ApprovalResult>{};
            
      }
      
      // Method to cancel opportunity line items
      public static void cancelOLI(String request, String requestId){
            // Initialize lists and map
            Savepoint sp ;
            if(rollbackMode){
                  sp = Database.setSavepoint();
            }
            
            List<OpportunityLineItem> lstOppLI = new List<OpportunityLineItem>();
            Map<String, PCC_Deal_Change_Request_Line_Item__c> oliToCrMap = new Map<String, PCC_Deal_Change_Request_Line_Item__c>();
            List<OpportunityLineItem> oliToBeUpdated = new List<OpportunityLineItem>();
            
            
            try{
                  // Map the change request to the Opportunity Line Item
                  List<PCC_Deal_Change_Request_Line_Item__c> changeRequestedLines = (List<PCC_Deal_Change_Request_Line_Item__c>) JSON.deserialize(request, List<PCC_Deal_Change_Request_Line_Item__c>.class);
                  
                  for(PCC_Deal_Change_Request_Line_Item__c dcr : changeRequestedLines){
                        oliToCrMap.put(dcr.PCC_Opportunity_Product_Id__c, dcr);
                  }
                  
                  // Get the corresponding Opportunity Line Items that need to be updated
                  lstOppLI = [SELECT Id,Name, Core_Status__c FROM OpportunityLineItem WHERE Core_Status__c!='Production Cancelled' and Core_Status__c!='Cancelled' and id in : oliToCrMap.keySet()];
                  
                  // Update the Opportunity Line Items
                  if(lstOppLI.size()>0 ){
                        for( OpportunityLineItem oli : lstOppLI){
                              // Depending on the status, update the status value
                              if (oli.Core_Status__c == 'Production Win Approved'){
                                    oli.Core_Status__c = 'Production Cancelled';
                              }else{
                                    oli.Core_Status__c = 'Cancelled';
                              }
                              // Set the cancel reason and details
                              oli.Core_Loss_Cancel_Reason__c = 'Cancelled - Entered in Error';
                              oli.Core_Loss_Cancel_Details__c = oliToCrMap.get(oli.id).PCC_Partner_Comment__c;
                              
                              // Add to the list to be updated
                              oliToBeUpdated.add(oli);
                        }
                  }
                  
                  // Update the Opportunity Line Items
                  if(oliToBeUpdated.size()>0){
                        // update oliToBeUpdated;
                        Database.SaveResult[] srList = Database.update(oliToBeUpdated, false);
                        List<PCC_Deal_Change_Request_Line_Item__c> linesToBeUpdated = new List<PCC_Deal_Change_Request_Line_Item__c>();
                        List<PCC_Deal_Change_Request_Line_Item__c> success = new List<PCC_Deal_Change_Request_Line_Item__c>();
                        Integer i =0;
                        boolean failed = false;
                        String erroMessage ='';
                        for(Database.saveResult sr : srList){
                              if(!sr.isSuccess()){
                                    failed = true;
                                    for(Database.Error err : sr.getErrors()) {
                                          erroMessage = 'The following error has occurred.'+err.getStatusCode() + ': ' + err.getMessage()+'Account fields that affected this error: ' + err.getFields();
                                    }
                                    linesToBeUpdated.add(new PCC_Deal_Change_Request_Line_Item__c(Id = changeRequestedLines[i].Id, PCC_Request_Line_Status_Response__c =erroMessage, PCC_RequestLineStatus__c = 'Entered in Error'));
                              }
                              else{
                                    
                                    success.add(new PCC_Deal_Change_Request_Line_Item__c(Id = changeRequestedLines[i].Id, PCC_Request_Line_Status_Response__c ='Processed Successfully!', PCC_RequestLineStatus__c = 'Approved'));
                              }
                              i++;
                        }
                        if(failed)update linesToBeUpdated;
                        if(success != null && success.size()>0) update success;
                        // create platform event on success
                        publishPlatformEvent(JSON.serialize(oliToCrMap), 'REQUEST_FOR_ADD_PRODUCT', requestId, 'OpportunityLineItem');
                        
                  }else{
                        publishPlatformEvent(JSON.serialize(oliToCrMap), 'REQUEST_FOR_ADD_PRODUCT', requestId, 'OpportunityLineItem');
                        
                  }
            } catch(Exception ex) {
                  
                  //publish platform event on failure
                  publishPlatformEvent(JSON.serialize(oliToCrMap)+'\n Exception :'+ex.getMessage(), 'CR_PROD_CANCELLATION_ERROR', requestId, 'OpportunityLineItem');
            }finally{
                  if(rollbackMode){
                        Database.rollback(sp);
                  }
            }
      }
      
      // Method to add opportunity line items
      public static Boolean addOLI(String request, boolean pdiEligible, String requestId, boolean rollbackMode){
            // This method has to be filled with the right code
            Savepoint sp ;
            Boolean savedRecord = false;
            if(rollbackMode){
                  sp = Database.setSavepoint(); // for test purpose
            }
            try{
                  List<PCC_Deal_Change_Request_Line_Item__c> changeRequestedLines = (List<PCC_Deal_Change_Request_Line_Item__c>) JSON.deserialize(request, List<PCC_Deal_Change_Request_Line_Item__c>.class);
                  
                  if(changeRequestedLines.size() == 0) return true;
                  
                  
                  String recordTypePartnerId = Schema.SobjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Partner').getRecordTypeId();
                  List<Core_Design_Registration_Product__c> newProducts = new List<Core_Design_Registration_Product__c>();
                  Core_Design_Registration_Product__c product;
                  Set<Id> productIds = new Set<Id>();
                  
                  for(PCC_Deal_Change_Request_Line_Item__c lineItem : changeRequestedLines){
                        product = (Core_Design_Registration_Product__c) JSON.deserialize(lineItem.PCC_Product_JSON__c, Core_Design_Registration_Product__c.class);
                        product.Id = null;
                        product.Core_Design_Product_Status_Nm__c ='Approved';
                        product.recordTypeId = recordTypePartnerId;
                        product.PCC_Change_Request_Line_Item__c = lineItem.Id;
                        product.Core_Product_Id__c = lineItem.PCC_Deal_Product__r.Product__c;
                        product.PCC_Change_Requested__c = true;
                        newProducts.add(product);
                        productIds.add(lineItem.PCC_Deal_Product__r.Product__c);
                  }
                  
                  Map<Id, PricebookEntry> productToPriceBook = PCC_FlowApexActionCntroller.getPricebookEntries(productIds);
                  
                  if (!productToPriceBook.keySet().containsAll(productIds)) {
                        //     return new List<ActionOutput>{generateErrorOutput('Invalid products selected!')};
                  }else{
                        //insert newProducts;
                        Integer i =0;
                        Database.saveResult[] results = Database.insert(newProducts,false);
                        boolean failed = false;
                        List<PCC_Deal_Change_Request_Line_Item__c> errored = new List<PCC_Deal_Change_Request_Line_Item__c>();
                        List<PCC_Deal_Change_Request_Line_Item__c> success = new List<PCC_Deal_Change_Request_Line_Item__c>();
                        for(Database.saveResult sr : results){
                              String erroMessage ='';
                              if(!sr.isSuccess()){
                                    savedRecord = false;
                                    failed = true;
                                    for(Database.Error err : sr.getErrors()) {
                                          erroMessage = 'The following error has occurred.'+err.getStatusCode() + ': ' + err.getMessage()+'Account fields that affected this error: ' + err.getFields();
                                    }
                                    PCC_Deal_Change_Request_Line_Item__c item =changeRequestedLines[i];
                                    item.PCC_Request_Line_Status_Response__c = erroMessage;
                                    item.PCC_RequestLineStatus__c='Entered in Error';
                                    errored.add(item);
                              }
                              else{
                                    savedRecord =true;
                                    PCC_Deal_Change_Request_Line_Item__c item =changeRequestedLines[i];
                                    item.PCC_Request_Line_Status_Response__c = 'Successfully Created';
                                    item.PCC_RequestLineStatus__c='Approved';
                                    success.add(item);
                              }
                              i++;
                        }
                        if(failed){
                              update errored;
                        }else if(success !=null && success.size()>0){
                              update success;
                        }
                        // update cr lines
                  }
                  
                  
                  // Create Opportunity Line Items
                  List<OpportunityLineItem> oliList = PCC_FlowApexActionCntroller.createOpportunityLineItems(newProducts, changeRequestedLines[0].PCC_Change_Request__r.PCC_Opportunity__c, productToPriceBook);
                  
                  String errorMessage = PCC_FlowApexActionCntroller.processOLIandUpdateDRP(oliList, newProducts);
                  errorMessage = String.isNotBlank(errorMessage)? errorMessage:'Success';
                  
                  if(errorMessage != 'Success'){
                        update new PCC_Deal_Change_Request__c(Id=requestId, PCC_Transaction_Information_Message__c = changeRequestedLines[0].PCC_Change_Request__r.PCC_Transaction_Information_Message__c + errorMessage);
                  }
                  
                  // create record for pricing stage integration - PENDING
                  if(pdiEligible){
                        insert new Pricing_Integration_Staging__c(Pricing_Message_Type__c='Financial Incentive Update', Pricing_SObjectId__c=changeRequestedLines[0].PCC_Change_Request__r.PCC_Opportunity__c, Pricing_SObject__c='Opportunity', Pricing_Status__c='Pending');
                  }
                  
                  if(!newProducts.isEmpty()){
                        publishPlatformEvent(JSON.serialize(newProducts), 'REQUEST_FOR_CHANGE_PRODUCTS', requestId, 'OpportunityLineItem');
                  }
            }catch(Exception ex){
                  // return new List<String>{ex.getMessage()};
                  publishPlatformEvent(ex.getMessage(), 'CR_PROD_ADD_ERROR', requestId, 'OpportunityLineItem');
            }finally{
                  if(rollbackMode){
                        Database.rollback(sp); // for test purpose
                  }
            }
            return savedRecord;
            
      }
      
      // Method that calls the business logic for changing the requested lines
      public static void changeRequestedLinesMethod( String requestWrapper, String requestId, String changedLinesJSON, boolean rollbackMode){
            Savepoint sp ;
            if(rollbackMode){
                  sp = Database.setSavepoint(); // for test purpose
            }
            try{
                  Map<Id, PCC_Deal_Change_Request_Line_Item__c> changedLinesMp = (Map<Id, PCC_Deal_Change_Request_Line_Item__c>) JSON.deserialize(changedLinesJSON, Map<Id, PCC_Deal_Change_Request_Line_Item__c>.class);
                  List<String> res_messages = Pricing_FinancialIncentive_BusinessLogic.opportunityToQuoteLineChangeReq((List<Pricing_FinancialIncentive_BusinessLogic.OpportunityToQuoteLineCRWrapper>) JSON.deserialize(requestWrapper, List<Pricing_FinancialIncentive_BusinessLogic.OpportunityToQuoteLineCRWrapper>.class));
                  List<PCC_Deal_Change_Request_Line_Item__c> erroredLines = new List<PCC_Deal_Change_Request_Line_Item__c>();
                  List<PCC_Deal_Change_Request_Line_Item__c> approvedLines = new List<PCC_Deal_Change_Request_Line_Item__c>();
                  if(res_messages!=null && res_messages[0].length()>18){
                        for(String message : res_messages){
                              
                              List<String> splittedMessage = message.split(':');
                              erroredLines.add(new PCC_Deal_Change_Request_Line_Item__c(Id=changedLinesMp.get(splittedMessage[1]).Id, PCC_Change_Request_Quote_Line__c=splittedMessage[1], PCC_Request_Line_Status_Response__c = splittedMessage[2], PCC_RequestLineStatus__c='Entered in Error' ));
                        }
                  }else{
                        for(PCC_Deal_Change_Request_Line_Item__c line : changedLinesMp.values()){
                              line.PCC_RequestLineStatus__c ='Approved';
                              approvedLines.add(line);
                              approveChangeRequestInstance(requestId);
                        }
                  }
                  
                  if(erroredLines!=null && erroredLines.size()>0){
                        update erroredLines;
                  }
                  if(approvedLines != null && approvedLines.size()>0){
                        update approvedLines;
                  }
                  
            }catch(Exception ex){
            }finally{
                  if(rollbackMode){
                        Database.rollback(sp);
                  }
            }
      }
      
      public static void approveChangeRequestInstance(Id requestId){
            // Process the change request details and update the related Change Request Line Items
            List<ProcessInstanceWorkItem> workItems = [SELECT Id, ProcessInstance.TargetObjectId
                                                   FROM ProcessInstanceWorkItem
                                                   WHERE ProcessInstance.TargetObjectId = :requestId order by createddate desc];
            
            if (!workItems.isEmpty()) {
                  // Create an approval request for the work item
                  Approval.ProcessWorkItemRequest req = new Approval.ProcessWorkItemRequest();
                  req.setComments('Approved');
                  req.setAction('Approve');
                  req.setWorkItemId(workItems[0].Id);
                  
                  // Submit the approval request
                  Approval.ProcessResult result = Approval.process(req);
                  
                  // Check if approval was successful
                  if (result.isSuccess()) {
                        System.debug('Record has been successfully approved');
                  } else {
                        System.debug('Approval process failed: ' + result.getErrors());
                  }
            }
      }
      
      
      public static void publishPlatformEvent(String message, String type, String recordId, String objectName){
            
            PCC_Deal_Approval_Process_Communication__e errorEvent = new PCC_Deal_Approval_Process_Communication__e();
            errorEvent.PCC_Error_Message__c = message;//JSON.serialize(oliToCrMap)+'\n Exception :'+ex.getMessage();
            errorEvent.PCC_Object__c = objectName;//'OpportunityLineItem';
            errorEvent.PCC_Type__c = type;//'CR_PROD_CANCELLATION_ERROR';
            errorEvent.PCC_Record_ID__c = recordId;//requestId;
            EventBus.publish(new List<PCC_Deal_Approval_Process_Communication__e>{errorEvent});
      }
      
      
      // Inner class to represent the Approval Result
      public class ApprovalResult{
            @InvocableVariable public List<String> changedResults;
            @InvocableVariable public List<String> canceledResults;
            @InvocableVariable public List<String> addResults;
            
      }
}