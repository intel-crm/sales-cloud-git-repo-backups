@IsTest(SeeAllData=false)
private class Core_MDF_PFR_ActivityActionAPI_Test {
    private static final String ENDPOINT =
        '/services/apexrest/v1.0/partnercenter/activityactions/';

    @TestSetup
    static void setupData() {
        User apiTestUser = Core_MDF_CCP_TestDataUtility.createUser(true);
        System.runAs(apiTestUser) {
            try {
                Core_MDF_CCP_TestDataUtility.byPassFeature(
                    new List<String>{
                        'BypassCampaignBenefitValidation',
                        'Core_MDF_Bypass_Manual_Share',
                        'Bypass_MDF_Budget_Access',
                        'Bypass_MDF_Budget_Access_Validation',
                        'Bypass_ValidateActivityWithCampaign',
                        'Core_MDF_beforeInsertIUPGM',
                        'Core_MDF_beforeUpdateIUPGM'
                    },
                    true,
                    true
                );
            } catch (Exception ignored) {
            }

            ChannelProgram program = Core_MDF_CCP_TestDataUtility.createProgram(
                'Client', 'Client CoMarketing Fund', true
            );
            Account intelAccount =
                Core_MDF_CCP_TestDataUtility.createIntelAccount(
                    'Activity API Intel Account',
                    Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type,
                    true
                );
            Account partnerAccount =
                Core_MDF_CCP_TestDataUtility.createCoMarketingAccount(
                    'Activity API Partner Account',
                    program.Id,
                    Core_MDF_CCP_TestDataUtility.Account_Record_Type,
                    intelAccount.Id,
                    true
                );

            Campaign campaign = new Campaign(
                Name = 'Activity API Test Campaign',
                Core_MDF_Program__c = 'Client CoMarketing Fund',
                Status = 'Draft',
                Core_MDF_Account__c = partnerAccount.Id,
                RecordTypeId = Schema.SObjectType.Campaign
                    .getRecordTypeInfosByDeveloperName()
                    .get('Core_MDF_Client_CoMarketing_Fund')
                    .getRecordTypeId(),
                StartDate = Date.today(),
                EndDate = Date.today().addDays(30),
                Core_MDF_Region_cd__c = 'APJ',
                Core_MDF_Market__c = 'INDIA'
            );
            insert campaign;

            PartnerMarketingBudget budget = new PartnerMarketingBudget(
                Title = 'Activity API Test Budget',
                Amount = 50000,
                Core_MDF_Budget_Partner__c = partnerAccount.Id,
                Core_MDF_Program__c = program.Id,
                RecordTypeId = Schema.SObjectType.PartnerMarketingBudget
                    .getRecordTypeInfosByDeveloperName()
                    .get('Core_MDF_Co_Marketing')
                    .getRecordTypeId(),
                StartDate = Date.today(),
                EndDate = Date.today().addDays(365),
                Description = 'Activity API test budget',
                Core_MDF_Budget_Comments__c = 'Activity API test budget',
                Core_MDF_Budget_Type__c = 'MDF',
                Core_MDF_Budget_Type_Txt__c = 'MDF',
                Core_MDF_Budget_Status__c = 'Released'
            );
            insert budget;

            PartnerFundAllocation allocation = new PartnerFundAllocation(
                Title = 'Activity API Test Allocation',
                Amount = 25000,
                BudgetId = budget.Id,
                ChannelPartnerId = partnerAccount.Id,
                RecordTypeId = Schema.SObjectType.PartnerFundAllocation
                    .getRecordTypeInfosByDeveloperName()
                    .get('Core_MDF_Client_CoMarketing_Fund')
                    .getRecordTypeId()
            );
            insert allocation;

            Id pfrRecordTypeId = Schema.SObjectType.PartnerFundRequest
                .getRecordTypeInfosByDeveloperName()
                .get('Core_MDF_Client_CoMarketing_Fund')
                .getRecordTypeId();
            List<PartnerFundRequest> activities = new List<PartnerFundRequest>();
            for (String title : new List<String>{ 'Activity API Pending Review', 'Activity API Planned' }) {
                PartnerFundRequest activity =
                    Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(
                        String.valueOf(campaign.Id),
                        pfrRecordTypeId,
                        String.valueOf(partnerAccount.Id),
                        allocation,
                        budget,
                        'INDIA',
                        'Commercial',
                        'Mini PC',
                        'Intel vPro® platform',
                        'Sales Readiness',
                        'Personnel',
                        'Draft',
                        false
                    );
                activity.Title = title;
                activity.Core_MDF_Fund_Request_Status__c = title.endsWith('Planned')
                    ? 'Planned'
                    : 'Pending Review';
                activity.Core_MDF_Budget_Type_nm__c = 'MDF';
                activity.Core_MDF_Start_Date__c = Date.today();
                activity.Core_MDF_End_Date__c = Date.today().addDays(30);
                activities.add(activity);
            }
            insert activities;
        }
    }

