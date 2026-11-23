public class Sales_SplitMergeDynamicLinkCreation {
   /*public class SplitMergeInput {
        @InvocableVariable
        public String licenseId;			
        @InvocableVariable
        public String contactId; 
    
    }
    
    public class SplitMergeOutput {
        @InvocableVariable
        public String mergeSeatLink;	
        @InvocableVariable
        public String splitSeatLink;
    }
    
    @InvocableMethod(label='Generate License record dynamic link')
     public static List<SplitMergeOutput> generateLicenseLink(List<SplitMergeInput> inputData){
          List<SplitMergeOutput> outputData = new List<SplitMergeOutput>();
        Boolean result;
        //Dynamically Fetching the URL of Community
        Network psgQuotingLicensing = [SELECT Id, Name, UrlPathPrefix FROM Network where Name =: (System.Label.Sales_Community_Name) Limit 1];
        String pageURL = Network.getLoginUrl(psgQuotingLicensing.Id).removeEndIgnoreCase('login') + 'detail/';  
         for(SplitMergeInput input : inputData) {
               SplitMergeOutput output = new SplitMergeOutput();
             if(input.licenseId!=null){
                 output.mergeSeatLink=pageURL + input.licenseId+'?license=merge';
                  output.splitSeatLink=pageURL + input.licenseId+'?license=split';       
             }
              outputData.add(output);
         }
         return outputData;
    }*/
}