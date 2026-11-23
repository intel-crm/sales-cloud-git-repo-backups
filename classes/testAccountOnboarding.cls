public class testAccountOnboarding {

    Public Static Account acc ;
    public Static ChannelProgram cp;
    
    public static void testonboarding(List<PDF_Conversion_POC__c> pc){
        Set<id> accids = new Set<id>();
        Set<id> channelids = new Set<id>();
        for(PDF_Conversion_POC__c poc : pc){
            accids.add(poc.Account__c);
            channelids.add(poc.Channel_Program__c);
        }
        system.debug('accid'+accids);
        system.debug('channelids'+channelids);
         acc =[select id,Name from Account where id IN :accids];
        cp = [select id,Core_MDF_Technical_Program_Name__c from ChannelProgram where id IN :channelids];
        System.debug('@@'+acc);
        system.debug('##'+cp);
        List<Core_MDF_CCPAccountOnboardWrapper> pcs = new List<Core_MDF_CCPAccountOnboardWrapper>();
        for(PDF_Conversion_POC__c pocs : pc){
            Core_MDF_CCPAccountOnboardWrapper ccpwrapper = new Core_MDF_CCPAccountOnboardWrapper();
            ccpwrapper.account = acc;
            ccpwrapper.program = cp.Core_MDF_Technical_Program_Name__c;
            pcs.add(ccpwrapper);
        }
        Core_MDF_CCPAccount_Onboard.onboardAccountToCCP(pcs);
        System.debug('wrapper' +pcs);
        
    }
}