public with sharing class ips_GeminiController {
    
    private static final String PROJECT_ID =   'gcp-sales-dev-intel';
    private static final String SERVICE_ACCOUNT_EMAIL =   'ips-agent@gcp-sales-dev-intel.iam.gserviceaccount.com';
    private static final String API_KEY = 'AQ.Ab8RN6KVr24GCDAGHI7xFpCFjsAQo1ICZbvUHH6_nmimVYnE5g';
    private static final String ACCESS_TOKEN = 'ya29.a0AdMD6EiOLm3L3Iae8F48_H1CWXPDKawAONS7J9EZgU7L2jb7ayoErg8I_uSpfJhUeKibeUCVDg8zgeN0ZeXYijDRyWKxgwN5Cf4RazbDQIAaZeHB4syB-JHXm0U3vcF3PvDdf4-aZbgxRdqoaF_-1rfVAOE2TXaHVlWGb9lpqumz21bkojOxL2GiEYZ2yQh1kF01bobxYgE2cQaCgYKARsSARUSFQHGX2MiCzV9d92HUwoTr25iKUrSqg0213';

    @AuraEnabled
    public static String askGemini(
        String question,
        Id caseNumber
    ) {

        Case myCase = [
            SELECT
                Id,
                CaseNumber,
                Subject,
                CreatedDate,
                ClosedDate,
                Status,
                Description,
                Priority,
                Comments,
                Core_Issue_Description__c,
                Core_Closure_Comment__c,
                Core_IPS_email_text__c,
                Core_IPS_Product_name__c,
                Core_IPS_Case_Owner_Name__c,
                Core_IPS_Case_Owner_Email__c,
                Core_IPS_Internal_Note__c,
                Core_IPS_Problem_Statement__c,
                Core_IPS_Resolution__c,
                Core_IPS_Knowledge_Base_Link__c,
                Core_IPS_Project_Case__c,

                (
                    SELECT Core_IPS_Comment__c
                    FROM Case_RTFS__r
                ),

                (
                    SELECT
                        Core_File_Name__c,
                        Core_File_Description__c,
                        Core_File_Hyperlink__c
                    FROM IPS_Case_Attachments__r
                )

            FROM Case
            WHERE RecordType.Name IN (
                'IPS Case Create',
                'IPS Closed Case',
                'IPS No Assigned Contact Case'
            )
            AND Id = :caseNumber
            LIMIT 1
        ];

        List<Case> historicalCases = [
            SELECT
                Id,
                CaseNumber,
                Subject,
                Status,
                ClosedDate,
                Core_Issue_Description__c,
                Core_IPS_Problem_Statement__c,
                Core_IPS_Resolution__c,
                Core_Closure_Comment__c,
                Core_IPS_Knowledge_Base_Link__c,
                Core_IPS_Internal_Note__c,

                (
                    SELECT Core_IPS_Comment__c
                    FROM Case_RTFS__r
                )

            FROM Case
            WHERE RecordType.Name IN (
                'IPS Case Create',
                'IPS Closed Case',
                'IPS No Assigned Contact Case'
            )
            AND Status IN (
                'Closed',
                'Resolved'
            )
            AND Core_IPS_Product_name__c =
                :myCase.Core_IPS_Product_name__c
            AND Id != :myCase.Id
            ORDER BY ClosedDate DESC
            LIMIT 10
        ];

        List<Core_IPS_Project__c> projectList = [
            SELECT
                Id,
                Name,
                Core_IPS_Project_ID__c,
                Core_Project_Description__c
            FROM Core_IPS_Project__c
            WHERE Id = :myCase.Core_IPS_Project_Case__c
            AND IsDeleted = false
            WITH USER_MODE
        ];

        String rtfsComments = '';

        if (myCase.Case_RTFS__r != null) {

            for (SObject rtf : myCase.Case_RTFS__r) {

                rtfsComments +=
                    '- ' +
                    String.valueOf(
                        rtf.get(
                            'Core_IPS_Comment__c'
                        )
                    ) +
                    '\n';
            }
        }

        String attachments = '';

        if (
            myCase.IPS_Case_Attachments__r != null
        ) {

            for (
                SObject file :
                myCase.IPS_Case_Attachments__r
            ) {

                attachments +=
                    '- File Name: ' +
                    String.valueOf(
                        file.get(
                            'Core_File_Name__c'
                        )
                    ) +
                    '\n' +

                    '  Description: ' +
                    String.valueOf(
                        file.get(
                            'Core_File_Description__c'
                        )
                    ) +
                    '\n' +

                    '  Link: ' +
                    String.valueOf(
                        file.get(
                            'Core_File_Hyperlink__c'
                        )
                    ) +
                    '\n\n';
            }
        }

        String historicalCasesText = '';

        for (Case hc : historicalCases) {

            String historicalRTFS = '';

            if (hc.Case_RTFS__r != null) {

                for (
                    SObject r :
                    hc.Case_RTFS__r
                ) {

                    historicalRTFS +=
                        '- ' +
                        String.valueOf(
                            r.get(
                                'Core_IPS_Comment__c'
                            )
                        ) +
                        '\n';
                }
            }

            historicalCasesText +=
                'Case Number: ' +
                hc.CaseNumber +
                '\n' +

                'Subject: ' +
                hc.Subject +
                '\n' +

                'Status: ' +
                hc.Status +
                '\n' +

                'Closed Date: ' +
                String.valueOf(
                    hc.ClosedDate
                ) +
                '\n\n' +

                'Issue Description:\n' +
                String.valueOf(
                    hc.Core_Issue_Description__c
                ) +
                '\n\n' +

                'Problem Statement:\n' +
                String.valueOf(
                    hc.Core_IPS_Problem_Statement__c
                ) +
                '\n\n' +

                'Resolution:\n' +
                String.valueOf(
                    hc.Core_IPS_Resolution__c
                ) +
                '\n\n' +

                'Closure Comment:\n' +
                String.valueOf(
                    hc.Core_Closure_Comment__c
                ) +
                '\n\n' +

                'Knowledge Base:\n' +
                String.valueOf(
                    hc.Core_IPS_Knowledge_Base_Link__c
                ) +
                '\n\n' +

                'RTFS Comments:\n' +
                historicalRTFS +
                '\n---------------------------------\n\n';
        }

        String projectText = '';

        for (
            Core_IPS_Project__c p :
            projectList
        ) {

            projectText +=
                'Project Name: ' +
                p.Name +
                '\n' +

                'Project ID: ' +
                p.Core_IPS_Project_ID__c +
                '\n' +

                'Project Description:\n' +
                String.valueOf(
                    p.Core_Project_Description__c
                ) +
                '\n\n';
        }
                String emailText =
            String.valueOf(
                myCase.Core_IPS_email_text__c
            );

        if (
            emailText != null &&
            emailText.length() > 5000
        ) {

            emailText =
                emailText.substring(
                    0,
                    5000
                ) +
                '\n\n[Email thread truncated]';
        }

        String internalNotes =
            String.valueOf(
                myCase.Core_IPS_Internal_Note__c
            );

        if (
            internalNotes != null &&
            internalNotes.length() > 5000
        ) {

            internalNotes =
                internalNotes.substring(
                    0,
                    5000
                ) +
                '\n\n[Internal notes truncated]';
        }

        if (
            historicalCasesText != null &&
            historicalCasesText.length() > 50000
        ) {

            historicalCasesText =
                historicalCasesText.substring(
                    0,
                    50000
                ) +
                '\n\n[Historical cases truncated]';
        }

        String prompt =
            'You are a Senior IPS Support AI Assistant.\n\n' +

            '# Executive Summary\n' +
            'Provide 3-5 concise bullet points.\n\n' +

            '# Issue Analysis\n' +
            '## Problem\n' +
            '## Business Impact\n' +
            '## Current Status\n' +
            '## Root Cause (if known)\n\n' +

            '# Historical Similar Cases\n' +
            'Reference related cases and lessons learned.\n\n' +

            '# Recommended Next Actions\n' +
            'Provide numbered actionable recommendations.\n\n' +

            '# Risks and Blockers\n' +
            'List current risks.\n\n' +

            '# Customer Email Draft\n' +
            'Generate a professional customer-facing email that is ready to send.\n' +
            'Use a friendly and concise tone.\n\n' +

            '===== CURRENT CASE DETAILS =====\n\n' +

            'Case Number: ' +
            myCase.CaseNumber +
            '\n' +

            'Subject: ' +
            myCase.Subject +
            '\n' +

            'Status: ' +
            myCase.Status +
            '\n' +

            'Priority: ' +
            myCase.Priority +
            '\n' +

            'Created Date: ' +
            String.valueOf(
                myCase.CreatedDate
            ) +
            '\n' +

            'Closed Date: ' +
            String.valueOf(
                myCase.ClosedDate
            ) +
            '\n' +

            'Product Name: ' +
            myCase.Core_IPS_Product_name__c +
            '\n\n' +

            '===== CASE DESCRIPTION =====\n' +
            String.valueOf(
                myCase.Description
            ) +
            '\n\n' +

            '===== ISSUE DESCRIPTION =====\n' +
            String.valueOf(
                myCase.Core_Issue_Description__c
            ) +
            '\n\n' +

            '===== PROBLEM STATEMENT =====\n' +
            String.valueOf(
                myCase.Core_IPS_Problem_Statement__c
            ) +
            '\n\n' +

            '===== INTERNAL NOTES =====\n' +
            internalNotes +
            '\n\n' +

            '===== ENGINEER COMMENTS =====\n' +
            String.valueOf(
                myCase.Comments
            ) +
            '\n\n' +

            '===== RTFS COMMENTS =====\n' +
            rtfsComments +
            '\n\n' +

            '===== RESOLUTION =====\n' +
            String.valueOf(
                myCase.Core_IPS_Resolution__c
            ) +
            '\n\n' +

            '===== CLOSURE COMMENTS =====\n' +
            String.valueOf(
                myCase.Core_Closure_Comment__c
            ) +
            '\n\n' +

            '===== KNOWLEDGE BASE =====\n' +
            String.valueOf(
                myCase.Core_IPS_Knowledge_Base_Link__c
            ) +
            '\n\n' +

            '===== PROJECT DETAILS =====\n' +
            projectText +
            '\n\n' +

            '===== ATTACHMENTS =====\n' +
            attachments +
            '\n\n' +

            '===== HISTORICAL CASES =====\n' +
            historicalCasesText +
            '\n\n' +

            '===== CUSTOMER EMAIL THREAD =====\n' +
            emailText +
            '\n\n' +

            '===== USER REQUEST =====\n' +
            question;
            
            String endpoint2 =
            'https://generativelanguage.googleapis.com/v1beta/models/' +
            'gemini-2.5-flash:generateContent?key=' +
            EncodingUtil.urlEncode(
                API_KEY,
                'UTF-8'
            );

        String endpoint =
        'https://us-central1-aiplatform.googleapis.com/v1/' +
        'projects/' + PROJECT_ID +
        '/locations/us-central1/' +
        'publishers/google/models/' +
        'gemini-3.6-flash:generateContent';

        Map<String, Object> body =
            new Map<String, Object>{
                'contents' => new List<Object>{
                    new Map<String, Object>{
                        'parts' => new List<Object>{
                            new Map<String, Object>{
                                'text' => prompt
                            }
                        }
                    }
                }
            };

        HttpRequest req =  new HttpRequest();

        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader(
            'Authorization',
            'Bearer ' + ACCESS_TOKEN
        );
        req.setHeader(
            'Content-Type',
            'application/json'
        );
        req.setTimeout(120000);

        req.setBody(
            JSON.serialize(body)
        );

        HttpResponse res;

        try {

            Http http =
                new Http();

            res =
                http.send(req);

        } catch (Exception e) {

            throw new AuraHandledException(
                'Gemini callout failed: ' +
                e.getMessage()
            );
        }

        if (
            res.getStatusCode() != 200
        ) {

            throw new AuraHandledException(
                'Gemini Error: ' +
                res.getBody()
            );
        }

        Map<String, Object> responseMap =
            (Map<String, Object>)
            JSON.deserializeUntyped(
                res.getBody()
            );

        List<Object> candidates =
            (List<Object>)
            responseMap.get(
                'candidates'
            );

        if (
            candidates == null ||
            candidates.isEmpty()
        ) {

            throw new AuraHandledException(
                'No response returned from Gemini.'
            );
        }

        Map<String, Object> candidate =
            (Map<String, Object>)
            candidates[0];

        Map<String, Object> content =
            (Map<String, Object>)
            candidate.get(
                'content'
            );

        List<Object> parts =
            (List<Object>)
            content.get(
                'parts'
            );

        if (
            parts == null ||
            parts.isEmpty()
        ) {

            throw new AuraHandledException(
                'Gemini returned an empty response.'
            );
        }

        Map<String, Object> firstPart =
            (Map<String, Object>)
            parts[0];

        return (String)
            firstPart.get(
                'text'
            );
    }
}