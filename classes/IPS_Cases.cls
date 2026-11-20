/*
================================================================================
Updated On  : 10/02/2026

Purpose:
--------
This REST API provides IPS Case details based on CaseNumber.

Key Features:
-------------
1. Retrieves Case details for IPS record types:
   - IPS Case Create
   - IPS Closed Case
   - IPS No Assigned Contact Case

2. Includes child relationship data:
   - Case_RTFS__r (Case comments / RTFS records)
   - IPS_Case_Attachments__r (Attachments metadata)

3. Returns ONLY fields that have values:
   - Excludes NULL fields from response
   - Produces clean JSON output

4. Handles:
   - Input validation
   - Access checks
   - Proper HTTP status codes
   - Error handling

API Endpoint:
-------------
GET /services/apexrest/ipscases?caseNumber=XXXX

================================================================================
*/

@RestResource(urlMapping='/ipscases/*')
global with sharing class IPS_Cases {

    /*
    ================================================================================
    Method Name : getIPSCases
    Description : Fetch IPS Case details including child records
    ================================================================================
    */
    @HttpGet
    global static void getIPSCases() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            // Read request parameter
            String caseNumber = req.params.get('caseNumber');

            // Validate input
            if (String.isBlank(caseNumber)) {
                sendResponse(res, 400, false, 'A Case Number is required', null);
                return;
            }

            // Check object access
            if (!Schema.sObjectType.Case.isAccessible()) {
                sendResponse(res, 400, false, 'Insufficient privileges to access IPS Cases', null);
                return;
            }
            
            // Check object access
            if (!Schema.sObjectType.Core_IPS_Project__c.isAccessible()) {
                sendResponse(res, 400, false, 'Insufficient privileges to access IPS Projects', null);
                return;
            }
            
            // Check object access
            if (!Schema.sObjectType.Core_IPS_Case_Comments__c.isAccessible()) {
                sendResponse(res, 400, false, 'Insufficient privileges to access IPS Comments', null);
                return;
            }
            
             // Check object access
            if (!Schema.sObjectType.Core_IPS_Case_Attachments__c.isAccessible()) {
                sendResponse(res, 400, false, 'Insufficient privileges to access IPS Attachments', null);
                return;
            }

            /*
            ================================================================================
            Query:
            - Fetch Case fields
            - Include child relationships: 
                Case_RTFS__r
                IPS_Case_Attachments__r
            ================================================================================
            */
            List<Case> caseList = [
                SELECT Id, CaseNumber, Subject, CreatedDate, ClosedDate, Status,
                    Description, 
                    Core_IPS_email_text__c,  
                    Core_IPS_Product_name__c,
                    Core_IPS_Case_Owner_Name__c,
                    Core_IPS_Case_Owner_Email__c,
                    //Core_IPS_External_Environment_Details__c,
                    //Core_IPS_Internal_Note__c,
                    Core_Severity__c,
                    Core_IPS_Problem_Statement__c,
                    Core_IPS_Resolution__c,
                    Core_IPS_Knowledge_Base_Link__c,
                    Core_IPS_Project_Case__c,

                    (SELECT Core_IPS_Comment__c, CreatedDate, CreatedBy_Name__c FROM Case_RTFS__r ORDER BY CreatedDate DESC LIMIT 15),

                    (SELECT Core_File_Name__c,
                            Core_File_Description__c,
                            Core_File_Hyperlink__c,
                            CreatedDate
                     FROM IPS_Case_Attachments__r ORDER BY CreatedDate DESC LIMIT 15)

                FROM Case 
                WHERE RecordType.Name IN (
                    'IPS Case Create',
                    'IPS Closed Case',
                    'IPS No Assigned Contact Case'
                )
                AND CaseNumber = :caseNumber
                WITH USER_MODE
                LIMIT 1
            ];

            Case c = caseList[0];
            
            /*
            ===============================================================================
            Historical Cases
            - Same Product
            - Closed/Resolved Cases
            - Exclude Current Case
            ===============================================================================
            */
            List<Case> historicalCases = [
                SELECT
                    Id,
                    CaseNumber,
                    Subject,
                    Status,
                    ClosedDate,
                    Description,
                    Core_IPS_Problem_Statement__c,
                    Core_IPS_Resolution__c,
                    Core_IPS_Knowledge_Base_Link__c,
                    //Core_IPS_Internal_Note__c,
                    Core_Severity__c,
                    (SELECT Core_IPS_Comment__c, CreatedDate, CreatedBy_Name__c FROM Case_RTFS__r ORDER BY CreatedDate DESC LIMIT 15)
                FROM Case
                WHERE RecordType.Name IN (
                    'IPS Case Create',
                    'IPS Closed Case',
                    'IPS No Assigned Contact Case'
                )
                AND Status IN ('Closed', 'Resolved')
                AND Core_IPS_Product_name__c = :c.Core_IPS_Product_name__c
                AND Core_Severity__c = :c.Core_Severity__c
                AND (ClosedDate = LAST_N_MONTHS:12 OR ClosedDate = TODAY)
                AND Subject != null
                AND Id != :c.Id
                WITH USER_MODE
                ORDER BY ClosedDate DESC
                LIMIT 30
            ];
                        
            /*
            ================================================================================
            Query: Fetch Projects of the case 
            ================================================================================
            */
            List<Core_IPS_Project__c> projectList = [
                SELECT Id, Core_IPS_Project_ID__c, Name, Core_Project_Description__c  
                FROM Core_IPS_Project__c 
                WHERE Id = :c.Core_IPS_Project_Case__c
 				AND IsDeleted= false
                WITH USER_MODE
                LIMIT 50
            ];
            

            /*
            ================================================================================
            Build Case Response Map - Only include fields with values (remove NULLs)
            ================================================================================
            */
            Map<String, Object> caseMap = filterNulls(new Map<String, Object>{
                'Id' => c.Id,
                'CaseNumber' => c.CaseNumber,
                'Subject' => c.Subject,
                'Status' => c.Status,
                'Description' => stripHtml(c.Description),
                'Date Created' => c.CreatedDate,
                'Date Closed' => c.ClosedDate,
                //'Closure Comment' => stripHtml(c.Core_Closure_Comment__c),
                'Email' => c.Core_IPS_email_text__c,
                'Product Name' => c.Core_IPS_Product_name__c,
                'Case Owner' => c.Core_IPS_Case_Owner_Name__c,
                'Case Owner Email' => c.Core_IPS_Case_Owner_Email__c,
                //'External Environment' => c.Core_IPS_External_Environment_Details__c,
                //'Internal Note' => c.Core_IPS_Internal_Note__c,
                'Severity' => c.Core_Severity__c,
                'Problem Statement' => c.Core_IPS_Problem_Statement__c,
                'Resolution' => c.Core_IPS_Resolution__c,
                'Knowledge Base Link' => c.Core_IPS_Knowledge_Base_Link__c,
                'Project Case' => c.Core_IPS_Project_Case__c
            });

            /*
            ================================================================================
            Process Case_RTFS__r (Generic SObject to avoid type errors)
            ================================================================================
            */
            List<Map<String, Object>> rtfsList = new List<Map<String, Object>>();

            if (c.Case_RTFS__r != null) {
                for (SObject r : c.Case_RTFS__r) {

                    Map<String, Object> rtfsMap = filterNulls(new Map<String, Object>{
                        'Comment' => (String) r.get('Core_IPS_Comment__c'),
                        'CreatedDate' => (Datetime) r.get('CreatedDate'),
                        'CreatedBy' => (String) r.get('CreatedBy_Name__c')
                    });

                    if (!rtfsMap.isEmpty()) {
                        rtfsList.add(rtfsMap);
                    }
                }
            }

            /*
            ================================================================================
            Process IPS_Case_Attachments__r
            ================================================================================
            */
            List<Map<String, Object>> attachmentsList = new List<Map<String, Object>>();

            if (c.IPS_Case_Attachments__r != null) {
                for (SObject a : c.IPS_Case_Attachments__r) {

                    Map<String, Object> attMap = filterNulls(new Map<String, Object>{
                        'File Name' => (String) a.get('Core_File_Name__c'),
                        'Description' => (String) a.get('Core_File_Description__c'),
                        'Link' => (String) a.get('Core_File_Hyperlink__c'),
                        'CreatedDate' => (Datetime) a.get('CreatedDate')
                    });

                    if (!attMap.isEmpty()) {
                        attachmentsList.add(attMap);
                    }
                }
            }
            
            /*
            ================================================================================
            Process Project (Generic SObject to avoid type errors)
            ================================================================================
            */
            List<Map<String, Object>> prjsList = new List<Map<String, Object>>();

            if (projectList != null) {
                for (SObject pr : projectList) {

                    Map<String, Object> prjMap = filterNulls(new Map<String, Object>{
                        'Project Id' => (String) pr.get('Core_IPS_Project_ID__c'),
                        'Name' => (String) pr.get('Name'),
                        'Project Description' => (String) pr.get('Core_Project_Description__c')
                    });

                    if (!prjMap.isEmpty()) {
                        prjsList.add(prjMap);
                    }
                }
            }
            

            // Add child data only if present
            if (!rtfsList.isEmpty()) {
                caseMap.put('Case_RTFS', rtfsList);
            }
			
            if (!attachmentsList.isEmpty()) {
                caseMap.put('Attachments', attachmentsList);
            }
            
			if (!prjsList.isEmpty()) {
                caseMap.put('Projects', prjsList);
            }
            
            /*
            ===============================================================================
            Process Historical Cases
            ===============================================================================
            */
            List<Map<String, Object>> historicalCaseList = new List<Map<String, Object>>();
            String orgUrl = URL.getOrgDomainURL().toExternalForm();
            
            for (Case hc : historicalCases) {
            
                List<String> historicalComments = new List<String>();
            
                if (hc.Case_RTFS__r != null) {
                    for (SObject rtfs : hc.Case_RTFS__r) {
            
                        String comment =
                            (String)rtfs.get('Core_IPS_Comment__c');
            
                        if (!String.isBlank(comment)) {
                            historicalComments.add(comment);
                        }
                    }
                }
                
                historicalCaseList.add(
                    filterNulls(
                        new Map<String, Object>{
                            'Case Number' => hc.CaseNumber,
                            'Subject' => hc.Subject,
                            'Status' => hc.Status,
                            'Closed Date' => hc.ClosedDate,
                            'Severity' =>  hc.Core_Severity__c,
                            /* Historical Case Context */
                            'Description' => c.Description,
                            'Problem Statement' => hc.Core_IPS_Problem_Statement__c,
            
                            /* Resolution Knowledge */
                            'Resolution' => hc.Core_IPS_Resolution__c,
                            //'Closure Comment' => hc.Core_Closure_Comment__c,
                            'Knowledge Base Link' => hc.Core_IPS_Knowledge_Base_Link__c,
            
                            /* Key Statements */
                            //'Internal Note' => hc.Core_IPS_Internal_Note__c,
                            'RTFS Comments' => historicalComments,
                            'Case URL' => orgUrl + '/lightning/r/Case/'+ hc.Id +'/view'
                        }
                    )
                );
            }      
            
            /*
            ===============================================================================
            Final Response
            ===============================================================================
            */
            Map<String, Object> responseMap = new Map<String, Object>{
                'success' => true,
                'case' => caseMap
            };
            
            /*
            ===============================================================================
            Add Historical Cases Only If Found
            ===============================================================================
            */
            if (!historicalCaseList.isEmpty()) {
                responseMap.put('historicalCases', historicalCaseList);
            }

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));

        } catch (Exception e) {
            // Generic error handling
            sendResponse(res, 500, false, 'An error occurred while processing your request : ' + e, null);
        }
    }

    /*
    ================================================================================
    Utility Method: filterNulls
    Purpose: Removes fields with NULL values from response map
    ================================================================================
    */
    private static Map<String, Object> filterNulls(Map<String, Object> inputMap) {
        Map<String, Object> output = new Map<String, Object>();

        for (String key : inputMap.keySet()) {
            if (inputMap.get(key) != null) {
                output.put(key, inputMap.get(key));
            }
        }
        return output;
    }

    /*
    ================================================================================
    Utility Method: sendResponse
    Purpose: Standardized API response structure
    ================================================================================
    */
    private static void sendResponse(RestResponse res,
                                     Integer status,
                                     Boolean success,
                                     String message,
                                     Object data) {

        Map<String, Object> resp = new Map<String, Object>{
            'success' => success,
            'message' => message
        };

        if (data != null) {
            resp.put('data', data);
        }

        res.statusCode = status;
        res.responseBody = Blob.valueOf(JSON.serialize(resp));
    }
    
    //strip the HTML before adding it to caseMap
    private static String stripHtml(String input) {
    if (String.isBlank(input)) {
        return input;
    }
    return input.replaceAll('<[^>]*>', '');
}
}