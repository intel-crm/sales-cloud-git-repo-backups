public with sharing class testcontrollerISVC {

public testcontrollerISVC(){
system.debug('test construuctor');
//signInRedirect();
}
public PageReference signInRedirect(){ 
        PageReference signInPage=null;
        system.debug('test');
        String relayString = '/?lang=en-US';
        //String relayString = '/servicecenter?lang=en-US';
        relayString = EncodingUtil.urlEncode(relayString, 'UTF-8');
  //Pyxis: added '&' instead of '?' 
        //signInPage = new PageReference('https://consumer.intel.com/intelcorpb2c.onmicrosoft.com/B2C_1A_UNIFIEDLOGIN_SISU_PSC_SAML/generic/login?entityId=https://isvc.my.salesforce.com&RelayState='+relayString);
        //signInPage.setRedirect(true);
        return signInPage;
    }
}