    @IsTest
    static void testRequestValidationAndNumericCodes() {
        System.runAs(getApiTestUser()) {
            Map<String, Object> response = invoke('status', null);
            assertError(response, 400, 5001);

            response = invoke('not-an-action', '{}');
            assertError(response, 400, 5002);

            response = invoke('status', '{}');
            assertError(response, 400, 5003);

            response = invoke('status', '{"activity_id":"one","activity_number":"two"}');
            assertError(response, 400, 5004);

            response = invoke('status', '{"activity_id":"invalid-id"}');
            assertError(response, 400, 5005);

            response = invoke('close', '{"activity_ids":["001000000000001AAA"]}');
            assertError(response, 400, 5001);

            response = invoke('status', JSON.serialize(new Map<String, Object>{
                'activity_ids' => new List<String>{
                    '001000000000001AAA', '001000000000001AAA'
                }
            }));
            assertError(response, 400, 5015);

            List<String> tooManyIds = new List<String>();
            for (Integer index = 0; index < 11; index++) {
                tooManyIds.add('001000000000001AAA');
            }
            response = invoke('status', JSON.serialize(new Map<String, Object>{
                'activity_ids' => tooManyIds
            }));
            assertError(response, 400, 5016);
        }
    }

    @IsTest
    static void testSingleAndBatchStatusResponses() {
        System.runAs(getApiTestUser()) {
            List<PartnerFundRequest> activities = [
                SELECT Id, Core_MDF_Activity_Number__c
                FROM PartnerFundRequest
                WHERE Title IN ('Activity API Pending Review', 'Activity API Planned')
                ORDER BY Title
            ];
            System.assertEquals(2, activities.size());

            Map<String, Object> response = invoke(
                'status',
                JSON.serialize(new Map<String, Object>{
                    'activity_id' => String.valueOf(activities[0].Id)
                })
            );
            System.assertEquals(true, response.get('success'));
            System.assertNotEquals(null, response.get('data'));

            response = invoke(
                'status',
                JSON.serialize(new Map<String, Object>{
                    'activity_ids' => new List<String>{
                        String.valueOf(activities[0].Id),
                        String.valueOf(activities[1].Id)
                    }
                })
            );
            System.assertEquals(true, response.get('success'));
            Map<String, Object> data = (Map<String, Object>) response.get('data');
            System.assertEquals(2, ((List<Object>) data.get('activities')).size());

            response = invoke(
                'status',
                JSON.serialize(new Map<String, Object>{
                    'activity_numbers' => new List<String>{
                        activities[0].Core_MDF_Activity_Number__c,
                        activities[1].Core_MDF_Activity_Number__c
                    }
                })
            );
            System.assertEquals(true, response.get('success'));
            data = (Map<String, Object>) response.get('data');
            System.assertEquals(2, ((List<Object>) data.get('activities')).size());

            response = invoke(
                'status',
                JSON.serialize(new Map<String, Object>{
                    'activity_id' => String.valueOf(UserInfo.getUserId())
                })
            );
            assertError(response, 404, 5007);
        }
    }

    @IsTest
    static void testCloseAndCancelGuards() {
        System.runAs(getApiTestUser()) {
            PartnerFundRequest pendingReviewActivity = [
                SELECT Id, Core_MDF_Fund_Request_Status__c FROM PartnerFundRequest
                WHERE Title = 'Activity API Pending Review' LIMIT 1
            ];
            System.assertEquals(
                'Pending Review',
                pendingReviewActivity.Core_MDF_Fund_Request_Status__c
            );
            Map<String, Object> response = invoke(
                'close',
                JSON.serialize(new Map<String, Object>{
                    'activity_id' => String.valueOf(pendingReviewActivity.Id)
                })
            );
            assertError(response, 403, 5012);

            response = invoke(
                'cancel',
                JSON.serialize(new Map<String, Object>{
                    'activity_id' => String.valueOf(pendingReviewActivity.Id)
                })
            );
            assertError(response, 500, 5018);

            PartnerFundRequest plannedActivity = [
                SELECT Id FROM PartnerFundRequest
                WHERE Title = 'Activity API Planned' LIMIT 1
            ];
            response = invoke(
                'cancel',
                JSON.serialize(new Map<String, Object>{
                    'activity_id' => String.valueOf(plannedActivity.Id)
                })
            );
            assertError(response, 403, 5012);
        }
    }

