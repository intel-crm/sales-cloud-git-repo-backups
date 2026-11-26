global with sharing class IPS_Support_CopilotHandler {
    
    global ResponseWrapper getCasesForUser(RestRequest req) {
        
        /**Checking user and required parameters**/
        String clientId = req == null || req.headers == null ? null : req.headers.get('client_id');
        
        String email = req == null || req.params == null ? null : req.params.get('email').trim();
        
        String accountName = req == null || req.params == null ? null : req.params.get('accountName').trim();
        
        String oauthUserId = req == null || req.params == null ? null : req.params.get('oauth');
        
        if (String.isBlank(email)) {
            
            return errorResponse(400, 'The email parameter is required.', clientId);
            
        }
        
        email = email.trim();
         List<Case> caseRecords;
        
        try {
            
            String loggedInEmail = UserInfo.getUserEmail();
            
            Boolean emailMatchesLoggedInUser =
                
                !String.isBlank(loggedInEmail) &&
                
                email.equalsIgnoreCase(loggedInEmail);
            
            if (!emailMatchesLoggedInUser) {
                
                List<User> matchingUsers = [SELECT Id FROM User WHERE Email = :email AND IsActive = true WITH SYSTEM_MODE LIMIT 1 ];
                
                if (matchingUsers.isEmpty()) {
                    
                    // The oauth parameter is treated as a Salesforce user ID,
                    
                    // and must match the authenticated Salesforce user.
                    
                    if (String.isBlank(oauthUserId) || oauthUserId != String.valueOf(UserInfo.getUserId())) {
                            
                            throw new InvalidUserException('The email does not match an active user.');
                            
                        }
                    
                }
                
                if(accountName != null){
                    List<Contact> userContact = [select id, Name, AccountId, Account.Name, email from Contact where Email =: email WITH USER_MODE LIMIT 1 ];
                    Boolean hasAccessToAccount = userContact[0].Account.Name == accountName ? true : false;
                    if(!hasAccessToAccount){ 
                        throw new NoAccessToAccountCasesException('Cases for the mentioned account are not accessible to the logged-in user.');
                    }
                    else {
                        try{
                           caseRecords =  [SELECT Id, CaseNumber, Status, Core_Sub_Status__c,Subject, CreatedDate, LastModifiedDate FROM Case WHERE AccountId = :userContact[0].AccountId WITH USER_MODE ORDER BY CreatedDate DESC];
                        } catch(Exception ex){
                            throw new NoAccessToAccountCasesException('No cases found for the account');
                        }
                	}
                } 
                
            }
            
            
            try {
                
                caseRecords = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c,Subject, CreatedDate, LastModifiedDate FROM Case WHERE Contact.Email = :email WITH USER_MODE ORDER BY CreatedDate DESC];
                
            } catch (QueryException ex) {
                
                throw new CasesNotAccessibleException(
                    
                    'Cases are not accessible to the logged-in user.'
                    
                );
                
            }
            
            List<CaseWrapper> caseDetails = new List<CaseWrapper>();
            
            String orgUrl = URL.getOrgDomainUrl().toExternalForm();
            
            for (Case caseRecord : caseRecords) {
                
                String caseUrl = orgUrl + '/lightning/r/Case/' + caseRecord.Id + '/view';
                
                caseDetails.add(new CaseWrapper(caseRecord.CaseNumber,caseRecord.Status,caseRecord.Core_Sub_Status__c, caseRecord.Subject,caseRecord.CreatedDate, caseUrl,caseRecord.LastModifiedDate));
                
            }
            
            return new ResponseWrapper(200,true,caseDetails,null,clientId);
            
        } catch (CasesNotAccessibleException ex) {
            
            return errorResponse(403, ex.getMessage(), clientId);
            
        } catch (InvalidUserException ex) {
            
            return errorResponse(401, ex.getMessage(), clientId);
            
        } 
        catch (NoAccessToAccountCasesException ex) {
            
            return errorResponse(401, ex.getMessage(), clientId);
            
        } catch (Exception ex) {
            
            return errorResponse(500, 'Unable to retrieve cases.',clientId );          
		}
        
    }
    
    global ResponseWrapper createCaseFromCopilot(RestRequest req){
        //get caseInputJson from request and process to create a case 
        return null;
    }
    
    private static ResponseWrapper errorResponse(Decimal code,String message, String clientId) {
        
        return new ResponseWrapper(code, false, null, message, clientId);
        
    }
    
    global class ResponseWrapper {        
        global Decimal Code;
        global Boolean IsSuccess;
        global List<CaseWrapper> Cases;
        global String ErrorMessage;
        global String ClientId;
        global ResponseWrapper(Decimal code, Boolean isSuccess, List<CaseWrapper> cases, String errorMessage, String clientId) {
                                  Code = code;
                                  IsSuccess = isSuccess;
                                  Cases = cases;
                                  ErrorMessage = errorMessage;
                                  ClientId = clientId;                                  
                              }        
    }
    
    global class CaseWrapper {
        global String CaseNumber;
        global String Status;
        global String SubStatus;
        global String Subject;
        global Datetime CreatedDate;
        global String CaseUrl;        
        global Datetime LastModifiedDate;
        
        global CaseWrapper(String caseNumber,String status,String subStatus, String subject, Datetime createdDate,String caseUrl, Datetime lastModifiedDate) 
		  {
            CaseNumber = caseNumber;
            Status = status;
            SubStatus = subStatus;
            Subject = subject;
            CreatedDate = createdDate;
            CaseUrl = caseUrl;
            LastModifiedDate = lastModifiedDate;
        }
        
    }
    
    global class CasesNotAccessibleException extends Exception {}
    
    global class InvalidUserException extends Exception {}
    
    global class NoAccessToAccountCasesException extends Exception {}
    
}