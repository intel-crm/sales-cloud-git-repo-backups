public class Core_MDF_FileUploadAPIController {

    // ================================================================
    // CONSTANTS
    // ================================================================
    private static final Integer CHUNK_SIZE    = 4 * 1024 * 1024;
    private static final String SF_LOGIN_URL   = 'https://test.salesforce.com/services/oauth2/token';
    private static final String API_VERSION    = 'v59.0';
	private static final String PRIVATE_KEY = '-----BEGIN RSA PRIVATE KEY----- MIIEowIBAAKCAQEAwavbE14Irt7AFc+Qwl6wgyrAnWdjt3u2tj1owHCL64z75+/P zPfz0y0BE8FsApqDcUCQfMLHvqlHsbFlMZ51VJrBZEL5Z+erxlnpv2TG+B9lSNA2 gPTFjMdMEcu858Vb3f5UTkClr/3kkYFYTVoGimTz7oY+TKx24znsD+RZHTjkuRlH ctb/n5T1Rju0jSN/by0B77jw+5iAEdeh25mPslNBiANrESajUtBvKAQyu9tPbiPb eermz8po7FuY33EJHIPHoIh031dyBGj4oAQSPjEu0eo8gpE7bh6eKSgHxJNy/695 q0XfJKGddImFPM9/UXjAUps/+UgPu+M6fDEGuwIDAQABAoIBADfkAaAQNg9JJ0Pk F9GQA/6Gevmx2Zwc7rie9jj7AdYjZJsloOF0+P+LcFEkM6h4sNAhItFuYLiMH62P FTYBlbipxH/LuDAdMnxWfFeInMcEQHWH6QLEILKk3TYRht2YHg/tkqTWkTo92hWH r1T7UwHjamX+hcIYz2J5178qVfFRdVtZwJWz7cwE5E8SVzs5zQ7e1nDL+73AXTXS FthUjbiF6Lf4eAJoQpypiZq3YUK/zdFT4i6/D4aXWvEABGYfuNR7IVOV13AoYSaB KQGjXYdJcFcQY0rM4Z7OdGkugopGBwNfVt4gy3ftmqR4lZfIbLLpUuWnkBCchMPK sj0WALkCgYEA/L5rIZVLGb22HD/dz85m4O14VrGweXwiuk1GDrIzOkrCx9NL9u7l BcjjEA34v6HNZwOVe6/VlmlquLwfMleq3vGGaB0ziBaKP4SOQXmjOv/K+Laf9V6G +8H5AoJgw+A7kyoQ5PpA8lC/xbaXic6Xr4O539y6qz+fsI2JOPjQQZ8CgYEAxCqb y1+Tnr1UE2Cq/RMTuxkyw1BM7EKWuAbSWPdaXg2EP9srPOxr3CRr2FnMQ/SPRimW yVT7ohsag4eKoZkck7deX0zgIBkcccRF3s/oTa99e/UVKLy02LX8f0yXYToHpQQ+ u0Z8DtU/kcnk5+TDW59fQ3JyT0jwNslUJQGz/WUCgYEAlCfHQwNx55/2ra6eht82 HWn23dMBYOVssgr0I09Aik4iyeJJqHG3nOF6gQG/rA3cCyPlr4COUsJuxeW439jW GCQ6prNfbsnPtpYskaMNFVu2jn73W21S8SduoZLtyESch5LkHmW4RpMhJ3P2dti8 wC0We2y3nAUKxgLhypzH738CgYAoJ2yikZrfCHQ4TzZQ/WGxj7PjZQGJ7wt4+fR+ v4sg63VhuNQ98UsW0eG9dIwqcNoPC55Q8fNcOF4SBGGtOHEwD33i1hKen2VCKGIA /N/ZXw25nO5K223NWlsoF555CW7dKWRJ42CrjJ0pk4Emsp4GmDXg0YFyl0SMgmOV +6ZDPQKBgCFa29S7Y93LOM/TvGbmX8SkLpHzy28ePsFEDFR/rDvu7vvQnt0+B4uM EBAaIto0fWD4elSJqicrp/RsHc9dSzMZSXDMGrxtsc+2bgx50OpeeOGFAgyWMKfH WLXFurJnRbqPna74eu8s38fNpsOZ5MtdYtfKeoRx1wx3A5PkfuZo -----END RSA PRIVATE KEY-----';

    // ================================================================
    // WRAPPER CLASS
    // ================================================================
    public class AuthResponse {
        public String accessToken;
        public String instanceUrl;
    }

    // ================================================================
    // JWT AUTHENTICATION METHODS
    // ================================================================

    private static AuthResponse getAuthDetails() {
        try {
            String jwtToken = buildJWTToken();
            return exchangeJWTForAuthDetails(jwtToken);
        } catch (Exception e) {
            throw new CalloutException('JWT Auth Error: ' + e.getMessage());
        }
    }

    private static String buildJWTToken() {
        String header       = '{"alg":"RS256","typ":"JWT"}';
        String encodedHeader = base64UrlEncode(Blob.valueOf(header));

        Long issuedAt  = DateTime.now().getTime() / 1000;
        Long expiresAt = issuedAt + 300;

        //JWT_Config__mdt config = getJWTConfig();

        Map<String, Object> claims = new Map<String, Object>{
            'iss' => '3MVG9ahGHqp.k2_yt2nTHU9QGHNnYtDnv.NQsU8_ftMpBYRpGLW4QkTMZw8sqhdTZuMeL0j65tQ==', //config.Consumer_Key__c,
            'sub' => '12337753@intel.com.crm.crmdevccp', //config.Username__c,
            'aud' => SF_LOGIN_URL,
            'exp' => expiresAt
        };

        String encodedPayload = base64UrlEncode(Blob.valueOf(JSON.serialize(claims)));
        String signingInput   = encodedHeader + '.' + encodedPayload;
		
		String cleanedKey   = cleanPrivateKey(PRIVATE_KEY);
        Blob privateKeyBlob   = EncodingUtil.base64Decode(cleanedKey);
		
        Blob signature        = Crypto.sign('RSA-SHA256', Blob.valueOf(signingInput), privateKeyBlob);
        String encodedSignature = base64UrlEncode(signature);

        return signingInput + '.' + encodedSignature;
    }

    private static AuthResponse exchangeJWTForAuthDetails(String jwtToken) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(SF_LOGIN_URL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(
            'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer' +
            '&assertion=' + jwtToken
        );
        req.setTimeout(60000);

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            AuthResponse auth   = new AuthResponse();
            auth.accessToken    = (String) responseMap.get('access_token');
            auth.instanceUrl    = (String) responseMap.get('instance_url'); // ✅ From response
            return auth;
        } else {
            throw new CalloutException('Token Exchange Failed: ' + res.getBody());
        }
    }

    // ================================================================
    // FILE UPLOAD METHODS
    // ================================================================

    @AuraEnabled
	public static Map<String, Object> uploadFile(
		String fileName,
		String base64Data,
		String title,
		String recordId
	) {
		Map<String, Object> result = new Map<String, Object>();

		try {
			// Step 1: Get Auth Details
			AuthResponse auth = getAuthDetails();
			System.debug('✅ Auth Success - Instance URL: ' + auth.instanceUrl);

			// Step 2: Decode Base64 to Blob
			Blob fileBlob    = EncodingUtil.base64Decode(base64Data);
			Integer fileSize = fileBlob.size();
			System.debug('✅ File Size: ' + fileSize + ' bytes');

			String contentVersionId;

			// Step 3: Upload based on file size
			if (fileSize <= CHUNK_SIZE) {
				System.debug('📤 Starting Direct Upload...');
				contentVersionId = uploadDirectly(
					auth.accessToken, auth.instanceUrl, fileName, fileBlob, title
				);
			} else {
				System.debug('📤 Starting Chunked Upload...');
				contentVersionId = uploadInChunks(
					auth.accessToken, auth.instanceUrl, fileName, fileBlob, title, fileSize
				);
			}

			System.debug('✅ ContentVersion ID: ' + contentVersionId);

			// ✅ Step 4: Always get ContentDocumentId
			String contentDocumentId = getContentDocumentId(
				auth.accessToken, auth.instanceUrl, contentVersionId
			);
			System.debug('✅ ContentDocument ID: ' + contentDocumentId);

			// ✅ Step 5: Link to Record if provided
			if (String.isNotBlank(recordId)) {
				System.debug('🔗 Linking file to Record: ' + recordId);
				linkFileToRecord(
					auth.accessToken, auth.instanceUrl, contentDocumentId, recordId
				);
				System.debug('✅ File linked to record successfully');
			}

			// ✅ Step 6: Return all IDs in response
			result.put('success',           true);
			result.put('contentVersionId',  contentVersionId);
			result.put('contentDocumentId', contentDocumentId);  // ✅ Always returned
			result.put('fileName',          fileName);
			result.put('fileSize',          fileSize);
			result.put('message',           'File uploaded successfully!');

		} catch (CalloutException ce) {
			System.debug('❌ Callout Exception: ' + ce.getMessage());
			result.put('success', false);
			result.put('message', ce.getMessage());
			throw new AuraHandledException(ce.getMessage());

		} catch (Exception e) {
			System.debug('❌ General Exception: ' + e.getMessage());
			System.debug('❌ Stack Trace: '       + e.getStackTraceString());
			result.put('success', false);
			result.put('message', e.getMessage());
			throw new AuraHandledException(e.getMessage());
		}

		return result;
	}

    private static String uploadDirectly(
        String accessToken,
        String instanceUrl,
        String fileName,
        Blob fileData,
        String title
    ) {
        String endpoint = instanceUrl + '/services/data/' + API_VERSION +
                          '/sobjects/ContentVersion';

        Map<String, Object> body = new Map<String, Object>{
            'Title'        => title,
            'PathOnClient' => fileName,
            'VersionData'  => EncodingUtil.base64Encode(fileData)
        };

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(body));
        req.setTimeout(120000);

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() == 201) {
            Map<String, Object> responseMap =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) responseMap.get('id');
        } else {
            throw new CalloutException('Direct Upload Failed: ' + res.getBody());
        }
    }

    private static String uploadInChunks(
        String accessToken,
        String instanceUrl,
        String fileName,
        Blob fileData,
        String title,
        Integer fileSize
    ) {
        String contentVersionId = null;
        Integer offset          = 0;
        Integer chunkNumber     = 0;

        String base64Data       = EncodingUtil.base64Encode(fileData);
        Integer base64Length    = base64Data.length();
        Integer base64ChunkSize = CHUNK_SIZE * 4 / 3;

        while (offset < base64Length) {
            Integer endIndex    = Math.min(offset + base64ChunkSize, base64Length);
            String chunkBase64  = base64Data.substring(offset, endIndex);
            Blob chunkBlob      = EncodingUtil.base64Decode(chunkBase64);

            if (chunkNumber == 0) {
                contentVersionId = createInitialChunk(
                    accessToken, instanceUrl, fileName, title, chunkBlob, fileSize
                );
            } else {
                appendChunk(
                    accessToken, instanceUrl, contentVersionId, chunkBlob, offset, fileSize
                );
            }

            offset += base64ChunkSize;
            chunkNumber++;
        }

        return contentVersionId;
    }

    private static String createInitialChunk(
        String accessToken,
        String instanceUrl,
        String fileName,
        String title,
        Blob chunkData,
        Integer totalSize
    ) {
        String endpoint = instanceUrl + '/services/data/' + API_VERSION +
                          '/sobjects/ContentVersion';

        Map<String, Object> body = new Map<String, Object>{
            'Title'          => title,
            'PathOnClient'   => fileName,
            'VersionData'    => EncodingUtil.base64Encode(chunkData),
            'IsMajorVersion' => false
        };

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Content-Range', '0-' + (chunkData.size() - 1) + '/' + totalSize);
        req.setBody(JSON.serialize(body));
        req.setTimeout(120000);

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() == 201) {
            Map<String, Object> responseMap =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) responseMap.get('id');
        } else {
            throw new CalloutException('Initial Chunk Failed: ' + res.getBody());
        }
    }

    private static void appendChunk(
        String accessToken,
        String instanceUrl,
        String contentVersionId,
        Blob chunkData,
        Integer offset,
        Integer totalSize
    ) {
        String endpoint = instanceUrl + '/services/data/' + API_VERSION +
                          '/sobjects/ContentVersion/' + contentVersionId;

        Map<String, Object> body = new Map<String, Object>{
            'VersionData' => EncodingUtil.base64Encode(chunkData)
        };

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('PATCH');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Content-Range',
            offset + '-' + (offset + chunkData.size() - 1) + '/' + totalSize
        );
        req.setBody(JSON.serialize(body));
        req.setTimeout(120000);

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() != 204) {
            throw new CalloutException('Chunk Append Failed: ' + res.getBody());
        }
    }

    // ================================================================
    // CONTENT DOCUMENT LINK METHODS
    // ================================================================

    private static String getContentDocumentId(
        String accessToken,
        String instanceUrl,
        String contentVersionId
    ) {
        String endpoint = instanceUrl + '/services/data/' + API_VERSION +
                          '/sobjects/ContentVersion/' + contentVersionId +
                          '?fields=ContentDocumentId';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setTimeout(60000);

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) responseMap.get('ContentDocumentId');
        } else {
            throw new CalloutException('Get ContentDocumentId Failed: ' + res.getBody());
        }
    }

    private static void linkFileToRecord(
        String accessToken,
        String instanceUrl,
        String contentDocumentId,
        String recordId
    ) {
        String endpoint = instanceUrl + '/services/data/' + API_VERSION +
                          '/sobjects/ContentDocumentLink';

        Map<String, Object> body = new Map<String, Object>{
            'ContentDocumentId' => contentDocumentId,
            'LinkedEntityId'    => recordId,
            'ShareType'         => 'V'
        };

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(body));
        req.setTimeout(60000);

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() != 201) {
            throw new CalloutException('Link File Failed: ' + res.getBody());
        }
    }

    // ================================================================
    // HELPER METHODS
    // ================================================================

    private static String base64UrlEncode(Blob input) {
        return EncodingUtil.base64Encode(input)
            .replace('+', '-')
            .replace('/', '_')
            .replace('=', '');
    }

    /*private static JWT_Config__mdt getJWTConfig() {
        return [
            SELECT Consumer_Key__c,
                   Username__c,
                   Private_Key__c
            FROM JWT_Config__mdt
            WHERE DeveloperName = 'Default'
            LIMIT 1
        ];
    }*/

	private static String cleanPrivateKey(String privateKey) {
		if (String.isBlank(privateKey)) {
			throw new CalloutException('Private Key is empty in JWT_Config__mdt');
		}

		String cleaned = privateKey;

		// ✅ Remove PEM Headers & Footers
		cleaned = cleaned.replace('-----BEGIN RSA PRIVATE KEY-----', '');
		cleaned = cleaned.replace('-----END RSA PRIVATE KEY-----', '');
		cleaned = cleaned.replace('-----BEGIN PRIVATE KEY-----', '');
		cleaned = cleaned.replace('-----END PRIVATE KEY-----', '');
		cleaned = cleaned.replace('-----BEGIN ENCRYPTED PRIVATE KEY-----', '');
		cleaned = cleaned.replace('-----END ENCRYPTED PRIVATE KEY-----', '');

		// ✅ Remove all whitespace, spaces, newlines, tabs
		cleaned = cleaned.replaceAll('[\\s\\r\\n\\t]', '');
		
		// ✅ Remove any remaining non-Base64 characters
		// Base64 valid chars: A-Z, a-z, 0-9, +, /, =
		cleaned = cleaned.replaceAll('[^A-Za-z0-9+/=]', '');

		cleaned = cleaned.trim();

		System.debug('✅ Cleaned Key Length: ' + cleaned.length());
		System.debug('✅ Cleaned Key Preview: ' + cleaned.substring(0, Math.min(30, cleaned.length())));

		// ✅ Validate cleaned key is not empty
		if (String.isBlank(cleaned)) {
			throw new CalloutException('Private Key is empty after cleaning. Check stored format.');
		}

		// ✅ Validate it is proper Base64
		try {
			Blob testDecode = EncodingUtil.base64Decode(cleaned);
			System.debug('✅ Key decoded successfully. Size: ' + testDecode.size() + ' bytes');
		} catch (Exception e) {
			throw new CalloutException(
				'Private Key is not valid Base64 after cleaning: ' + e.getMessage()
			);
		}

		return cleaned;
	}
}