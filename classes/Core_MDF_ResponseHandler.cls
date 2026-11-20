/************************************************************************************
 class Name 		: Core_MDF_ResponseHandler
 Change History:
---------------------------------------------------------------------------------------
 #CH	Changes By 		 Date			Change Description
--------------------------------------------------------------------------------------
  1. 	Anish 			 09/7/2021		Added changes for IPA 
************************************************************************************/
public class Core_MDF_ResponseHandler {
    @AuraEnabled public Boolean isSuccess;
    @AuraEnabled public String responseMessage;
    @AuraEnabled public PartnerFundRequest pfr;
    @AuraEnabled public List<PartnerFundRequest> pfrList;

    public Core_MDF_ResponseHandler(Boolean isSuccess, String responseMessage, List<PartnerFundRequest> pfrList){
        this.isSuccess = isSuccess;
        this.responseMessage = responseMessage;
        this.pfrList = pfrList;  
    }

}