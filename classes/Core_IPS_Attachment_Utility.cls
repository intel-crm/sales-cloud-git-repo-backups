public without sharing class Core_IPS_Attachment_Utility {
    public static String setURL(String params, String backendType, String backendId) {
        String URL = '';
        try{
            List<String> strList = params.split('/download/');
            String firstPart = '';
            String secondPart = '';
            if(strList.size()>0){
                firstPart = strList[0];
                secondPart = strList[1].replace('IPS_SFT', backendType);
                URL = firstPart + '/download/' + secondPart;
            }
            List<String> strList1 = URL.split('AppData=');
            String firstString = '';
            String secondString = '';
            if(strList1.size()>0){
                firstString = strList1[0]; 
                secondString =  backendId;
                URL = firstString + 'AppData=' + secondString;
            }

        }catch(Exception e){
        }
        return URL;
    }
}