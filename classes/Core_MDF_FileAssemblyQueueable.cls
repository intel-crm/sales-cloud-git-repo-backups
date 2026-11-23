/**
 * @description     Queueable Apex to assemble file chunks into final file
 * @author          Core MDF Team
 * @created         2026
 */
public class Core_MDF_FileAssemblyQueueable implements Queueable {

    // ── Properties ───────────────────────────────────────────────────────────
    private List<Id>    chunkVersionIds;
    private String      fileName;
    private String      recordId;
    private String      uploadId;
    private Integer     currentIndex;
    private String      assembledBase64;
    private Id          finalContentDocumentId;

    // ── Constants ────────────────────────────────────────────────────────────
    private static final String CHUNK_PREFIX     = 'CHUNK|';
    private static final String ASSEMBLED_PREFIX = 'ASSEMBLED|';
    private static final Integer MAX_CHUNKS_PER_JOB = 5; // Process 5 chunks per job

    /**
     * @description Constructor
     */
    public Core_MDF_FileAssemblyQueueable(
        List<Id> chunkVersionIds,
        String   fileName,
        String   recordId,
        String   uploadId
    ) {
        this.chunkVersionIds = chunkVersionIds;
        this.fileName        = fileName;
        this.recordId        = recordId;
        this.uploadId        = uploadId;
        this.currentIndex    = 0;
        this.assembledBase64 = '';
    }

    /**
     * @description Constructor for chained jobs (continuing assembly)
     */
    public Core_MDF_FileAssemblyQueueable(
        List<Id> chunkVersionIds,
        String   fileName,
        String   recordId,
        String   uploadId,
        Integer  currentIndex,
        String   assembledBase64
    ) {
        this.chunkVersionIds = chunkVersionIds;
        this.fileName        = fileName;
        this.recordId        = recordId;
        this.uploadId        = uploadId;
        this.currentIndex    = currentIndex;
        this.assembledBase64 = assembledBase64;
    }

    /**
     * @description Execute queueable job
     */
    public void execute(QueueableContext context) {
        try {
            // Calculate end index for this batch
            Integer endIndex = Math.min(
                this.currentIndex + MAX_CHUNKS_PER_JOB,
                this.chunkVersionIds.size()
            );

            // Process chunks for this batch
            List<Id> batchIds = new List<Id>();
            for (Integer i = this.currentIndex; i < endIndex; i++) {
                batchIds.add(this.chunkVersionIds[i]);
            }

            // Query chunk data
            List<ContentVersion> chunks = [
                SELECT Id, VersionData, Title
                FROM ContentVersion
                WHERE Id IN :batchIds
                ORDER BY Title ASC
            ];

            // Append chunk data to assembled base64
            for (ContentVersion chunk : chunks) {
                this.assembledBase64 += EncodingUtil.base64Encode(
                    chunk.VersionData
                );
            }

            // Check if more chunks remain
            if (endIndex < this.chunkVersionIds.size()) {
                // Chain next queueable job for remaining chunks
                System.enqueueJob(
                    new Core_MDF_FileAssemblyQueueable(
                        this.chunkVersionIds,
                        this.fileName,
                        this.recordId,
                        this.uploadId,
                        endIndex,
                        this.assembledBase64
                    )
                );
            } else {
                // All chunks processed - create final file
                this.createFinalFile(context.getJobId());
            }

        } catch (Exception e) {
            System.debug(
                LoggingLevel.ERROR,
                'Core_MDF_FileAssemblyQueueable.execute failed: ' 
                + e.getMessage() + '\n' + e.getStackTraceString()
            );
            // Store error status
            this.storeErrorStatus(e.getMessage());
        }
    }

    /**
     * @description Create final assembled ContentVersion
     */
    private void createFinalFile(Id jobId) {
        try {
            // Decode combined base64 to Blob
            Blob finalBlob = EncodingUtil.base64Decode(this.assembledBase64);

            // Create final ContentVersion
            ContentVersion finalCV  = new ContentVersion();
            finalCV.Title           = this.fileName;
            finalCV.PathOnClient    = this.fileName;
            finalCV.VersionData     = finalBlob;
            finalCV.IsMajorVersion  = true;
            finalCV.Description     = ASSEMBLED_PREFIX + this.uploadId 
                                    + '|' + jobId;
            insert finalCV;

            // Get ContentDocumentId
            finalCV = [
                SELECT Id, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :finalCV.Id
                LIMIT 1
            ];

            // Link to record if provided
            if (String.isNotBlank(this.recordId)) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId   = finalCV.ContentDocumentId;
                cdl.LinkedEntityId      = this.recordId;
                cdl.ShareType           = 'V';
                cdl.Visibility          = 'AllUsers';
                insert cdl;
            }

            // Cleanup temp chunk files
            this.cleanupChunks();

        } catch (Exception e) {
            System.debug(
                LoggingLevel.ERROR,
                'Core_MDF_FileAssemblyQueueable.createFinalFile failed: '
                + e.getMessage()
            );
            this.storeErrorStatus(e.getMessage());
        }
    }

    /**
     * @description Cleanup temporary chunk files
     */
    private void cleanupChunks() {
        try {
            List<ContentVersion> chunks = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id IN :this.chunkVersionIds
            ];

            Set<Id> docIds = new Set<Id>();
            for (ContentVersion cv : chunks) {
                docIds.add(cv.ContentDocumentId);
            }

            if (!docIds.isEmpty()) {
                delete [
                    SELECT Id 
                    FROM ContentDocument 
                    WHERE Id IN :docIds
                ];
            }
        } catch (Exception e) {
            System.debug(
                LoggingLevel.ERROR,
                'Cleanup failed: ' + e.getMessage()
            );
        }
    }

    /**
     * @description Store error status for polling
     */
    private void storeErrorStatus(String errorMessage) {
        // Log error - can be extended to store in custom object
        System.debug(
            LoggingLevel.ERROR,
            'Upload failed for uploadId: ' + this.uploadId 
            + ' Error: ' + errorMessage
        );
    }
}