/**
 * @description Test class for Core_MDF_PFR_RestAPI_InputWrapper
 */
@isTest
private class Core_MDF_PFR_RestAPI_InputWrapper_Test {

    // ==========================================
    // Helpers
    // ==========================================

    private static Id getFakeId(Schema.SObjectType sot) {
        String prefix = sot.getDescribe().getKeyPrefix();
        return (Id)(prefix + '0'.repeat(12));
    }

    private static Id getFakeProductId() {
        return getFakeId(Product2.SObjectType);
    }

    private static Id getFakePfrId() {
        return getFakeId(PartnerFundRequest.SObjectType);
    }

    private static Core_MDF_PFR_RestAPI_InputWrapper.SegmentInputDetail buildValidSegment(
        String name, Decimal volume, Decimal incentive, List<String> productIds
    ) {
        Core_MDF_PFR_RestAPI_InputWrapper.SegmentInputDetail seg =
            new Core_MDF_PFR_RestAPI_InputWrapper.SegmentInputDetail();
        seg.segmentName            = name;
        seg.minimumForecastVolume  = volume;
        seg.incentiveAmountPerUnit = incentive;
        seg.productIds             = productIds;
        return seg;
    }

    private static Core_MDF_PFR_RestAPI_InputWrapper.SegmentInputDetail buildSegmentWithFakeProductId(
        String name
    ) {
        return buildValidSegment(
            name, 100, 50,
            new List<String>{ String.valueOf(getFakeProductId()) }
        );
    }

    /**
     * Builds a minimal activity JSON payload map
     */
    private static Map<String, Object> buildActivityPayload(Map<String, Object> overrides) {
        Map<String, Object> activity = new Map<String, Object>{
            'ActivityName' => 'Test Activity'
        };
        if (overrides != null) {
            activity.putAll(overrides);
        }
        return new Map<String, Object>{ 'activity' => activity };
    }

    private static String serializePayload(Map<String, Object> overrides) {
        return JSON.serialize(buildActivityPayload(overrides));
    }

    // ==========================================
    // FileUpload inner class
    // ==========================================
    @isTest
    static void testFileUploadInitialization() {
        Core_MDF_PFR_RestAPI_InputWrapper.FileUpload fu =
            new Core_MDF_PFR_RestAPI_InputWrapper.FileUpload();
        Assert.isNull(fu.FileName);
        Assert.isNull(fu.file);
        Assert.isNull(fu.comment);

        fu.FileName = 'test.pdf';
        fu.file     = 'base64content';
        fu.comment  = 'Test file';

        Assert.areEqual('test.pdf',      fu.FileName);
        Assert.areEqual('base64content', fu.file);
        Assert.areEqual('Test file',     fu.comment);
    }

    // ==========================================
    // SegmentInputDetail – construction & toMap
    // ==========================================
    @isTest
    static void testSegmentInputDetailInitialization() {
        Core_MDF_PFR_RestAPI_InputWrapper.SegmentInputDetail seg =
            new Core_MDF_PFR_RestAPI_InputWrapper.SegmentInputDetail();
        Assert.isNull(seg.segmentName);
        Assert.isNull(seg.minimumForecastVolume);
        Assert.isNull(seg.incentiveAmountPerUnit);
        Assert.isNotNull(seg.productIds);
        Assert.areEqual(0, seg.productIds.size());
    }

    @isTest
    static void testSegmentInputDetailToMap() {
        String fakeProductId = String.valueOf(getFakeProductId());
        Core_MDF_PFR_RestAPI_InputWrapper.SegmentInputDetail seg =
            buildValidSegment('Premium', 100, 50.00, new List<String>{ fakeProductId });

        Map<String, Object> m = seg.toMap();
        Assert.areEqual('Premium', m.get('SegmentName'));
        Assert.areEqual(100,       m.get('MinimumForecastVolume'));
        Assert.areEqual(50.00,     m.get('IncentiveAmountPerUnit'));
        Assert.isNotNull(m.get('ProductIds'));
    }

