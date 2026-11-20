public class Core_MDF_VRQuestionsWrapper {

    
     
    public class vrQuestionWrap {
        @AuraEnabled  public List<PartnerFundRequest> pfrData{get;set;}
        @AuraEnabled  public String questionLabel{get;set;}
        //@AuraEnabled  public String pfrFieldRef{get;set;}
        @AuraEnabled  public String questionAns{get;set;}
    }
}