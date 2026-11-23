/*************************************************************************************************************************************************************************
* Class Name  : Intel_Uploader 
* Version     : 1.0 
* Created Date: 4/25/2019
* Modification Log : Original Version
* Description : This wrapper class is used in Create Offering functionality. Used in MarketplaceCreateProductController.Apex 
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************************************************/
// FILE UPLOADER - https://developer.salesforce.com/docs/component-library/bundle/lightning:fileUpload
public class Intel_Uploader extends Intel_Input {
      { type = 'uploader'; }
      public String recordIdForUpload { get; set; }
    }