    @IsTest
    static void testMalformedAndBatchValidation() {
        System.runAs(getApiTestUser()) {
            for (String body : new List<String>{ '', 'null', '{invalid-json' }) {
                assertError(invoke('status', body), 400, 5001);
            }
            assertError(invoke('status', '{"activity_ids":["short"]}'), 400, 5005);
            assertError(invoke('status', '{"activity_ids":[null]}'), 400, 5005);
            assertError(
                invoke('status', '{"activity_ids":["!!!!!!!!!!!!!!!!!!"]}'),
                400, 5005
            );
            assertError(
                invoke('status', '{"activity_numbers":[" "]}'), 400, 5003
            );
            assertError(
                invoke('status', '{"activity_number":"one","activity_numbers":["two"]}'),
                400, 5004
            );
            assertError(
                invoke('status', '{"activity_ids":["001000000000001AAA"],"activity_numbers":["one"]}'),
                400, 5004
            );
            assertError(
                invoke('cancel', '{"activity_numbers":["one"]}'), 400, 5001
            );
            assertError(
                invoke('status', '{"activity_numbers":["one","one","one"]}'),
                400, 5015
            );
            List<String> numbers = new List<String>();
            for (Integer index = 0; index < 11; index++) {
                numbers.add('Activity API Missing ' + index);
            }
            assertError(invoke('status', JSON.serialize(new Map<String, Object>{
                'activity_numbers' => numbers
            })), 400, 5016);
        }
    }

    @IsTest
    static void testStatusByNumberAndMissingBatchEntries() {
        System.runAs(getApiTestUser()) {
            PartnerFundRequest activity = [
                SELECT Id, Core_MDF_Activity_Number__c
                FROM PartnerFundRequest WHERE Title = 'Activity API Planned' LIMIT 1
            ];
            Test.startTest();
            Map<String, Object> response = invoke('STATUS', JSON.serialize(
                new Map<String, Object>{
                    'activity_number' => activity.Core_MDF_Activity_Number__c
                }
            ));
            System.assertEquals(true, response.get('success'));
            System.assertEquals(200, RestContext.response.statusCode);

            String missingNumber = 'Activity API Missing';
            String missingId = String.valueOf(UserInfo.getUserId());
            for (String identifierType : new List<String>{
                'activity_ids', 'activity_numbers'
            }) {
                Boolean useIds = identifierType == 'activity_ids';
                String foundIdentifier = useIds
                    ? String.valueOf(activity.Id)
                    : activity.Core_MDF_Activity_Number__c;
                String missingIdentifier = useIds ? missingId : missingNumber;
                response = invoke('status', JSON.serialize(new Map<String, Object>{
                    identifierType => new List<String>{
                        missingIdentifier, foundIdentifier
                    }
                }));
                System.assertEquals(true, response.get('success'));
                Map<String, Object> data = (Map<String, Object>) response.get('data');
                List<Object> results = (List<Object>) data.get('activities');
                System.assertEquals(2, results.size());
                Map<String, Object> missing = (Map<String, Object>) results[0];
                Map<String, Object> found = (Map<String, Object>) results[1];
                String responseIdentifier = useIds ? 'activityId' : 'activityNumber';
                System.assertEquals(missingIdentifier, missing.get(responseIdentifier));
                System.assertEquals(false, missing.get('found'));
                for (String section : new List<String>{
                    'ActivityDetails', 'ClaimDetails', 'SystemInformation',
                    'IncentiveInformation', 'Metrics',
                    'EcosystemPartnerPercentageAllocation', 'UploadAttachment'
                }) {
                    System.assert(missing.containsKey(section), section);
                    System.assertEquals(null, missing.get(section), section);
                }
                System.assertEquals(foundIdentifier, found.get(responseIdentifier));
                System.assertEquals(true, found.get('found'));
                System.assertNotEquals(null, found.get('ActivityDetails'));
            }
            assertError(invoke('status', JSON.serialize(new Map<String, Object>{
                'activity_number' => missingNumber
            })), 404, 5007);
            assertError(invoke('cancel', JSON.serialize(new Map<String, Object>{
                'activity_number' => missingNumber
            })), 404, 5007);
            Test.stopTest();
        }
    }

