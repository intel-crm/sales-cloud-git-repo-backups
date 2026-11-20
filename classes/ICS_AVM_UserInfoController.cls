public class ICS_AVM_UserInfoController {
    public String userDetails {get;set;}
    public String iv {get;set;}
   // public string  lang {get;set;}
    

   
    public ICS_AVM_UserInfoController() {
        User usr = [SELECT FirstName, LastName,Languagelocalekey , Email, FederationIdentifier FROM User WHERE Id =:UserInfo.getUserId()];// '0051J000004jIujQAE'
        system.debug('usr'+usr);
        userInfoWrapper wrapper = new userInfoWrapper();
        wrapper.firstName = usr.FirstName;
        wrapper.lastName = usr.LastName;
        wrapper.email = usr.Email;
        wrapper.uuid = usr.FederationIdentifier;
        wrapper.us_Lang = usr.LanguageLocaleKey;
        wrapper.isLoggedIn = 'true';
        
        if(usr.Languagelocalekey =='en_US'){
            Blob blobiv = Blob.valueOf('sixteencharslong');
            Blob key = EncodingUtil.convertFromHex('345a970527db7145325387f7447f4746bf29069fb0014e049eda83951282c7ed');
            Blob data = Blob.valueOf(JSON.serialize(wrapper));
            Blob encrypted = Crypto.encrypt('AES256', key, blobiv, data);
           // Blob blobUserLanguage = blob.valueOf(wrapper.us_Lang); 
            userDetails = EncodingUtil.convertToHex(encrypted);
            iv = EncodingUtil.convertToHex(blobiv);
            //lang = wrapper.us_Lang;
        }else{
            userDetails = 'undefined';
        }      
    }
    class userInfoWrapper {
        String firstName;
        String lastName;
        String isLoggedIn;
        String email;
        String uuid;
        String us_Lang;
    }
}