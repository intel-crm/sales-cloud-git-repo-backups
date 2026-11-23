public class AccountFuzzyMatchProcessor {

    // ============================================
    // REQUEST & RESULT CLASSES
    // ============================================
    
    public class ProcessRequest {
        @InvocableVariable(
            required=true 
            label='Parsed Data JSON')
        public String parsedDataJson;
        
        @InvocableVariable(
            required=true 
            label='Column Mapping JSON')
        public String columnMappingJson;
        
        @InvocableVariable(label='Fuzzy Threshold')
        public Integer fuzzyThreshold;
        
        @InvocableVariable(label='Task Subject Prefix')
        public String taskSubjectPrefix;
        
        @InvocableVariable(label='Task Due Days')
        public Integer taskDueDays;
    }
    
    public class ProcessResult {
        @InvocableVariable(label='Tasks Created Count')
        public Integer tasksCreated;
        
        @InvocableVariable(label='Not Found JSON')
        public String notFoundJson;
        
        @InvocableVariable(label='Not Found Count')
        public Integer notFoundCount;
        
        @InvocableVariable(label='Not Found List String')
        public String notFoundListString;
        
        @InvocableVariable(label='Is Success')
        public Boolean isSuccess;
        
        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }

    // ============================================
    // MAIN INVOCABLE METHOD
    // ============================================
    
    @InvocableMethod(
        label='Fuzzy Match Accounts and Create Tasks'
        description='Matches companies and creates tasks'
        category='Excel Import'
    )
    public static List<ProcessResult> processRecords(
        List<ProcessRequest> requests) {
        
        List<ProcessResult> results = 
            new List<ProcessResult>();
        ProcessResult result = new ProcessResult();
        
        try {
            ProcessRequest req = requests[0];
            
            // Set defaults
            Integer threshold = 
                req.fuzzyThreshold != null ? 
                req.fuzzyThreshold : 75;
            String subjectPrefix = 
                String.isNotBlank(req.taskSubjectPrefix) ?
                req.taskSubjectPrefix : 'Product Follow-up';
            Integer dueDays = 
                req.taskDueDays != null ? 
                req.taskDueDays : 7;
            
            // Step 1: Deserialize inputs
            List<Object> rawData = 
                (List<Object>)JSON.deserializeUntyped(
                    req.parsedDataJson);
            Map<String,Object> colMapping = 
                (Map<String,Object>)JSON.deserializeUntyped(
                    req.columnMappingJson);
            
            // Step 2: Get column names
            String companyCol = 
                (String)colMapping.get('company_name');
            String productCol = 
                (String)colMapping.get('product');
            String ownerEmailCol = 
                (String)colMapping.get('owner_email');
            String notesCol = 
                (String)colMapping.get('notes');
            
            // Step 3: Load all accounts - single SOQL
            List<Account> allAccounts = [
                SELECT Id, Name, OwnerId, 
                       Owner.Email, Owner.Name
                FROM Account 
                WHERE IsDeleted = false
            ];
            
            // Step 4: Process each row
            List<Task> tasksToCreate = new List<Task>();
            List<String> notFoundList = new List<String>();
            
            for(Object rowObj : rawData) {
                Map<String,Object> row = 
                    (Map<String,Object>)rowObj;
                
                String companyName = 
                    (String)row.get(companyCol);
                String product = 
                    productCol != null ? 
                    (String)row.get(productCol) : '';
                String notes = 
                    notesCol != null ? 
                    (String)row.get(notesCol) : '';
                    
                if(String.isBlank(companyName)) continue;
                
                // Step 5: Fuzzy match
                MatchResult matchResult = fuzzyMatch(
                    companyName, 
                    allAccounts, 
                    threshold
                );
                
                if(matchResult.account != null) {
                    Task t = new Task();
                    t.WhatId = matchResult.account.Id;
                    t.OwnerId = matchResult.account.OwnerId;
                    t.Subject = subjectPrefix + ': ' + product;
                    t.Description = 
                        'Imported Company: ' + companyName + '\n' +
                        'Product: ' + product + '\n' +
                        'Notes: ' + notes + '\n' +
                        'Matched To: ' + 
                            matchResult.account.Name + '\n' +
                        'Match Score: ' + 
                            matchResult.score + '%';
                    t.Status = 'Not Started';
                    t.Priority = 'Normal';
                    t.ActivityDate = 
                        Date.today().addDays(dueDays);
                    tasksToCreate.add(t);
                } else {
                    notFoundList.add(companyName);
                }
            }
            
            // Step 6: Insert tasks
            if(!tasksToCreate.isEmpty()) {
                insert tasksToCreate;
            }
            
            // Step 7: Build results
            result.tasksCreated = tasksToCreate.size();
            result.notFoundJson = 
                JSON.serialize(notFoundList);
            result.notFoundCount = notFoundList.size();
            result.isSuccess = true;
            
            // Format for email
            String notFoundStr = '';
            for(Integer i = 0; i < notFoundList.size(); i++) {
                notFoundStr += (i+1) + '. ' + 
                    notFoundList[i] + '\n';
            }
            result.notFoundListString = notFoundStr;
            
        } catch(Exception e) {
            result.isSuccess = false;
            result.errorMessage = e.getMessage();
        }
        
        results.add(result);
        return results;
    }

    // ============================================
    // FUZZY MATCH
    // ============================================
    
    private class MatchResult {
        public Account account;
        public Integer score;
        public MatchResult(Account a, Integer s) {
            this.account = a;
            this.score = s;
        }
    }
    
    private static MatchResult fuzzyMatch(
        String searchName,
        List<Account> accounts,
        Integer threshold) {
        
        Account bestMatch = null;
        Integer bestScore = 0;
        String normalizedSearch = normalize(searchName);
        
        for(Account acc : accounts) {
            String normalizedAcc = normalize(acc.Name);
            Integer score = 0;
            
            // Exact match
            if(normalizedSearch == normalizedAcc) {
                score = 100;
            }
            // Contains match
            else if(normalizedAcc.contains(normalizedSearch) 
                || normalizedSearch.contains(normalizedAcc)) {
                score = 90;
            }
            // Levenshtein similarity
            else {
                score = levenshteinSimilarity(
                    normalizedSearch, normalizedAcc);
            }
            
            if(score > bestScore) {
                bestScore = score;
                bestMatch = acc;
            }
        }
        
        if(bestScore >= threshold) {
            return new MatchResult(bestMatch, bestScore);
        }
        return new MatchResult(null, 0);
    }
    
    private static String normalize(String input) {
        if(input == null) return '';
        String s = input.toLowerCase().trim();
        s = s.replaceAll(
            '\\b(inc|llc|ltd|corp|co|company|limited)\\b','');
        s = s.replaceAll('[^a-z0-9 ]', '');
        s = s.replaceAll('\\s+', ' ').trim();
        return s;
    }
    
    private static Integer levenshteinSimilarity(
        String s1, String s2) {
        Integer maxLen = Math.max(s1.length(), s2.length());
        if(maxLen == 0) return 100;
        Integer distance = levenshteinDistance(s1, s2);
        Decimal sim = 
            ((maxLen - distance) / (Decimal)maxLen) * 100;
        return sim.intValue();
    }
    
    private static Integer levenshteinDistance(
        String s1, String s2) {
        Integer m = s1.length();
        Integer n = s2.length();
        List<Integer> prev = new List<Integer>();
        List<Integer> curr = new List<Integer>();
        
        for(Integer j = 0; j <= n; j++) prev.add(j);
        
        for(Integer i = 1; i <= m; i++) {
            curr = new List<Integer>();
            curr.add(i);
            for(Integer j = 1; j <= n; j++) {
                Integer cost = 
                    s1.substring(i-1,i) == 
                    s2.substring(j-1,j) ? 0 : 1;
                curr.add(Math.min(
                    curr[j-1] + 1,
                    Math.min(
                        prev[j] + 1,
                        prev[j-1] + cost
                    )
                ));
            }
            prev = curr;
        }
        return prev[n];
    }
}