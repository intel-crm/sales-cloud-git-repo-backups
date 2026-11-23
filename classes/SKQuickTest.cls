public class SKQuickTest {
    public static void quickTest(){
        String jsonInput = '{"caseDetail":{"status":"close"}}';
        String jsonInput2 = '{"caseDetail":{"SeverityReason":null,"endCustomer":null,"customerReferenceId":null,"caseType":"Question","subject":"Case udpate api testing","caseSeverity":"Low","caseDescription":"API testing ","caseCategoryId":"","subCategoryId":"","envDetails":[{"envDetQuestion":"Found In Build","envDetQuestionId":"AEV-00019025","answers":[{"answer":"update Dev testing"}]},{"envDetQuestion":"Hardware","envDetQuestionId":"AEV-00019028","answers":[{"answer":"Sandy Peak (3168) "},{"answer":"Jackson Peak 2 (6235) "}]},{"envDetQuestion":"Platforms","envDetQuestionId":"AEV-00019032","answers":[{"answer":"Unassigned"},{"answer":"Alder Lake"}]},{"envDetQuestion":"Operating System","envDetQuestionId":"AEV-00019035","answers":[{"answer":"Unassigned "},{"answer":"Android M "}]},{"envDetQuestion":"OEM","envDetQuestionId":"AEV-00019495","answers":[{"answer":"ACE"}]}]}}';
        
        Map<String, Object> json = (Map<String, Object>) JSON.deserializeUntyped(jsonInput2);
        System.debug(' json '+json);
        Map<String, Object> caseDetail =  (Map<String, Object>) json.get('caseDetail');
        System.debug(' caseDetail '+caseDetail);
        System.debug(' caseDetail '+caseDetail.size());
        
        
        
        
        
    }
    
    
    
}