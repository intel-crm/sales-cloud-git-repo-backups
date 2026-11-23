public without sharing class Sales_DynamicUrlCreation {
    public class ChatbotInput {
        @InvocableVariable
        public String statusVariable;      
    }
    public class ChatbotOutput {
        @InvocableVariable
        public String outputUrl;
        @InvocableVariable
        public String Sales_Signupevaluationurl;
        @InvocableVariable
        public String Sales_IPS_How_to_Link;
        @InvocableVariable
        public String Sales_Qnaurl;
        @InvocableVariable
        public String Sales_Installationurl;
        @InvocableVariable
        public String Sales_FAQurl;
        @InvocableVariable
        public String Sales_newadminurl;
        @InvocableVariable
        public String Sales_activecomputerurl;
        @InvocableVariable
        public String Sales_maintanceurl;
        @InvocableVariable
        public String Sales_ActivationCode_Cancle_Navurl;
        @InvocableVariable
        public String Sales_Frequently_asked_questions;
        @InvocableVariable
        public String Salese_Rnewal_Add_Seat_License_Link;
        @InvocableVariable
        public String Sales_FGPA_Installation;
        @InvocableVariable
        public String Sales_contact_your_distributor;
        @InvocableVariable
        public String Sales_30_day_trial_license;
        @InvocableVariable
        public String Sales_Quartus_II_Web_edition;
         @InvocableVariable
        public String Sales_Maxplus_II_license;
        @InvocableVariable
        public string Sales_Intel;
          @InvocableVariable
        public string Sales_URL_IPS_User;
         @InvocableVariable
        public string Sales_LicenseQuartus;
    }
    @InvocableMethod(label='Update dynamic URL')
    public static List<ChatbotOutput> generateUrl(List<ChatbotInput> inputData){
        List<ChatbotOutput> outputData = new List<ChatbotOutput>();
        for(ChatbotInput input : inputData) {
            ChatbotOutput output = new ChatbotOutput();
            output.outputUrl=System.Label.Sales_Supporturl;
            output.Sales_Signupevaluationurl=System.Label.Sales_Signupevaluation;
            output.Sales_IPS_How_to_Link=System.Label.Sales_IPS_How_to_Link;
            output.Sales_Qnaurl=System.Label.Sales_Qna; 
            output.Sales_Installationurl=System.Label.Sales_Installation;
            output.Sales_FAQurl=System.Label.Sales_FAQ;
            output.Sales_newadminurl=System.Label.Sales_newadmin;
            output.Sales_activecomputerurl=System.Label.Sales_activecomputer;
            output.Sales_maintanceurl=System.Label.Sales_maintance;
            output.Sales_ActivationCode_Cancle_Navurl=System.Label.Sales_ActivationCode_Cancle_Nav;
            
            output.Sales_Frequently_asked_questions=System.Label.Sales_Frequently_asked_questions;
            output.Salese_Rnewal_Add_Seat_License_Link=System.Label.Salese_Rnewal_Add_Seat_License_Link;
            output.Sales_FGPA_Installation=System.Label.Sales_FGPA_Installation;
            output.Sales_contact_your_distributor=System.Label.Sales_contact_your_distributor;
            output.Sales_30_day_trial_license=System.Label.Sales_30_day_trial_license;
            output.Sales_Quartus_II_Web_edition=System.Label.Sales_Quartus_II_Web_edition;
            output.Sales_Maxplus_II_license=System.Label.Sales_Maxplus_II_license;
            output.Sales_Intel=System.Label.Sales_Intel;
            output.Sales_URL_IPS_User=System.Label.Sales_URL_IPS_User;
            output.Sales_LicenseQuartus=System.Label.Sales_LicenseQuartus;
                outputData.add(output);
        }
        return outputData;
    }
}