    // ==========================================
    // InputWrapper – getter defaults (null-safe)
    // ==========================================
    @isTest
    static void testWrapperGetterDefaults() {
        Core_MDF_PFR_RestAPI_InputWrapper w = new Core_MDF_PFR_RestAPI_InputWrapper();
        Assert.areEqual(0, w.getPartnerFundRequests().size());
        Assert.areEqual(0, w.getFileUploads().size());
        Assert.areEqual(0, w.getValidationFailures().size());
        Assert.areEqual(0, w.getEcosystemPartnerAllocations().size());
        Assert.areEqual(0, w.getSegments().size());
    }

    @isTest
    static void testGetFileUploadsPopulated() {
        Core_MDF_PFR_RestAPI_InputWrapper w = new Core_MDF_PFR_RestAPI_InputWrapper();
        w.fileUploads = new List<Core_MDF_PFR_RestAPI_InputWrapper.FileUpload>();
        Core_MDF_PFR_RestAPI_InputWrapper.FileUpload fu =
            new Core_MDF_PFR_RestAPI_InputWrapper.FileUpload();
        fu.FileName = 'doc.pdf';
        w.fileUploads.add(fu);

        Assert.areEqual(1,         w.getFileUploads().size());
        Assert.areEqual('doc.pdf', w.getFileUploads()[0].FileName);
    }

    // ==========================================
    // InputWrapper – getSegmentMaps & getSegmentProductString
    // ==========================================
    @isTest
    static void testGetSegmentMapsAndProductString() {
        Core_MDF_PFR_RestAPI_InputWrapper w = new Core_MDF_PFR_RestAPI_InputWrapper();
        w.segments = new List<Core_MDF_PFR_RestAPI_InputWrapper.SegmentInputDetail>{
            buildSegmentWithFakeProductId('TestSeg')
        };

        List<Map<String, Object>> maps = w.getSegmentMaps();
        Assert.areEqual(1,         maps.size());
        Assert.areEqual('TestSeg', maps[0].get('SegmentName'));

        String productStr = w.getSegmentProductString();
        Assert.isNotNull(productStr);
        Assert.isTrue(productStr.containsIgnoreCase('TestSeg'));
    }

    @isTest
    static void testGetSegmentProductStringEmpty() {
        Assert.isNull(new Core_MDF_PFR_RestAPI_InputWrapper().getSegmentProductString());
    }

    // ==========================================
    // ActivityWrapper – toRecord
    // ==========================================
    @isTest
    static void testActivityWrapperToRecord() {
        Core_MDF_PFR_RestAPI_InputWrapper.ActivityWrapper act =
            new Core_MDF_PFR_RestAPI_InputWrapper.ActivityWrapper();
        act.ActivityName               = 'Test Activity';
        act.ActivityDescription        = 'Test Desc';
        act.BudgetType                 = 'CCF';
        act.ActivitySpendingLimitLocal = 1000.00;
        act.GovernmentInvolvement      = 'No';
        act.CompetitiveElements        = 'No';

        PartnerFundRequest pfr = act.toRecord();
        Assert.areEqual('Test Activity', pfr.Title);
        Assert.areEqual('Test Desc',     pfr.Core_MDF_Activity_Description__c);
        Assert.isNull(pfr.Core_MDF_Domain_Type_nm__c);
    }

