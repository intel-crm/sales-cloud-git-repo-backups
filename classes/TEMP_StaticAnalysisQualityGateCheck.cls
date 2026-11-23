public class TEMP_StaticAnalysisQualityGateCheck {

    void testMethod1() {
        List<Account> accts = [select Id, Name from Account limit 10];
        List<Contact> conts = new List<Contact>();
        for (Account acct : accts) {
            Contact c = [select Id, Email from Contact where AccountId = :acct.Id limit 1][0];
            conts.add(c);
        }
        System.debug('### accts: ' + accts);
        System.debug('### conts: ' + conts);
    }

}