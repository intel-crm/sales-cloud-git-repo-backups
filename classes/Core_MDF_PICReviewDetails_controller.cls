/****************************************************************************************************************************************
 * Class Name  : Core_MDF_PICReviewDetails_controller
 * Version     : 1.0
 * Created Date:
 * Modification Log :
 * Test Class Name : Core_MDF_PICReviewDetails_controllerTest
 * Developer                    Date                          Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Accenture - Vinodhini B       24/7/2022                      Created Core_MDF_PICReviewDetails_controller to retrive PIC Reviews Detail.
 *****************************************************************************************************************************************/

 public without sharing class Core_MDF_PICReviewDetails_controller {

  /****************************************************************************************************** 
Method Name:        getUserAndPICReviewResultDetails
@return  :          string
@parameters:        Claim Id
Description:        Method to return userdetails,pic review details and pic review results
Added By:           Accenture - Vinodhini B       24/7/2022
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    @AuraEnabled
  public static userAndPICreviewResultsWrapper getUserAndPICReviewResultDetails(
    Id claimId
  ) {
    UserAndPICreviewResultsWrapper wrapper = new UserAndPICreviewResultsWrapper();
    userDetailsWrapper userDetails = new userDetailsWrapper();
    List<Core_MDF_PIC_Review__c> picReviewList = new List<Core_MDF_PIC_Review__c>();
    Map<Id, List<Core_MDF_PICReviewResult__c>> picReviewResultMap = new Map<Id, List<Core_MDF_PICReviewResult__c>>();
    Set<Id> picReviewIds = new Set<Id>();
    String picReviewLocalizedFieldAPIName;
    Boolean isCCRMUserOrPICReviewer = false;
    Boolean hasClaimUndergonePICReview = false;
    Boolean ipaOutcomeBasedClaim = false;
    Boolean finalOutcomeBasedClaim = false;  //Roshan - Final Outcome Based New Status
    try {
      userDetails = getUserDetails();
      picReviewLocalizedFieldAPIName = getPICReviewLocalizedFieldAPIName(userDetails.userLanguageLocaleKey);
      isCCRMUserOrPICReviewer = FeatureManagement.checkPermission('Core_MDF_PICReviewDetails_Access');
      picReviewList = getPICReviewDetails(claimId, isCCRMUserOrPICReviewer);
      if(!picReviewList.isEmpty()) {
        hasClaimUndergonePICReview = true;
          for(Core_MDF_PIC_Review__c picReview : picReviewList) {
              picReviewIds.add(picReview.Id);
              if(!ipaOutcomeBasedClaim) {
                ipaOutcomeBasedClaim = (picReview.Core_MDF_Claim_ID_id__r.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM && picReview.Core_MDF_Claim_ID_id__r.Core_MDF_OutcomeBased_Ind__c) ? true : false;
              }
              //Roshan - Final Outcome Based New Status
              if (!finalOutcomeBasedClaim) {
                finalOutcomeBasedClaim = picReview.Core_MDF_Claim_ID_id__r.Request.Core_MDF_Is_Outcome_Based_Ind__c ? true : false;
              }
          }
          if(!picReviewIds.isEmpty()) {
            picReviewResultMap = getPICReviewResultDetails(picReviewIds, userDetails.isInternalUser, picReviewLocalizedFieldAPIName);
          }
      }

      wrapper.userDetails = userDetails;
      wrapper.picReviewLocalizedFieldAPIName = picReviewLocalizedFieldAPIName;
      wrapper.picReviewDetails = picReviewList;
      wrapper.picReviewResultDetails = picReviewResultMap;
      wrapper.isCCRMUserOrPICReviewer = isCCRMUserOrPICReviewer;
      wrapper.hasClaimUndergonePICReview = hasClaimUndergonePICReview;
      wrapper.ipaOutcomeBasedClaim = ipaOutcomeBasedClaim;
      wrapper.finalOutcomeBasedClaim = finalOutcomeBasedClaim;  //Roshan - Final Outcome Based New Status

    } catch (Exception e) {throw new AuraHandledException(e.getMessage());
    }
    return wrapper;
  }

  /****************************************************************************************************** 
Method Name:        getPICReviewLocalizedFieldAPIName
@return  :          string
@parameters:        String of User Language code
Description:        Fetch Language Field Name using Language key.
Added By:           Accenture - Vinodhini B       24/7/2022
Modified By:        Date:       Changes: 
*******************************************************************************************************/
  @AuraEnabled(cacheable=true)
  public static string getPICReviewLocalizedFieldAPIName(String userLangKey) {
    List<Core_MDF_Email_Translation_Resub_Reqd__mdt> localizedFieldList = new List<Core_MDF_Email_Translation_Resub_Reqd__mdt>();
    String localizedFieldName = 'Core_MDF_Issue_English_txt__c';
    String userLanguageKey = userLangKey;
    try {
      if (userLanguageKey != null && userLanguageKey != '') {
            localizedFieldList = [SELECT Core_MDF_LanguageLocalKey__c,Core_MDF_PIC_Review_Result_Field_Name__c FROM Core_MDF_Email_Translation_Resub_Reqd__mdt WHERE Core_MDF_LanguageLocalKey__c = :userLanguageKey LIMIT 1];

            /*if (localizedFieldList != null && localizedFieldList.size() > 0) {
              if (
                !String.isblank(
                  localizedFieldList[0].Core_MDF_PIC_Review_Result_Field_Name__c
                )
              ) {
                localizedFieldName = localizedFieldList[0]
                  .Core_MDF_PIC_Review_Result_Field_Name__c;
              }
            }*/
            if (localizedFieldList != null && localizedFieldList.size() > 0 && !String.isBlank(localizedFieldList[0].Core_MDF_PIC_Review_Result_Field_Name__c)) { //ATHR Fix WW19
                localizedFieldName = localizedFieldList[0].Core_MDF_PIC_Review_Result_Field_Name__c;
            }
      }
    } catch (exception ex) {Core_MDF_CCP_UtilityClass.logError(ex);throw new AuraHandledException(ex.getMessage());
    }
    return localizedFieldName;
  }

  public static String localizeTacticValues(String tacticValues) {

    List<Schema.PicklistEntry> pickValues = Core_MDF_PICReviewResult__c.Core_MDF_Tactics_nm__c.getDescribe().getPicklistValues();
    Map<String, String> apiToLabel = new Map<String, String>();

    for (Schema.PicklistEntry pe : pickValues) {
        apiToLabel.put(pe.getValue(), pe.getLabel());
    }

    List<String> apiValues = tacticValues.split(';');
    List<String> localizedValues = new List<String>();

    for (String val : apiValues) {
        String key = val.trim();
        localizedValues.add(apiToLabel.containsKey(key) ? apiToLabel.get(key) : key);
    }

    return String.join(localizedValues, '; ');
  }


  /*public static Boolean hasCCRMOrPICReviewerAccess() {
    Boolean isPICReviewerCCRM =
      FeatureManagement.checkPermission('Core_MDF_PICReviewDetails_Access');
    return isPICReviewerCCRM;
  }*/

  /****************************************************************************************************** 
Method Name:        getObjectAccess
@return  :          string
@parameters:        null
Description:        Method to check the object access
Added By:           Accenture - Vinodhini B       24/7/2022
Modified By:        Date:       Changes: 
*******************************************************************************************************/
  @AuraEnabled
  public static Boolean getObjectAccess() {
    Boolean hasPICReviewObjAccess = false;
    Boolean hasPICReviewResultObjAccess = false;
    Boolean hasObjectAccess = false;
    try {
      hasPICReviewObjAccess = Core_MDF_checkSObjectCRUDPermission.checkSObjectReadPermission(
        'Core_MDF_PIC_Review__c'
      );
      hasPICReviewResultObjAccess = Core_MDF_checkSObjectCRUDPermission.checkSObjectReadPermission(
        'Core_MDF_PICReviewResult__c'
      );
      if (hasPICReviewObjAccess && hasPICReviewResultObjAccess) {
        hasObjectAccess = true;
      } else {
        hasObjectAccess = false;
      }
    } catch (Exception e) {throw new AuraHandledException(e.getMessage());
    }
    return hasObjectAccess;
  }

   /****************************************************************************************************** 
Method Name:        getUserDetails
@return  :          string
@parameters:        null
Description:        Method to fetch userdetails
Added By:           Accenture - Vinodhini B       24/7/2022
Modified By:        Date:       Changes: 
*******************************************************************************************************/
  public static userDetailsWrapper getUserDetails() {
    User userData = [
      SELECT Id, LanguageLocaleKey, LocaleSidKey, UserType
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ];
    userDetailsWrapper userDetails = new userDetailsWrapper();
    if (userData != null) {
      userDetails.userType = userData.UserType;
      userDetails.userLanguageLocalekey = userData.LanguageLocaleKey;
      if (userDetails.userType != 'PowerPartner') {
        userDetails.isInternalUser = true;
      } else {
        userDetails.isInternalUser = false;
      }
    }
    return userDetails;
  }

   /****************************************************************************************************** 
Method Name:        getPICReviewDetails
@return  :          string
@parameters:        claimdId and PICreviewer boolean
Description:        Method to return all the pic reviews related to the claim
Added By:           Accenture - Vinodhini B       24/7/2022
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static List<Core_MDF_PIC_Review__c> getPICReviewDetails(Id claimId, Boolean isCCRMUserOrPICReviewer){
        List<Core_MDF_PIC_Review__c> picReviewList = new List<Core_MDF_PIC_Review__c>();
        String picReviewQuery;
        try{
        boolean isPICReviewerOrCCRMUser = isCCRMUserOrPICReviewer;
        // Query the Required fields data
        if(isPICReviewerOrCCRMUser) {
            picReviewQuery = 'Select '+'Id'+','+'Core_MDF_CycleNumber_nbr__c'+','+'Core_MDF_Review_Status_nm__c'+','+'format(Core_MDF_Review_Date_dt__c) formattedDate'+','+'Core_MDF_ReviewedBy_id__r.Name'+','+'Core_MDF_InternalComments_txt__c,'+
            'Core_MDF_Claim_ID_id__r.Core_MDF_Program__c, Core_MDF_Claim_ID_id__r.Core_MDF_Campaign_Id__r.Core_MDF_CampOutcomeOpt_In_Ind__c, Core_MDF_Claim_ID_id__r.Request.Core_MDF_Is_Outcome_Based_Ind__c, Core_MDF_Claim_ID_id__r.Core_MDF_OutcomeBased_Ind__c from  Core_MDF_PIC_Review__c'+' WHERE Core_MDF_Claim_ID_id__c =:claimId'+' and Core_MDF_AI_PIC_Review_Ind__c = false order by Core_MDF_CycleNumber_nbr__c desc';
        } else {
            picReviewQuery = 'Select '+'Id'+','+'Core_MDF_CycleNumber_nbr__c'+','+'Core_MDF_Review_Status_nm__c'+','+'toLabel(Core_MDF_Review_Status_nm__c) LocalizedPICReviewStatus'+','+'format(Core_MDF_Review_Date_dt__c) formattedDate,'+
            'Core_MDF_Claim_ID_id__r.Core_MDF_Program__c, Core_MDF_Claim_ID_id__r.Core_MDF_Campaign_Id__r.Core_MDF_CampOutcomeOpt_In_Ind__c, Core_MDF_Claim_ID_id__r.Request.Core_MDF_Is_Outcome_Based_Ind__c, Core_MDF_Claim_ID_id__r.Core_MDF_OutcomeBased_Ind__c from Core_MDF_PIC_Review__c'+' WHERE Core_MDF_Claim_ID_id__c =:claimId'+' and Core_MDF_AI_PIC_Review_Ind__c = false order by Core_MDF_CycleNumber_nbr__c desc';
        }
        picReviewList = Database.query(String.escapeSingleQuotes(picReviewQuery));
        }catch(Exception ex){Core_MDF_CCP_UtilityClass.logError(ex);throw new AuraHandledException(ex.getMessage());
        }
        return picReviewList;
    }
   /****************************************************************************************************** 
Method Name:        getPICReviewResultDetails
@return  :          string
@parameters:        set of Pic review ids, internal user bool, localized field name
Description:        Method to return all the pic review results based on pic review 
Added By:           Accenture - Vinodhini B       24/7/2022
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static Map<Id, List<Core_MDF_PICReviewResult__c>> getPICReviewResultDetails(set<Id> picReviewIds, Boolean isInternalUser, String localizedFieldName) {
    Set<Id> picReviewIdsSet = picReviewIds;
    String localizedField = localizedFieldName;
    Set<String> response_No = new Set<String>{'No','True'};
    String statusCompleted = 'Completed';
    boolean isIntlUser = isInternalUser;
    Map<Id, List<Core_MDF_PICReviewResult__c>> picIdtoPICReviewResult = new Map<Id, List<Core_MDF_PICReviewResult__c>>();
    String finalQuery = '';
    try {
      if (picReviewIdsSet != null && isIntlUser != null) {

        if (!isIntlUser) {
          finalQuery =
            'Select ' +
            'Id' +
            ',' +
            String.escapeSingleQuotes(localizedField) +','+'Core_MDF_Question_id__r.Core_MDF_Parent_Question__c,Core_MDF_Question_id__r.Core_MDF_Sub_Question_Ind__c,Core_MDF_Question_id__c'+
            ',' +
            'Core_MDF_Response_txt__c' +
            ',' +
            'Core_MDF_FilesAffected_txt__c' +
            ',' +
            'Core_MDF_PIC_Review_id__c' +
            ',' +
            'Core_MDF_Comment_txt__c' +
            ',' +
            'Core_MDF_Tactics_nm__c' +
            ' from Core_MDF_PICReviewResult__c' +
            ' WHERE Core_MDF_PIC_Review_id__c IN: picReviewIdsSet ' +
            ' And ' +
            '(Core_MDF_Response_txt__c  IN: response_No)'+
            ' order by Core_MDF_Question_id__r.Core_MDF_Sort_Order__c';
        } else {
            finalQuery =
              'Select ' +
              'Id' +
              ',Core_MDF_Issue_English_txt__c,' +'Core_MDF_Question_id__r.Core_MDF_Parent_Question__c,Core_MDF_Question_id__r.Core_MDF_Sub_Question_Ind__c,Core_MDF_Question_id__c,'+
              'Core_MDF_Response_txt__c' +
              ',' +
              'Core_MDF_QuestionEnglish_txt__c' +
              ',' +
              'Core_MDF_FilesAffected_txt__c' +
              ',' +
              'Core_MDF_PIC_Review_id__c' +
              ',' +
              'Core_MDF_Comment_txt__c' +
              ',' +
              'Core_MDF_Tactics_nm__c' +
              ' from Core_MDF_PICReviewResult__c' +
              ' WHERE Core_MDF_PIC_Review_id__c IN: picReviewIdsSet ' +
              ' And ' +
              '(Core_MDF_Response_txt__c  IN: response_No)'+
              ' order by Core_MDF_Question_id__r.Core_MDF_Sort_Order__c';
          }
        }
        List<Core_MDF_PICReviewResult__c> listOfPICReviewResults = Database.Query(String.escapeSingleQuotes(finalQuery));
        for (
          Core_MDF_PICReviewResult__c picReviewResult : listOfPICReviewResults
        ) {
            if (!isIntlUser && picReviewResult.Core_MDF_Tactics_nm__c != null) {
                picReviewResult.Core_MDF_Tactics_nm__c = localizeTacticValues(picReviewResult.Core_MDF_Tactics_nm__c);
            }
          if (
            picIdtoPICReviewResult.containsKey(
              picReviewResult.Core_MDF_PIC_Review_id__c
            )
          ) {
            picIdtoPICReviewResult.get(
                picReviewResult.Core_MDF_PIC_Review_id__c
              )
              .add(picReviewResult);
          } else {
            picIdtoPICReviewResult.put(
              picReviewResult.Core_MDF_PIC_Review_id__c,
              new List<Core_MDF_PICReviewResult__c>{ picReviewResult }
            );
          }
        }
    } catch (exception ex) {Core_MDF_CCP_UtilityClass.logError(ex);throw new AuraHandledException(ex.getMessage());
    }
    return picIdtoPICReviewResult;
  }
//Wrapper class to store userdetails,picreviewdetails,picreviewresultdetails,localizedfieldname
  public class userAndPICreviewResultsWrapper {
    @AuraEnabled
    public userDetailsWrapper userDetails { get; set; }
    @AuraEnabled
    public List<Core_MDF_PIC_Review__c> picReviewDetails { get; set; }
    @AuraEnabled
    public Map<Id, List<Core_MDF_PICReviewResult__c>> picReviewResultDetails {
      get;
      set;
    }
    @AuraEnabled
    public String picReviewLocalizedFieldAPIName { get; set; }
    @AuraEnabled
    public Boolean isCCRMUserOrPICReviewer { get; set; }
    @AuraEnabled
    public Boolean hasClaimUndergonePICReview { get; set; }
    @AuraEnabled
    public Boolean ipaOutcomeBasedClaim { get; set; }
    @AuraEnabled
    public Boolean finalOutcomeBasedClaim { get; set; }  //Roshan - Final Outcome Based New Status
  }
//wrapper to store the userdetails
  public class userDetailsWrapper {
    @AuraEnabled
    public String userType { get; set; }
    @AuraEnabled
    public String userLanguageLocaleKey { get; set; }
    @AuraEnabled
    public Boolean isInternalUser { get; set; }
  }
}