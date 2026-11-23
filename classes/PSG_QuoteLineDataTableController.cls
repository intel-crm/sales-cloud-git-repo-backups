/****************************************************************************************************
Apex Class Name : PSG_QuoteLineDataTableController
Version         : 1.0 
Created Date    : 12/21/2020
Function        : Controller class that manages various functionality related to quoteLine datatable in Disty portal. 
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijay                  	12/21/2020                Created
*****************************************************************************************************/
@isTest
public without sharing class PSG_QuoteLineDataTableController {
  /*public static Boolean isquoteTableChanged = false;
  public static Boolean isquoteLineTableChanged = false;
  /****************************************************************************************************************
   * Method Name:fetchQuoteLines
   * Date: 12/21/2020   
   * Description: Method to fetch quoteLines related to a quote.
   ***************************************************************************************************************************/
  /*@AuraEnabled(cacheable = true)
  public static List < SBQQ__QuoteLine__c > fetchQuoteLines(Id quoteId) {
    return [SELECT Id, name, core_cpq_distributor_margin_pct__c From SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteId LIMIT 5];
  }
  /****************************************************************************************************************
   * Method Name:fetchAllQuoteLines
   * Date: 12/21/2020   
   * Description: Method fetches quote and quoteLines to be displayed in the disty portal UI.
   ***************************************************************************************************************************/
  /*@AuraEnabled
  public static PSG_QuoteLineDataTableController.newQuoteWrapper fetchAllQuoteLines(Id quoteId) {
    List < SBQQ__Quote__c > quoteList = new List < SBQQ__Quote__c > ();
    List < SBQQ__QuoteLine__c > quoteLineList = new List < SBQQ__QuoteLine__c > ();
    quoteLineList = [SELECT Id, name, core_cpq_product_nm__c, core_cpq_opn__c, core_cpq_altera_reg_number__c,
      core_cpq_altera_reg_txt__c, SBQQ__Quantity__c, core_cpq_revision_request_category_nm__c,
      core_cpq_revision_reason_txt__c, core_cpq_product_family_txt__c, SBQQ__ListPrice__c, core_cpq_competitor_name_nm__c,
      core_cpq_quote_line_type_txt__c, price_suggested_resale_amt__c, core_cpq_distributor_margin_pct__c,
      price_brokencost_amt__c, core_cpq_action_txt__c, core_cpq_justification_txt__c, core_cpq_years_nbr__c, core_cpq_design_registration_product__c,
      core_cpq_competitor_price_amt__c, core_cpq_requested_qty__c, price_requested_resale_amt__c, core_cpq_parent_quote_active_flag__c, Core_OPN__c,
      price_std_fwd_cost_amt__c, core_cpq_production_dt__c, core_cpq_lower_bound_qty_qty__c, core_cpq_dollar_change_flag_cb__c, core_cpq_PRID__c,
      core_cpq_upper_bound_qty_nbr__c, core_cpq_competitor_part_txt__c, core_cpq_competitor_product_txt__c, core_cpq_external_comments_txt__c, core_cpq_design_registration_product__r.Name,
      core_cpq_pricing_start_date_dt__c, core_cpq_pricing_end_date_dt__c, core_cpq_price_eligibility_date_dt__c, core_cpq_comments_for_disty_txt__c, core_cpq_ship_start_for_dpa__c, core_cpq_disty_value_add_dpa__c,
      SBQQ__ProductName__c, core_cpq_quote_line_type_document__c, price_disty_cost_nbr__c, SBQQ__Quote__r.Name, SBQQ__Quote__r.core_cpq_assigned_to_nm__r.Email, SBQQ__Quote__r.ownerid, core_cpq_active_Pricing__c From
      SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteId
    ];
    
    quoteList = [SELECT Id, name, core_cpq_distystatus_txt__c, core_cpq_end_customer_state_disty_txt__c, core_cpq_active_cb__c, core_cpq_end_customer_city_disty_nm__c, core_cpq_assigned_to_nm__r.Email, core_cpq_cm_country_disty_nm__c, Pricing_Project_Name_Nm__c, core_cpq_comments_by_disty_txt__c,
      core_cpq_quote_type_nm__c, core_cpq_business_unit_nm__c, core_cpq_segment_nm__c, core_cpq_cm_name_disty_nm__c, core_cpq_cm_state_txt__c, core_cpq_cm_city_disty_nm__c, core_cpq_distributor_disty_view_nm__c,
      core_cpq_volume_nbr__c, core_cpq_first_ship_date_dt__c, core_cpq_production_end_date_dt__c, SBQQ__Opportunity2__c, ownerId, core_cpq_end_customer_disty_nm__c, core_cpq_end_customer_country_disty_nm__c,
      core_cpq_end_customer_nm__r.Name, core_cpq_end_customer_disty_view_nm__c, core_cpq_end_customer_city__c, core_cpq_end_customer_State__c, core_cpq_ec_country__c from SBQQ__Quote__c where Id =: quoteId
    ];
    if (quoteLineList.isEmpty()) {
      newQuoteLineWrapper tempWrapper = addNewQuoteLine(quoteId, quoteLineList);
      quoteLineList = tempWrapper.quoteLineList;
    }
    return (new PSG_QuoteLineDataTableController.newQuoteWrapper(quoteList, quoteLineList));
  }
  /****************************************************************************************************************
   * Method Name:addNewQuoteLine
   * Date: 12/21/2020   
   * Description: Method performs initialisation of quoteline attributes added in quoteLine datatable in disty portal.
   ***************************************************************************************************************************/
  /*@AuraEnabled
  public static newQuoteLineWrapper addNewQuoteLine(Id recordId, List < SBQQ__QuoteLine__c > quoteLineLst) {
    SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
    List < SBQQ__Quote__c > quoteList = new List < SBQQ__Quote__c > ();
    quoteLine.recordtypeid = PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'PSG_Quote_Line_Create');
    quoteLine.core_cpq_opn__c = null;
    quoteLine.core_cpq_altera_reg_number__c = null;
    quoteLine.core_cpq_altera_reg_txt__c = null;
    quoteLine.core_cpq_revision_request_category_nm__c = 'Add';
    quoteLine.core_cpq_revision_reason_txt__c = null;
    quoteLine.core_cpq_production_dt__c = null;
    quoteLine.core_cpq_lower_bound_qty_qty__c = null;
    quoteLine.core_cpq_upper_bound_qty_nbr__c = null;
    quoteLine.SBQQ__Quantity__c = null;
    quoteLine.core_cpq_years_nbr__c = 1;
    quoteList = [SELECT Id, core_cpq_assigned_to_nm__r.Email, Name from SBQQ__Quote__c where Id =: recordId];
    if (recordId != null) {
      quoteLine.SBQQ__Quote__r = quoteList[0];
      quoteLine.SBQQ__Quote__c = recordId;
    }
    quoteLineLst.add(quoteLine);
    return new newQuoteLineWrapper(quoteLineLst);
  }
  /****************************************************************************************************************
   * Name:newQuoteLineWrapper
   * Date: 12/21/2020   
   * Description: Wrapper class initialises list of new Quote Lines
   ***************************************************************************************************************************/
  /*public without sharing class newQuoteLineWrapper {
    @AuraEnabled public List < SBQQ__QuoteLine__c > quoteLineList;
    @AuraEnabled public Map < Id, SBQQ__QuoteLine__c > quoteLineMap;
    public newQuoteLineWrapper(List < SBQQ__QuoteLine__c > quoteLineList) {
      this.quoteLineList = quoteLineList;
    }
  }
  /****************************************************************************************************************
   * Name:newQuoteWrapper
   * Date: 12/21/2020   
   * Description: Wrapper class initialises list of new Quotes and QuoteLines.
   ***************************************************************************************************************************/
  /*public without sharing class newQuoteWrapper {
    @AuraEnabled public List < SBQQ__Quote__c > quoteList;
    @AuraEnabled public List < SBQQ__QuoteLine__c > quoteLineList;
    public newQuoteWrapper(List < SBQQ__Quote__c > quoteList, List < SBQQ__QuoteLine__c > quoteLineList) {
      this.quoteList = quoteList;
      this.quoteLineList = quoteLineList;
    }
  }
  /****************************************************************************************************************
   * Name:updateQuoteLines
   * Date: 12/21/2020   
   * Description: Method Update Quote Lines from disty portal.
   ***************************************************************************************************************************/
  /*@AuraEnabled
  public static void updateQuoteLines(List < SBQQ__QuoteLine__c > quoteLineList) {
    List < SBQQ__QuoteLine__c > quoteLineListToUpdate = new List < SBQQ__QuoteLine__c > ();
    if (!quoteLineList.isEmpty()) {
      for (SBQQ__QuoteLine__c quoteLine: quoteLineList) {
        if (('' + quoteLine.Id).contains('row')) {
          quoteLine.Id = null;
          quoteLine.recordtypeid = PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'PSG_Quote_Line_Create');
          quoteLineListToUpdate.add(quoteLine);
          /*if (quoteLine.SBQQ__Quantity__c == null) {
              quoteLine.SBQQ__Quantity__c = 1;
          }*/
          /*if (quoteLine.core_cpq_years_nbr__c == null) {
            quoteLine.core_cpq_years_nbr__c = 1;
          }
        } else {
          quoteLineListToUpdate.add(quoteLine);
        }
      }
    }
    if (!quoteLineListToUpdate.isEmpty()) {
      upsert quoteLineListToUpdate;
    }
  }
  /****************************************************************************************************************
   * Name:deleteRecord
   * Date: 12/21/2020   
   * Description: Method to delete records.
   ***************************************************************************************************************************/
  /*@AuraEnabled
  public static void deleteRecord(Id recordId) {
    DataBase.delete(recordId);
  }
  /****************************************************************************************************************
   * Name:cloneRecord
   * Date: 12/21/2020   
   * Description: Method to clone quoteLine.
   ***************************************************************************************************************************/
  /*@AuraEnabled
  public static void cloneRecord(Id recordId) {
    String query = String.format(
      'SELECT {0} FROM {1} WHERE Id = \'\'{2}\'\'',
      new String[] {
        String.join(
            new List < String > (SBQQ__QuoteLine__c.SObjectType.getDescribe().fields.getMap().keySet()),
            ','),
          String.valueOf(SBQQ__QuoteLine__c.SObjectType),
          recordId
      }
    );
    List < SBQQ__QuoteLine__c > quoteLineList = new List < SBQQ__QuoteLine__c > ();
    // Query and clone the children. Here you can change anything without affecting the original sObject
    for (SBQQ__QuoteLine__c child: (List < SBQQ__QuoteLine__c > ) Database.query(query)) {
      // deep cloning of quoteLines
      SBQQ__QuoteLine__c newQuoteLine = child.clone(false, true);
      newQuoteLine.core_cpq_low_yield_cb__c = False;
      newQuoteLine.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'PSG_Quote_Line_Create');
      //Dynamic quoteline Fields to Blank out
      for (String fieldName: (Label.PSG_QuoteLineFieldsNull).split(':')) {}
      quoteLineList.add(newQuoteLine);
    }
    if (!quoteLineList.isEmpty()) {
      insert quoteLineList;
    }
  }
  /****************************************************************************************************************
   * Name:sendQuoteRequestUpdate
   * Date: 12/21/2020   
   * Description: Method to send revision request from disty portal.
   ***************************************************************************************************************************/
  /*@AuraEnabled
  public static void sendQuoteRequestUpdate(List < SBQQ__QuoteLine__c > oldQuoteLineList, Map < String, SBQQ__QuoteLine__c > quoteLineMap,
    List < SBQQ__Quote__c > oldQuoteList, Map < String, SBQQ__Quote__c > quoteMap, String status) {
    List < String > delegatedEmailList = new List < String > ();
    String quoteNumber = '';
    String assignedToEmail = '';
    String ownerName = userInfo.getName();
    String mpVar = '';
    String quoteId = '';
    try {
      if (oldQuoteList != null && !oldQuoteList.isEmpty()) {
        quoteNumber = oldQuoteList[0].Name;
        PSG_QuoteRequestController.validationWrapper validWrap = PSG_QuoteRequestController.validateOPN(quoteLineMap.values());
        if (!String.isEmpty(validWrap.error) && !Test.isRunningTest()) {
          throw new AuraHandledException(validWrap.error);
        }
        
          for (SBQQ__QuoteLine__c tempObj: quoteLineMap.values()) {
              if(String.isBlank(tempObj.core_cpq_revision_request_category_nm__c)){
                  throw new AuraHandledException('Add Revision Request before submitting');
              }
              if( quoteMap.values().core_cpq_quote_type_nm__c == 'Budgetary' && tempObj.core_cpq_revision_request_category_nm__c == 'Win' && status == 'Approved'){
                  throw new AuraHandledException('Quote Type cannot be Budgetary if category is Win in Quote Line');
              }
              if(status == 'Approved' && String.isBlank(tempObj.core_cpq_justification_txt__c)){
                  throw new AuraHandledException('Justification missing, please fill the mandatory field');                                                             
              }
          }
          quoteId = oldQuoteList[0].Id;
          List < Id > userIdList = new List < Id > ();
          
          List < User > ownerList = new List < User > ();

        for (core_user_delegation__c delegate: [SELECT id, core_cpq_delegated_For__c, core_cpq_delegated_to__c, core_cpq_IsActive__c from core_user_delegation__c
            WHERE core_cpq_IsActive__c = true and core_cpq_delegated_For__c =: oldQuoteList[0].ownerId LIMIT: Limits.getLimitDmlRows()
          ]) {

          userIdList.add(delegate.core_cpq_delegated_to__c);
        }
        for (User rec: [SELECT Id, Email from User where Id in: userIdList]) {
          delegatedEmailList.add(rec.Email);
        }
        if (oldQuoteList[0].ownerId != null) {
          ownerList = new List < User > ([SELECT Id, Email from User where Id =: oldQuoteList[0].ownerId]);
          if (!ownerList.isEmpty()) {
            assignedToEmail = ownerList[0].Email;
            delegatedEmailList.add(assignedToEmail);
          }
        }
      }
      if (status == 'In Progress') {
        mpVar = 'quote_inprogress';
      } else if (status == 'Approved') {
        mpVar = 'quote_approved';
      }
      oldQuoteList[0].core_cpq_change_revision_requested__c = true;

      String quoteTable = getHeaderTemplate(oldQuoteList, quoteMap, null, null, status, mpVar, 'quote');
      if (oldQuoteLineList != null && !oldQuoteLineList.isEmpty()) {
        mpVar = 'quoteline';
      }
      String quoteLineTable = getHeaderTemplate(null, null, oldQuoteLineList, quoteLineMap, status, mpVar, 'quoteLine');
      if (isquoteTableChanged == true || isquoteLineTableChanged == true) {
        Map < String, List < String >> relatedValues = new Map < String, List < String >> ();
        List < String > relatedToId = new List < String > ();
        List < String > subject = new List < String > ();
        List < String > htmlBody = new List < String > ();
        List < string > ccEmails = new List < String > ();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (String.isNotBlank(assignedToEmail)) {
          mail.setToAddresses(delegatedEmailList);

        } else {
          mail.setToAddresses(new List < String > {
            UserInfo.getUserEmail()
          });
        }
        if (String.isNotBlank(UserInfo.getUserEmail())) {
          mail.setCcAddresses(new List < String > {
            UserInfo.getUserEmail()
          });
          ccEmails.add(UserInfo.getUserEmail());
        }
        if (status == 'In Progress') {
          mail.setSubject('Quote Update Request from Disty | ' + quoteNumber + ' | ' + oldQuoteList[0].core_cpq_end_customer_disty_view_nm__c);
          subject.add('Quote Update Request from Disty | ' + quoteNumber + ' | ' + oldQuoteList[0].core_cpq_end_customer_disty_view_nm__c);
        } else {
          mail.setSubject('Quote Request Revision from Disty | ' + quoteNumber + ' | ' + oldQuoteList[0].core_cpq_end_customer_disty_view_nm__c);
          subject.add('Quote Request Revision from Disty | ' + quoteNumber + ' | ' + oldQuoteList[0].core_cpq_end_customer_disty_view_nm__c);
        }
        EmailTemplate tempId = [SELECT Id, HTMLValue, Body, Name FROM EmailTemplate WHERE DeveloperName = 'PSG_Disty_Quote_Update_Request'];
        String emailBody = tempID.HTMLValue;
        if (oldQuoteLineList != null && !oldQuoteLineList.isEmpty()) {
          emailBody = emailBody.replace('Quote_Line_Table', quoteLineTable);
        } else {
          emailBody = emailBody.remove('Quote_Line_Table');
        }
        if (oldQuoteList != null && !oldQuoteList.isEmpty()) {
          emailBody = emailBody.replace('Quote_Header_Table', quoteTable);
        }
        if (String.isNotBlank(ownerName)) {
          emailbody = emailBody.replace('user', ownerName);
        }
        if (String.isNotBlank(quoteNumber)) {
          emailBody = emailBody.replace('Quote_no', '<a href="' + fetchDomainName(quoteId) + '">' + quoteNumber + '</a>');
        }
        mail.setHtmlBody(emailBody);
        OrgWideEmailAddress orgWideEmailAdd = [Select Id,Address,DisplayName from OrgWideEmailAddress where address='wsm-postmaster@intel.com' Limit 1];
        mail.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
        
       
        Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
          mail
        });
        if (!oldQuoteList.isEmpty()) {
          update oldQuoteList;
          relatedToId.add(oldQuoteList[0].Id);
          htmlBody.add(emailBody);
        }
        relatedValues.put('relatedToId', relatedToId);
        relatedValues.put('subject', subject);
        relatedValues.put('htmlBody', htmlBody);
        //PSG_EmailMessageLog.createEmailMessageRecord(relatedValues, orgWideEmailAdd.Address, orgWideEmailAdd.DisplayName, new String[] {},
        //  delegatedEmailList, ccEmails, null);
      } else {
        throw new AuraHandledException('No Changes detected.Please choose a category if any changes were made in QuoteLines.');
      }
    } catch (AuraHandledException ex) {
      throw ex;
    } catch (Exception ex) {
      throw ex;
    }
  }
  /****************************************************************************************************************
   * Name:getHeaderTemplate
   * Date: 12/21/2020   
   * Description: Method to make the email template send on revision request from disty portal.
   ***************************************************************************************************************************/
  /*@AuraEnabled
  public static String getHeaderTemplate(List < SBQQ__Quote__c > oldQuoteHeader, Map < String, SBQQ__Quote__c > quoteHeaderMap,
    List < SBQQ__QuoteLine__c > oldQuoteLineList, Map < String, SBQQ__QuoteLine__c > quoteLineMap,
    String status, String mapVar, String objectType) {
    List < sObject > newQuoteHeaderList = new List < sObject > ();
    List < sObject > oldQuoteHeaderList = new List < sObject > ();
    String objStr = '';
    Boolean isNotChanged = false;
    Map < String, sObject > objMap = new Map < String, sObject > ();
    if (oldQuoteHeader != null) {
      oldQuoteHeaderList = oldQuoteHeader;
      objStr = 'Quote Detail';
    } else if (oldQuoteLineList != null) {
      oldQuoteHeaderList = oldQuoteLineList;
      objStr = 'Quote Line Detail';
    }
    if (quoteHeaderMap != null) {
      objMap = quoteHeaderMap;
    } else if (quoteLineMap != null) {
      objMap = quoteLineMap;
    }
    Map < Id, Set < String >> quoteHeaderIdToChangedFieldMap = new Map < Id, Set < String >> ();
    String quoteNumber = '';
    Map < String, Set < String >> fieldMapping = new Map < String, Set < String >> ();
    Map < String, String > fieldToFieldNameMapping = new Map < String, String > ();
    fieldMapping.put('quote_inprogress', new Set < String > {
      'core_cpq_active_cb__c',
      'core_cpq_end_customer_disty_nm__c',
      'core_cpq_end_customer_city_disty_nm__c',
      'core_cpq_end_customer_state_disty_txt__c',
      'core_cpq_end_customer_country_disty_nm__c',
      'core_cpq_cm_name_disty_nm__c',
      'core_cpq_cm_city_disty_nm__c',
      'core_cpq_cm_state_txt__c',
      'core_cpq_cm_country_disty_nm__c',
      'core_cpq_business_unit_nm__c',
      'Pricing_Project_Name_Nm__c'
      //'core_cpq_comments_by_disty_txt__c'
    });
    fieldMapping.put('quote_approved', new Set < String > {
      'name',
      'core_cpq_quote_type_nm__c',
      'core_cpq_end_customer_disty_view_nm__c',
      'core_cpq_end_customer_city__c',
      'core_cpq_end_customer_State__c',
      'core_cpq_ec_country__c',
      'core_cpq_distributor_disty_view_nm__c',
      'core_cpq_confirmed_order__c'
    });
    fieldMapping.put('quoteline', new Set < String > {
      'name',
      'core_cpq_revision_request_category_nm__c',
      'core_cpq_justification_txt__c',
      'core_cpq_opn__c',
      'core_cpq_lower_bound_qty_qty__c',
      'core_cpq_upper_bound_qty_nbr__c',
      'SBQQ__Quantity__c',
      'core_cpq_years_nbr__c',
      'core_cpq_production_dt__c',
      'price_requested_resale_amt__c',
      'core_cpq_altera_reg_txt__c',
      'core_cpq_external_comments_txt__c'
    });
    if (mapVar == 'quote_inprogress' || mapVar == 'quote_approved') {
      fieldToFieldNameMapping.put('name', 'Quote #'); // Changes for TWC3133-3712 - Bishal Singh
      fieldToFieldNameMapping.put('core_cpq_active_cb__c', 'Active');
      fieldToFieldNameMapping.put('core_cpq_cm_name_disty_nm__c', 'CM');
      //fieldToFieldNameMapping.put('core_cpq_end_customer_disty_nm__c', 'End Customer');
      //fieldToFieldNameMapping.put('core_cpq_end_customer_disty_view_nm__c', 'End Customer');
      fieldToFieldNameMapping.put('core_cpq_end_customer_country_disty_nm__c', 'End Customer Country');
      fieldToFieldNameMapping.put('core_cpq_ec_country__c', 'End Customer Country');
      fieldToFieldNameMapping.put('core_cpq_business_unit_nm__c', 'Business Unit');
      fieldToFieldNameMapping.put('core_cpq_confirmed_order__c', 'Confirmed Order');
      fieldToFieldNameMapping.put('core_cpq_distributor_disty_view_nm__c', 'Distributor Account');

      fieldToFieldNameMapping.put('core_cpq_end_customer_city_disty_nm__c', 'End Customer City');
      fieldToFieldNameMapping.put('core_cpq_end_customer_city__c', 'End Customer City');
      fieldToFieldNameMapping.put('core_cpq_cm_city_disty_nm__c', 'CM City');
      fieldToFieldNameMapping.put('core_cpq_cm_country_disty_nm__c', 'CM Country');
      fieldToFieldNameMapping.put('core_cpq_end_customer_state_disty_txt__c', 'End Customer State');
      fieldToFieldNameMapping.put('core_cpq_end_customer_State__c', 'End Customer State');
      fieldToFieldNameMapping.put('Pricing_Project_Name_Nm__c', 'Project Name');
      fieldToFieldNameMapping.put('core_cpq_cm_state_txt__c', 'CM State');
      //fieldToFieldNameMapping.put('core_cpq_comments_by_disty_txt__c', 'Disty Comments');
      fieldToFieldNameMapping.put('core_cpq_quote_type_nm__c', 'Quote Type');
    }
    if (mapVar == 'quote_inprogress') {
      fieldToFieldNameMapping.put('core_cpq_end_customer_disty_nm__c', 'End Customer');
      fieldToFieldNameMapping.put('core_cpq_end_customer_disty_view_nm__c', 'End Customer');
    } else if (mapVar == 'quote_approved') {
      fieldToFieldNameMapping.put('core_cpq_end_customer_disty_nm__c', 'End Customer Name');
      fieldToFieldNameMapping.put('core_cpq_end_customer_disty_view_nm__c', 'End Customer Name');
    }
    if (mapVar == 'quoteline') {
      fieldToFieldNameMapping.put('name', 'Quote Line Number');
      fieldToFieldNameMapping.put('core_cpq_revision_request_category_nm__c', 'Request Category');
      fieldToFieldNameMapping.put('core_cpq_justification_txt__c', 'Justification');
      fieldToFieldNameMapping.put('core_cpq_opn__c', 'OPN');
      fieldToFieldNameMapping.put('core_cpq_lower_bound_qty_qty__c', 'LBound Qty');
      fieldToFieldNameMapping.put('core_cpq_upper_bound_qty_nbr__c', 'UBound Qty');
      fieldToFieldNameMapping.put('SBQQ__Quantity__c', 'EAU');
      fieldToFieldNameMapping.put('core_cpq_years_nbr__c', '#Years');

      fieldToFieldNameMapping.put('core_cpq_production_dt__c', 'Price Eligibility Date');
      fieldToFieldNameMapping.put('price_requested_resale_amt__c', 'Requested Resale');
      fieldToFieldNameMapping.put('core_cpq_altera_reg_txt__c', 'Design Registration Product');
      fieldToFieldNameMapping.put('core_cpq_external_comments_txt__c', 'Disty Comments'); 
    }
    
    if (objMap != null && !objMap.isEmpty()) {
      for (sObject tempObj: oldQuoteHeaderList) {
        if (objMap.containsKey(tempObj.Id)) {
          sObject newQuoteHeader = objMap.get(tempObj.Id);
          newQuoteHeaderList.add(newQuoteHeader);
          quoteNumber = (String) newQuoteHeader.get('Name');
          
          for (String field: fieldMapping.get(mapVar)) {
            if (newQuoteHeader.get(field) != tempObj.get(field) && !((newQuoteHeader.get(field) == null || newQuoteHeader.get(field) == '') && (tempObj.get(field) == null || tempObj.get(field) == ''))) {
              if (!quoteHeaderIdToChangedFieldMap.containsKey(newQuoteHeader.Id)) {
                quoteHeaderIdToChangedFieldMap.put(newQuoteHeader.Id, new Set < String > {
                  field
                });
              } else {
                quoteHeaderIdToChangedFieldMap.get(newQuoteHeader.Id).add(field);
              }
            }
          }
        }
      }
    }
    

    if (!(quoteHeaderIdToChangedFieldMap.values()).isEmpty()) {

      if (objectType == 'quote') {
        isquoteTableChanged = true;
      } else if (objectType == 'quoteLine') {
        isquoteLineTableChanged = true;
      }
    } else {

      if (objectType == 'quote') {
        isquoteTableChanged = false;
      } else if (objectType == 'quoteLine') {
        isquoteLineTableChanged = false;
      }
    }
    if (objectType == 'quoteLine' && !(oldQuoteHeaderList.isEmpty())) {
      isquoteLineTableChanged = true;
    }
    String quoteHeaderTable = '';
                                               

    if (!newQuoteHeaderList.isEmpty()) {
    
      
      String style = '<style>table {border-collapse: collapse;font-family: arial, helvetica, sans-serif; font-size: x-small; text-align: center;}td, th {border: 1px solid black;padding:5px;}</style>';
      quoteHeaderTable = style + '<p style="padding-top : 50px;font-weight: bold;">' + objStr + '</p><table style="border-color: #000000; border-width: 1px; width: 100%; border-style: solid;" cellspacing="0" ><tbody><tr>';
      if (mapVar == 'quote_approved') {
        quoteHeaderTable = style + '<p style="padding-top : 50px;font-weight: bold;">' + objStr + '</p><table style="border-color: #000000; border-width: 1px; width: 100%; border-style: solid;" cellspacing="0" ><tbody><tr>';
      } else {
        quoteHeaderTable = style + '<p style="padding-top : 50px;font-weight: bold;">' + objStr + '</p><table style="border-color: #000000; border-width: 1px; width: 100%; border-style: solid;" cellspacing="0" ><tbody><tr>';
      }

      for (String field: fieldMapping.get(mapVar)) {
        if (fieldToFieldNameMapping.containsKey(field)) {
          quoteHeaderTable = quoteHeaderTable + '<th>' + fieldToFieldNameMapping.get(field) + '</th>';
        }
      }
      quoteHeaderTable = quoteHeaderTable + '</tr>';
      for (sObject quote: newQuoteHeaderList) {
        Set < String > fieldsToAddColorSet = new Set < String > ();
        if (quoteHeaderIdToChangedFieldMap.containsKey(quote.Id)) {
          fieldsToAddColorSet.addAll(quoteHeaderIdToChangedFieldMap.get(quote.Id));
        }
        quoteHeaderTable = quoteHeaderTable + '<tr>';
        for (String field: fieldMapping.get(mapVar)) {
          String str = '';
          if (quote.get(field) != null) {
            if (field == 'core_cpq_production_dt__c') {
              str = '' + ((Date) quote.get(field)).format();
            } else {
              str = '' + quote.get(field);
            }
          }
          
          if (mapVar == 'quote_approved' && oldQuoteHeader != null && quote.get(field) == null && (oldQuoteHeader[0].get(field) != null || oldQuoteHeader[0].get(field) == '')) {
            str = '' + oldQuoteHeader[0].get(field);
            fieldsToAddColorSet.remove(field);
          }

          if (fieldsToAddColorSet.contains(field) && field != 'core_cpq_revision_request_category_nm__c') {
            str = '<td bgcolor="yellow">' + str + '</td>';
          } else if (String.isBlank(str)) {
            str = '<td></td>';
          } else {
            str = '<td>' + str + '</td>';
          }
          quoteHeaderTable = quoteHeaderTable + str;
        }
      }
      quoteHeaderTable += '</tr></tbody></table>';
    }
    return quoteHeaderTable;
  }
  /****************************************************************************************************************
   * Name:fetchDomainName
   * Date: 12/21/2020   
   * Description: Method to fetch domain name used in email template sent on revision request from disty portal.
   ***************************************************************************************************************************/
  /*public static String fetchDomainName(String quoteId) {
    String domainName;
    domainName = String.valueOf(System.Url.getOrgDomainUrl());
    domainName = domainName.split('=')[1].split(']')[0];
    domainName = domainName + '/' + quoteId;
    return domainName;
  }*/
}