    @IsTest
    static void testStatusUploadAttachment() {
        System.runAs(getApiTestUser()) {
            PartnerFundRequest activity = [
                SELECT Id FROM PartnerFundRequest
                WHERE Title = 'Activity API Planned' LIMIT 1
            ];
            ContentVersion version = new ContentVersion(
                Title = 'Activity API Attachment',
                PathOnClient = 'Activity API Attachment.txt',
                VersionData = Blob.valueOf('Activity API test attachment'),
                FirstPublishLocationId = activity.Id
            );
            insert version;
            version = [
                SELECT ContentDocumentId FROM ContentVersion WHERE Id = :version.Id
            ];
            Test.startTest();
            Map<String, Object> response = invoke('status', JSON.serialize(
                new Map<String, Object>{ 'activity_id' => String.valueOf(activity.Id) }
            ));
            Test.stopTest();
            System.assertEquals(true, response.get('success'));
            Map<String, Object> data = (Map<String, Object>) response.get('data');
            List<Object> attachments = (List<Object>) data.get('UploadAttachment');
            System.assertEquals(1, attachments.size());
            Map<String, Object> attachment = (Map<String, Object>) attachments[0];
            System.assertEquals('Activity API Attachment.txt', attachment.get('Title'));
            System.assertEquals(
                String.valueOf(version.ContentDocumentId),
                attachment.get('ContentDocumentId')
            );
            System.assertEquals(
                '/sfc/servlet.shepherd/document/download/' +
                    version.ContentDocumentId + '?operationContext=S1',
                attachment.get('docurl')
            );
        }
    }

    @IsTest
    static void testConfiguredErrorMessages() {
        System.runAs(getApiTestUser()) {
            Core_MDF_External_API_Response_Codes__c setting =
                new Core_MDF_External_API_Response_Codes__c(
                    Core_Category__c = 'Activity Actions',
                    Core_Code__c = '5015',
                    Core_Context_of_Error__c = 'DUPLICATE_ACTIVITY_IDENTIFIER',
                    Core_Message__c = 'Duplicates: {value}'
                );
            if (Schema.SObjectType.Core_MDF_External_API_Response_Codes__c
                .fields.Name.isCreateable()) {
                setting.put('Name', 'Activity API Duplicate Test');
            }
            insert setting;
            String body = '{"activity_numbers":["one","one","one"]}';
            Map<String, Object> response = invoke('status', body);
            assertError(response, 400, 5015);
            System.assertEquals(
                'Duplicates: activity numbers: one', response.get('message')
            );

            setting.Core_Message__c = '@Label:Core_MDF_ApplicationErrorMessage';
            update setting;
            response = invoke('status', body);
            assertError(response, 400, 5015);
            String expectedMessage = System.Label.Core_MDF_ApplicationErrorMessage
                .replace('{value}', 'activity numbers: one')
                .replace('{0}', 'activity numbers: one');
            while (expectedMessage.contains('  ')) {
                expectedMessage = expectedMessage.replace('  ', ' ');
            }
            System.assertEquals(expectedMessage, response.get('message'));

            setting.Core_Message__c = '@Label:';
            update setting;
            response = invoke('status', body);
            assertError(response, 400, 5015);
            System.assertEquals(
                System.Label.Core_MDF_ApplicationErrorMessage, response.get('message')
            );

            setting.Core_Message__c = '@Label:Activity_API_Nonexistent_Label';
            update setting;
            response = invoke('status', body);
            assertError(response, 400, 5015);
            System.assertEquals(
                System.Label.Core_MDF_ApplicationErrorMessage, response.get('message')
            );
        }
    }

    @IsTest
    static void testAuthorizedCloseGuards() {
        User apiTestUser = getApiTestUser();
        Set<String> allowedPermissions = new Set<String>(
            Label.Core_MDF_Close_Activity_Allowed_Roles.split(',')
        );
        List<CustomPermission> closePermissions = [
            SELECT DeveloperName FROM CustomPermission
            WHERE DeveloperName IN :allowedPermissions
            ORDER BY DeveloperName
            LIMIT 1
        ];
        System.assertEquals(
            1, closePermissions.size(),
            'At least one configured close activity custom permission must exist.'
        );
        grantCustomPermissions(apiTestUser.Id, new Set<String>{
            closePermissions[0].DeveloperName
        });
        System.runAs(apiTestUser) {
            System.assert(FeatureManagement.checkPermission(
                closePermissions[0].DeveloperName
            ), 'The test user must have an allowed close activity permission.');
            PartnerFundRequest activity = [
                SELECT Id, Core_MDF_End_Date__c FROM PartnerFundRequest
                WHERE Title = 'Activity API Planned' LIMIT 1
            ];
            activity.Core_MDF_Start_Date__c = Date.today().addDays(1);
            update activity;
            Test.startTest();
            assertError(invoke('close', JSON.serialize(new Map<String, Object>{
                'activity_id' => String.valueOf(activity.Id)
            })), 409, 5019);
            assertError(invoke('close', JSON.serialize(new Map<String, Object>{
                'activity_id' => String.valueOf(UserInfo.getUserId())
            })), 404, 5007);
            Test.stopTest();
        }
    }