    // ==========================================
    // ActivityWrapper – toRecord catch block (invalid date -> ERR-9014)
    // Covered by passing an invalid StartDate through parse() so toRecord() throws
    // ==========================================
    @isTest
    static void testParseInvalidDateTriggersToRecordCatch() {
        Map<String, Object> activity = new Map<String, Object>{
            'ActivityName' => 'Bad Date Activity',
            'StartDate'    => 'not-a-date'
        };
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            JSON.serialize(new Map<String, Object>{ 'activity' => activity })
        );
        Assert.isNotNull(w);
        Assert.isTrue(w.getValidationFailures().size() > 0);
        Assert.areEqual(0, w.getPartnerFundRequests().size());
    }

    // ==========================================
    // parse() – blank / null / invalid root
    // ==========================================
    @isTest
    static void testParseBlankAndNullBody() {
        Core_MDF_PFR_RestAPI_InputWrapper w1 = Core_MDF_PFR_RestAPI_InputWrapper.parse('');
        Assert.areEqual(0, w1.getPartnerFundRequests().size());
        Assert.areEqual(0, w1.getValidationFailures().size());

        Core_MDF_PFR_RestAPI_InputWrapper w2 = Core_MDF_PFR_RestAPI_InputWrapper.parse(null);
        Assert.areEqual(0, w2.getPartnerFundRequests().size());
    }

    @isTest
    static void testParseInvalidJSONRootArray() {
        Assert.isTrue(
            Core_MDF_PFR_RestAPI_InputWrapper.parse('["not","an","object"]')
                .getValidationFailures().size() > 0
        );
    }

    @isTest
    static void testParseMissingActivityNode() {
        Core_MDF_PFR_RestAPI_InputWrapper w =
            Core_MDF_PFR_RestAPI_InputWrapper.parse('{"someField":"value"}');
        Assert.areEqual(0, w.getPartnerFundRequests().size());
        Assert.areEqual(0, w.getValidationFailures().size());
    }

    @isTest
    static void testParseDuplicateActivityFields() {
        String json = '{"activity":{"ActivityName":"A","ActivityName":"B"}}';
        Assert.isTrue(
            Core_MDF_PFR_RestAPI_InputWrapper.parse(json)
                .getValidationFailures().size() > 0
        );
    }

    @isTest
    static void testParseActivityNodeIsString() {
        String json = '{"activity":"not_an_object"}';
        try {
            Core_MDF_PFR_RestAPI_InputWrapper w =
                Core_MDF_PFR_RestAPI_InputWrapper.parse(json);
            Assert.areEqual(0, w.getPartnerFundRequests().size());
        } catch (JSONException e) {
            Assert.isTrue(e.getMessage().containsIgnoreCase('Expected'));
        } catch (Exception e) {
            Assert.isNotNull(e.getMessage());
        }
    }

    // ==========================================
    // parse() – extractActivity branches
    // ==========================================
    @isTest
    static void testParseActivityWithFilesNode() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'Files' => new List<Object>{
                    new Map<String, Object>{
                        'FileName' => 'doc.pdf', 'file' => 'abc123', 'comment' => 'note'
                    }
                }
            })
        );
        Assert.areEqual(1,         w.getFileUploads().size());
        Assert.areEqual('doc.pdf', w.getFileUploads()[0].FileName);
    }

    @isTest
    static void testParseActivityWithEcosystemPartnerAllocations() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'EcosystemPartnerAllocations' => new List<Object>{
                    new Map<String, Object>{ 'partner' => 'PartnerA', 'percent' => 100 }
                }
            })
        );
        Assert.isTrue(w.getEcosystemPartnerAllocations().containsKey('PartnerA'));
        Assert.areEqual(100, w.getEcosystemPartnerAllocations().get('PartnerA'));
    }

    @isTest
    static void testParseLegacyEcoPercentageAllocationSinglePartner() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'EcosystemPartner'        => 'PartnerB',
                'EcoPercentageAllocation' => '75'
            })
        );
        Assert.isTrue(w.getEcosystemPartnerAllocations().containsKey('PartnerB'));
        Assert.areEqual(75, w.getEcosystemPartnerAllocations().get('PartnerB'));
    }

    @isTest
    static void testParseLegacyEcoPercentageAllocationMultiplePartners() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'EcosystemPartner'        => 'PartnerC;PartnerD',
                'EcoPercentageAllocation' => '50'
            })
        );
        Map<String, Decimal> allocs = w.getEcosystemPartnerAllocations();
        Assert.isTrue(allocs.containsKey('PartnerC'));
        Assert.isTrue(allocs.containsKey('PartnerD'));
        Assert.areEqual(50, allocs.get('PartnerC'));
        Assert.areEqual(50, allocs.get('PartnerD'));
    }

    @isTest
    static void testParseCurrencyFieldAlias() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{ 'Currency' => 'USD' })
        );
        Assert.isNotNull(w);
    }

    @isTest
    static void testParseNumberOfWinnersAliases() {
        for (String alias : new List<String>{
            'Number of Winners', 'NumberOfPotentialWinners', 'Number of Potential Winners'
        }) {
            Map<String, Object> overrides = new Map<String, Object>();
            overrides.put(alias, 5);
            Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
                serializePayload(overrides)
            );
            Assert.isNotNull(w, 'Should not throw for alias: ' + alias);
        }
    }

    @isTest
    static void testParseGovernmentInvolvementDefaultsToNo() {
        Assert.isNotNull(
            Core_MDF_PFR_RestAPI_InputWrapper.parse(serializePayload(null))
        );
    }

    @isTest
    static void testParseGovernmentInvolvementQuestionFieldAlias() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'Is this Activity targeting government entities or state-owned enterprises or having key participants from government entities or state-owned enterprises or their employees?' => 'Yes'
            })
        );
        Assert.isNotNull(w);
    }

    @isTest
    static void testParseCompetitiveElementsQuestionFieldAlias() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Event',
                'Does your event include one or more Competitive Elements?' => 'No'
            })
        );
        Assert.isNotNull(w);
    }

    @isTest
    static void testParseBlankDecimalFieldsNormalized() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivitySpendingLimitLocal' => '',
                'ReimbursementAmt'           => ''
            })
        );
        Assert.isNotNull(w);
    }

    // ==========================================
    // parse() – hasEnteredSegments branches
    // ==========================================

    @isTest
    static void testHasEnteredSegmentsNullSegmentsNode() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Volume'
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testHasEnteredSegmentsExplicitNullValue() {
        Map<String, Object> activity = new Map<String, Object>{
            'ActivityName'     => 'Test',
            'ActivityCategory' => 'Seller Incentive',
            'ActivityTypes'    => 'SPIF Volume',
            'Segments'         => null
        };
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            JSON.serialize(new Map<String, Object>{ 'activity' => activity })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testHasEnteredSegmentsNonListValue() {
        Map<String, Object> activity = new Map<String, Object>{
            'ActivityName'                 => 'Test',
            'ActivityCategory'             => 'Seller Incentive',
            'ActivityTypes'                => 'SPIF Contest',
            'NumberOfWinners'              => 1,
            'NumberOfExpectedParticipants' => 10,
            'Segments'                     => 'unexpected_string'
        };
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            JSON.serialize(new Map<String, Object>{ 'activity' => activity })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testHasEnteredSegmentValueNonMapRawSegment() {
        Map<String, Object> activity = new Map<String, Object>{
            'ActivityName'                 => 'Test',
            'ActivityCategory'             => 'Seller Incentive',
            'ActivityTypes'                => 'SPIF Contest',
            'NumberOfWinners'              => 1,
            'NumberOfExpectedParticipants' => 10,
            'Segments'                     => new List<Object>{ 'not_a_map' }
        };
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            JSON.serialize(new Map<String, Object>{ 'activity' => activity })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testHasEnteredSegmentValueAllBlankFields() {
        Map<String, Object> activity = new Map<String, Object>{
            'ActivityName'     => 'Test',
            'ActivityCategory' => 'Seller Incentive',
            'ActivityTypes'    => 'SPIF Volume',
            'Segments'         => new List<Object>{
                new Map<String, Object>{
                    'SegmentName'            => '',
                    'MinimumForecastVolume'  => null,
                    'IncentiveAmountPerUnit' => null,
                    'ProductIds'             => new List<Object>()
                }
            }
        };
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            JSON.serialize(new Map<String, Object>{ 'activity' => activity })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testHasEnteredSegmentValueProductIdsWithNonNullEntry() {
        Map<String, Object> activity = new Map<String, Object>{
            'ActivityName'                 => 'Test',
            'ActivityCategory'             => 'Seller Incentive',
            'ActivityTypes'                => 'SPIF Contest',
            'NumberOfWinners'              => 1,
            'NumberOfExpectedParticipants' => 10,
            'Segments'                     => new List<Object>{
                new Map<String, Object>{
                    'SegmentName'            => '',
                    'MinimumForecastVolume'  => null,
                    'IncentiveAmountPerUnit' => null,
                    'ProductIds'             => new List<Object>{ 'someProduct' }
                }
            }
        };
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            JSON.serialize(new Map<String, Object>{ 'activity' => activity })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testHasEnteredSegmentValueProductIdsAllNullEntries() {
        Map<String, Object> activity = new Map<String, Object>{
            'ActivityName'     => 'Test',
            'ActivityCategory' => 'Seller Incentive',
            'ActivityTypes'    => 'SPIF Volume',
            'Segments'         => new List<Object>{
                new Map<String, Object>{
                    'SegmentName'            => '',
                    'MinimumForecastVolume'  => null,
                    'IncentiveAmountPerUnit' => null,
                    'ProductIds'             => new List<Object>{ null }
                }
            }
        };
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            JSON.serialize(new Map<String, Object>{ 'activity' => activity })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testHasEnteredSegmentValueProductIdsNonListNonNull() {
        Map<String, Object> activity = new Map<String, Object>{
            'ActivityName'                 => 'Test',
            'ActivityCategory'             => 'Seller Incentive',
            'ActivityTypes'                => 'SPIF Contest',
            'NumberOfWinners'              => 1,
            'NumberOfExpectedParticipants' => 10,
            'Segments'                     => new List<Object>{
                new Map<String, Object>{
                    'SegmentName'            => '',
                    'MinimumForecastVolume'  => null,
                    'IncentiveAmountPerUnit' => null,
                    'ProductIds'             => 'scalar_product'
                }
            }
        };
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            JSON.serialize(new Map<String, Object>{ 'activity' => activity })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    // ==========================================
    // parse() – resolveLookup branches
    // ==========================================
    @isTest
    static void testParseUnresolvedCampaignLookup() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'Campaign' => 'NONEXISTENT-CAMPAIGN-REF-99999'
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseUnresolvedAccountLookup() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'AccountName' => 'NONEXISTENT-ACCOUNT-NAME-99999'
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseUnresolvedBudgetLookup() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'BudgetReferenceNumber' => 'NONEXISTENT-BUDGET-REF-99999'
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseUnresolvedIntelApproverLookup() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'IntelApproverUsername' => 'nonexistent.user@nonexistent.invalid'
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseUnresolvedMemberAcceptorLookup() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'MemberAcceptorUsername' => 'nonexistent.member@nonexistent.invalid'
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    // ==========================================
    // parse() – validateConditionalIncentiveFields branches
    // ==========================================
    @isTest
    static void testParseTechnicalSalesWithGovernmentInvolvement() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory'    => 'Technical Sales',
                'GovernmentInvolvement' => 'Yes'
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSellerIncentiveSPIFVolumeRequiresSegments() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Volume'
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSellerIncentiveSPIFTargetRequiresSegments() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Target'
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSellerIncentiveSPIFContestRequiresWinnerFields() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Contest'
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSellerIncentiveSPIFContestWinnersExceedParticipants() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory'             => 'Seller Incentive',
                'ActivityTypes'                => 'SPIF Contest',
                'NumberOfWinners'              => 10,
                'NumberOfExpectedParticipants' => 5
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSellerIncentiveSPIFContestWinnerPercentExceeds33() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory'             => 'Seller Incentive',
                'ActivityTypes'                => 'SPIF Contest',
                'NumberOfWinners'              => 5,
                'NumberOfExpectedParticipants' => 10
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseBuyerIncentiveOfferContestRequiresWinnerFields() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Buyer Incentive',
                'ActivityTypes'    => 'Offer Contest'
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseBuyerIncentiveOfferSweepstakesRequiresWinnerFields() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Buyer Incentive',
                'ActivityTypes'    => 'Offer Sweepstakes'
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseBuyerIncentiveOfferBundleRequiresSegments() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Buyer Incentive',
                'ActivityTypes'    => 'Offer Bundle'
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseBuyerIncentiveOfferTargetRequiresSegments() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Buyer Incentive',
                'ActivityTypes'    => 'Offer Target'
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSegmentTypeWithWinnerFieldsForbidden() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Volume',
                'NumberOfWinners'  => 3
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseContestTypeWithSegmentsForbidden() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory'             => 'Seller Incentive',
                'ActivityTypes'                => 'SPIF Contest',
                'NumberOfWinners'              => 1,
                'NumberOfExpectedParticipants' => 10,
                'Segments' => new List<Object>{
                    new Map<String, Object>{
                        'SegmentName'            => 'S1',
                        'MinimumForecastVolume'  => 100,
                        'IncentiveAmountPerUnit' => 50,
                        'ProductIds'             => new List<String>{ 'p1' }
                    }
                }
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    // ==========================================
    // parse() – segment parsing via validateConditionalIncentiveFields
    // These tests exercise parseRootSegments indirectly through parse()
    // ==========================================
    @isTest
    static void testParseSegmentNotArray() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Volume',
                'Segments'         => 'not_array'
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSegmentEmptyArray() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Volume',
                'Segments'         => new List<Object>()
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSegmentTooMany() {
        List<Object> segs = new List<Object>();
        for (Integer i = 0; i < 11; i++) {
            segs.add(new Map<String, Object>{
                'SegmentName'            => 'Seg' + i,
                'MinimumForecastVolume'  => 100,
                'IncentiveAmountPerUnit' => 50,
                'ProductIds'             => new List<String>{ 'p1' }
            });
        }
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Volume',
                'Segments'         => segs
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSegmentDuplicateName() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Volume',
                'Segments'         => new List<Object>{
                    new Map<String, Object>{
                        'SegmentName'            => 'Premium',
                        'MinimumForecastVolume'  => 100,
                        'IncentiveAmountPerUnit' => 50,
                        'ProductIds'             => new List<String>{ 'p1' }
                    },
                    new Map<String, Object>{
                        'SegmentName'            => 'Premium',
                        'MinimumForecastVolume'  => 200,
                        'IncentiveAmountPerUnit' => 75,
                        'ProductIds'             => new List<String>{ 'p2' }
                    }
                }
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSegmentMissingName() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Volume',
                'Segments'         => new List<Object>{
                    new Map<String, Object>{
                        'MinimumForecastVolume'  => 100,
                        'IncentiveAmountPerUnit' => 50,
                        'ProductIds'             => new List<String>{ 'p1' }
                    }
                }
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSegmentZeroVolume() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Volume',
                'Segments'         => new List<Object>{
                    new Map<String, Object>{
                        'SegmentName'            => 'S1',
                        'MinimumForecastVolume'  => 0,
                        'IncentiveAmountPerUnit' => 50,
                        'ProductIds'             => new List<String>{ 'p1' }
                    }
                }
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSegmentZeroIncentive() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Volume',
                'Segments'         => new List<Object>{
                    new Map<String, Object>{
                        'SegmentName'            => 'S1',
                        'MinimumForecastVolume'  => 100,
                        'IncentiveAmountPerUnit' => 0,
                        'ProductIds'             => new List<String>{ 'p1' }
                    }
                }
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSegmentEmptyProductIds() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Volume',
                'Segments'         => new List<Object>{
                    new Map<String, Object>{
                        'SegmentName'            => 'S1',
                        'MinimumForecastVolume'  => 100,
                        'IncentiveAmountPerUnit' => 50,
                        'ProductIds'             => new List<String>()
                    }
                }
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSegmentProductIdsNotArray() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Volume',
                'Segments'         => new List<Object>{
                    new Map<String, Object>{
                        'SegmentName'            => 'S1',
                        'MinimumForecastVolume'  => 100,
                        'IncentiveAmountPerUnit' => 50,
                        'ProductIds'             => 'not_array'
                    }
                }
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSegmentNonObjectElement() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Volume',
                'Segments'         => new List<Object>{ 'not_a_map' }
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSegmentDuplicateProductIds() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Volume',
                'Segments'         => new List<Object>{
                    new Map<String, Object>{
                        'SegmentName'            => 'S1',
                        'MinimumForecastVolume'  => 100,
                        'IncentiveAmountPerUnit' => 50,
                        'ProductIds'             => new List<String>{ 'p1', 'p1' }
                    }
                }
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSegmentMissingVolume() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Volume',
                'Segments'         => new List<Object>{
                    new Map<String, Object>{
                        'SegmentName'            => 'S1',
                        'IncentiveAmountPerUnit' => 50,
                        'ProductIds'             => new List<String>{ 'p1' }
                    }
                }
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    @isTest
    static void testParseSegmentMissingIncentive() {
        Core_MDF_PFR_RestAPI_InputWrapper w = Core_MDF_PFR_RestAPI_InputWrapper.parse(
            serializePayload(new Map<String, Object>{
                'ActivityCategory' => 'Seller Incentive',
                'ActivityTypes'    => 'SPIF Volume',
                'Segments'         => new List<Object>{
                    new Map<String, Object>{
                        'SegmentName'           => 'S1',
                        'MinimumForecastVolume' => 100,
                        'ProductIds'            => new List<String>{ 'p1' }
                    }
                }
            })
        );
        Assert.isTrue(w.getValidationFailures().size() > 0);
    }

    // ==========================================
    // getSegmentMaps – null segment in list
    // ==========================================
    @isTest
    static void testGetSegmentMapsSkipsNullSegment() {
        Core_MDF_PFR_RestAPI_InputWrapper w = new Core_MDF_PFR_RestAPI_InputWrapper();
        w.segments = new List<Core_MDF_PFR_RestAPI_InputWrapper.SegmentInputDetail>{
            null,
            buildValidSegment('ValidSeg', 100, 50, new List<String>{ 'p1' })
        };
        List<Map<String, Object>> maps = w.getSegmentMaps();
        Assert.areEqual(1, maps.size());
        Assert.areEqual('ValidSeg', maps[0].get('SegmentName'));
    }

    // ==========================================
    // getSegmentProductString – null segment in list
    // ==========================================
    @isTest
    static void testGetSegmentProductStringSkipsNullSegment() {
        Core_MDF_PFR_RestAPI_InputWrapper w = new Core_MDF_PFR_RestAPI_InputWrapper();
        w.segments = new List<Core_MDF_PFR_RestAPI_InputWrapper.SegmentInputDetail>{
            null,
            buildValidSegment('ValidSeg', 100, 50, new List<String>{ 'p1' })
        };
        String result = w.getSegmentProductString();
        Assert.isNotNull(result);
        Assert.isTrue(result.containsIgnoreCase('ValidSeg'));
    }

    // ==========================================
    // Wrapper populated fields
    // ==========================================
    @isTest
    static void testWrapperPopulatedGetters() {
        Core_MDF_PFR_RestAPI_InputWrapper w = new Core_MDF_PFR_RestAPI_InputWrapper();
        w.partnerfundrequests = new List<PartnerFundRequest>{ new PartnerFundRequest() };
        w.validationFailures  = new List<Core_MDF_PFR_RestAPI_Response.ErrorContent>{
            new Core_MDF_PFR_RestAPI_Response.ErrorContent()
        };
        w.ecosystemPartnerAllocations = new Map<String, Decimal>{ 'P1' => 100 };
        w.segments = new List<Core_MDF_PFR_RestAPI_InputWrapper.SegmentInputDetail>{
            buildValidSegment('S1', 10, 5, new List<String>{ 'p1' })
        };

        Assert.areEqual(1, w.getPartnerFundRequests().size());
        Assert.areEqual(1, w.getValidationFailures().size());
        Assert.areEqual(1, w.getEcosystemPartnerAllocations().size());
        Assert.areEqual(1, w.getSegments().size());
    }
}