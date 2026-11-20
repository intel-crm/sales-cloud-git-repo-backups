/*
 Author: Sai Thotakura
 Onyx Team
 Purpose: Controller class for Rich Media asset Search box lwc
 */
public with sharing class PMP_RichMediaAssetController {
  /*
   Query method to return all partners where name or tagline matches the search input
   */
  @AuraEnabled(cacheable = true)
  public static list<CompanyResult> getCompanyList(string searchKey){
    string searchKeyword = '%' + searchKey + '%';
    // create Partners list to store search result
    List<CompanyResult> lstReturnResult = new List<CompanyResult>();
    // query PMP_Company__c records
    if (Schema.sObjectType.PMP_Company__c.isAccessible()){
      for (PMP_Company__c partnerObj : [Select id, Name
                                  From PMP_Company__c
                                  WHERE PMP_Benefit_Update_Ind__c = false and PMP_Is_Working_Copy_Ind__c = false and PMP_Company_Lifecycle_Status_Nm__c = 'Published' and (name LIKE:searchKeyword or PMP_Account_Tag_Line__c LIKE:searchKeyword)
                                  limit 30]){
        CompanyResult cr = new CompanyResult();
        cr.recordId = (String) partnerObj.get('Id');
        cr.recordName = (String) partnerObj.get('Name');
        lstReturnResult.add(cr);
      }
    }
    return lstReturnResult;
  }

  /*
   Query method to return all offerings based on the partner ids
   */
  // @AuraEnabled(cacheable = true)
  // public static List<PMP_Partner_Offering__c> getOfferingsonPartners(String ids){
  //   String description = '';
  //   String newdesc = '';
  //   string novalue = PMP_Utility.getValue('PMP_PreReleaseCheck_Nm');
  //   List<Id> partneridlist = ids.split(', ');
  //   List<PMP_Partner_Offering__c> offeringlist = new List<PMP_Partner_Offering__c>();
  //   /*
  //    1. Fully Published Copies
  //    2. Pre-release count greater than 0 approved offerings
  //    3. Pre-release count is zero and pre release check : NO offerings
  //    4. Offerings with future start date
  //    */
  //   if (Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()){
  //     for (PMP_Partner_Offering__c offering : [SELECT Id, PMP_Partner_Offering_Dsc__c, PMP_Working_Copy_Id__c, PMP_Company_Id__c, PMP_Company_Id__r.Name, PMP_Pre_Release_Item_Count_Num__c, PMP_Partner_Offering_Tag_Line_Txt__c, PMP_Partner_Offering_Nm__c, PMP_Partner_Offering_Lifecycle_Status_Nm__c, PMP_Partner_Offering_Start_Dt__c, PMP_Partner_Offering_End_Dt__c
  //                                        FROM PMP_Partner_Offering__c
  //                                        WHERE ((PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Published and (PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Partner_Offering_End_Dt__c >= TODAY and PMP_Is_Not_Available_On_MP_Ind__c = false)) OR (PMP_Working_Copy_Id__c = null and PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Approved and PMP_Pre_Release_Item_Count_Num__c > :PMP_StaticConstants_MasterData.Zero and PMP_Pre_Release_Check_Nm__c != null) OR (PMP_Working_Copy_Id__c = null and PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Approved and PMP_Pre_Release_Item_Count_Num__c = :PMP_StaticConstants_MasterData.Zero and PMP_Pre_Release_Check_Nm__c = :novalue and PMP_Partner_Offering_Start_Dt__c != null) OR (PMP_Working_Copy_Id__c = null and PMP_Partner_Offering_Lifecycle_Status_Nm__c = :PMP_StaticConstants_Partner.Approved and PMP_Pre_Release_Item_Count_Num__c = :PMP_StaticConstants_MasterData.Zero and PMP_Pre_Release_Check_Nm__c = null and PMP_Partner_Offering_Start_Dt__c > TODAY)) AND PMP_Company_Id__c IN:partneridlist]){
  //       if(offering.PMP_Partner_Offering_Dsc__c!=null){
  //         description = offering.PMP_Partner_Offering_Dsc__c;
  //       }  
  //       if (!Test.isRunningTest() && description!=null){
  //         newdesc = description.stripHtmlTags();
  //         offering.PMP_Partner_Offering_Dsc__c = newdesc;
  //       }
  //       offeringlist.add(offering);
  //     }
  //     if (offeringlist.size() == 0){
  //       throw new AuraHandledException('No Records Found..');
  //     }
  //   }
  //   return offeringlist;
  // }

  /*
   Save Operation based on the record id passed and the offering list selected
   */
  // @AuraEnabled(cacheable = false)
  // public static String assetSaveOperation(Id recordid, List<PMP_Partner_Offering__c> selectedRecords){

  //   String result = '';
  //   Integer maxSizeName = Integer.valueOf(PMP_Utility.getValue('OfferingResourceNameMaxSize'));
  //   Integer descriptionMaxSize = Integer.valueOf(PMP_Utility.getValue('OfferingResourceDescMaxSize'));
  //   List<PMP_Rich_Media_Asset_Stage__c> richMediaAssetRecord = new List<PMP_Rich_Media_Asset_Stage__c>();
  //   List<PMP_Partner_Offering_Resource__c> richmediaresource = new List<PMP_Partner_Offering_Resource__c>();


  //   //Query the rich media asset record where the documents are present
  //   if (Schema.sObjectType.PMP_Rich_Media_Asset_Stage__c.isAccessible()){
  //     richMediaAssetRecord = [Select Id, Name, PMP_Added_On_Dt__c, PMP_Document_Description_Dsc__c, PMP_Document_Download_Path_url__c, PMP_Document_Id__c, PMP_Document_Name_Nm__c, PMP_Document_Path_Txt__c, PMP_Document_Type_Txt__c, PMP_Is_Retrieved_Ind__c, PMP_Partner_Name_Nm__c, PMP_Updated_On_Dt__c
  //                       from PMP_Rich_Media_Asset_Stage__c
  //                       Where Id = :recordid AND PMP_Is_Retrieved_Ind__c = true];
  //   }

  //   //the download url will be generated with the help of custom setting
  //   //String baseUrl = PMP_Utility.getValue('NetworkBuilderUrl');
  //   String completeUrl = richMediaAssetRecord[0].PMP_Document_Download_Path_url__c;

  //   //Query the content Document link attached to the rich media asset record
  //   List<ContentDocumentLink> conDocLinkList = new List<ContentDocumentLink>();
  //   if (Schema.sObjectType.ContentDocumentLink.isAccessible()){
  //     conDocLinkList = [Select Id, LinkedEntityId, ContentDocumentId, shareType
  //                 from ContentDocumentLink
  //                 Where LinkedEntityId = :recordid];
  //   }

  //   //this document will be attached to all the selected working copy offerings
  //   List<ContentDocumentLink> conDocLinkListOffering = new List<ContentDocumentLink>();
  //   Set<Id> uniqueOffIdSet = new Set<Id>();
  //   if (conDocLinkList.size() > 0){
  //     Id conDocId = conDocLinkList[0].ContentDocumentId;
  //     for (PMP_Partner_Offering__c p1 : selectedRecords){
  //       uniqueOffIdSet.add((Id) p1.PMP_Working_Copy_Id__c != null ? p1.PMP_Working_Copy_Id__c : p1.Id);
  //       uniqueOffIdSet.add((Id) p1.PMP_Published_Copy_Id_Txt__c != null ? (Id) p1.PMP_Published_Copy_Id_Txt__c : p1.Id);
  //     }

  //     for(Id offeringId:uniqueOffIdSet){
  //       ContentDocumentLink conDocLinkOffering = New ContentDocumentLink();
  //       conDocLinkOffering.LinkedEntityId = (Id) offeringId;
  //       conDocLinkOffering.ContentDocumentId = conDocId;
  //       conDocLinkOffering.shareType = 'V';
  //       conDocLinkOffering.Visibility = 'AllUsers';
  //       conDocLinkListOffering.add(conDocLinkOffering);
  //     }

  //     if (Schema.sObjectType.ContentDocumentLink.isCreateable() && Schema.sObjectType.ContentDocumentLink.IsUpdateable() && conDocLinkListOffering != null){
  //       upsert conDocLinkListOffering;
  //     }

  //     for (PMP_Partner_Offering__c sl : selectedRecords){

  //       //for published copy records
  //       PMP_Partner_Offering_Resource__c poffr2 = new PMP_Partner_Offering_Resource__c();
  //       poffr2.PMP_Offering_Id__c = sl.Id;
  //       if ((richMediaAssetRecord[0].PMP_Document_Name_Nm__c).length() > maxSizeName){
  //         poffr2.Name = (richMediaAssetRecord[0].PMP_Document_Name_Nm__c).substring(0, maxSizeName);
  //       } else{
  //         poffr2.Name = richMediaAssetRecord[0].PMP_Document_Name_Nm__c;
  //       }
  //       poffr2.PMP_Partner_Offering_Image__c = conDocId;
  //       poffr2.PMP_Partner_Offering_Resource_URL_Txt__c = completeUrl;
  //       if(richMediaAssetRecord[0].PMP_Document_Description_Dsc__c!=null) {
  //         if ((richMediaAssetRecord[0].PMP_Document_Description_Dsc__c).length() > descriptionMaxSize){
  //           poffr2.PMP_Resource_Description_Txt__c = offeringResourceDescriptionTurncate(richMediaAssetRecord[0].PMP_Document_Description_Dsc__c, descriptionMaxSize);
  //         } else {
  //           poffr2.PMP_Resource_Description_Txt__c = richMediaAssetRecord[0].PMP_Document_Description_Dsc__c;
  //         }
  //       } else {
  //         poffr2.PMP_Resource_Description_Txt__c = 'NA';
  //       }
  //       poffr2.PMP_Resource_Type_Nm__c = 'Additional Resources';
  //       poffr2.PMP_External_Source_Id__c = richMediaAssetRecord[0].PMP_Document_Id__c;
  //       richmediaresource.add(poffr2);

  //       //for working copy records
  //       PMP_Partner_Offering_Resource__c poffr = new PMP_Partner_Offering_Resource__c();
  //       poffr.PMP_Offering_Id__c = sl.PMP_Working_Copy_Id__c != null ? sl.PMP_Working_Copy_Id__c : sl.Id;
  //       if ((richMediaAssetRecord[0].PMP_Document_Name_Nm__c).length() > maxSizeName){
  //         poffr.Name = (richMediaAssetRecord[0].PMP_Document_Name_Nm__c).substring(0, maxSizeName);
  //       } else{
  //         poffr.Name = richMediaAssetRecord[0].PMP_Document_Name_Nm__c;
  //       }
  //       poffr.PMP_Partner_Offering_Image__c = conDocId;
  //       poffr.PMP_Partner_Offering_Resource_URL_Txt__c = completeUrl;
  //       if(richMediaAssetRecord[0].PMP_Document_Description_Dsc__c!=null) {
  //        if ((richMediaAssetRecord[0].PMP_Document_Description_Dsc__c).length() > descriptionMaxSize){
  //          poffr.PMP_Resource_Description_Txt__c = offeringResourceDescriptionTurncate(richMediaAssetRecord[0].PMP_Document_Description_Dsc__c, descriptionMaxSize);
  //        }  else{
  //          poffr.PMP_Resource_Description_Txt__c = richMediaAssetRecord[0].PMP_Document_Description_Dsc__c;
  //        }
  //       }  else {
  //         poffr.PMP_Resource_Description_Txt__c = 'NA';
  //       }
  //       poffr.PMP_Resource_Type_Nm__c = 'Additional Resources';
  //       poffr.PMP_External_Source_Id__c = richMediaAssetRecord[0].PMP_Document_Id__c;

  //       //criteria to check if the offering id field is same as above for published copy
  //       if (poffr2.PMP_Offering_Id__c != poffr.PMP_Offering_Id__c){
  //         richmediaresource.add(poffr);
  //       } else{
  //         //System.debug('The working copy id is null or not present');
  //       }
  //     }

  //     if (Schema.sObjectType.PMP_Partner_Offering_Resource__c.isCreateable() && richmediaresource.size() > 0){
  //       insert richmediaresource;
  //     }

  //     result = JSON.Serialize(conDocLinkListOffering);
  //   }
  //   //ContentAssetCreation(richmediaresource,conDocLinkList[0].ContentDocumentId);
  //   return result;
  // }

 /* public static String offeringResourceDescriptionTurncate(String richmediadescription, Integer descriptionMaxSize) {
    Integer turncatefromHere = 0;
    String updatedDescription = richmediadescription.substring(0, descriptionMaxSize);
    try {
      if (updatedDescription.right(1) == ' '){
        turncatefromHere = updatedDescription.lastIndexof(' ', (descriptionMaxSize - 1)); 
      } else{
        turncatefromHere = updatedDescription.lastIndexof(' ', descriptionMaxSize);  
      }
       if (turncatefromHere > (descriptionMaxSize - 3)){
        turncatefromHere = updatedDescription.lastIndexof(' ', (turncatefromHere-1));
        updatedDescription = richmediadescription.substring(0, turncatefromHere)+'...';
      } else{
        updatedDescription = richmediadescription.substring(0, turncatefromHere)+'...';
      }
    } catch (exception e) {
      PMP_Utility.logError(e,'PMP_RichMediaAssetController_RichmediaTruncate');
    }
    return updatedDescription;
  }*/

  /*
   Wrapper Object
   */
  public class CompanyResult{
    @AuraEnabled
    public String recordId;
    @AuraEnabled
    public String recordName;
  }
}