    @IsTest
    static void testAuthorizedCancelAndRepeatedCancel() {
        User apiTestUser = getApiTestUser();
        grantCustomPermissions(apiTestUser.Id, new Set<String>{
            'Core_MDF_Allowed_Permission_Set_for_Cancel_Activity'
        });
        System.runAs(apiTestUser) {
            System.assert(FeatureManagement.checkPermission(
                'Core_MDF_Allowed_Permission_Set_for_Cancel_Activity'
            ));
            PartnerFundRequest activity = [
                SELECT Id, Description FROM PartnerFundRequest
                WHERE Title = 'Activity API Planned' LIMIT 1
            ];
            String originalDescription = activity.Description;
            String body = JSON.serialize(new Map<String, Object>{
                'activity_id' => String.valueOf(activity.Id),
                'Comments' => 'Cancelled by activity API test'
            });
            Test.startTest();
            Map<String, Object> response = invoke('cancel', body);
            System.assertEquals(true, response.get('success'), JSON.serialize(response));
            System.assertEquals(200, RestContext.response.statusCode);
            String cancelledStatus = Core_MDF_CustomLabelConfig.getTextValues(
                'Core_MDF_Activity_Cancelled_Status'
            );
            Map<String, Object> data = (Map<String, Object>) response.get('data');
            System.assertEquals(String.valueOf(activity.Id), data.get('activityId'));
            System.assertEquals(cancelledStatus, data.get('status'));
            activity = [
                SELECT Core_MDF_Fund_Request_Status__c, Description
                FROM PartnerFundRequest WHERE Id = :activity.Id
            ];
            System.assertEquals(cancelledStatus, activity.Core_MDF_Fund_Request_Status__c);
            System.assertEquals(
                ((String.isNotBlank(originalDescription) ? originalDescription : '') +
                    '\n[Cancel Comment]: Cancelled by activity API test').trim(),
                activity.Description
            );
            assertError(invoke('cancel', body), 409, 5011);
            Test.stopTest();
        }
    }

    private static void grantCustomPermissions(Id userId, Set<String> permissionNames) {
        List<CustomPermission> permissions = [
            SELECT Id FROM CustomPermission WHERE DeveloperName IN :permissionNames
        ];
        System.assertEquals(
            permissionNames.size(), permissions.size(),
            'The configured activity action custom permissions must exist.'
        );
        PermissionSet permissionSet = new PermissionSet(
            Name = 'Activity_API_Test_Actions', Label = 'Activity API Test Actions'
        );
        insert permissionSet;
        List<SetupEntityAccess> access = new List<SetupEntityAccess>();
        for (CustomPermission permission : permissions) {
            access.add(new SetupEntityAccess(
                ParentId = permissionSet.Id, SetupEntityId = permission.Id
            ));
        }
        insert access;
        insert new PermissionSetAssignment(
            AssigneeId = userId, PermissionSetId = permissionSet.Id
        );
    }

    private static User getApiTestUser() {
        return [
            SELECT Id
            FROM User
            WHERE Username LIKE 'testUser%@CoreMDF.com'
            LIMIT 1
        ];
    }

    private static Map<String, Object> invoke(String action, String body) {
        RestRequest request = new RestRequest();
        request.requestURI = ENDPOINT + action;
        request.httpMethod = 'POST';
        if (body != null) {
            request.requestBody = Blob.valueOf(body);
        }
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Core_MDF_PFR_ActivityActionAPI.doPost();
        return (Map<String, Object>) JSON.deserializeUntyped(
            RestContext.response.responseBody.toString()
        );
    }

    private static void assertError(
        Map<String, Object> response,
        Integer statusCode,
        Integer errorCode
    ) {
        System.assertEquals(false, response.get('success'));
        System.assertEquals(statusCode, RestContext.response.statusCode);
        System.assertEquals(
            errorCode,
            Integer.valueOf(String.valueOf(response.get('errorCode')))
        );
    }
}